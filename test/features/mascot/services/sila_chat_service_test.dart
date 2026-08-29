import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kinquest/features/mascot/models/sila_chat_message.dart';
import 'package:kinquest/features/mascot/services/sila_chat_service.dart';

void main() {
  test(
    'sendMessage uses the authenticated backend and parses the exchange',
    () async {
      late http.Request captured;
      final service = _service(
        MockClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode({
              'userMessage': {
                'id': 'user-1',
                'role': 'user',
                'content': 'Hello Sila',
                'pose': null,
                'createdAt': null,
              },
              'silaMessage': {
                'id': 'sila-1',
                'role': 'assistant',
                'content': 'Hello! What shall we do together?',
                'pose': 'welcome',
                'createdAt': null,
              },
            }),
            200,
          );
        }),
      );

      final exchange = await service.sendMessage(
        message: '  Hello Sila  ',
        languageCode: 'ar-AE',
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, '/api/sila/chat');
      expect(captured.headers['authorization'], 'Bearer test-token');
      expect(jsonDecode(captured.body), {
        'message': 'Hello Sila',
        'locale': 'ar',
      });
      expect(exchange.userMessage.role, SilaChatRole.user);
      expect(exchange.silaMessage.pose, SilaChatPose.welcome);
      expect(exchange.messages, hasLength(2));
    },
  );

  test('loadHistory and clearHistory use the same private endpoint', () async {
    final methods = <String>[];
    final service = _service(
      MockClient((request) async {
        methods.add(request.method);
        if (request.method == 'DELETE') {
          return http.Response(jsonEncode({'deleted': 2}), 200);
        }
        return http.Response(
          jsonEncode({
            'messages': [
              {
                'id': 'message-1',
                'role': 'assistant',
                'content': 'Welcome back!',
                'pose': 'encouraging',
                'createdAt': '2026-08-29T12:00:00.000Z',
              },
            ],
          }),
          200,
        );
      }),
    );

    final history = await service.loadHistory();
    final deleted = await service.clearHistory();

    expect(methods, ['GET', 'DELETE']);
    expect(history.single.content, 'Welcome back!');
    expect(deleted, 2);
  });

  test('invalid local messages never reach the network', () async {
    var requestCount = 0;
    final service = _service(
      MockClient((_) async {
        requestCount += 1;
        return http.Response('{}', 200);
      }),
    );

    await expectLater(
      service.sendMessage(message: '   ', languageCode: 'en'),
      throwsA(
        isA<SilaChatException>().having(
          (error) => error.failure,
          'failure',
          SilaChatFailure.invalidRequest,
        ),
      ),
    );
    await expectLater(
      service.sendMessage(
        message: 'x' * (SilaChatService.maximumMessageLength + 1),
        languageCode: 'en',
      ),
      throwsA(isA<SilaChatException>()),
    );

    expect(requestCount, 0);
  });

  test('maps authentication, family, quota, and server failures', () async {
    Future<SilaChatFailure> failureFor(int status, String message) async {
      final service = _service(
        MockClient(
          (_) async => http.Response(jsonEncode({'error': message}), status),
        ),
      );
      try {
        await service.loadHistory();
      } on SilaChatException catch (error) {
        return error.failure;
      }
      fail('Expected a SilaChatException');
    }

    expect(
      await failureFor(401, 'Sign in is required.'),
      SilaChatFailure.signInRequired,
    );
    expect(
      await failureFor(400, 'Join a family before chatting with Sila.'),
      SilaChatFailure.familyRequired,
    );
    expect(
      await failureFor(429, 'Too many requests.'),
      SilaChatFailure.rateLimited,
    );
    expect(await failureFor(503, 'Sila is busy.'), SilaChatFailure.unavailable);
  });

  test(
    'malformed success data becomes a stable invalidResponse failure',
    () async {
      final service = _service(
        MockClient((_) async => http.Response('<html>proxy error</html>', 200)),
      );

      await expectLater(
        service.loadHistory(),
        throwsA(
          isA<SilaChatException>().having(
            (error) => error.failure,
            'failure',
            SilaChatFailure.invalidResponse,
          ),
        ),
      );
    },
  );

  test('token refresh failures become a stable unavailable failure', () async {
    final service = SilaChatService(
      client: MockClient((_) async => http.Response('{}', 200)),
      endpointBuilder: (path) => Uri.parse('https://api.sila.test$path'),
      headersProvider: () async => throw StateError('private auth failure'),
    );

    await expectLater(
      service.loadHistory(),
      throwsA(
        isA<SilaChatException>().having(
          (error) => error.failure,
          'failure',
          SilaChatFailure.unavailable,
        ),
      ),
    );
  });
}

SilaChatService _service(http.Client client) {
  return SilaChatService(
    client: client,
    endpointBuilder: (path) => Uri.parse('https://api.sila.test$path'),
    headersProvider: () async => {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer test-token',
    },
  );
}
