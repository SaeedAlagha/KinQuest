# kinquest

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## AI backend URL

KinQuest uses the local backend on port `3000` by default:

- Web, iOS simulator, macOS, Windows, and Linux use `http://localhost:3000`.
- The Android emulator uses `http://10.0.2.2:3000`.

For a physical device or deployed backend, provide a reachable URL when running
or building the app:

```sh
flutter run \
  --dart-define=KINQUEST_API_BASE_URL=http://192.168.1.20:3000
```

Use an HTTPS URL for production builds:

```sh
flutter build web \
  --dart-define=KINQUEST_API_BASE_URL=https://api.example.com
```
