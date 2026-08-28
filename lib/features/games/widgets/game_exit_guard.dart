import 'package:flutter/material.dart';

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
    if (_dialogOpen) return;

    _dialogOpen = true;

    final shouldLeave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.sports_esports_rounded),
          title: const Text('Leave game?'),
          content: const Text(
            'Your current match will be lost if you leave now.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep Playing'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Leave Game'),
            ),
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
