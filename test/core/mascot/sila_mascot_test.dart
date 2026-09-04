import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/mascot/sila_mascot.dart';
import 'package:kinquest/core/theme/app_theme.dart';
import 'package:kinquest/core/theme/appearance_controller.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  test('every mascot pose is a real transparent production asset', () async {
    expect(
      SilaMascotPose.values.map((pose) => pose.assetPath).toSet(),
      hasLength(SilaMascotPose.values.length),
    );

    for (final pose in SilaMascotPose.values) {
      final data = await rootBundle.load(pose.assetPath);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final rgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

      expect(image.width, 384, reason: pose.name);
      expect(image.height, 512, reason: pose.name);
      expect(rgba, isNotNull, reason: pose.name);

      final bytes = rgba!.buffer.asUint8List();
      var hasTransparentPixel = false;
      var hasOpaquePixel = false;
      for (var index = 3; index < bytes.length; index += 4) {
        final alpha = bytes[index];
        hasTransparentPixel = hasTransparentPixel || alpha == 0;
        hasOpaquePixel = hasOpaquePixel || alpha == 255;
        if (hasTransparentPixel && hasOpaquePixel) {
          break;
        }
      }

      expect(hasTransparentPixel, isTrue, reason: pose.name);
      expect(hasOpaquePixel, isTrue, reason: pose.name);
    }
  });

  testWidgets('mascot artwork never changes with the selected app theme', (
    tester,
  ) async {
    for (final appearance in AppAppearance.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.forAppearance(appearance),
          home: const Scaffold(
            body: SilaMascot(pose: SilaMascotPose.welcome, animate: false),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      final provider = image.image as ResizeImage;
      final asset = provider.imageProvider as AssetImage;
      expect(
        asset.assetName,
        SilaMascotPose.welcome.assetPath,
        reason: appearance.name,
      );
      // Every Sila instance reuses the same compact native-size cache entry,
      // including after responsive layout and device-pixel-ratio changes.
      expect(provider.width, 384);
      expect(provider.height, 512);
      expect(image.gaplessPlayback, isTrue);
    }
  });

  testWidgets('every supported wardrobe accessory renders on Sila', (
    tester,
  ) async {
    for (final accessory in SilaMascotAccessories.supported) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SilaMascot(animate: false, accessoryAssetKey: accessory),
          ),
        ),
      );

      expect(
        find.byKey(ValueKey('sila-mascot-accessory-$accessory')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SilaMascot(
            animate: false,
            accessoryAssetKey: 'retired-accessory',
          ),
        ),
      ),
    );
    expect(
      find.byKey(const ValueKey('sila-mascot-accessory-retired-accessory')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('outfits and auras can render together with headwear', (
    tester,
  ) async {
    for (final outfit in SilaMascotOutfits.supported) {
      for (final aura in SilaMascotAuras.supported) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SilaMascot(
                animate: false,
                accessoryAssetKey: SilaMascotAccessories.guardianCrown,
                outfitAssetKey: outfit,
                auraAssetKey: aura,
              ),
            ),
          ),
        );

        expect(
          find.byKey(ValueKey('sila-mascot-outfit-$outfit')),
          findsOneWidget,
        );
        expect(find.byKey(ValueKey('sila-mascot-aura-$aura')), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('cosmetics use separate depth planes around Sila', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SilaMascot(
            animate: false,
            accessoryAssetKey: SilaMascotAccessories.scholarCap,
            outfitAssetKey: SilaMascotOutfits.familyCape,
            auraAssetKey: SilaMascotAuras.cosmicOrbit,
          ),
        ),
      ),
    );

    for (final key in [
      'sila-mascot-aura-cosmic_orbit',
      'sila-mascot-outfit-back-family_cape',
      'sila-mascot-accessory-back-scholar_cap',
      'sila-mascot-outfit-family_cape',
      'sila-mascot-accessory-scholar_cap',
      'sila-mascot-aura-front-cosmic_orbit',
    ]) {
      expect(find.byKey(ValueKey(key)), findsOneWidget, reason: key);
    }

    final rigStack = tester.widget<Stack>(
      find.descendant(
        of: find.byKey(const ValueKey('sila-character-rig')),
        matching: find.byType(Stack),
      ),
    );
    expect(rigStack.children.map((child) => child.key), const [
      ValueKey('sila-aura-back-layer'),
      ValueKey('sila-outfit-back-layer'),
      ValueKey('sila-accessory-back-layer'),
      ValueKey('sila-pose-artwork-layer'),
      ValueKey('sila-animated-outfit-layer'),
      ValueKey('sila-animated-accessory-layer'),
      ValueKey('sila-aura-front-layer'),
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('combined cosmetics remain paint-safe at app display sizes', (
    tester,
  ) async {
    const sizes = [58.0, 100.0, 126.0, 205.0];
    const looks = [
      (
        SilaMascotAccessories.guardianCrown,
        SilaMascotOutfits.familyCape,
        SilaMascotAuras.victoryBurst,
      ),
      (
        SilaMascotAccessories.explorerCap,
        SilaMascotOutfits.memoryKeeper,
        SilaMascotAuras.familySparkles,
      ),
      (
        SilaMascotAccessories.scholarCap,
        SilaMascotOutfits.spaceScout,
        SilaMascotAuras.cosmicOrbit,
      ),
      (
        SilaMascotAccessories.starHalo,
        SilaMascotOutfits.gameJersey,
        SilaMascotAuras.uaeRibbon,
      ),
      (
        SilaMascotAccessories.familyLeafWreath,
        SilaMascotOutfits.desertExplorer,
        SilaMascotAuras.memoryHearts,
      ),
    ];

    for (final size in sizes) {
      for (final pose in SilaMascotPose.values) {
        for (final look in looks) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: SilaMascot(
                    pose: pose,
                    height: size,
                    animate: false,
                    accessoryAssetKey: look.$1,
                    outfitAssetKey: look.$2,
                    auraAssetKey: look.$3,
                  ),
                ),
              ),
            ),
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '${pose.name} at $size with ${look.$1}',
          );
        }
      }
    }
  });

  testWidgets('every pose has attached wardrobe geometry', (tester) async {
    final accessoryGeometries = <String>{};
    final outfitGeometries = <String>{};
    const expectedAccessoryGeometry = {
      SilaMascotPose.idle: (Offset(0.033, 0), 1.0),
      SilaMascotPose.welcome: (Offset(0.043, -0.006), 1.0),
      SilaMascotPose.thinking: (Offset(0.013, 0.01), 0.94),
      SilaMascotPose.celebrating: (Offset(-0.052, 0.021), 0.96),
      SilaMascotPose.oops: (Offset(0.02, -0.088), 0.96),
      SilaMascotPose.encouraging: (Offset(0.028, -0.068), 0.94),
      SilaMascotPose.winner: (Offset(-0.019, -0.066), 0.95),
    };
    const expectedOutfitGeometry = {
      SilaMascotPose.idle: (Offset(0.039, 0.012), 1.0),
      SilaMascotPose.welcome: (Offset(-0.018, 0.013), 1.0),
      SilaMascotPose.thinking: (Offset(-0.046, 0.025), 0.95),
      SilaMascotPose.celebrating: (Offset(-0.069, 0.037), 0.97),
      SilaMascotPose.oops: (Offset(0.009, -0.083), 0.96),
      SilaMascotPose.encouraging: (Offset(0.003, -0.069), 0.95),
      SilaMascotPose.winner: (Offset(-0.018, -0.067), 0.95),
    };

    for (final pose in SilaMascotPose.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SilaMascot(
              pose: pose,
              animate: false,
              accessoryAssetKey: SilaMascotAccessories.guardianCrown,
              outfitAssetKey: SilaMascotOutfits.gameJersey,
              auraAssetKey: SilaMascotAuras.cosmicOrbit,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(ValueKey('sila-pose-${pose.name}')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('sila-character-rig')),
          matching: find.byKey(
            const ValueKey('sila-mascot-accessory-guardian_crown'),
          ),
        ),
        findsOneWidget,
        reason: pose.name,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('sila-character-rig')),
          matching: find.byKey(
            const ValueKey('sila-mascot-outfit-game_jersey'),
          ),
        ),
        findsOneWidget,
        reason: pose.name,
      );

      final accessoryTranslation = tester.widget<FractionalTranslation>(
        find.byKey(const ValueKey('sila-animated-accessory-layer')),
      );
      final accessoryScale = tester.widget<Transform>(
        find.byKey(const ValueKey('sila-animated-accessory-scale')),
      );
      final outfitTranslation = tester.widget<FractionalTranslation>(
        find.byKey(const ValueKey('sila-animated-outfit-layer')),
      );
      final outfitScale = tester.widget<Transform>(
        find.byKey(const ValueKey('sila-animated-outfit-scale')),
      );

      expect(
        accessoryTranslation.translation.dx.isFinite,
        isTrue,
        reason: pose.name,
      );
      expect(
        accessoryTranslation.translation.dy.isFinite,
        isTrue,
        reason: pose.name,
      );
      expect(
        accessoryScale.transform.entry(0, 0),
        greaterThan(0),
        reason: pose.name,
      );
      expect(
        outfitTranslation.translation.dx.isFinite,
        isTrue,
        reason: pose.name,
      );
      expect(
        outfitTranslation.translation.dy.isFinite,
        isTrue,
        reason: pose.name,
      );
      expect(
        outfitScale.transform.entry(0, 0),
        greaterThan(0),
        reason: pose.name,
      );
      expect(
        accessoryTranslation.translation,
        expectedAccessoryGeometry[pose]!.$1,
        reason: 'measured head anchor for ${pose.name}',
      );
      expect(
        accessoryScale.transform.entry(0, 0),
        closeTo(expectedAccessoryGeometry[pose]!.$2, 0.0001),
        reason: 'measured head scale for ${pose.name}',
      );
      expect(
        outfitTranslation.translation,
        expectedOutfitGeometry[pose]!.$1,
        reason: 'measured chest anchor for ${pose.name}',
      );
      expect(
        outfitScale.transform.entry(0, 0),
        closeTo(expectedOutfitGeometry[pose]!.$2, 0.0001),
        reason: 'measured chest scale for ${pose.name}',
      );

      accessoryGeometries.add(
        '${accessoryTranslation.translation.dx}:'
        '${accessoryTranslation.translation.dy}:'
        '${accessoryScale.transform.entry(0, 0)}',
      );
      outfitGeometries.add(
        '${outfitTranslation.translation.dx}:'
        '${outfitTranslation.translation.dy}:'
        '${outfitScale.transform.entry(0, 0)}',
      );
      expect(tester.takeException(), isNull, reason: pose.name);
    }

    expect(accessoryGeometries, hasLength(SilaMascotPose.values.length));
    expect(outfitGeometries, hasLength(SilaMascotPose.values.length));
  });

  testWidgets('pose changes keep one animated character rig', (tester) async {
    var pose = SilaMascotPose.idle;
    late StateSetter updateHost;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              updateHost = setState;
              return SilaMascot(
                key: const ValueKey('stable-sila'),
                pose: pose,
                loop: true,
                accessoryAssetKey: SilaMascotAccessories.scholarCap,
                outfitAssetKey: SilaMascotOutfits.spaceScout,
                auraAssetKey: SilaMascotAuras.victoryBurst,
              );
            },
          ),
        ),
      ),
    );

    final initialState = tester.state(
      find.byKey(const ValueKey('stable-sila')),
    );
    final initialTransform = List<double>.of(
      tester
          .widget<Transform>(
            find.byKey(const ValueKey('sila-character-motion-transform')),
          )
          .transform
          .storage,
    );

    await tester.pump(const Duration(milliseconds: 320));
    final movingTransform = List<double>.of(
      tester
          .widget<Transform>(
            find.byKey(const ValueKey('sila-character-motion-transform')),
          )
          .transform
          .storage,
    );
    expect(movingTransform, isNot(equals(initialTransform)));

    updateHost(() => pose = SilaMascotPose.celebrating);
    await tester.pump();
    expect(
      identical(
        tester.state(find.byKey(const ValueKey('stable-sila'))),
        initialState,
      ),
      isTrue,
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('sila-pose-celebrating')), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byKey(const ValueKey('sila-mascot-accessory-scholar_cap')),
        matching: find.byKey(const ValueKey('sila-character-motion-transform')),
      ),
      findsOneWidget,
    );
    expect(
      find.ancestor(
        of: find.byKey(const ValueKey('sila-mascot-outfit-space_scout')),
        matching: find.byKey(const ValueKey('sila-character-motion-transform')),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('pose dissolve never paints two Silas or trailing cosmetics', (
    tester,
  ) async {
    var pose = SilaMascotPose.idle;
    late StateSetter updateHost;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              updateHost = setState;
              return SilaMascot(
                pose: pose,
                accessoryAssetKey: SilaMascotAccessories.guardianCrown,
                outfitAssetKey: SilaMascotOutfits.gameJersey,
              );
            },
          ),
        ),
      ),
    );

    final idleAccessory = tester
        .widget<FractionalTranslation>(
          find.byKey(const ValueKey('sila-animated-accessory-layer')),
        )
        .translation;
    expect(find.byType(Image), findsOneWidget);
    expect(find.byKey(const ValueKey('sila-pose-idle')), findsOneWidget);

    updateHost(() => pose = SilaMascotPose.thinking);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Before the invisible midpoint, the complete old rig is still shown.
    expect(find.byType(Image), findsOneWidget);
    expect(find.byKey(const ValueKey('sila-pose-idle')), findsOneWidget);
    expect(
      tester
          .widget<FractionalTranslation>(
            find.byKey(const ValueKey('sila-animated-accessory-layer')),
          )
          .translation,
      idleAccessory,
    );

    await tester.pump(const Duration(milliseconds: 30));

    // After the midpoint, artwork and both cosmetic layers switch together.
    expect(find.byType(Image), findsOneWidget);
    expect(find.byKey(const ValueKey('sila-pose-thinking')), findsOneWidget);
    expect(
      tester
          .widget<FractionalTranslation>(
            find.byKey(const ValueKey('sila-animated-accessory-layer')),
          )
          .translation,
      isNot(idleAccessory),
    );
    expect(
      tester
          .widget<Opacity>(
            find.byKey(const ValueKey('sila-pose-transition-opacity')),
          )
          .opacity,
      inInclusiveRange(0.0, 1.0),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpAndSettle();
  });

  testWidgets(
    'interactive Sila has one button node and replays motion on tap',
    (tester) async {
      var tapCount = 0;
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SilaMascot(
              semanticLabel: 'Sila, your family companion',
              semanticHint: 'Plays a friendly reaction',
              motion: SilaMascotMotion.excited,
              onTap: () => tapCount += 1,
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Sila, your family companion'),
        findsOneWidget,
      );
      final node = tester.getSemantics(
        find.bySemanticsLabel('Sila, your family companion'),
      );
      final data = node.getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.actions & ui.SemanticsAction.tap.index, isNot(0));
      expect(data.hint, 'Plays a friendly reaction');
      semantics.dispose();

      await tester.pump(const Duration(milliseconds: 1050));
      final settledTransform = List<double>.of(
        tester
            .widget<Transform>(
              find.byKey(const ValueKey('sila-character-motion-transform')),
            )
            .transform
            .storage,
      );

      await tester.tap(find.byType(SilaMascot));
      await tester.pump(const Duration(milliseconds: 180));
      final replayedTransform = List<double>.of(
        tester
            .widget<Transform>(
              find.byKey(const ValueKey('sila-character-motion-transform')),
            )
            .transform
            .storage,
      );

      expect(tapCount, 1);
      expect(replayedTransform, isNot(equals(settledTransform)));
      expect(tester.takeException(), isNull);

      await tester.pumpAndSettle();
    },
  );

  testWidgets('reduced motion swaps pose and cosmetics immediately', (
    tester,
  ) async {
    var pose = SilaMascotPose.idle;
    late StateSetter updateHost;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            updateHost = setState;
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: Scaffold(
                body: SilaMascot(
                  pose: pose,
                  accessoryAssetKey: SilaMascotAccessories.scholarCap,
                  outfitAssetKey: SilaMascotOutfits.spaceScout,
                ),
              ),
            );
          },
        ),
      ),
    );

    updateHost(() => pose = SilaMascotPose.winner);
    await tester.pump();

    expect(find.byKey(const ValueKey('sila-pose-winner')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('sila-pose-transition-opacity')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('sila-character-motion-transform')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion stops and cleanly restarts a paused loop', (
    tester,
  ) async {
    var reduceMotion = false;
    late StateSetter updateHost;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            updateHost = setState;
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(disableAnimations: reduceMotion),
              child: const Scaffold(
                body: SilaMascot(
                  key: ValueKey('motion-aware-sila'),
                  motion: SilaMascotMotion.gameReady,
                  loop: true,
                  loopPause: Duration(milliseconds: 500),
                ),
              ),
            );
          },
        ),
      ),
    );

    final initialState = tester.state(
      find.byKey(const ValueKey('motion-aware-sila')),
    );
    expect(
      find.byKey(const ValueKey('sila-character-motion-transform')),
      findsOneWidget,
    );

    // Finish the first cycle so the mascot is waiting on its loop timer.
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump();

    updateHost(() => reduceMotion = true);
    await tester.pump();
    expect(
      find.byKey(const ValueKey('sila-character-motion-transform')),
      findsNothing,
    );

    // The canceled loop timer must not restart animation while motion is off.
    await tester.pump(const Duration(seconds: 2));
    expect(
      find.byKey(const ValueKey('sila-character-motion-transform')),
      findsNothing,
    );

    updateHost(() => reduceMotion = false);
    await tester.pump();
    expect(
      identical(
        tester.state(find.byKey(const ValueKey('motion-aware-sila'))),
        initialState,
      ),
      isTrue,
    );

    final restartedTransform = List<double>.of(
      tester
          .widget<Transform>(
            find.byKey(const ValueKey('sila-character-motion-transform')),
          )
          .transform
          .storage,
    );
    await tester.pump(const Duration(milliseconds: 320));
    final movingTransform = List<double>.of(
      tester
          .widget<Transform>(
            find.byKey(const ValueKey('sila-character-motion-transform')),
          )
          .transform
          .storage,
    );
    expect(movingTransform, isNot(equals(restartedTransform)));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Arabic mascot guide is RTL and fits a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    late String localizedMessage;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) {
            final strings = AppLocalizations.of(context)!;
            localizedMessage = strings.mascotWelcomeMessage;
            return Scaffold(
              body: SafeArea(
                child: SilaMascotGuide(
                  title: strings.mascotName,
                  message: strings.mascotWelcomeMessage,
                  semanticLabel: strings.mascotSemanticLabel,
                  animate: false,
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    final message = find.text(localizedMessage);
    expect(message, findsOneWidget);
    expect(Directionality.of(tester.element(message)), TextDirection.rtl);
    expect(find.byType(SilaMascot), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
