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
    this.onTap,
    this.semanticHint,
  }) : assert(height > 0 && height < double.infinity),
       assert(onTap == null || (semanticLabel != null && semanticLabel != ''));

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

  /// Makes Sila an optional interactive character instead of forcing every
  /// decorative use to behave like a button. Interactive instances replay
  /// their current motion when selected.
  final VoidCallback? onTap;

  /// Describes the result of selecting an interactive Sila to assistive tech.
  final String? semanticHint;

  @override
  State<SilaMascot> createState() => _SilaMascotState();
}

class _SilaMascotState extends State<SilaMascot> with TickerProviderStateMixin {
  static const _poseTransitionDuration = Duration(milliseconds: 240);

  late final AnimationController _motionController;
  late final Animation<double> _motionProgress;
  late final AnimationController _poseController;
  late SilaMascotPose _displayedPose;
  late SilaMascotPose _targetPose;
  Timer? _loopTimer;
  var _animationGeneration = 0;
  var _poseHasSwitched = true;
  var _reduceMotion = false;
  (int, int)? _precachedPoseDimensions;

  @override
  void initState() {
    super.initState();
    _displayedPose = widget.pose;
    _targetPose = widget.pose;
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _motionProgress = CurvedAnimation(
      parent: _motionController,
      curve: Curves.linear,
    );
    _poseController = AnimationController(
      vsync: this,
      duration: _poseTransitionDuration,
      value: 1,
    )..addListener(_handlePoseTransitionTick);
    _syncMotionAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precachePoseFrames();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (_reduceMotion) {
      _showPoseImmediately(widget.pose);
    }
    _syncMotionAnimation();
  }

  @override
  void didUpdateWidget(covariant SilaMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.height != widget.height) {
      _precachePoseFrames();
    }
    if (oldWidget.pose != widget.pose) {
      _transitionToPose(widget.pose);
    } else if (oldWidget.animate != widget.animate && !widget.animate) {
      _showPoseImmediately(widget.pose);
    }

    if (oldWidget.animate != widget.animate ||
        oldWidget.motion != widget.motion ||
        oldWidget.loop != widget.loop ||
        oldWidget.loopPause != widget.loopPause) {
      _syncMotionAnimation();
    }
  }

  (int, int) _poseCacheDimensions() {
    // Every pose asset is already a compact 384 x 512 sprite. Reusing one
    // native-size provider across cards, games, Studio, rotation, and layout
    // breakpoints gives Flutter a single shared cache entry per expression.
    // Height-specific providers caused a second decode when a responsive
    // layout rebuilt Sila at a new size, briefly leaving only his cosmetics.
    return (384, 512);
  }

  ImageProvider<Object> _poseImageProvider(
    SilaMascotPose pose,
    (int, int) dimensions,
  ) {
    return ResizeImage.resizeIfNeeded(
      dimensions.$1,
      dimensions.$2,
      AssetImage(pose.assetPath),
    );
  }

  void _precachePoseFrames() {
    final dimensions = _poseCacheDimensions();
    if (_precachedPoseDimensions == dimensions) return;
    _precachedPoseDimensions = dimensions;

    // Sila reacts frequently in games and chat. Decode every expression once
    // at its compact native resolution so the first reaction—and every later
    // responsive size—can reuse the same shared image-cache entries.
    for (final pose in SilaMascotPose.values) {
      unawaited(
        precacheImage(
          _poseImageProvider(pose, dimensions),
          context,
          onError: (_, _) {},
        ),
      );
    }
  }

  void _syncMotionAnimation() {
    _animationGeneration += 1;
    _loopTimer?.cancel();
    _loopTimer = null;
    _motionController.stop();

    if (widget.animate && !_reduceMotion) {
      _motionController.duration = _motionDuration;
      if (widget.loop) {
        if (widget.loopPause > Duration.zero) {
          _playLoopCycle(_animationGeneration);
        } else {
          _motionController.repeat();
        }
      } else {
        _motionController.forward(from: 0);
      }
    } else {
      _motionController
        ..stop()
        ..value = 0;
    }
  }

  void _playLoopCycle(int generation) {
    _motionController.forward(from: 0).whenCompleteOrCancel(() {
      if (!mounted ||
          generation != _animationGeneration ||
          _reduceMotion ||
          !widget.animate ||
          !widget.loop) {
        return;
      }

      final pause = widget.loopPause.isNegative
          ? Duration.zero
          : widget.loopPause;
      _loopTimer = Timer(pause, () {
        if (!mounted || generation != _animationGeneration || _reduceMotion) {
          return;
        }
        _playLoopCycle(generation);
      });
    });
  }

  void _transitionToPose(SilaMascotPose pose) {
    _targetPose = pose;
    if (!widget.animate || _reduceMotion) {
      _showPoseImmediately(pose);
      return;
    }

    // Fade the old rig fully out, swap the pose and all attachment geometry at
    // the invisible midpoint, then fade the new rig in. AnimatedSwitcher would
    // paint two full characters and one in-between cosmetic rig at once, which
    // made hats and outfits look doubled or detached during quick reactions.
    _poseHasSwitched = false;
    _poseController.forward(from: 0);
  }

  void _showPoseImmediately(SilaMascotPose pose) {
    _targetPose = pose;
    _displayedPose = pose;
    _poseHasSwitched = true;
    _poseController
      ..stop()
      ..value = 1;
  }

  void _handlePoseTransitionTick() {
    if (_poseHasSwitched || _poseController.value < 0.5) return;
    _poseHasSwitched = true;
    if (!mounted || _displayedPose == _targetPose) return;
    final defaultMotionChanges =
        widget.motion == null &&
        _motionForPose(_displayedPose) != _motionForPose(_targetPose);
    setState(() => _displayedPose = _targetPose);
    if (defaultMotionChanges) {
      _syncMotionAnimation();
    }
  }

  double get _poseOpacity {
    final progress = _poseController.value;
    if (progress < 0.5) {
      return 1 - Curves.easeInCubic.transform(progress * 2);
    }
    return Curves.easeOutCubic.transform((progress - 0.5) * 2);
  }

  void _handleTap() {
    widget.onTap?.call();
    if (mounted && widget.animate && !_reduceMotion) {
      _syncMotionAnimation();
    }
  }

  SilaMascotMotion get _effectiveMotion {
    if (widget.motion case final motion?) return motion;
    return _motionForPose(_displayedPose);
  }

  SilaMascotMotion _motionForPose(SilaMascotPose pose) {
    return switch (pose) {
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
    _poseController
      ..removeListener(_handlePoseTransitionTick)
      ..dispose();
    _motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accessoryGeometry = _accessoryGeometryFor(_displayedPose);
    final outfitGeometry = _outfitGeometryFor(_displayedPose);
    final cacheDimensions = _poseCacheDimensions();
    final rig = SizedBox(
      key: const ValueKey('sila-character-rig'),
      width: widget.height * 0.75,
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: _SilaAuraOverlay(
              assetKey: widget.auraAssetKey,
              animation: _motionProgress,
            ),
          ),
          RepaintBoundary(
            child: Image(
              image: _poseImageProvider(_displayedPose, cacheDimensions),
              key: ValueKey('sila-pose-${_displayedPose.name}'),
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              // Keep the already decoded pose visible while a new raster size
              // is prepared after rotation or a responsive layout change.
              // Pose changes still use different keys and the coordinated rig
              // dissolve below, so this cannot paint two Silas at once.
              gaplessPlayback: true,
              excludeFromSemantics: true,
            ),
          ),
          FractionalTranslation(
            key: const ValueKey('sila-animated-outfit-layer'),
            translation: outfitGeometry.offset,
            transformHitTests: false,
            child: Transform.rotate(
              angle: outfitGeometry.rotation,
              alignment: const Alignment(0, 0.2),
              transformHitTests: false,
              child: Transform.scale(
                key: const ValueKey('sila-animated-outfit-scale'),
                scale: outfitGeometry.scale,
                alignment: const Alignment(0, 0.2),
                transformHitTests: false,
                child: RepaintBoundary(
                  child: _SilaOutfitOverlay(assetKey: widget.outfitAssetKey),
                ),
              ),
            ),
          ),
          FractionalTranslation(
            key: const ValueKey('sila-animated-accessory-layer'),
            translation: accessoryGeometry.offset,
            transformHitTests: false,
            child: Transform.rotate(
              angle: accessoryGeometry.rotation,
              alignment: const Alignment(0, -0.58),
              transformHitTests: false,
              child: Transform.scale(
                key: const ValueKey('sila-animated-accessory-scale'),
                scale: accessoryGeometry.scale,
                alignment: const Alignment(0, -0.58),
                transformHitTests: false,
                child: RepaintBoundary(
                  child: _SilaAccessoryOverlay(
                    assetKey: widget.accessoryAssetKey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Widget result = rig;
    if (widget.animate && !_reduceMotion) {
      result = AnimatedBuilder(
        animation: _poseController,
        child: rig,
        builder: (context, child) => Opacity(
          key: const ValueKey('sila-pose-transition-opacity'),
          opacity: _poseOpacity,
          child: child,
        ),
      );

      result = AnimatedBuilder(
        animation: _motionProgress,
        child: result,
        builder: (context, child) {
          final phase = _motionProgress.value * math.pi * 2;
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
            transformHitTests: false,
            child: Transform.rotate(
              angle: angle,
              transformHitTests: false,
              child: Transform.scale(
                scale: scale,
                transformHitTests: false,
                child: child,
              ),
            ),
          );
        },
      );
    }

    result = RepaintBoundary(child: result);
    if (widget.semanticLabel case final label?) {
      result = Semantics(
        container: true,
        image: widget.onTap == null,
        button: widget.onTap != null,
        label: label,
        hint: widget.semanticHint,
        onTap: widget.onTap == null ? null : _handleTap,
        child: ExcludeSemantics(child: result),
      );
    }

    if (widget.onTap case final _?) {
      result = Material(
        type: MaterialType.transparency,
        child: InkResponse(
          containedInkWell: false,
          highlightShape: BoxShape.circle,
          radius: widget.height * 0.45,
          splashColor: SilaMascotPalette.deepGreen.withValues(alpha: 0.12),
          hoverColor: SilaMascotPalette.deepGreen.withValues(alpha: 0.06),
          focusColor: SilaMascotPalette.sandGold.withValues(alpha: 0.14),
          mouseCursor: SystemMouseCursors.click,
          excludeFromSemantics: true,
          onTap: _handleTap,
          child: result,
        ),
      );
    }

    return result;
  }
}

/// Each pose uses the same 384 x 512 canvas, while Sila's head and torso move
/// within it. Cosmetics are painted in the idle coordinate space, then this
/// small rig correction follows the character in every pose. Geometry swaps at
/// the invisible midpoint of a pose transition, so it never trails the artwork.
class _SilaLayerGeometry {
  const _SilaLayerGeometry({
    this.offset = Offset.zero,
    this.scale = 1,
    this.rotation = 0,
  });

  final Offset offset;
  final double scale;
  final double rotation;
}

_SilaLayerGeometry _accessoryGeometryFor(SilaMascotPose pose) => switch (pose) {
  SilaMascotPose.idle => const _SilaLayerGeometry(),
  SilaMascotPose.welcome => const _SilaLayerGeometry(scale: 0.99),
  SilaMascotPose.thinking => const _SilaLayerGeometry(
    offset: Offset(0.034, 0.02),
    scale: 0.99,
    rotation: 0.018,
  ),
  SilaMascotPose.celebrating => const _SilaLayerGeometry(
    offset: Offset(-0.018, 0.01),
    scale: 0.98,
  ),
  SilaMascotPose.encouraging => const _SilaLayerGeometry(scale: 1.01),
  SilaMascotPose.oops => const _SilaLayerGeometry(offset: Offset(0, -0.02)),
  SilaMascotPose.winner => const _SilaLayerGeometry(
    offset: Offset(-0.004, 0.004),
  ),
};

_SilaLayerGeometry _outfitGeometryFor(SilaMascotPose pose) => switch (pose) {
  SilaMascotPose.idle => const _SilaLayerGeometry(),
  SilaMascotPose.welcome => const _SilaLayerGeometry(
    offset: Offset(0.015, 0),
    scale: 0.98,
  ),
  SilaMascotPose.thinking => const _SilaLayerGeometry(
    offset: Offset(0.035, 0.016),
    scale: 0.94,
    rotation: 0.008,
  ),
  SilaMascotPose.celebrating => const _SilaLayerGeometry(
    offset: Offset(0.008, 0.008),
    scale: 0.88,
  ),
  SilaMascotPose.encouraging => const _SilaLayerGeometry(
    offset: Offset(0.018, -0.014),
    scale: 0.93,
  ),
  SilaMascotPose.oops => const _SilaLayerGeometry(
    offset: Offset(0.003, -0.018),
    scale: 0.9,
  ),
  SilaMascotPose.winner => const _SilaLayerGeometry(
    offset: Offset(-0.005, -0.012),
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
        isComplex: true,
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
        isComplex: true,
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
      child: CustomPaint(
        key: ValueKey('sila-mascot-aura-$assetKey'),
        painter: _SilaAuraPainter(assetKey, animation),
        isComplex: true,
        willChange: true,
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
  _SilaAuraPainter(this.assetKey, this.animation) : super(repaint: animation);

  final String assetKey;
  final Animation<double> animation;

  double get progress => animation.value;

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
      oldDelegate.assetKey != assetKey || oldDelegate.animation != animation;
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
    this.onMascotTap,
    this.mascotSemanticHint,
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
  final VoidCallback? onMascotTap;
  final String? mascotSemanticHint;

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
          onTap: onMascotTap,
          semanticHint: mascotSemanticHint,
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
