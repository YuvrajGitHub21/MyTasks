# Frontend — Flutter

The Android and iOS client is scaffolded here with Flutter 3.47.7 stable and Dart 3.13.5. The current app is an empty starter shell; feature work follows the approved [UI flow](../Documentation/UI-Flow-and-Wireframe.md) and [first implementation slice](../Documentation/Implementation-Roadmap.md).

## Local setup on the current Windows machine

The SDKs are installed under `%USERPROFILE%\develop\MyTasksToolchains`.

```powershell
$env:FLUTTER_ROOT = Join-Path $env:USERPROFILE 'develop\MyTasksToolchains\flutter'
$env:JAVA_HOME = Join-Path $env:USERPROFILE 'develop\MyTasksToolchains\jdk-25.0.4.1+1'
& "$env:FLUTTER_ROOT\bin\flutter.bat" pub get
& "$env:FLUTTER_ROOT\bin\flutter.bat" analyze
& "$env:FLUTTER_ROOT\bin\flutter.bat" run
```

`pubspec.lock` is committed to pin resolved app dependencies. Android uses API 24 as its minimum; the iOS deployment target is 15.0. The iOS project is generated, but building it requires macOS and Xcode. The current application ID is `com.yuvrajpadhy.mytasks`; verify its availability before the first public store submission.

The package design and folder responsibilities are described in [`../Documentation/LLD.md`](../Documentation/LLD.md).
