import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/mascot/models/sila_chat_message.dart';

void main() {
  test('parses a Sila message with its pose and timestamp', () {
    final message = SilaChatMessage.fromJson({
      'id': 'message-1',
      'role': 'assistant',
      'content': 'Let us play charades!',
      'pose': 'celebrating',
      'createdAt': '2026-08-29T10:30:00.000Z',
    });

    expect(message.id, 'message-1');
    expect(message.role, SilaChatRole.assistant);
    expect(message.text, 'Let us play charades!');
    expect(message.pose, SilaChatPose.celebrating);
    expect(message.createdAt, DateTime.utc(2026, 8, 29, 10, 30));
    expect(message.isFromSila, isTrue);
  });

  test('uses the encouraging pose for an unknown assistant pose', () {
    final message = SilaChatMessage.fromJson({
      'id': 'message-2',
      'role': 'assistant',
      'content': 'I am here to help.',
      'pose': 'not-a-real-pose',
      'createdAt': null,
    });

    expect(message.pose, SilaChatPose.encouraging);
    expect(message.createdAt, isNull);
  });

  test('exchange validates user and assistant roles', () {
    expect(
      () => SilaChatExchange.fromJson({
        'userMessage': {
          'id': 'wrong-role',
          'role': 'assistant',
          'content': 'Hello',
        },
        'silaMessage': {'id': 'sila', 'role': 'assistant', 'content': 'Hi!'},
      }),
      throwsFormatException,
    );
  });

  test('rejects incomplete messages instead of accepting unsafe data', () {
    expect(
      () => SilaChatMessage.fromJson({
        'id': '',
        'role': 'user',
        'content': 'Hello',
      }),
      throwsFormatException,
    );
    expect(
      () => SilaChatMessage.fromJson({
        'id': 'message',
        'role': 'unknown',
        'content': 'Hello',
      }),
      throwsFormatException,
    );
  });
}
