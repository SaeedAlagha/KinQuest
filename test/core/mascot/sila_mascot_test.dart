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
      final provider = image.image as AssetImage;
      expect(
        provider.assetName,
        SilaMascotPose.welcome.assetPath,
        reason: appearance.name,
      );
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

  testWidgets('Arabic mascot guide is RTL and fits a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) {
            final strings = AppLocalizations.of(context)!;
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

    final message = find.text(
      'مرحبًا! أنا صلة. سأساعد عائلتكم على اللعب وصنع الذكريات والتقارب.',
    );
    expect(message, findsOneWidget);
    expect(Directionality.of(tester.element(message)), TextDirection.rtl);
    expect(find.byType(SilaMascot), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
