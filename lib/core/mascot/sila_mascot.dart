import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

part 'sila_cosmetic_painters.dart';

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
    final accessoryGeometry = _accessoryGeometryFor(
      widget.accessoryAssetKey,
      _displayedPose,
    );
    final outfitGeometry = _outfitGeometryFor(
      widget.outfitAssetKey,
      _displayedPose,
    );
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
            key: const ValueKey('sila-aura-back-layer'),
            child: _SilaAuraOverlay(
              assetKey: widget.auraAssetKey,
              animation: _motionProgress,
              layer: _SilaCosmeticLayer.back,
              willAnimate: widget.animate && !_reduceMotion,
            ),
          ),
          FractionalTranslation(
            key: const ValueKey('sila-outfit-back-layer'),
            translation: outfitGeometry.offset,
            transformHitTests: false,
            child: Transform.rotate(
              angle: outfitGeometry.rotation,
              alignment: const Alignment(0, 0.2),
              transformHitTests: false,
              child: Transform.scale(
                scale: outfitGeometry.scale,
                alignment: const Alignment(0, 0.2),
                transformHitTests: false,
                child: RepaintBoundary(
                  child: _SilaOutfitOverlay(
                    assetKey: widget.outfitAssetKey,
                    layer: _SilaCosmeticLayer.back,
                    pose: _displayedPose,
                  ),
                ),
              ),
            ),
          ),
          FractionalTranslation(
            key: const ValueKey('sila-accessory-back-layer'),
            translation: accessoryGeometry.offset,
            transformHitTests: false,
            child: Transform.rotate(
              angle: accessoryGeometry.rotation,
              alignment: const Alignment(0, -0.64),
              transformHitTests: false,
              child: Transform.scale(
                scale: accessoryGeometry.scale,
                alignment: const Alignment(0, -0.64),
                transformHitTests: false,
                child: RepaintBoundary(
                  child: _SilaAccessoryOverlay(
                    assetKey: widget.accessoryAssetKey,
                    animation: _motionProgress,
                    layer: _SilaCosmeticLayer.back,
                  ),
                ),
              ),
            ),
          ),
          RepaintBoundary(
            key: const ValueKey('sila-pose-artwork-layer'),
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
                  child: _SilaOutfitOverlay(
                    assetKey: widget.outfitAssetKey,
                    layer: _SilaCosmeticLayer.front,
                    pose: _displayedPose,
                  ),
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
              alignment: const Alignment(0, -0.64),
              transformHitTests: false,
              child: Transform.scale(
                key: const ValueKey('sila-animated-accessory-scale'),
                scale: accessoryGeometry.scale,
                alignment: const Alignment(0, -0.64),
                transformHitTests: false,
                child: RepaintBoundary(
                  child: _SilaAccessoryOverlay(
                    assetKey: widget.accessoryAssetKey,
                    animation: _motionProgress,
                    layer: _SilaCosmeticLayer.front,
                  ),
                ),
              ),
            ),
          ),
          RepaintBoundary(
            key: const ValueKey('sila-aura-front-layer'),
            child: _SilaAuraOverlay(
              assetKey: widget.auraAssetKey,
              animation: _motionProgress,
              layer: _SilaCosmeticLayer.front,
              willAnimate: widget.animate && !_reduceMotion,
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

_SilaLayerGeometry _accessoryGeometryFor(String assetKey, SilaMascotPose pose) {
  final headGeometry = switch (pose) {
    SilaMascotPose.idle => const _SilaLayerGeometry(offset: Offset(0.033, 0)),
    SilaMascotPose.welcome => const _SilaLayerGeometry(
      offset: Offset(0.043, -0.006),
      rotation: 0.04,
    ),
    SilaMascotPose.thinking => const _SilaLayerGeometry(
      offset: Offset(0.013, 0.01),
      scale: 0.94,
      rotation: 0.08,
    ),
    SilaMascotPose.celebrating => const _SilaLayerGeometry(
      offset: Offset(-0.052, 0.021),
      scale: 0.96,
      rotation: 0.025,
    ),
    SilaMascotPose.oops => const _SilaLayerGeometry(
      offset: Offset(0.02, -0.088),
      scale: 0.96,
    ),
    SilaMascotPose.encouraging => const _SilaLayerGeometry(
      offset: Offset(0.028, -0.068),
      scale: 0.94,
      rotation: 0.02,
    ),
    SilaMascotPose.winner => const _SilaLayerGeometry(
      offset: Offset(-0.019, -0.066),
      scale: 0.95,
      rotation: -0.01,
    ),
  };

  // A halo remains level while tracking Sila's head; worn pieces inherit the
  // subtle head angle so their contact edge stays planted on the shell.
  if (assetKey == SilaMascotAccessories.starHalo) {
    return _SilaLayerGeometry(
      // High-head poses move the worn pieces up by almost nine percent of the
      // sprite. A floating halo needs less of that correction so its glints
      // and glow remain inside clipped profile/game surfaces.
      offset: Offset(
        headGeometry.offset.dx,
        math.max(headGeometry.offset.dy, -0.045),
      ),
      scale: headGeometry.scale,
    );
  }
  return headGeometry;
}

_SilaLayerGeometry _outfitGeometryFor(String assetKey, SilaMascotPose pose) {
  final bodyGeometry = switch (pose) {
    SilaMascotPose.idle => const _SilaLayerGeometry(
      offset: Offset(0.039, 0.012),
    ),
    SilaMascotPose.welcome => const _SilaLayerGeometry(
      offset: Offset(-0.018, 0.013),
    ),
    SilaMascotPose.thinking => const _SilaLayerGeometry(
      offset: Offset(-0.046, 0.025),
      scale: 0.95,
    ),
    SilaMascotPose.celebrating => const _SilaLayerGeometry(
      offset: Offset(-0.069, 0.037),
      scale: 0.97,
    ),
    SilaMascotPose.encouraging => const _SilaLayerGeometry(
      offset: Offset(0.003, -0.069),
      scale: 0.95,
    ),
    SilaMascotPose.oops => const _SilaLayerGeometry(
      offset: Offset(0.009, -0.083),
      scale: 0.96,
    ),
    SilaMascotPose.winner => const _SilaLayerGeometry(
      offset: Offset(-0.018, -0.067),
      scale: 0.95,
    ),
  };
  final slotOffset = switch (assetKey) {
    SilaMascotOutfits.familyCape => const Offset(0, -0.004),
    SilaMascotOutfits.memoryKeeper => const Offset(0.006, 0.004),
    SilaMascotOutfits.desertExplorer => const Offset(0, -0.004),
    SilaMascotOutfits.spaceScout => const Offset(0, 0.002),
    _ => Offset.zero,
  };
  return _SilaLayerGeometry(
    offset: bodyGeometry.offset + slotOffset,
    scale: bodyGeometry.scale,
    rotation: bodyGeometry.rotation,
  );
}

enum _SilaCosmeticLayer { back, front }

class _SilaAccessoryOverlay extends StatelessWidget {
  const _SilaAccessoryOverlay({
    required this.assetKey,
    required this.animation,
    required this.layer,
  });

  final String assetKey;
  final Animation<double> animation;
  final _SilaCosmeticLayer layer;

  @override
  Widget build(BuildContext context) {
    if (!SilaMascotAccessories.supported.contains(assetKey)) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        key: ValueKey(
          layer == _SilaCosmeticLayer.front
              ? 'sila-mascot-accessory-$assetKey'
              : 'sila-mascot-accessory-back-$assetKey',
        ),
        painter: _SilaAccessoryPainter(assetKey, animation, layer),
        isComplex: true,
      ),
    );
  }
}

class _SilaOutfitOverlay extends StatelessWidget {
  const _SilaOutfitOverlay({
    required this.assetKey,
    required this.layer,
    required this.pose,
  });

  final String assetKey;
  final _SilaCosmeticLayer layer;
  final SilaMascotPose pose;

  @override
  Widget build(BuildContext context) {
    if (!SilaMascotOutfits.supported.contains(assetKey)) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        key: ValueKey(
          layer == _SilaCosmeticLayer.front
              ? 'sila-mascot-outfit-$assetKey'
              : 'sila-mascot-outfit-back-$assetKey',
        ),
        painter: _SilaOutfitPainter(assetKey, layer, pose),
        isComplex: true,
      ),
    );
  }
}

class _SilaAuraOverlay extends StatelessWidget {
  const _SilaAuraOverlay({
    required this.assetKey,
    required this.animation,
    required this.layer,
    required this.willAnimate,
  });

  final String assetKey;
  final Animation<double> animation;
  final _SilaCosmeticLayer layer;
  final bool willAnimate;

  @override
  Widget build(BuildContext context) {
    if (!SilaMascotAuras.supported.contains(assetKey)) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        key: ValueKey(
          layer == _SilaCosmeticLayer.back
              ? 'sila-mascot-aura-$assetKey'
              : 'sila-mascot-aura-front-$assetKey',
        ),
        painter: _SilaAuraPainter(assetKey, animation, layer),
        isComplex: !willAnimate,
        willChange: willAnimate,
      ),
    );
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
