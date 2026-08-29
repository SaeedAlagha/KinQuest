import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

enum SilaMascotPose {
  idle('assets/mascot/sila_idle.png'),
  welcome('assets/mascot/sila_welcome.png'),
  thinking('assets/mascot/sila_thinking.png'),
  celebrating('assets/mascot/sila_celebrating.png'),
  oops('assets/mascot/sila_oops.png'),
  encouraging('assets/mascot/sila_encouraging.png'),
  winner('assets/mascot/sila_winner.png');

  const SilaMascotPose(this.assetPath);

  final String assetPath;
}

enum SilaMascotMotion { hover, gameReady, thinking, excited, celebrate }

class SilaMascotPalette {
  const SilaMascotPalette._();

  static const deepGreen = Color(0xFF087443);
  static const sandGold = Color(0xFFE4A719);
  static const coral = Color(0xFFF45D48);
  static const faceNavy = Color(0xFF07123D);
  static const pearl = Color(0xFFFFF5DF);
}

abstract final class SilaMascotAccessories {
  static const none = 'none';
  static const guardianCrown = 'guardian_crown';
  static const explorerCap = 'explorer_cap';
  static const starHalo = 'star_halo';
  static const familyLeafWreath = 'family_leaf_wreath';
  static const scholarCap = 'scholar_cap';

  static const supported = {
    guardianCrown,
    explorerCap,
    starHalo,
    familyLeafWreath,
    scholarCap,
  };
}

abstract final class SilaMascotOutfits {
  static const none = 'none';
  static const familyCape = 'family_cape';
  static const gameJersey = 'game_jersey';
  static const memoryKeeper = 'memory_keeper';
  static const spaceScout = 'space_scout';
  static const desertExplorer = 'desert_explorer';

  static const supported = {
    familyCape,
    gameJersey,
    memoryKeeper,
    spaceScout,
    desertExplorer,
  };
}

abstract final class SilaMascotAuras {
  static const none = 'none';
  static const familySparkles = 'family_sparkles';
  static const cosmicOrbit = 'cosmic_orbit';
  static const uaeRibbon = 'uae_ribbon';
  static const memoryHearts = 'memory_hearts';
  static const victoryBurst = 'victory_burst';

  static const supported = {
    familySparkles,
    cosmicOrbit,
    uaeRibbon,
    memoryHearts,
    victoryBurst,
  };
}

/// The fixed Sila character artwork. App themes may style the surrounding
/// surface, but never recolor or replace the mascot itself.
class SilaMascot extends StatefulWidget {
  const SilaMascot({
    super.key,
    this.pose = SilaMascotPose.idle,
    this.height = 128,
    this.animate = true,
    this.semanticLabel,
    this.accessoryAssetKey = SilaMascotAccessories.none,
    this.outfitAssetKey = SilaMascotOutfits.none,
    this.auraAssetKey = SilaMascotAuras.none,
    this.motion,
    this.loop = false,
    this.loopPause = Duration.zero,
  });

  final SilaMascotPose pose;
  final double height;
  final bool animate;
  final String? semanticLabel;
  final String accessoryAssetKey;
  final String outfitAssetKey;
  final String auraAssetKey;
  final SilaMascotMotion? motion;
  final bool loop;
  final Duration loopPause;

  @override
  State<SilaMascot> createState() => _SilaMascotState();
}

class _SilaMascotState extends State<SilaMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;
  Timer? _loopTimer;
  var _animationGeneration = 0;
  var _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progress = CurvedAnimation(parent: _controller, curve: Curves.linear);
    _syncAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant SilaMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate ||
        oldWidget.pose != widget.pose ||
        oldWidget.motion != widget.motion ||
        oldWidget.loop != widget.loop ||
        oldWidget.loopPause != widget.loopPause) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    _animationGeneration += 1;
    _loopTimer?.cancel();
    _loopTimer = null;
    _controller.stop();

    if (widget.animate && !_reduceMotion) {
      _controller.duration = _motionDuration;
      if (widget.loop) {
        if (widget.loopPause > Duration.zero) {
          _playLoopCycle(_animationGeneration);
        } else {
          _controller.repeat();
        }
      } else {
        _controller.forward(from: 0);
      }
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  void _playLoopCycle(int generation) {
    _controller.forward(from: 0).whenCompleteOrCancel(() {
      if (!mounted ||
          generation != _animationGeneration ||
          _reduceMotion ||
          !widget.animate ||
          !widget.loop) {
        return;
      }

      _loopTimer = Timer(widget.loopPause, () {
        if (!mounted || generation != _animationGeneration || _reduceMotion) {
          return;
        }
        _playLoopCycle(generation);
      });
    });
  }

  SilaMascotMotion get _effectiveMotion {
    if (widget.motion case final motion?) return motion;
    return switch (widget.pose) {
      SilaMascotPose.thinking => SilaMascotMotion.thinking,
      SilaMascotPose.celebrating ||
      SilaMascotPose.winner => SilaMascotMotion.celebrate,
      SilaMascotPose.welcome ||
      SilaMascotPose.encouraging => SilaMascotMotion.gameReady,
      SilaMascotPose.oops => SilaMascotMotion.excited,
      SilaMascotPose.idle => SilaMascotMotion.hover,
    };
  }

  Duration get _motionDuration => switch (_effectiveMotion) {
    SilaMascotMotion.hover => const Duration(milliseconds: 2600),
    SilaMascotMotion.gameReady => const Duration(milliseconds: 1800),
    SilaMascotMotion.thinking => const Duration(milliseconds: 2200),
    SilaMascotMotion.excited => const Duration(milliseconds: 1050),
    SilaMascotMotion.celebrate => const Duration(milliseconds: 1250),
  };

  @override
  void dispose() {
    _animationGeneration += 1;
    _loopTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transitionDuration = !widget.animate || _reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 260);
    final accessoryGeometry = _accessoryGeometryFor(widget.pose);
    final outfitGeometry = _outfitGeometryFor(widget.pose);
    final image = SizedBox(
      key: const ValueKey('sila-character-rig'),
      width: widget.height * 0.75,
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          _SilaAuraOverlay(assetKey: widget.auraAssetKey, animation: _progress),
          AnimatedSwitcher(
            duration: transitionDuration,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: Image.asset(
              widget.pose.assetPath,
              key: ValueKey('sila-pose-${widget.pose.name}'),
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
              excludeFromSemantics: widget.semanticLabel == null,
              semanticLabel: widget.semanticLabel,
            ),
          ),
          AnimatedSlide(
            key: const ValueKey('sila-animated-outfit-layer'),
            offset: outfitGeometry.offset,
            duration: transitionDuration,
            curve: Curves.easeOutBack,
            child: AnimatedScale(
              key: const ValueKey('sila-animated-outfit-scale'),
              scale: outfitGeometry.scale,
              alignment: const Alignment(0, 0.2),
              duration: transitionDuration,
              curve: Curves.easeOutBack,
              child: _SilaOutfitOverlay(assetKey: widget.outfitAssetKey),
            ),
          ),
          AnimatedSlide(
            key: const ValueKey('sila-animated-accessory-layer'),
            offset: accessoryGeometry.offset,
            duration: transitionDuration,
            curve: Curves.easeOutBack,
            child: AnimatedScale(
              key: const ValueKey('sila-animated-accessory-scale'),
              scale: accessoryGeometry.scale,
              alignment: const Alignment(0, -0.58),
              duration: transitionDuration,
              curve: Curves.easeOutBack,
              child: _SilaAccessoryOverlay(assetKey: widget.accessoryAssetKey),
            ),
          ),
        ],
      ),
    );

    if (!widget.animate || _reduceMotion) {
      return image;
    }

    return AnimatedBuilder(
      animation: _progress,
      child: image,
      builder: (context, child) {
        final phase = _progress.value * math.pi * 2;
        final (offset, angle, scale) = switch (_effectiveMotion) {
          SilaMascotMotion.hover => (
            Offset(0, -3.8 * math.sin(phase)),
            0.006 * math.sin(phase),
            1.0,
          ),
          SilaMascotMotion.gameReady => (
            Offset(0, -4.5 * math.sin(phase).abs()),
            0.012 * math.sin(phase),
            1 + 0.018 * math.sin(phase).abs(),
          ),
          SilaMascotMotion.thinking => (
            Offset(2.5 * math.sin(phase), -2 * math.cos(phase)),
            0.02 * math.sin(phase),
            1.0,
          ),
          SilaMascotMotion.excited => (
            Offset(0, -6 * math.sin(phase).abs()),
            0.026 * math.sin(phase * 2),
            1 + 0.025 * math.sin(phase).abs(),
          ),
          SilaMascotMotion.celebrate => (
            Offset(0, -8 * math.sin(phase).abs()),
            0.018 * math.sin(phase),
            1 + 0.04 * math.sin(phase).abs(),
          ),
        };
        return Transform.translate(
          key: const ValueKey('sila-character-motion-transform'),
          offset: offset,
          child: Transform.rotate(
            angle: angle,
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
    );
  }
}

/// Each pose uses the same 384 x 512 canvas, while Sila's head and torso move
/// within it. Cosmetics are painted in the idle coordinate space, then this
/// small rig correction follows the photographed character in every pose.
class _SilaLayerGeometry {
  const _SilaLayerGeometry({this.offset = Offset.zero, this.scale = 1});

  final Offset offset;
  final double scale;
}

_SilaLayerGeometry _accessoryGeometryFor(SilaMascotPose pose) => switch (pose) {
  SilaMascotPose.idle => const _SilaLayerGeometry(),
  SilaMascotPose.welcome => const _SilaLayerGeometry(
    offset: Offset(0.045, 0.018),
  ),
  SilaMascotPose.thinking => const _SilaLayerGeometry(
    offset: Offset(0.032, 0.035),
    scale: 1.02,
  ),
  SilaMascotPose.celebrating => const _SilaLayerGeometry(
    offset: Offset(-0.045, 0.026),
    scale: 0.92,
  ),
  SilaMascotPose.encouraging => const _SilaLayerGeometry(
    offset: Offset(0.02, -0.055),
    scale: 0.96,
  ),
  SilaMascotPose.oops => const _SilaLayerGeometry(
    offset: Offset(0.005, -0.075),
    scale: 0.97,
  ),
  SilaMascotPose.winner => const _SilaLayerGeometry(
    offset: Offset(-0.045, -0.058),
    scale: 0.94,
  ),
};

_SilaLayerGeometry _outfitGeometryFor(SilaMascotPose pose) => switch (pose) {
  SilaMascotPose.idle => const _SilaLayerGeometry(),
  SilaMascotPose.welcome => const _SilaLayerGeometry(
    offset: Offset(0.015, -0.002),
    scale: 0.98,
  ),
  SilaMascotPose.thinking => const _SilaLayerGeometry(
    offset: Offset(0.02, 0.01),
    scale: 0.96,
  ),
  SilaMascotPose.celebrating => const _SilaLayerGeometry(
    offset: Offset(-0.045, 0.025),
    scale: 0.88,
  ),
  SilaMascotPose.encouraging => const _SilaLayerGeometry(
    offset: Offset(0.015, -0.052),
    scale: 0.91,
  ),
  SilaMascotPose.oops => const _SilaLayerGeometry(
    offset: Offset(0.005, -0.07),
    scale: 0.9,
  ),
  SilaMascotPose.winner => const _SilaLayerGeometry(
    offset: Offset(-0.045, -0.052),
    scale: 0.9,
  ),
};

class _SilaAccessoryOverlay extends StatelessWidget {
  const _SilaAccessoryOverlay({required this.assetKey});

  final String assetKey;

  @override
  Widget build(BuildContext context) {
    if (!SilaMascotAccessories.supported.contains(assetKey)) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        key: ValueKey('sila-mascot-accessory-$assetKey'),
        painter: _SilaAccessoryPainter(assetKey),
      ),
    );
  }
}

class _SilaOutfitOverlay extends StatelessWidget {
  const _SilaOutfitOverlay({required this.assetKey});

  final String assetKey;

  @override
  Widget build(BuildContext context) {
    if (!SilaMascotOutfits.supported.contains(assetKey)) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        key: ValueKey('sila-mascot-outfit-$assetKey'),
        painter: _SilaOutfitPainter(assetKey),
      ),
    );
  }
}

class _SilaAuraOverlay extends StatelessWidget {
  const _SilaAuraOverlay({required this.assetKey, required this.animation});

  final String assetKey;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    if (!SilaMascotAuras.supported.contains(assetKey)) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) => CustomPaint(
          key: ValueKey('sila-mascot-aura-$assetKey'),
          painter: _SilaAuraPainter(assetKey, animation.value),
        ),
      ),
    );
  }
}

class _SilaOutfitPainter extends CustomPainter {
  const _SilaOutfitPainter(this.assetKey);

  final String assetKey;

  @override
  void paint(Canvas canvas, Size size) {
    switch (assetKey) {
      case SilaMascotOutfits.familyCape:
        _paintFamilyCape(canvas, size);
      case SilaMascotOutfits.gameJersey:
        _paintGameJersey(canvas, size);
      case SilaMascotOutfits.memoryKeeper:
        _paintMemoryKeeper(canvas, size);
      case SilaMascotOutfits.spaceScout:
        _paintSpaceScout(canvas, size);
      case SilaMascotOutfits.desertExplorer:
        _paintDesertExplorer(canvas, size);
    }
  }

  void _paintFamilyCape(Canvas canvas, Size size) {
    final collar = Path()
      ..moveTo(size.width * 0.28, size.height * 0.49)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.58,
        size.width * 0.72,
        size.height * 0.49,
      )
      ..lineTo(size.width * 0.66, size.height * 0.57)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.63,
        size.width * 0.34,
        size.height * 0.57,
      )
      ..close();
    canvas.drawShadow(collar, const Color(0x77002A1C), 3, false);
    canvas.drawPath(
      collar,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF07583E), Color(0xFF13A775)],
        ).createShader(collar.getBounds()),
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.565),
      size.width * 0.035,
      Paint()..color = SilaMascotPalette.sandGold,
    );
  }

  void _paintGameJersey(Canvas canvas, Size size) {
    // A torso jersey stays attached during raised-arm poses. The previous
    // detached sleeve patches were convincing only on the idle artwork.
    final jersey = Path()
      ..moveTo(size.width * 0.34, size.height * 0.52)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.57,
        size.width * 0.66,
        size.height * 0.52,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.68,
        size.width * 0.65,
        size.height * 0.79,
      )
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.86,
        size.width * 0.35,
        size.height * 0.79,
      )
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.68,
        size.width * 0.34,
        size.height * 0.52,
      )
      ..close();
    canvas.drawShadow(jersey, const Color(0x66002D5E), 4, false);
    canvas.drawPath(
      jersey,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B91E8), Color(0xFF0754A7), Color(0xFF06356E)],
        ).createShader(jersey.getBounds()),
    );
    canvas.drawPath(
      jersey,
      Paint()
        ..color = const Color(0xFF59E3E8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, size.width * 0.014),
    );

    final collar = Path()
      ..moveTo(size.width * 0.4, size.height * 0.535)
      ..lineTo(size.width * 0.5, size.height * 0.615)
      ..lineTo(size.width * 0.6, size.height * 0.535);
    canvas.drawPath(
      collar,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = math.max(2, size.width * 0.026),
    );

    final badgeCenter = Offset(size.width * 0.5, size.height * 0.7);
    canvas.drawCircle(
      badgeCenter,
      size.width * 0.075,
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    final linkPaint = Paint()
      ..color = const Color(0xFF0877C9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, size.width * 0.018);
    canvas.drawOval(
      Rect.fromCenter(
        center: badgeCenter.translate(-size.width * 0.027, 0),
        width: size.width * 0.07,
        height: size.width * 0.045,
      ),
      linkPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: badgeCenter.translate(size.width * 0.027, 0),
        width: size.width * 0.07,
        height: size.width * 0.045,
      ),
      linkPaint,
    );
  }

  void _paintMemoryKeeper(Canvas canvas, Size size) {
    final strap = Paint()
      ..color = const Color(0xFF8D5B2A)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(2, size.width * 0.035);
    canvas.drawLine(
      Offset(size.width * 0.36, size.height * 0.52),
      Offset(size.width * 0.62, size.height * 0.82),
      strap,
    );
    final pouch = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.63, size.height * 0.79),
        width: size.width * 0.2,
        height: size.height * 0.12,
      ),
      Radius.circular(size.width * 0.035),
    );
    canvas.drawShadow(
      Path()..addRRect(pouch),
      const Color(0x66000000),
      3,
      false,
    );
    canvas.drawRRect(pouch, Paint()..color = const Color(0xFFB57B3D));
    canvas.drawCircle(
      pouch.center,
      size.width * 0.035,
      Paint()..color = const Color(0xFF123B78),
    );
    canvas.drawCircle(
      pouch.center,
      size.width * 0.016,
      Paint()..color = const Color(0xFF59E3E8),
    );
  }

  void _paintSpaceScout(Canvas canvas, Size size) {
    // Keep the spacesuit on Sila's core instead of drawing independent
    // shoulder pads that remain behind when his arms wave or celebrate.
    final shell = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.67),
        width: size.width * 0.52,
        height: size.height * 0.3,
      ),
      Radius.circular(size.width * 0.13),
    );
    final shellPath = Path()..addRRect(shell);
    canvas.drawShadow(shellPath, const Color(0x77091851), 5, false);
    canvas.drawRRect(
      shell,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF182A73), Color(0xFF7257C9), Color(0xFF24C7C9)],
        ).createShader(shell.outerRect),
    );
    canvas.drawRRect(
      shell,
      Paint()
        ..color = const Color(0xFF60F0DF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, size.width * 0.016),
    );

    final controlPanel = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.68),
        width: size.width * 0.3,
        height: size.height * 0.14,
      ),
      Radius.circular(size.width * 0.045),
    );
    canvas.drawRRect(
      controlPanel,
      Paint()..color = const Color(0xFF101B58).withValues(alpha: 0.9),
    );
    canvas.drawCircle(
      controlPanel.center,
      size.width * 0.052,
      Paint()..color = const Color(0xFFFFE28A),
    );
    canvas.drawCircle(
      controlPanel.center,
      size.width * 0.027,
      Paint()..color = const Color(0xFF24C7C9),
    );
    for (final direction in [-1.0, 1.0]) {
      canvas.drawCircle(
        Offset(size.width * (0.5 + direction * 0.19), size.height * 0.61),
        size.width * 0.022,
        Paint()
          ..color = direction < 0
              ? SilaMascotPalette.coral
              : const Color(0xFF60F0DF),
      );
    }
  }

  void _paintDesertExplorer(Canvas canvas, Size size) {
    final scarf = Path()
      ..moveTo(size.width * 0.27, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.61,
        size.width * 0.73,
        size.height * 0.5,
      )
      ..lineTo(size.width * 0.67, size.height * 0.59)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.66,
        size.width * 0.33,
        size.height * 0.59,
      )
      ..close();
    canvas.drawShadow(scarf, const Color(0x66562812), 3, false);
    canvas.drawPath(
      scarf,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFC967), Color(0xFFE7773C), Color(0xFFFFE3A3)],
        ).createShader(scarf.getBounds()),
    );
    final stitch = Paint()
      ..color = const Color(0xFFFFF1CC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, size.width * 0.008);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.34, size.height * 0.565)
        ..quadraticBezierTo(
          size.width * 0.5,
          size.height * 0.62,
          size.width * 0.66,
          size.height * 0.565,
        ),
      stitch,
    );
  }

  @override
  bool shouldRepaint(covariant _SilaOutfitPainter oldDelegate) =>
      oldDelegate.assetKey != assetKey;
}

class _SilaAuraPainter extends CustomPainter {
  const _SilaAuraPainter(this.assetKey, this.progress);

  final String assetKey;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    switch (assetKey) {
      case SilaMascotAuras.familySparkles:
        _paintFamilySparkles(canvas, size);
      case SilaMascotAuras.cosmicOrbit:
        _paintCosmicOrbit(canvas, size);
      case SilaMascotAuras.uaeRibbon:
        _paintUaeRibbon(canvas, size);
      case SilaMascotAuras.memoryHearts:
        _paintMemoryHearts(canvas, size);
      case SilaMascotAuras.victoryBurst:
        _paintVictoryBurst(canvas, size);
    }
  }

  void _paintFamilySparkles(Canvas canvas, Size size) {
    const colors = [
      SilaMascotPalette.deepGreen,
      SilaMascotPalette.sandGold,
      SilaMascotPalette.coral,
    ];
    for (var index = 0; index < 9; index += 1) {
      final angle = progress * math.pi * 2 + index * math.pi * 2 / 9;
      final radiusX = size.width * 0.47;
      final radiusY = size.height * 0.39;
      final center = Offset(
        size.width * 0.5 + math.cos(angle) * radiusX,
        size.height * 0.52 + math.sin(angle) * radiusY,
      );
      final pulse = 0.65 + 0.35 * math.sin(angle * 2).abs();
      canvas.drawCircle(
        center,
        size.width * 0.022 * pulse,
        Paint()..color = colors[index % colors.length].withValues(alpha: 0.82),
      );
    }
  }

  void _paintCosmicOrbit(Canvas canvas, Size size) {
    final orbit = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.52),
      width: size.width * 1.02,
      height: size.height * 0.34,
    );
    canvas.save();
    canvas.translate(orbit.center.dx, orbit.center.dy);
    canvas.rotate(-0.28);
    canvas.translate(-orbit.center.dx, -orbit.center.dy);
    canvas.drawOval(
      orbit,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF59E3E8), Color(0xFFB778FF), Color(0xFFFFD77A)],
        ).createShader(orbit)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, size.width * 0.014),
    );
    final angle = progress * math.pi * 2;
    final point = Offset(
      orbit.center.dx + math.cos(angle) * orbit.width / 2,
      orbit.center.dy + math.sin(angle) * orbit.height / 2,
    );
    canvas.drawCircle(point, size.width * 0.032, Paint()..color = Colors.white);
    canvas.drawCircle(
      point,
      size.width * 0.022,
      Paint()..color = const Color(0xFF7B5CFA),
    );
    canvas.restore();
  }

  void _paintUaeRibbon(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.56),
      width: size.width * 1.03,
      height: size.height * 0.58,
    );
    const colors = [
      Color(0xFFF00000),
      Color(0xFF00732F),
      Color(0xFFFFFFFF),
      Color(0xFF101820),
    ];
    for (var index = 0; index < colors.length; index += 1) {
      canvas.drawArc(
        rect.deflate(index * size.width * 0.024),
        math.pi * (0.84 + progress * 0.05),
        math.pi * 0.72,
        false,
        Paint()
          ..color = colors[index].withValues(alpha: index == 2 ? 0.9 : 0.72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, size.width * 0.018)
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _paintMemoryHearts(Canvas canvas, Size size) {
    const colors = [
      Color(0xFFFF6D8B),
      Color(0xFFFFB05C),
      Color(0xFF65DFBE),
      Color(0xFFC5A8FF),
    ];
    for (var index = 0; index < 8; index += 1) {
      final angle = progress * math.pi * 2 + index * math.pi * 2 / 8;
      final center = Offset(
        size.width * 0.5 + math.cos(angle) * size.width * 0.48,
        size.height * 0.52 + math.sin(angle) * size.height * 0.4,
      );
      final scale = size.width * (0.027 + 0.009 * math.sin(angle).abs());
      final heart = Path()
        ..moveTo(center.dx, center.dy + scale)
        ..cubicTo(
          center.dx - scale * 2.1,
          center.dy - scale * 0.35,
          center.dx - scale,
          center.dy - scale * 1.65,
          center.dx,
          center.dy - scale * 0.55,
        )
        ..cubicTo(
          center.dx + scale,
          center.dy - scale * 1.65,
          center.dx + scale * 2.1,
          center.dy - scale * 0.35,
          center.dx,
          center.dy + scale,
        )
        ..close();
      canvas.drawPath(
        heart,
        Paint()..color = colors[index % colors.length].withValues(alpha: 0.85),
      );
    }
  }

  void _paintVictoryBurst(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.51);
    const colors = [Color(0xFFFFD15C), Color(0xFFFF715F), Color(0xFF54DFC1)];
    for (var index = 0; index < 18; index += 1) {
      final angle = index * math.pi * 2 / 18 + progress * 0.35;
      final pulse = 0.82 + 0.18 * math.sin(progress * math.pi * 2 + index);
      final start = Offset(
        center.dx + math.cos(angle) * size.width * 0.42 * pulse,
        center.dy + math.sin(angle) * size.height * 0.35 * pulse,
      );
      final end = Offset(
        center.dx + math.cos(angle) * size.width * 0.53 * pulse,
        center.dy + math.sin(angle) * size.height * 0.46 * pulse,
      );
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = colors[index % colors.length].withValues(alpha: 0.82)
          ..strokeWidth = math.max(1.5, size.width * 0.018)
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SilaAuraPainter oldDelegate) =>
      oldDelegate.assetKey != assetKey || oldDelegate.progress != progress;
}

class _SilaAccessoryPainter extends CustomPainter {
  const _SilaAccessoryPainter(this.assetKey);

  final String assetKey;

  @override
  void paint(Canvas canvas, Size size) {
    switch (assetKey) {
      case SilaMascotAccessories.guardianCrown:
        _paintCrown(canvas, size);
      case SilaMascotAccessories.explorerCap:
        _paintExplorerCap(canvas, size);
      case SilaMascotAccessories.starHalo:
        _paintStarHalo(canvas, size);
      case SilaMascotAccessories.familyLeafWreath:
        _paintFamilyLeafWreath(canvas, size);
      case SilaMascotAccessories.scholarCap:
        _paintScholarCap(canvas, size);
    }
  }

  void _paintCrown(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final baseY = size.height * 0.205;
    final halfWidth = size.width * 0.23;
    final crownHeight = size.height * 0.105;
    final crown = Path()
      ..moveTo(centerX - halfWidth, baseY)
      ..lineTo(centerX - halfWidth * 0.86, baseY - crownHeight * 0.92)
      ..lineTo(centerX - halfWidth * 0.3, baseY - crownHeight * 0.47)
      ..lineTo(centerX, baseY - crownHeight * 1.18)
      ..lineTo(centerX + halfWidth * 0.3, baseY - crownHeight * 0.47)
      ..lineTo(centerX + halfWidth * 0.86, baseY - crownHeight * 0.92)
      ..lineTo(centerX + halfWidth, baseY)
      ..close();
    final bounds = crown.getBounds();
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF0A6), Color(0xFFF0B62F), Color(0xFFB77612)],
      ).createShader(bounds)
      ..style = PaintingStyle.fill;
    canvas.drawShadow(crown, const Color(0xAA5B3900), 5, false);
    canvas.drawPath(crown, paint);
    canvas.drawPath(
      crown,
      Paint()
        ..color = const Color(0xFFFFF2B7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, size.width * 0.012),
    );

    for (final point in [
      Offset(centerX - halfWidth * 0.82, baseY - crownHeight * 0.88),
      Offset(centerX, baseY - crownHeight * 1.13),
      Offset(centerX + halfWidth * 0.82, baseY - crownHeight * 0.88),
    ]) {
      canvas.drawCircle(
        point,
        size.width * 0.026,
        Paint()..color = const Color(0xFFFF6B52),
      );
    }
  }

  void _paintExplorerCap(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final crown = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, size.height * 0.155),
        width: size.width * 0.43,
        height: size.height * 0.105,
      ),
      Radius.circular(size.width * 0.12),
    );
    final crownPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF16A56A), Color(0xFF006B49), Color(0xFF064C39)],
      ).createShader(crown.outerRect);
    canvas.drawShadow(
      Path()..addRRect(crown),
      const Color(0x9900271B),
      4,
      false,
    );
    canvas.drawRRect(crown, crownPaint);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + size.width * 0.13, size.height * 0.19),
        width: size.width * 0.34,
        height: size.height * 0.052,
      ),
      Paint()..color = const Color(0xFF074D39),
    );
    canvas.drawCircle(
      Offset(centerX - size.width * 0.07, size.height * 0.15),
      size.width * 0.035,
      Paint()..color = const Color(0xFFFFD77A),
    );
  }

  void _paintStarHalo(Canvas canvas, Size size) {
    final haloRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.255),
      width: size.width * 0.86,
      height: size.height * 0.29,
    );
    final haloPaint = Paint()
      ..color = const Color(0xFFFFD77A).withValues(alpha: 0.82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.3, size.width * 0.012);
    canvas.drawOval(haloRect, haloPaint);

    final sparklePaint = Paint()..color = const Color(0xFFFFE9A8);
    for (final angle in [-2.5, -1.35, -0.25, 0.7, 2.25]) {
      final point = Offset(
        haloRect.center.dx + math.cos(angle) * haloRect.width / 2,
        haloRect.center.dy + math.sin(angle) * haloRect.height / 2,
      );
      final radius = size.width * (angle == -1.35 ? 0.035 : 0.024);
      canvas.save();
      canvas.translate(point.dx, point.dy);
      canvas.rotate(math.pi / 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: radius * 1.2,
            height: radius * 2.6,
          ),
          Radius.circular(radius),
        ),
        sparklePaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: radius * 2.6,
            height: radius * 1.2,
          ),
          Radius.circular(radius),
        ),
        sparklePaint,
      );
      canvas.restore();
    }
  }

  void _paintFamilyLeafWreath(Canvas canvas, Size size) {
    final arc = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.23),
      width: size.width * 0.61,
      height: size.height * 0.2,
    );
    canvas.drawArc(
      arc,
      math.pi * 1.05,
      math.pi * 0.9,
      false,
      Paint()
        ..color = const Color(0xFFD7A83B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, size.width * 0.013),
    );
    const leafColors = [
      Color(0xFF087443),
      Color(0xFF54B967),
      Color(0xFFFFC955),
    ];
    for (var index = 0; index < 9; index += 1) {
      final angle = math.pi * (1.08 + index * 0.105);
      final point = Offset(
        arc.center.dx + math.cos(angle) * arc.width / 2,
        arc.center.dy + math.sin(angle) * arc.height / 2,
      );
      canvas.save();
      canvas.translate(point.dx, point.dy);
      canvas.rotate(angle + math.pi / 2);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: size.width * 0.05,
          height: size.height * 0.033,
        ),
        Paint()..color = leafColors[index % leafColors.length],
      );
      canvas.restore();
    }
  }

  void _paintScholarCap(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.145);
    final board = Path()
      ..moveTo(center.dx, center.dy - size.height * 0.055)
      ..lineTo(center.dx + size.width * 0.31, center.dy)
      ..lineTo(center.dx, center.dy + size.height * 0.055)
      ..lineTo(center.dx - size.width * 0.31, center.dy)
      ..close();
    canvas.drawShadow(board, const Color(0x77000000), 4, false);
    canvas.drawPath(
      board,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF75174B), Color(0xFFAF286A), Color(0xFF4B1235)],
        ).createShader(board.getBounds()),
    );
    canvas.drawCircle(
      center,
      size.width * 0.025,
      Paint()..color = Colors.white,
    );
    final tassel = Paint()
      ..color = const Color(0xFFFFD36A)
      ..strokeWidth = math.max(1.5, size.width * 0.014)
      ..strokeCap = StrokeCap.round;
    final end = Offset(size.width * 0.74, size.height * 0.245);
    canvas.drawLine(center, end, tassel);
    canvas.drawCircle(end, size.width * 0.026, tassel);
  }

  @override
  bool shouldRepaint(covariant _SilaAccessoryPainter oldDelegate) {
    return oldDelegate.assetKey != assetKey;
  }
}

class SilaMascotGuide extends StatelessWidget {
  const SilaMascotGuide({
    super.key,
    required this.message,
    required this.semanticLabel,
    this.title,
    this.pose = SilaMascotPose.welcome,
    this.compact = false,
    this.animate = true,
    this.loop = false,
    this.loopPause = Duration.zero,
    this.action,
    this.accessoryAssetKey = SilaMascotAccessories.none,
    this.outfitAssetKey = SilaMascotOutfits.none,
    this.auraAssetKey = SilaMascotAuras.none,
    this.motion,
  });

  final String message;
  final String semanticLabel;
  final String? title;
  final SilaMascotPose pose;
  final bool compact;
  final bool animate;
  final bool loop;
  final Duration loopPause;
  final Widget? action;
  final String accessoryAssetKey;
  final String outfitAssetKey;
  final String auraAssetKey;
  final SilaMascotMotion? motion;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 340;
        final mascot = SilaMascot(
          pose: pose,
          height: compact ? 118 : 164,
          animate: animate,
          loop: loop,
          loopPause: loopPause,
          semanticLabel: semanticLabel,
          accessoryAssetKey: accessoryAssetKey,
          outfitAssetKey: outfitAssetKey,
          auraAssetKey: auraAssetKey,
          motion: motion,
        );
        final bubble = _MascotSpeechBubble(
          title: title,
          message: message,
          action: action,
          showSidePointer: !stacked,
          compact: compact,
        );

        if (stacked) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              mascot,
              const SizedBox(height: 4),
              SizedBox(width: double.infinity, child: bubble),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            mascot,
            SizedBox(width: compact ? 8 : 12),
            Expanded(child: bubble),
          ],
        );
      },
    );
  }
}

class _MascotSpeechBubble extends StatelessWidget {
  const _MascotSpeechBubble({
    required this.message,
    required this.showSidePointer,
    required this.compact,
    this.title,
    this.action,
  });

  final String message;
  final bool showSidePointer;
  final bool compact;
  final String? title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surface = colorScheme.surface;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (showSidePointer)
          PositionedDirectional(
            start: -6,
            top: compact ? 24 : 32,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: surface,
                  border: Border(
                    left: BorderSide(color: colorScheme.outlineVariant),
                    bottom: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
              ),
            ),
          ),
        Container(
          padding: EdgeInsets.all(compact ? 14 : 18),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(compact ? 20 : 24),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title case final title?) ...[
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
              ],
              Text(
                message,
                style:
                    (compact
                            ? theme.textTheme.bodyMedium
                            : theme.textTheme.bodyLarge)
                        ?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
              ),
              if (action case final action?) ...[
                const SizedBox(height: 12),
                action,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class SilaSharedRootsMark extends StatelessWidget {
  const SilaSharedRootsMark({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: const CustomPaint(painter: _SharedRootsPainter()),
      ),
    );
  }
}

class _SharedRootsPainter extends CustomPainter {
  const _SharedRootsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide;
    final stroke = math.max(2.0, scale * 0.075);
    final greenPaint = Paint()
      ..color = SilaMascotPalette.deepGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final rootPath = Path()
      ..moveTo(scale * 0.17, scale * 0.78)
      ..quadraticBezierTo(
        scale * 0.5,
        scale * 0.92,
        scale * 0.83,
        scale * 0.78,
      );
    canvas.drawPath(rootPath, greenPaint);

    final stems = [
      (Offset(scale * 0.30, scale * 0.73), Offset(scale * 0.30, scale * 0.48)),
      (Offset(scale * 0.50, scale * 0.80), Offset(scale * 0.50, scale * 0.25)),
      (Offset(scale * 0.70, scale * 0.73), Offset(scale * 0.70, scale * 0.48)),
    ];
    for (final stem in stems) {
      canvas.drawLine(stem.$1, stem.$2, greenPaint);
    }

    final radius = scale * 0.105;
    canvas.drawCircle(
      stems[0].$2,
      radius,
      Paint()..color = SilaMascotPalette.sandGold,
    );
    canvas.drawCircle(
      stems[1].$2,
      radius,
      Paint()..color = SilaMascotPalette.deepGreen,
    );
    canvas.drawCircle(
      stems[2].$2,
      radius,
      Paint()..color = SilaMascotPalette.coral,
    );
  }

  @override
  bool shouldRepaint(covariant _SharedRootsPainter oldDelegate) => false;
}
