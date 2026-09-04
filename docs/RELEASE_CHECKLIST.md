# Release Checklist

Use this checklist for a competition build, pilot build, or public deployment.
Record the commit SHA and evidence links in the release issue.

## 1. Source and scope

- [ ] Fetch `origin` and confirm the release branch contains the latest `main`.
- [ ] Confirm `git status --short` is clean.
- [ ] Review the complete diff; do not include `.env`, service-account files,
      emulator logs, generated build output, or unrelated teammate changes.
- [ ] Record the commit SHA, Flutter version, backend Node version, and intended
      environment.

## 2. Local quality gates

```sh
flutter analyze
flutter test
npm --prefix backend test
npm --prefix backend audit --omit=dev --audit-level=high
npx --yes firebase-tools@15.27.0 emulators:exec \
  --only firestore,storage \
  --project demo-kinquest \
  "npm --prefix backend run test:rules"
```

- [ ] Analysis has no issues.
- [ ] All Flutter and backend tests pass.
- [ ] The production dependency audit has no unresolved high-severity finding.
- [ ] Firestore and Storage emulator tests pass.

## 3. Configuration and secrets

- [ ] Rotate any credential that may have appeared in chat, logs, screenshots,
      or source history.
- [ ] Keep `GEMINI_API_KEY`, `OPENROUTER_API_KEY`, and Firebase Admin
      credentials in a secret manager.
- [ ] Confirm game and mission-proof routes report Google Gemini in `/`, and
      Sila Chat alone reports OpenRouter.
- [ ] Set backend `NODE_ENV=production`.
- [ ] Set `KINQUEST_ALLOWED_ORIGINS` to exact deployed client origins.
- [ ] Confirm Firebase project IDs and service credentials target the intended
      environment, not a developer or demo project.
- [ ] Confirm no production secret is embedded in the Flutter bundle.

## 4. Build

### Web

```sh
flutter build web --release \
  --dart-define=KINQUEST_API_BASE_URL=https://api.example.com
```

- [ ] The API URL is absolute, HTTPS, reachable, and environment-correct.
- [ ] `build/web/main.dart.js` contains the configured public API origin.
- [ ] The build completes its WebAssembly dry-run check.
- [ ] Store the release artifact with its source commit SHA.

### iOS / TestFlight

- [ ] Install full Xcode and accept its license/components.
- [ ] Join the Apple Developer Program and install an Apple Distribution
      signing identity.
- [ ] Replace `com.example.kinquest` with a unique registered bundle ID.
- [ ] Regenerate Firebase's iOS app configuration for that exact bundle ID.
- [ ] Enable Push Notifications and Background Modes / Remote notifications
      for the App ID and provisioning profile.
- [ ] Set a new monotonically increasing build number.

```sh
KINQUEST_API_BASE_URL=https://api.example.com \
  ./tool/build_ios_release.sh --build-number=2
```

- [ ] Confirm the helper creates `build/ios/archive/Runner.xcarchive` and an IPA
      in `build/ios/ipa`.
- [ ] Upload the IPA to App Store Connect and complete TestFlight compliance,
      privacy, age-rating, and tester information.
- [ ] Install the processed TestFlight build on a real iPhone and complete the
      product smoke test below.

## 5. Product smoke test

- [ ] Welcome screen paints on a narrow phone and a desktop viewport.
- [ ] Competition Demo completes Mission → Competition → Reward → Memory →
      Impact without authentication.
- [ ] Account creation/login and family creation/join work in the target
      environment.
- [ ] Family Overview opens from Home.
- [ ] Trivia and Emoji Guess open from View and Quick Play.
- [ ] Family Impostor offers random and selected categories.
- [ ] Shared game setup offers 1, 3, and 5 rounds.
- [ ] Caption Battle offers varied prompt styles.
- [ ] Rewards, Memories, official competitions, and token history open.
- [ ] English, Arabic RTL, Dark, and UAE Family Year appearances remain usable.
- [ ] No overflow, console exception, failed network request, or broken back
      navigation appears in the tested path.

## 6. Pull request and deployment

- [ ] Pull request explains product impact, risk, tests, and configuration.
- [ ] Flutter, backend, and Firebase rules checks are green on GitHub.
- [ ] Download and retain the CI `sila-web-release` artifact when appropriate.
- [ ] Merge only after required checks pass; delete the feature branch.
- [ ] Sync local `main` to the merged commit.
- [ ] Deploy backend before client when the client depends on a new API contract.
- [ ] Run one post-deployment smoke test and verify health, CORS, auth rejection,
      and representative authenticated requests.

## 7. Recovery

- [ ] Identify the last known-good client artifact and backend revision.
- [ ] Confirm the team can roll back without deleting family data.
- [ ] Assign an incident owner and communication channel.
- [ ] Record issues, screenshots, timestamps, environment, and affected family
      IDs without copying private family content into public tickets.
