enum SilaChatRole { user, assistant }

enum SilaChatPose { welcome, encouraging, thinking, celebrating, oops }

class SilaChatMessage {
  const SilaChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.pose,
    this.createdAt,
  });

  factory SilaChatMessage.user({
    required String id,
    required String content,
    DateTime? createdAt,
  }) {
    return SilaChatMessage(
      id: id,
      role: SilaChatRole.user,
      content: content,
      createdAt: createdAt,
    );
  }

  factory SilaChatMessage.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final content = json['content'];
    final roleValue = json['role'];

    if (id is! String || id.trim().isEmpty) {
      throw const FormatException('Sila chat message is missing an id.');
    }
    if (content is! String || content.trim().isEmpty) {
      throw const FormatException('Sila chat message is missing content.');
    }

    final role = switch (roleValue) {
      'user' => SilaChatRole.user,
      'assistant' => SilaChatRole.assistant,
      _ => throw const FormatException(
        'Sila chat message has an invalid role.',
      ),
    };
    final rawCreatedAt = json['createdAt'];
    final createdAt = rawCreatedAt is String && rawCreatedAt.isNotEmpty
        ? DateTime.tryParse(rawCreatedAt)?.toUtc()
        : null;

    return SilaChatMessage(
      id: id,
      role: role,
      content: content,
      pose: role == SilaChatRole.assistant
          ? SilaChatPoseWire.fromValue(json['pose'])
          : null,
      createdAt: createdAt,
    );
  }

  final String id;
  final SilaChatRole role;
  final String content;
  final SilaChatPose? pose;
  final DateTime? createdAt;

  String get text => content;
  bool get isFromSila => role == SilaChatRole.assistant;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'pose': pose?.wireValue,
      'createdAt': createdAt?.toUtc().toIso8601String(),
    };
  }
}

class SilaChatExchange {
  const SilaChatExchange({
    required this.userMessage,
    required this.silaMessage,
  });

  factory SilaChatExchange.fromJson(Map<String, dynamic> json) {
    final rawUserMessage = json['userMessage'];
    final rawSilaMessage = json['silaMessage'];

    if (rawUserMessage is! Map || rawSilaMessage is! Map) {
      throw const FormatException('Sila chat response is incomplete.');
    }

    final userMessage = SilaChatMessage.fromJson(
      Map<String, dynamic>.from(rawUserMessage),
    );
    final silaMessage = SilaChatMessage.fromJson(
      Map<String, dynamic>.from(rawSilaMessage),
    );

    if (userMessage.role != SilaChatRole.user || !silaMessage.isFromSila) {
      throw const FormatException('Sila chat response roles are invalid.');
    }

    return SilaChatExchange(userMessage: userMessage, silaMessage: silaMessage);
  }

  final SilaChatMessage userMessage;
  final SilaChatMessage silaMessage;

  List<SilaChatMessage> get messages => [userMessage, silaMessage];
}

extension SilaChatPoseWire on SilaChatPose {
  String get wireValue => name;

  static SilaChatPose fromValue(Object? value) {
    return switch (value) {
      'welcome' => SilaChatPose.welcome,
      'thinking' => SilaChatPose.thinking,
      'celebrating' => SilaChatPose.celebrating,
      'oops' => SilaChatPose.oops,
      _ => SilaChatPose.encouraging,
    };
  }
}
