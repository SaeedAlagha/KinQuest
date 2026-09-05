import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/mascot/sila_mascot.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/voice/sila_voice_service.dart';
import '../../../l10n/app_localizations.dart';
import '../models/sila_chat_message.dart';
import '../services/sila_chat_service.dart';

class SilaChatPanel extends StatefulWidget {
  const SilaChatPanel({
    super.key,
    this.developerPreview = false,
    this.active = true,
    this.chatService,
    this.voiceService,
    this.onPoseChanged,
  });

  final bool developerPreview;
  final bool active;
  final SilaChatService? chatService;
  final SilaVoiceService? voiceService;
  final ValueChanged<SilaMascotPose>? onPoseChanged;

  @override
  State<SilaChatPanel> createState() => _SilaChatPanelState();
}

class _SilaChatPanelState extends State<SilaChatPanel> {
  static const _autoVoicePreferencePrefix = 'sila_chat_auto_voice';

  late final SilaChatService _chatService =
      widget.chatService ?? SilaChatService();
  late final SilaVoiceService _voiceService =
      widget.voiceService ?? SilaVoiceService();
  late final bool _ownsChatService = widget.chatService == null;
  late final bool _ownsVoiceService = widget.voiceService == null;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<SilaChatMessage> _messages = [];

  bool _previewInitialized = false;
  bool _loading = true;
  bool _sending = false;
  bool _clearing = false;
  bool _offlineMode = false;
  bool _loadFailed = false;
  Object? _loadError;
  bool _autoVoice = false;
  bool _voiceUnavailable = false;
  int _operationGeneration = 0;
  String? _speakingMessageId;
  String? _liveReplyId;
  String? _voiceLocale;

  bool get _voiceSupported => _voiceService.isSupported && !_voiceUnavailable;

  String get _autoVoicePreferenceKey {
    var scope = widget.developerPreview ? 'developer-preview' : 'signed-out';
    try {
      if (Firebase.apps.isNotEmpty) {
        scope = FirebaseAuth.instance.currentUser?.uid ?? scope;
      }
    } on FirebaseException {
      // Tests and early startup can legitimately have no Firebase app yet.
    }
    return '${_autoVoicePreferencePrefix}_$scope';
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadVoicePreference());
    if (!widget.developerPreview) unawaited(_loadHistory());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLocale = Localizations.localeOf(context).languageCode;
    if (_voiceLocale != null && _voiceLocale != currentLocale) {
      _voiceUnavailable = false;
    }
    _voiceLocale = currentLocale;

    if (!widget.developerPreview || _previewInitialized) return;

    _previewInitialized = true;
    _loading = false;
    _messages.add(
      SilaChatMessage(
        id: 'preview-welcome',
        role: SilaChatRole.assistant,
        content: AppLocalizations.of(context)!.silaChatPreviewReply,
        pose: SilaChatPose.welcome,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant SilaChatPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active && !widget.active) {
      FocusScope.of(context).unfocus();
      if (_speakingMessageId != null) unawaited(_stopVoice());
    }
  }

  Future<void> _loadVoicePreference() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _autoVoice =
            _voiceSupported &&
            (preferences.getBool(_autoVoicePreferenceKey) ?? false);
      });
    } on Object {
      // Voice remains opt-in when preferences are unavailable.
    }
  }

  Future<void> _setAutoVoice(bool enabled) async {
    if (!_voiceSupported) return;
    setState(() => _autoVoice = enabled);
    await _persistAutoVoice(enabled);
    if (!enabled) await _stopVoice();
  }

  Future<void> _persistAutoVoice(bool enabled) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_autoVoicePreferenceKey, enabled);
    } on Object {
      // The current-session preference still works if persistence is blocked.
    }
  }

  Future<void> _loadHistory() async {
    final generation = ++_operationGeneration;
    if (mounted) {
      setState(() {
        _loading = true;
        _loadFailed = false;
        _loadError = null;
      });
    }

    try {
      final history = await _chatService.loadHistory();
      if (!mounted || generation != _operationGeneration) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(history);
        _loading = false;
        _offlineMode = false;
      });
      _scrollToBottom();
    } on Object catch (error) {
      if (!mounted || generation != _operationGeneration) return;
      if (_canUseOfflineChat(error)) {
        setState(() {
          _loading = false;
          _offlineMode = true;
          _loadFailed = false;
          _loadError = null;
        });
        widget.onPoseChanged?.call(SilaMascotPose.encouraging);
        return;
      }
      setState(() {
        _loading = false;
        _loadFailed = true;
        _loadError = error;
      });
    }
  }

  Future<void> _send([String? suggestedMessage]) async {
    if (_sending || _loading || _clearing) return;
    final text = (suggestedMessage ?? _messageController.text).trim();
    if (text.isEmpty || text.length > SilaChatService.maximumMessageLength) {
      return;
    }

    final localMessage = SilaChatMessage.user(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      content: text,
      createdAt: DateTime.now().toUtc(),
    );
    final generation = ++_operationGeneration;
    _messageController.clear();
    setState(() {
      _sending = true;
      _loadFailed = false;
      _liveReplyId = null;
      _messages.add(localMessage);
    });
    widget.onPoseChanged?.call(SilaMascotPose.thinking);
    _scrollToBottom();

    try {
      late final SilaChatMessage reply;
      if (widget.developerPreview || _offlineMode) {
        await Future<void>.delayed(const Duration(milliseconds: 420));
        if (!mounted || generation != _operationGeneration) return;
        reply = SilaChatMessage(
          id:
              '${_offlineMode ? 'offline' : 'preview'}-'
              '${DateTime.now().microsecondsSinceEpoch}',
          role: SilaChatRole.assistant,
          content: _offlineMode
              ? _offlineReply(text)
              : AppLocalizations.of(context)!.silaChatPreviewReply,
          pose: SilaChatPose.encouraging,
          createdAt: DateTime.now().toUtc(),
        );
      } else {
        final exchange = await _chatService.sendMessage(
          message: text,
          languageCode: Localizations.localeOf(context).languageCode,
        );
        reply = exchange.silaMessage;
        if (!mounted || generation != _operationGeneration) return;
        setState(() {
          _messages.removeWhere((message) => message.id == localMessage.id);
          _messages.add(exchange.userMessage);
        });
      }

      if (!mounted || generation != _operationGeneration) return;
      setState(() {
        _messages.add(reply);
        _sending = false;
        _liveReplyId = reply.id;
      });
      widget.onPoseChanged?.call(_mascotPoseFor(reply.pose));
      _scrollToBottom();
      if (_autoVoice && widget.active) unawaited(_speak(reply));
    } on Object catch (error) {
      if (!mounted || generation != _operationGeneration) return;
      if (_canUseOfflineChat(error)) {
        final reply = SilaChatMessage(
          id: 'offline-${DateTime.now().microsecondsSinceEpoch}',
          role: SilaChatRole.assistant,
          content: _offlineReply(text),
          pose: SilaChatPose.encouraging,
          createdAt: DateTime.now().toUtc(),
        );
        setState(() {
          _offlineMode = true;
          _messages.add(reply);
          _sending = false;
          _liveReplyId = reply.id;
        });
        widget.onPoseChanged?.call(SilaMascotPose.encouraging);
        _scrollToBottom();
        if (_autoVoice && widget.active) unawaited(_speak(reply));
        return;
      }
      setState(() {
        _messages.removeWhere((message) => message.id == localMessage.id);
        _sending = false;
      });
      _messageController.text = text;
      widget.onPoseChanged?.call(SilaMascotPose.oops);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _localizedChatError(AppLocalizations.of(context)!, error),
          ),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.tryAgain,
            onPressed: _send,
          ),
        ),
      );
    }
  }

  bool _canUseOfflineChat(Object error) {
    if (error is! SilaChatException) return false;
    return switch (error.failure) {
      SilaChatFailure.unavailable ||
      SilaChatFailure.invalidResponse ||
      SilaChatFailure.unknown => true,
      SilaChatFailure.signInRequired ||
      SilaChatFailure.invalidRequest ||
      SilaChatFailure.familyRequired ||
      SilaChatFailure.forbidden ||
      SilaChatFailure.notFound ||
      SilaChatFailure.rateLimited => false,
    };
  }

  String _offlineReply(String message) {
    final strings = AppLocalizations.of(context)!;
    final normalized = message.toLowerCase();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final gameWords = isArabic
        ? const ['لعبة', 'لعب', 'نلعب', 'اختار']
        : const ['game', 'play', 'choose'];
    final bondWords = isArabic
        ? const ['عائل', 'تقارب', 'نتقارب', 'نتواصل', 'رابطة']
        : const ['family', 'bond', 'connect', 'together'];
    final challengeWords = isArabic
        ? const ['تحدي', 'ممتع', 'تشجيع', 'شجع']
        : const ['challenge', 'fun', 'cheer', 'encourage'];

    if (gameWords.any(normalized.contains)) {
      return strings.silaChatOfflineGameReply;
    }
    if (bondWords.any(normalized.contains)) {
      return strings.silaChatOfflineBondReply;
    }
    if (challengeWords.any(normalized.contains)) {
      return strings.silaChatOfflineCheerReply;
    }
    return strings.silaChatOfflineGeneralReply;
  }

  Future<void> _speak(SilaChatMessage message) async {
    if (!widget.active || !message.isFromSila || !_voiceSupported) return;
    if (_speakingMessageId == message.id) {
      await _stopVoice();
      return;
    }

    setState(() => _speakingMessageId = message.id);
    widget.onPoseChanged?.call(SilaMascotPose.welcome);
    final result = await _voiceService.speak(
      text: message.content,
      languageCode: Localizations.localeOf(context).languageCode,
    );
    if (!mounted || _speakingMessageId != message.id) return;

    if (result == SilaVoiceResult.unsupported ||
        result == SilaVoiceResult.failed) {
      setState(() {
        _speakingMessageId = null;
        _voiceUnavailable = true;
        _autoVoice = false;
      });
      unawaited(_persistAutoVoice(false));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.silaChatVoiceUnavailable),
        ),
      );
      widget.onPoseChanged?.call(_mascotPoseFor(message.pose));
      return;
    }

    setState(() => _speakingMessageId = null);
    widget.onPoseChanged?.call(_mascotPoseFor(message.pose));
  }

  Future<void> _stopVoice() async {
    await _voiceService.stop();
    if (!mounted) return;
    setState(() => _speakingMessageId = null);
  }

  Future<void> _confirmClear() async {
    if (_messages.isEmpty || _clearing || _sending || _loading) return;
    final strings = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.silaChatClearTitle),
        content: Text(strings.silaChatClearMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancel),
          ),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete_sweep_outlined),
            label: Text(strings.silaChatClear),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || _clearing || _sending || _loading) {
      return;
    }

    final generation = ++_operationGeneration;
    setState(() => _clearing = true);
    try {
      await _stopVoice();
      if (!widget.developerPreview && !_offlineMode) {
        await _chatService.clearHistory();
      }
      if (!mounted || generation != _operationGeneration) return;
      setState(() {
        _messages.clear();
        _clearing = false;
        _liveReplyId = null;
      });
      widget.onPoseChanged?.call(SilaMascotPose.encouraging);
    } on Object {
      if (!mounted || generation != _operationGeneration) return;
      setState(() => _clearing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.silaChatClearError)));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    if (_ownsChatService) _chatService.close();
    if (_ownsVoiceService) {
      _voiceService.dispose();
    } else {
      unawaited(_voiceService.stop());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Container(
      key: const ValueKey('sila-chat-panel'),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5EE1BD), Color(0xFFFFD36E), Color(0xFFFF8B72)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.15),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(27),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ChatHeader(
                autoVoice: _autoVoice,
                voiceSupported: _voiceSupported,
                clearing: _clearing,
                canClear:
                    _messages.isNotEmpty &&
                    !_sending &&
                    !_loading &&
                    !_clearing,
                onAutoVoiceChanged: _setAutoVoice,
                onClear: _confirmClear,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.52),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 19,
                      color: colors.onPrimaryContainer,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        strings.silaChatPrivacy,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onPrimaryContainer,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                height: 360,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: _buildConversation(strings),
              ),
              const SizedBox(height: 12),
              _ChatComposer(
                controller: _messageController,
                enabled: !_loading && !_sending && !_clearing,
                showProgress: _loading || _sending || _clearing,
                onSend: _send,
              ),
              if (widget.developerPreview) ...[
                const SizedBox(height: 8),
                Text(
                  strings.silaChatDeveloperPreview,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversation(AppLocalizations strings) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadFailed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 38),
              const SizedBox(height: 10),
              Text(
                _localizedChatError(strings, _loadError),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _loadHistory,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(strings.tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(14),
      children: [
        if (_offlineMode) const _OfflineChatNotice(),
        if (_messages.isEmpty) _ChatEmptyState(onStarterSelected: _send),
        for (final message in _messages)
          _ChatBubble(
            message: message,
            speaking: _speakingMessageId == message.id,
            voiceSupported: _voiceSupported,
            liveRegion: _liveReplyId == message.id,
            onSpeak: () => _speak(message),
          ),
        if (_sending) _ThinkingBubble(label: strings.silaChatResponding),
      ],
    );
  }
}

class _OfflineChatNotice extends StatelessWidget {
  const _OfflineChatNotice();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('sila-chat-offline-notice'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.offline_bolt_rounded, color: colors.onSecondaryContainer),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.silaChatOfflineNotice,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSecondaryContainer,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.autoVoice,
    required this.voiceSupported,
    required this.clearing,
    required this.canClear,
    required this.onAutoVoiceChanged,
    required this.onClear,
  });

  final bool autoVoice;
  final bool voiceSupported;
  final bool clearing;
  final bool canClear;
  final ValueChanged<bool> onAutoVoiceChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final identity = Row(
      children: [
        Container(
          width: 48,
          height: 48,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colors.primary, width: 2),
          ),
          child: Image.asset(
            'assets/mascot/sila_app_icon.png',
            fit: BoxFit.cover,
            cacheWidth: 160,
            cacheHeight: 160,
            excludeFromSemantics: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.silaChatTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(
                strings.silaChatDescription,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final voiceControl = Row(
          children: [
            Icon(
              autoVoice
                  ? Icons.record_voice_over_rounded
                  : Icons.volume_up_outlined,
              size: 20,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                strings.silaChatVoice,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            Switch.adaptive(
              value: autoVoice,
              onChanged: voiceSupported ? onAutoVoiceChanged : null,
            ),
          ],
        );
        final controls = Row(
          mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (compact)
              Expanded(
                child: Tooltip(
                  message: strings.silaChatVoiceDescription,
                  child: voiceControl,
                ),
              )
            else
              SizedBox(
                width: 270,
                child: Tooltip(
                  message: strings.silaChatVoiceDescription,
                  child: voiceControl,
                ),
              ),
            IconButton(
              tooltip: strings.silaChatClear,
              onPressed: canClear && !clearing ? onClear : null,
              icon: clearing
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_sweep_outlined),
            ),
          ],
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [identity, const SizedBox(height: 8), controls],
          );
        }
        return Row(
          children: [
            Expanded(child: identity),
            const SizedBox(width: 12),
            controls,
          ],
        );
      },
    );
  }
}

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState({required this.onStarterSelected});

  final ValueChanged<String> onStarterSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final starters = [
      strings.silaChatStarterGame,
      strings.silaChatStarterBond,
      strings.silaChatStarterCheer,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: Column(
        children: [
          Text(
            strings.silaChatEmptyTitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(strings.silaChatEmptyDescription, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final starter in starters)
                ActionChip(
                  avatar: const Icon(Icons.auto_awesome_rounded, size: 17),
                  label: Text(starter),
                  onPressed: () => onStarterSelected(starter),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.speaking,
    required this.voiceSupported,
    required this.liveRegion,
    required this.onSpeak,
  });

  final SilaChatMessage message;
  final bool speaking;
  final bool voiceSupported;
  final bool liveRegion;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final fromSila = message.isFromSila;

    final bubble = Align(
      alignment: fromSila
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (fromSila) ...[
              CircleAvatar(
                radius: 16,
                backgroundImage: ResizeImage(
                  const AssetImage('assets/mascot/sila_app_icon.png'),
                  width: 96,
                  height: 96,
                ),
                backgroundColor: colors.primaryContainer,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 560),
                padding: EdgeInsetsDirectional.fromSTEB(
                  14,
                  11,
                  fromSila && voiceSupported ? 7 : 14,
                  11,
                ),
                decoration: BoxDecoration(
                  gradient: fromSila
                      ? LinearGradient(
                          colors: [
                            colors.primaryContainer,
                            colors.tertiaryContainer.withValues(alpha: 0.74),
                          ],
                        )
                      : AppTheme.heroGradientFor(context),
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: const Radius.circular(18),
                    topEnd: const Radius.circular(18),
                    bottomStart: Radius.circular(fromSila ? 5 : 18),
                    bottomEnd: Radius.circular(fromSila ? 18 : 5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        message.content,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: fromSila
                              ? colors.onPrimaryContainer
                              : Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (fromSila && voiceSupported) ...[
                      const SizedBox(width: 5),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: speaking
                            ? strings.silaChatStopVoice
                            : strings.silaChatListen,
                        onPressed: onSpeak,
                        icon: Icon(
                          speaking
                              ? Icons.stop_circle_rounded
                              : Icons.volume_up_rounded,
                          size: 20,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!liveRegion) return bubble;
    return Semantics(
      container: true,
      liveRegion: true,
      label: message.content,
      child: ExcludeSemantics(child: bubble),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      liveRegion: true,
      label: label,
      child: ExcludeSemantics(
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            key: const ValueKey('sila-chat-thinking'),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 9),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatComposer extends StatelessWidget {
  const _ChatComposer({
    required this.controller,
    required this.enabled,
    required this.showProgress,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool showProgress;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            key: const ValueKey('sila-chat-input'),
            controller: controller,
            enabled: enabled,
            minLines: 1,
            maxLines: 4,
            maxLength: SilaChatService.maximumMessageLength,
            buildCounter:
                (_, {required currentLength, required isFocused, maxLength}) =>
                    isFocused && currentLength > 650
                    ? Text('$currentLength/$maxLength')
                    : null,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: strings.silaChatMessageHint,
              prefixIcon: const Icon(Icons.chat_bubble_outline_rounded),
              filled: true,
            ),
          ),
        ),
        const SizedBox(width: 9),
        IconButton.filled(
          key: const ValueKey('sila-chat-send'),
          tooltip: strings.silaChatSend,
          onPressed: enabled ? onSend : null,
          icon: showProgress
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_rounded),
        ),
      ],
    );
  }
}

SilaMascotPose _mascotPoseFor(SilaChatPose? pose) {
  return switch (pose) {
    SilaChatPose.welcome => SilaMascotPose.welcome,
    SilaChatPose.thinking => SilaMascotPose.thinking,
    SilaChatPose.celebrating => SilaMascotPose.celebrating,
    SilaChatPose.oops => SilaMascotPose.oops,
    SilaChatPose.encouraging || null => SilaMascotPose.encouraging,
  };
}

String _localizedChatError(AppLocalizations strings, Object? error) {
  if (error is! SilaChatException) return strings.silaChatError;
  return switch (error.failure) {
    SilaChatFailure.signInRequired => strings.silaChatSignInRequired,
    SilaChatFailure.familyRequired ||
    SilaChatFailure.forbidden ||
    SilaChatFailure.notFound => strings.silaChatFamilyRequired,
    SilaChatFailure.rateLimited => strings.silaChatRateLimited,
    SilaChatFailure.invalidRequest ||
    SilaChatFailure.unavailable ||
    SilaChatFailure.invalidResponse ||
    SilaChatFailure.unknown => strings.silaChatError,
  };
}
