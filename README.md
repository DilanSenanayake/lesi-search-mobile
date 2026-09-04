# LesiSearch Mobile

Flutter client for [LesiSearch](https://www.lesisearch.com) — AI-ranked used-vehicle search across Riyasewana and Ikman.

Talks to the Django **Mobile JSON API** at `/api/mobile/v1/` (Bearer tokens). Never embeds partner `EXTERNAL_API_KEYS`.

## Features

- Home search matching the website — **no login required to search**
- Register / login / email OTP (sign-up & guest alerts)
- Secure token storage when signed in
- AI top picks with listing WebView
- Guest trial alerts or signed-in alerts
- Profile, alert filters, **account deletion**
- Links to Privacy & Terms

## Technology stack

- Flutter 3.22+ / Dart 3.3+
- `http`, `flutter_secure_storage`, `provider`, `webview_flutter`, `cached_network_image`, `google_fonts`, `url_launcher`
- Android `applicationId`: `com.lesisearch.lesi_search_mobile`

## Requirements

1. [Flutter SDK](https://docs.flutter.dev/get-started/install)
2. Android SDK (API 36 toolchain recommended)
3. Backend from `autoinsight` for local development

## Development setup

```bash
cd lesi-search-mobile
flutter pub get
```

### Environment / API base URL

Compile-time define (preferred):

```bash
# Production (also the app default)
flutter run --dart-define=API_BASE_URL=https://www.lesisearch.com

# Android emulator → host machine
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000

# Physical device on same LAN
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8000
```

Optional `.env` is only for documentation/local notes — the Flutter app reads `String.fromEnvironment('API_BASE_URL')`, not dotenv at runtime.

Backend local HTTP:

```env
MOBILE_API_REQUIRE_HTTPS=False
DJANGO_DEBUG=True
```

Debug/profile Android builds allow cleartext HTTP. **Release builds do not.**

## Release build instructions

```bash
# APK (testing / GitHub Releases)
flutter build apk --release --dart-define=API_BASE_URL=https://www.lesisearch.com

# Play Store AAB (requires android/key.properties + keystore)
flutter build appbundle --release --dart-define=API_BASE_URL=https://www.lesisearch.com
```

Signing:

1. Copy `android/key.properties.example` → `android/key.properties`
2. Create an upload keystore and fill passwords/alias/path
3. Never commit `key.properties` or `*.jks`

Without `key.properties`, release builds fall back to the **debug** keystore (not for Play).

## Testing

Manual checklist:

1. Health check / search  
2. Register → OTP → verify  
3. Sign in (no OTP gate)  
4. Open listing WebView  
5. Save alerts  
6. Profile edit + sign out  
7. Delete account (password confirm)  
8. Airplane mode / API errors show friendly messages  

Backend API tests (from `autoinsight`):

```bash
python manage.py test evaluator.tests.test_mobile_api
```

## Privacy & Terms

Drafts (must be hosted publicly before Play):

- [`docs/legal/privacy-policy.md`](docs/legal/privacy-policy.md)
- [`docs/legal/terms-and-conditions.md`](docs/legal/terms-and-conditions.md)
- [`docs/legal/account-deletion.md`](docs/legal/account-deletion.md)

Release / Play:

- [`docs/release/`](docs/release/)

Backend contract: `autoinsight/docs/mobile-api.md`
