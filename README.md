# Petrimonium Academy

Financial education with simulated money — *do I understand what I'm doing?*
One of four sibling repos in the Petrimonium ecosystem, alongside
`petrimonium-health` (cash flow), `petrimonium-wallet` (patrimony) and
`petrimonium-backend`, which serves all three and is the only place the
boundary between them is enforced.

| Read this | For |
|---|---|
| [`Petrimonium-Backend/docs/INTEGRATION.md`](../Petrimonium-Backend/docs/INTEGRATION.md) | **The integration contract** — what the three products share, what never crosses between them, and the known gaps |
| [`docs/ECOSYSTEM.md`](docs/ECOSYSTEM.md) | This repo's job and the history of how it got here |
| [`docs/ARCHITECTURE/`](docs/ARCHITECTURE/) | Pointer into the shared Atlas Técnico, plus what is specific to this repo |

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Configuring the backend URL

`ApiConstants.baseUrl` (`lib/core/constants/api_constants.dart`) defaults to
`http://localhost:8081`, which works for the iOS Simulator and Flutter Web but
**not** the Android emulator (which needs `10.0.2.2` to reach your machine's
localhost). Override it per run/build with `--dart-define` instead of editing
source:

```sh
# Android emulator, pointing at a locally running backend
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8081

# Pointing at a staging/prod deployment
flutter build apk --dart-define=API_BASE_URL=https://api.example.com
```

A release build (`--release`/`--profile`) refuses to start if `API_BASE_URL` was left at
the `localhost` default (see `ApiConstants.assertConfiguredForRelease`) — this is
intentional, so a build that forgot the flag fails immediately instead of silently
talking to a developer machine in front of a real user.

## Release signing (Android)

`android/app/build.gradle.kts` signs release builds with the debug key until
`android/key.properties` exists (gitignored — never commit it). To produce a real,
store-ready release build:

1. Generate a keystore (keep it and its passwords in a secrets manager, not the repo):
   ```sh
   keytool -genkey -v -keystore ~/petrimonium-release.jks -keyalg RSA -keysize 2048 \
     -validity 10000 -alias petrimonium
   ```
2. Copy `android/key.properties.example` to `android/key.properties` and fill in the
   real `storeFile`/passwords/alias.
3. `flutter build apk --release --dart-define=API_BASE_URL=...` now signs with that
   keystore automatically.

iOS signing (a Team ID + provisioning profile in Xcode) isn't scriptable the same way —
set it up in `ios/Runner.xcodeproj` under Signing & Capabilities.

## Crash/error reporting

Wired via `sentry_flutter` (`lib/main.dart`) but disabled by default — pass a real DSN
to enable it:

```sh
flutter build apk --release --dart-define=SENTRY_DSN=https://xxx@oXXX.ingest.sentry.io/XXX
```

Left unset, `SentryFlutter.init` is a documented no-op: nothing is sent, nothing breaks.

On Linux desktop, `sentry_flutter` pulls in `sentry-native`, which needs libcurl's dev headers
to configure via CMake — same class of issue as `libsecret-1-dev` below:

```sh
sudo apt-get install -y libcurl4-openssl-dev
```

## Linux desktop builds

`flutter_secure_storage` (used to store the auth token) needs the system
package `libsecret-1` to build its Linux desktop backend — it isn't bundled
with the Flutter SDK. Android/iOS/Web builds are unaffected; this is only
needed if you're building/running the `linux` target locally:

```sh
sudo apt-get install libsecret-1-dev
```
# Petrimounium-Academy
