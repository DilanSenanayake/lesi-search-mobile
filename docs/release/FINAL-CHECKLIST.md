# Play Store — final pre-upload checklist

Use with `play-store-checklist.md` and `data-safety-notes.md`.

## Still needed from you (cannot guess)

- [ ] Fill `LegalCopy` TODOs in `lib/legal/legal_copy.dart` (company, email, jurisdiction, retention, age)
- [ ] Lawyer review of Terms + Privacy; host same text at a **public HTTPS URL**
- [ ] Confirm `https://www.lesisearch.com/legal/#account-deletion` (or your URL) is live
- [ ] Create upload keystore + `android/key.properties` (never commit) — **currently MISSING on this machine**
- [ ] Deploy backend `POST /api/mobile/v1/account/delete/` to production and smoke-test deletion
- [ ] Bump `pubspec.yaml` `version:` **and** matching constants in `LegalCopy` for each upload
- [ ] Store listing: screenshots, feature graphic (1024×500), short/long description, high-res icon
- [ ] Play Console: Data Safety, content rating, target audience, account deletion URL, Privacy Policy URL
- [ ] Internal testing install on a real device (login, search, WebView, delete account)

## Already in good shape (as of this pass)

- [x] `applicationId` = `com.lesisearch.lesi_search_mobile` (not `com.example.*`)
- [x] `targetSdk` / `compileSdk` pinned to **36** (Play requirement from 31 Aug 2026)
- [x] Release `minifyEnabled` + `shrinkResources` + ProGuard rules
- [x] `debugShowCheckedModeBanner: false`; no `print`/`debugPrint` in `lib/`
- [x] Adaptive launcher icon via `flutter_launcher_icons` (brand blue `#2563EB`)
- [x] Branded splash (blue + icon), display name **LesiSearch**
- [x] In-app Terms + Privacy screens + About/Legal hub
- [x] In-app Delete account + web backup link
- [x] Only `INTERNET` permission declared
