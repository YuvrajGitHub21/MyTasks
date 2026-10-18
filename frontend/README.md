# Frontend — Flutter

The Android and iOS client uses Flutter 3.47.7 stable and Dart 3.13.5. V1 provides task lists and details, encrypted local persistence, configurable reminders, and a user-started study timer with optional task linking and timed breaks. See the [V1 implementation plan](../Documentation/V1-Implementation-Plan.md), [UI flow](../Documentation/UI-Flow-and-Wireframe.md), and [implementation roadmap](../Documentation/Implementation-Roadmap.md).

## Local setup on the current Windows machine

The SDKs are installed under `%USERPROFILE%\develop\MyTasksToolchains`.

```powershell
$env:FLUTTER_ROOT = Join-Path $env:USERPROFILE 'develop\MyTasksToolchains\flutter'
$env:JAVA_HOME = Join-Path $env:USERPROFILE 'develop\MyTasksToolchains\jdk-25.0.4.1+1'
& "$env:FLUTTER_ROOT\bin\flutter.bat" pub get
& "$env:FLUTTER_ROOT\bin\flutter.bat" analyze
& "$env:FLUTTER_ROOT\bin\flutter.bat" test
& "$env:FLUTTER_ROOT\bin\flutter.bat" run
```

To create a local Android debug APK, run `& "$env:FLUTTER_ROOT\bin\flutter.bat" build apk --debug`. Use `flutter run -d <device-id>` when more than one device is connected. This app's study timer reconstructs elapsed time from the encrypted database after the process closes; it does not run a permanent background service. Break-end alerts are normal local notifications and need OS notification access.

`pubspec.lock` is committed to pin resolved app dependencies. Android uses API 24 as its minimum; the iOS deployment target is 15.0. The iOS project is generated, but building it requires macOS and Xcode. The current application ID is `com.yuvrajpadhy.mytasks`; verify its availability before the first public store submission.

The package design and folder responsibilities are described in [`../Documentation/LLD.md`](../Documentation/LLD.md). The Java backend, user accounts, and cloud synchronization are planned for V2, after V1 review.
