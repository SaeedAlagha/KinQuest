import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
class GameExitGuard extends StatefulWidget {
  const GameExitGuard({
    super.key,
    required this.gameInProgress,
    required this.child,
  });

  final bool gameInProgress;
  final Widget child;

  @override
  State<GameExitGuard> createState() => _GameExitGuardState();
}

class _GameExitGuardState extends State<GameExitGuard> {
  bool _allowPop = false;
  bool _dialogOpen = false;

Future<void> _handleBackAttempt() async {
    final strings = AppLocalizations.of(context)!;

    if (_dialogOpen) return;

    _dialogOpen = true;

    final shouldLeave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.sports_esports_rounded),
title: Text(strings.leaveGameTitle),          content: Text(strings.leaveGameMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
child: Text(strings.keepPlaying),            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
child: Text(strings.leaveGame),            ),
          ],
        );
      },
    );

    _dialogOpen = false;

    if (shouldLeave != true || !mounted) {
      return;
    }

    setState(() {
      _allowPop = true;
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.gameInProgress || _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !widget.gameInProgress || _allowPop) {
          return;
        }

        _handleBackAttempt();
      },
      child: widget.child,
    );
  }
}
