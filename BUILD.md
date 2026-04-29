# Build Guide

_Last checked: 2026-04-29_

## Prerequisites

| Tool | Minimum version | Notes |
|---|---|---|
| Flutter SDK | 3.29.2+ compatible with Dart ^3.7.2 | Install via [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Dart | 3.7.2+ | Bundled with Flutter; `pubspec.yaml` sets `sdk: ^3.7.2` |
| Android Studio | latest stable | Required for Android emulator and SDK tools |
| JDK | 17+ | Required by Android Gradle Plugin 8.7; Android Studio's bundled JDK is OK. App source/target compatibility remains Java 11. |
| Android SDK | Android SDK configured in `flutter doctor` | `minSdk` is 23 (Firebase Auth requirement); `compileSdk` comes from the installed Flutter SDK |

iOS is **not** in scope for the current MVP — Android tablet (10", landscape) only.

## Install Dependencies

Check the local Flutter and Android setup first:

```bash
flutter doctor -v
```

```bash
flutter pub get
```

If you change any Freezed model (`lib/models/*.dart`) or add a new `@JsonSerializable` class, regenerate code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

To watch for changes during development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Environment / Firebase Setup

The app requires Firebase. The current Android Firebase config is tracked in git:

- `android/app/google-services.json` — Android Firebase config for package `com.kaokeng.daily_life`
- `lib/firebase_options.dart` — Firebase SDK options for project `tenacious-veld-453115-u8`

If you connect a different Firebase project, make sure the Firebase CLI is installed and logged in, then regenerate the FlutterFire config:

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

Download a replacement `android/app/google-services.json` from the Firebase console under **Project settings -> Your apps -> Android app**. No `.env` file is required. Do not commit Firebase service-account or admin SDK JSON files; `.gitignore` excludes those.

## Run Locally

Connect an Android device or start an emulator, then:

```bash
flutter run
```

To target a specific device:

```bash
flutter devices          # list available devices
flutter run -d <device-id>
```

The app is locked to landscape orientation; run it on a tablet emulator (10") for the intended layout.

## Android Build

Debug APK:

```bash
flutter build apk --debug
```

Release APK:

```bash
flutter build apk --release
```

Release App Bundle:

```bash
flutter build appbundle --release
```

Build outputs land under `build/app/outputs/`, for example `build/app/outputs/flutter-apk/app-debug.apk`, `build/app/outputs/flutter-apk/app-release.apk`, and `build/app/outputs/bundle/release/app-release.aab`.

`android/app/build.gradle.kts` currently signs release builds with the debug signing config so local release commands work. Configure a real release keystore before distributing an APK or uploading an AAB to Play Store.

## Tests

Run the full test suite:

```bash
flutter test
```

Test coverage spans:

- `test/models/` — data model serialisation
- `test/features/` — memory game controller, session recorder
- `test/providers/` — Riverpod provider logic
- `test/services/` — TTS service, content repository
- `test/game/` — Flame game render test
- `test/widgets/` — child and parent widget tests
- `test/content/` — asset manifest validation

## Troubleshooting

**`google-services.json` missing**
```
FAILURE: Build failed with an exception.
...google-services plugin requires a google-services.json file
```
Download the file from the Firebase console and place it at `android/app/google-services.json`.

**Freezed / generated code out of date**
```
Error: The getter 'copyWith' isn't defined for the class '...'
```
Run `dart run build_runner build --delete-conflicting-outputs`.

**Gradle JDK mismatch**
Ensure Android Studio is using JDK 17 or newer. Go to **File -> Project Structure -> SDK Location -> Gradle JDK** and select Android Studio's bundled JDK or another JDK 17+ installation.

**Android SDK not detected**
Run `flutter doctor -v`. If the Android SDK is installed in a custom location, run `flutter config --android-sdk <path-to-sdk>`.

**`flutter pub get` fails on Windows with path length errors**
Enable long paths in Windows: run `git config --system core.longpaths true` and enable the Windows long path policy via Group Policy or registry.

**Emulator not detected**
Run `flutter doctor -v` to verify your Android SDK and emulator setup. Make sure `ANDROID_HOME` (or `ANDROID_SDK_ROOT`) is set in your environment if Flutter cannot find the SDK.
