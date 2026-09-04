# Release checklist

## Engineering

- [x] Production API default `https://www.lesisearch.com`
- [x] Cleartext disabled in release; allowed in debug/profile only
- [x] Network errors sanitized (no raw exceptions to users)
- [x] Account deletion API + Profile UI
- [x] R8 minify enabled for release
- [ ] Upload keystore configured (`android/key.properties`)
- [ ] Production backend deployed with deletion endpoint
- [ ] Manual QA on a physical device (install APK/AAB)

## Documents

- [x] Privacy Policy draft (`docs/legal/privacy-policy.md`)
- [x] Terms draft (`docs/legal/terms-and-conditions.md`)
- [x] Account deletion doc
- [ ] Host privacy/terms on website
- [ ] Lawyer review of legal drafts

## Builds

```bash
cd lesi-search-mobile
flutter pub get

# GitHub / sideload APK (debug-signed if no key.properties)
flutter build apk --release --dart-define=API_BASE_URL=https://www.lesisearch.com

# Play upload (requires release keystore)
flutter build appbundle --release --dart-define=API_BASE_URL=https://www.lesisearch.com
```

Outputs:

- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`
