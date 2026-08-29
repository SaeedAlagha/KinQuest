import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../models/sila_chat_message.dart';

typedef SilaChatEndpointBuilder = Uri Function(String path);
typedef SilaChatHeadersProvider = Future<Map<String, String>> Function();

enum SilaChatFailure {
  signInRequired,
  invalidRequest,
  familyRequired,
  forbidden,
  notFound,
  rateLimited,
  unavailable,
  invalidResponse,
  unknown,
}

class SilaChatException implements Exception {
  const SilaChatException(this.failure, {this.debugMessage});

  final SilaChatFailure failure;
  final String? debugMessage;

  @override
  String toString() => 'SilaChatException($failure)';
}

class SilaChatService {
  SilaChatService({
    http.Client? client,
    SilaChatEndpointBuilder? endpointBuilder,
    SilaChatHeadersProvider? headersProvider,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null,
       _endpointBuilder = endpointBuilder ?? ApiConfig.endpoint,
       _headersProvider = headersProvider ?? ApiConfig.authenticatedJsonHeaders;

  static const int maximumMessageLength = 800;

  final http.Client _client;
  final bool _ownsClient;
  final SilaChatEndpointBuilder _endpointBuilder;
  final SilaChatHeadersProvider _headersProvider;
  final Duration timeout;

  Future<List<SilaChatMessage>> loadHistory() async {
    final response = await _send(
      () async => _client.get(
        _endpointBuilder('/api/sila/chat'),
        headers: await _headersProvider(),
      ),
    );
    final data = _decodeObject(response);
    final rawMessages = data['messages'];

    if (rawMessages is! List) {
      throw const SilaChatException(SilaChatFailure.invalidResponse);
    }

    try {
      return rawMessages
          .map(
            (message) => SilaChatMessage.fromJson(
              Map<String, dynamic>.from(message as Map),
            ),
          )
          .toList(growable: false);
    } on Object catch (error) {
      throw SilaChatException(
        SilaChatFailure.invalidResponse,
        debugMessage: error.toString(),
      );
    }
  }

  Future<SilaChatExchange> sendMessage({
    required String message,
    required String languageCode,
  }) async {
    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty ||
        normalizedMessage.length > maximumMessageLength) {
      throw const SilaChatException(SilaChatFailure.invalidRequest);
    }

    final response = await _send(
      () async => _client.post(
        _endpointBuilder('/api/sila/chat'),
        headers: await _headersProvider(),
        body: jsonEncode({
          'message': normalizedMessage,
          'locale': _normalizedLocale(languageCode),
        }),
      ),
    );

    try {
      return SilaChatExchange.fromJson(_decodeObject(response));
    } on SilaChatException {
      rethrow;
    } on Object catch (error) {
      throw SilaChatException(
        SilaChatFailure.invalidResponse,
        debugMessage: error.toString(),
      );
    }
  }

  Future<int> clearHistory() async {
    final response = await _send(
      () async => _client.delete(
        _endpointBuilder('/api/sila/chat'),
        headers: await _headersProvider(),
      ),
    );
    final data = _decodeObject(response);
    final deleted = data['deleted'];

    if (deleted is! num || deleted < 0) {
      throw const SilaChatException(SilaChatFailure.invalidResponse);
    }
    return deleted.toInt();
  }

  void close() {
    if (_ownsClient) _client.close();
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }
      throw _exceptionFor(response);
    } on SilaChatException {
      rethrow;
    } on TimeoutException catch (error) {
      throw SilaChatException(
        SilaChatFailure.unavailable,
        debugMessage: error.toString(),
      );
    } on http.ClientException catch (error) {
      throw SilaChatException(
        SilaChatFailure.unavailable,
        debugMessage: error.toString(),
      );
    } on Object catch (error) {
      // Token refresh and platform networking failures should never leak a
      // provider exception through the presentation layer.
      throw SilaChatException(
        SilaChatFailure.unavailable,
        debugMessage: error.toString(),
      );
    }
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // Converted to a stable invalid-response failure below.
    }
    throw const SilaChatException(SilaChatFailure.invalidResponse);
  }

  SilaChatException _exceptionFor(http.Response response) {
    var message = '';
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['error'] is String) {
        message = data['error'] as String;
      }
    } on FormatException {
      // A proxy can return HTML; never expose it as a user-facing error.
    }

    final normalized = message.toLowerCase();
    final failure = switch (response.statusCode) {
      400 when normalized.contains('join a family') =>
        SilaChatFailure.familyRequired,
      400 => SilaChatFailure.invalidRequest,
      401 => SilaChatFailure.signInRequired,
      403 => SilaChatFailure.forbidden,
      404 => SilaChatFailure.notFound,
      429 => SilaChatFailure.rateLimited,
      >= 500 => SilaChatFailure.unavailable,
      _ => SilaChatFailure.unknown,
    };
    return SilaChatException(failure, debugMessage: message);
  }

  String _normalizedLocale(String languageCode) {
    return languageCode.trim().toLowerCase().startsWith('ar') ? 'ar' : 'en';
  }
}
