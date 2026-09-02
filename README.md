# zed_school_ai

ZED School AI app.

### Run the app

```bash
flutter pub get
flutter run
```

### Run tests

```bash
flutter test
```

### Run build

```bash
flutter build apk --release --obfuscate --split-debug-info=symbols/1.0.0+2
```

```bash
flutter build appbundle --release --obfuscate --split-debug-info=symbols/1.0.0+2
```

## Audit Checklist

- Verify profile save/load behavior
- Confirm timer countdown and automatic timeout on quiz screen
- Confirm beep audio playback on countdown and answer events
- Verify perfect-score celebration and score popup
- Confirm rewarded ad flow every 3 quiz sessions
- Inspect `pubspec.yaml` for asset registration and dependency versions
- Confirm banner ad widget loads without blocking UI

## Notes

This README reflects the current implementation and status as of the latest changes. The app is functionally complete for quiz flow and basic audit review, but full Play Store readiness should include final QA on ads, sound behavior, and build packaging.
