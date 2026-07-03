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

## Google Cloud TTS API Key (Required for Sound)

All Thai speech in the app is synthesised with Google Cloud Text-to-Speech. The API key is injected **at build time** via `--dart-define` — pass it to every `flutter run` **and** `flutter build` command:

```bash
flutter run --dart-define=GOOGLE_TTS_API_KEY=<your-key>
flutter build apk --release --dart-define=GOOGLE_TTS_API_KEY=<your-key>
```

> [!NOTE]
> The app resolves audio per phrase in this order: **pre-recorded clips in `assets/tts/` → Cloud TTS (only when the key is supplied) → the device's built-in TTS engine** (`flutter_tts`). So the app always speaks even without a key — bundled clips give the best quality/latency at zero cost. See [docs/TTS_CLIPS.md](TTS_CLIPS.md) for the full clip checklist and how to generate them with Google AI Studio.

The key is a Google Cloud API key with the **Cloud Text-to-Speech API** enabled (create one in the Google Cloud console under **APIs & Services -> Credentials**). Do not commit the key to git.

Synthesised audio is cached on-device (up to 50 MB with LRU eviction), so each phrase costs an API call only the first time it is played.

## Run Locally

### 1. View Available Devices
First, list the available devices (including emulator/phone, desktop, and web browsers):

```bash
flutter devices
```

### 2. Run on Android (Primary Target)
Connect an Android device or start a 10" tablet emulator, then target it specifically:

```bash
flutter run -d <device-id>
```

> [!NOTE]
> The app is locked to landscape orientation; run it on a tablet emulator (10") for the intended layout.

### 3. Run on Web (Preview & Testing)
Although Android is the primary target, the app is fully compatible with Web for local testing and developer preview.

* **Incorrect attempts:** Flutter's CLI does not accept options like `--web`, `-web`, or `-w` for running (e.g., `flutter run -w` will fail). Instead, you target the specific browser device using the `-d` (device) flag.
* **Run in Chrome:**
  ```bash
  flutter run -d chrome
  ```
* **Run in Microsoft Edge:**
  ```bash
  flutter run -d edge
  ```

#### Web Renderer Options
Flutter supports different renderers for the web. CanvasKit is recommended for complex Flame game components:
* **CanvasKit (Recommended):** Uses WebAssembly and WebGL to render graphics. It offers pixel-perfect alignment and smooth performance for Flame, but has a larger download size.
  ```bash
  flutter run -d chrome --web-renderer canvaskit
  ```
* **HTML:** Uses standard HTML, CSS, Canvas elements, and SVG. Fast load time but might show slight visual discrepancies in high-performance games.
  ```bash
  flutter run -d chrome --web-renderer html
  ```

#### Simulating the Tablet Layout in the Browser
Since the application layout is optimized for landscape tablets:
1. Open the web preview (e.g., in Chrome).
2. Press `F12` (or right-click -> **Inspect**) to open Developer Tools.
3. Click the **Device Toolbar** icon (toggle device emulation).
4. Choose a tablet viewport (e.g., iPad, Kindle Fire, or custom dimensions) and click the **Rotate** button to switch it to **Landscape** orientation.

## Build for Web

To compile a production release of the web app:

```bash
flutter build web --release --web-renderer canvaskit
```

The output build files will be placed in the `build/web/` directory and are ready to be hosted on any web server (or Firebase Hosting).

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

**App runs but there is no Thai speech (TTS silent)**
Without `--dart-define=GOOGLE_TTS_API_KEY=<your-key>` the app uses the device's built-in TTS engine. If that is silent too, the device has no Thai voice installed — on Android open **Settings -> General management -> Text-to-speech** and install/enable Google Speech Services with Thai, or supply the Cloud key. Check the `flutter run` console for log lines tagged `tts` to see which engine failed.

**Speech uses a robotic voice instead of the natural one**
The build is running on the on-device fallback voice. Rebuild with a valid `GOOGLE_TTS_API_KEY` (see [Google Cloud TTS API Key](#google-cloud-tts-api-key-required-for-sound)) — invalid keys or a disabled Text-to-Speech API also land here (look for `Google TTS failed with 403` in the logs).

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
