# Windows 10/11 delivery plan

## Scope and decisions

- Target native 64-bit Windows 10 and Windows 11 only. Windows 7 and 8 are explicitly out of scope.
- Keep the current local-only model: study progress, preferences, and exam history are stored on the individual computer. Do not add accounts, a backend, or cloud sync.
- Keep Google Mobile Ads mobile-only. The Windows app must not initialize, load, or render Google Mobile Ads.
- Retain one Flutter codebase; add platform-specific code only when a package or Windows behavior requires it.

## Current starting point

- The repository already contains `windows/` and passes `flutter analyze`.
- The app currently locks orientation in `lib/main.dart`; this must be mobile-only so a desktop window remains freely resizable.
- `lib/ads/` contains Google Mobile Ads code. It is not currently wired into the main app, but any future use needs a platform-safe abstraction before it can be imported by shared UI.
- The UI is phone-first (bottom navigation, narrow header, fixed spacing). It needs a responsive desktop pass rather than a wholesale rewrite.

## Implementation order

### 1. Establish a repeatable Windows build

- [ ] On a Windows 10/11 build machine, run `flutter doctor`, install the required Visual Studio C++ desktop workload if needed, then run `flutter pub get`.
- [ ] Run `flutter run -d windows` and fix any Windows-only startup or plugin failures.
- [ ] Build a release with `flutter build windows` and record the output location and version in the release notes.
- [ ] Decide distribution: zip of the release folder for an internal deployment, or an MSIX installer if installation/update integration is required. A zip is likely sufficient for this short-lived exam-prep app.

### 2. Make shared startup and ads platform-safe

- [x] Replace the unconditional orientation lock with a mobile-only implementation; never import `dart:io` directly from code that also compiles for web.
- [x] Put ad operations behind a small interface with a no-op Windows implementation. The Windows build must show the exam-result flow immediately where an Android ad would otherwise appear.
- [ ] Verify the app launches and completes an exam when there is no ad implementation on a Windows 10/11 device.

### 3. Add desktop-responsive UI

- [x] Define compact, tablet, and desktop breakpoints for the shared layouts.
- [x] Constrain reading content to a comfortable maximum width; do not stretch question text and answer choices across an ultrawide window.
- [x] On desktop, replace or supplement the bottom navigation with a left navigation rail or persistent side navigation. Keep the compact layout unchanged for phone-sized windows.
- [x] Adapt the header, menu grid, cards, dialogs, question/exam screens, settings, chapter selection, and history screens for wide and narrow desktop windows.
- [ ] Ensure mouse and keyboard use are pleasant: visible focus states, sensible tab order, Enter/Space activation, Escape to dismiss dialogs, and enough hit area for touchscreens.
- [ ] Test with Windows scaling at 100%, 125%, and 150%, plus both light and dark themes.

### 4. Verify and release

- [ ] Run `flutter analyze` and relevant unit/widget tests.
- [ ] Manually test A1 and A licence flows: startup, study, catalogue, mock exam, result, history, reset, theme, text size, and persistence after restart.
- [ ] Smoke-test on a clean Windows 10 machine and a Windows 11 machine before distributing.
- [ ] Confirm the release folder contains the executable and all companion files; distribute the entire folder, not only the `.exe`.

## Acceptance checklist

- [ ] Runs as a native Windows app on Windows 10 and 11 without a browser or mobile-device dependency.
- [ ] No mobile ad SDK call is made on Windows.
- [ ] Window resizing, common display scaling, keyboard navigation, and large text do not hide or overlap controls.
- [ ] Local progress survives restart on the same computer; no account or network connection is required.
- [ ] A documented, reproducible release command and distribution format exist.

## Windows release handoff

Run these commands from a Windows 10 or Windows 11 machine after installing the Visual Studio **Desktop development with C++** workload:

```powershell
flutter doctor
flutter pub get
flutter analyze
flutter run -d windows
flutter build windows
```

Distribute the entire release directory, not only the executable:

```text
build\windows\x64\runner\Release\
```

For the initial school release, package this folder as a ZIP. It avoids installer complexity for an app students will use only briefly. The Windows window title, executable metadata, and generated icon use the GPLX branding.

## Automated Windows builds

The repository includes `.github/workflows/build-windows.yml`. GitHub runs it on a hosted Windows machine after each push to `main` (or when started manually from the Actions tab). It runs analysis and tests, builds the x64 release, a `GPLX-Windows-x64-Setup.exe` installer, and uploads both as workflow artifacts.

To download it, open GitHub **Actions** → **Build Windows release** → select the successful run → download the `GPLX-Windows-x64-Setup` artifact. Students should run the installer rather than the portable ZIP.

## Automatic updates

- The installed Windows app has **Cài đặt → Windows → Kiểm tra cập nhật**. It reads the latest public GitHub Release from `laandayo/gplx_app`.
- Push a version tag matching `pubspec.yaml`, for example `git tag v1.0.2` then `git push origin v1.0.2`. The workflow attaches `GPLX-Windows-x64-Setup.exe` to that GitHub Release.
- The updater downloads that exact installer, closes the app, runs the installer silently, then starts the installed app again.
- Do not rename the installer asset or make the GitHub Release private; the updater requires a public asset named `GPLX-Windows-x64-Setup.exe`.

## Handoff reminder

If the iOS PWA work is completed first, start here at **Implementation order, step 1**. Do not copy iOS PWA install or hosting logic into the native Windows release. Only share responsive layout and the ad abstraction where useful.
