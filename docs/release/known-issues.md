# Known issues

## Residual / accepted for v1

1. **Upload signing** — Without `android/key.properties`, release builds fall back to the debug keystore. Fine for internal APK testing; **blocking for Play**.
2. **Listing WebViews** — ikman/riyasewana pages may still show transient CDN/bot behavior; scroll/load improved but not perfect.
3. **Guest alert cancellation UX** — Guests cannot self-serve cancel from a dedicated screen; subscriptions expire; email the operator to stop early (`[INSERT PROCESS]`).
4. **Privacy Policy not yet hosted** — Draft exists in-repo; Play needs a public HTTPS URL.
5. **google_fonts** — May fetch fonts at runtime (network dependency on first launch).
6. **No crash reporting SDK** — Crashes won’t appear in Firebase Crashlytics/Sentry unless added later.

## Fixed in this release-prep pass

- Cleartext HTTP no longer enabled for release  
- Account deletion endpoint + in-app flow  
- Sanitized network error messages  
- Release signing config wired for optional upload keystore  
- Legal/release documentation drafts added
