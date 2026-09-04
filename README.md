# Sila | صِلَة

> Closer, one moment at a time. | أقرب، لحظة بعد لحظة

Sila is a private, bilingual family connection app created around the UAE Year
of Family 2026. It turns a simple loop—play together, celebrate progress, choose
a shared reward, and save the moment—into a habit that helps families reconnect.

The Flutter package and Firebase project retain the internal `kinquest`
identifier for compatibility. The user-facing product is **Sila | صِلَة**.

## The three-minute judge experience

No account, backend, or family data is needed for the competition demo.

1. Launch Sila and select **Try the 3-minute Competition Demo**.
2. Complete the mission and crown a family quiz champion.
3. Redeem a shared family reward.
4. Save the simulated challenge night as a memory.
5. Finish on the Impact screen, where the complete connection loop is visible.

The route uses clearly labelled simulated data and uploads no photos. See the
[full presenter script](docs/COMPETITION_DEMO.md) for timing, narration, and a
fallback plan.

## What makes Sila competition-ready

| Pillar | Experience | Evidence in the product |
| --- | --- | --- |
| Connect | Fifteen family-friendly games and missions | Shared 1/3/5-round setup, varied prompts, group play |
| Compete | Daily, weekly, and monthly family competitions | Results, tie-breaks, rankings, tokens, and trophies |
| Celebrate | UAE-inspired motion, color, and champion moments | Branded victory cards and the UAE Family Year theme |
| Continue | Rewards and memories turn play into real family rituals | Token history, family rewards, wishlists, saved memories |
| Include | English and Arabic core journeys | Runtime language switching, RTL layouts, narrow-screen tests |
| Protect | Family-scoped data and authenticated production AI | Firebase rules, bearer tokens, CORS, limits, and privacy headers |

Sila includes Quick Play experiences such as Family Impostor, Trivia, Emoji
Guess, Caption Battle, Would You Rather, Charades, Family Quiz, and more. The
Family Impostor setup supports random or selected categories; the common game
setup keeps round selection consistent; and Caption Battle includes multiple
prompt styles beyond a single “funny” mode.

## Product map

```text
Welcome
  ├─ Competition Demo (safe simulated judge journey)
  └─ Account + Family
       ├─ Home and Family Overview
       ├─ Memories
       ├─ Play and official competitions
       ├─ Family Missions
       └─ Profile, Rewards, Settings, Language, Appearance
```

The app adapts between mobile bottom navigation and a desktop navigation rail.
Appearance preferences include Sila Light, Dark, and UAE Family Year 2026.

## Technology and trust boundaries

- **Client:** Flutter 3.44.8 / Dart 3.12, responsive Material UI.
- **Identity and data:** Firebase Authentication, Firestore, Storage, and Cloud
  Messaging.
- **AI gateway:** Express routes every game and mission-proof request to Google
  Gemini, while Sila Chat alone uses OpenRouter. Both API keys stay server-side.
- **Authorization:** family-scoped Firestore and Storage rules tested in the
  official Firebase emulators.
- **Production boundary:** every `/api` route requires a verified Firebase ID
  token, applies rate limits, validates CORS, and returns privacy headers.
- **Release safety:** production clients fail closed unless an absolute HTTPS
  API URL is supplied at build time.

Read [Architecture and privacy](docs/ARCHITECTURE_AND_PRIVACY.md) for the data
flow, controls, and known operational responsibilities.

## Run locally

Prerequisites:

- Flutter 3.44.8 (stable)
- Node.js 20
- Java 21 when running Firebase CLI 15 emulator checks
- a configured Firebase project for authenticated, persistent app journeys

Install dependencies:

```sh
flutter pub get
npm --prefix backend ci
cp backend/.env.example backend/.env
```

Set `GEMINI_API_KEY` and `OPENROUTER_API_KEY` in `backend/.env`, then start the
AI gateway. Games use Gemini 3.8 Flash with a stable Gemini 2.5 Flash fallback;
Sila Chat uses the configurable OpenRouter model:

```sh
npm --prefix backend start
```

In another terminal, launch Flutter:

```sh
flutter run -d chrome
```

Debug builds default to `http://localhost:3000`; the Android emulator defaults
to `http://10.0.2.2:3000`. For a physical device, pass a reachable development
URL:

```sh
flutter run \
  --dart-define=KINQUEST_API_BASE_URL=http://192.168.1.20:3000
```

Never commit `backend/.env`, service-account JSON, Firebase tokens, or API keys.

## Validate changes

Run the same core gates used by CI:

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

The emulator command uses a demo project and does not need production Firebase
data. If the local machine has Java 11, use Firebase CLI `13.35.1` for the same
rules suite or install Java 21.

## Build a production candidate

A release build must receive the deployed HTTPS gateway URL:

```sh
flutter build web --release \
  --dart-define=KINQUEST_API_BASE_URL=https://api.example.com
```

For iOS, first replace the placeholder `com.example.kinquest` identifier with
the team's registered Apple bundle ID, regenerate the matching Firebase iOS
configuration, select an Apple Developer team in Xcode, and deploy the HTTPS
gateway. The guarded helper then creates the signed archive and IPA:

```sh
KINQUEST_API_BASE_URL=https://api.example.com \
  ./tool/build_ios_release.sh
```

The helper deliberately stops before building when the URL is insecure, full
Xcode or an Apple Distribution identity is missing, or the placeholder bundle
ID remains. Upload the resulting IPA through Xcode or Transporter for TestFlight
and App Store distribution.

Missing, malformed, or insecure release URLs stop the app instead of silently
calling localhost. GitHub Actions repeats analysis, tests, backend validation,
Firebase emulator tests, and the release build, then uploads `sila-web-release`
as a seven-day artifact.

Before any live deployment, follow the [release checklist](docs/RELEASE_CHECKLIST.md).

## Competition and pilot handoff

- [Competition demo script](docs/COMPETITION_DEMO.md)
- [Judge QR/web access](docs/JUDGE_WEB_ACCESS.md)
- [Architecture and privacy](docs/ARCHITECTURE_AND_PRIVACY.md)
- [Release checklist](docs/RELEASE_CHECKLIST.md)
- [Family pilot playbook](docs/PILOT_PLAYBOOK.md)

These documents separate verified product behavior from future claims. Pilot
targets are goals to measure, not results the team should claim before a real
pilot is completed.
