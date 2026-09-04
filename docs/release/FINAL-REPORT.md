# Final release-readiness report

**Date:** 2026-08-24  
**Verdict:** 🟡 **MANUAL ACTION REQUIRED** (not 🟢 READY for Play; not 🔴 if only GitHub sideload testing)

---

## 1. Changes made

- Release cleartext HTTP disabled; debug/profile keep cleartext for local API  
- Network security configs added  
- Optional upload keystore wiring (`key.properties`)  
- Sanitized client network error messages  
- Backend + app **account deletion** (password + confirm)  
- Profile: Delete account + Privacy & Terms link  
- Legal/release documentation drafts  
- README updated for production defaults and release builds  
- Mobile API docs updated  

## 2–3. Files changed / created

### Changed (mobile)

- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/debug/AndroidManifest.xml`
- `android/app/src/profile/AndroidManifest.xml`
- `android/app/build.gradle.kts`
- `lib/services/api_client.dart`
- `lib/services/auth_state.dart`
- `lib/screens/profile_screen.dart`
- `README.md`

### Created (mobile)

- `android/app/src/main/res/xml/network_security_config.xml`
- `android/app/src/debug/res/xml/network_security_config.xml`
- `android/app/src/profile/res/xml/network_security_config.xml`
- `android/key.properties.example`
- `docs/legal/*`
- `docs/release/*`

### Changed (backend `autoinsight`)

- `evaluator/firebase_auth.py` — `delete_account_with_id_token`
- `evaluator/mobile_views.py` — `MobileAccountDeleteView`
- `evaluator/mobile_urls.py`
- `evaluator/tests/test_mobile_api.py`
- `docs/mobile-api.md`

## 4. Security issues fixed

- Release cleartext traffic disabled  
- Error messages no longer leak raw exception / socket details  
- Account deletion requires re-auth password (Firebase delete when not E2E)

## 5. Security issues needing manual action

- 🔴 Create & protect **upload keystore**; do not use debug signing for Play  
- 🟡 Deploy account-deletion API to **production** and verify Firebase delete there  
- 🟡 Confirm no secrets in git history for mobile/backend `.env` (rotate if ever committed)  
- 🟡 Host Privacy Policy over HTTPS before Play Data Safety  

## 6. Privacy / data findings

See `docs/release/data-safety-notes.md` and `docs/release/audit-report.md`.

Collected when used: email, optional name/phone, alert filters, auth tokens, IP via servers, AI ranking inputs server-side, WebView third-party cookies on listing sites.

## 7. Permissions

- `INTERNET` only — API, images, WebView  

## 8. Third-party SDKs / services

**In app:** http, secure storage, provider, url_launcher, cached_network_image, google_fonts, webview_flutter  

**Backend processors:** Firebase Auth, Brevo, AI ranking provider, optional OTEL, hosting  

**No** ads / Crashlytics / GA in the app binary today  

## 9. Data Safety (Play)

Use `docs/release/data-safety-notes.md`.

## 10–11. Legal placeholders

See `docs/legal/privacy-policy-placeholders.md` and `[INSERT …]` markers in Privacy/Terms drafts.

## 12. Play declarations to complete

See `docs/release/play-store-checklist.md`.

## 13. Account deletion

- In-app: Profile → Delete account  
- API: `POST /api/mobile/v1/account/delete/`  
- Web URL/email still required for Play Console — see `docs/legal/account-deletion.md`

## 14. Remaining legal questions

- Entity name, address, governing law, retention, age gate, hosted policy URL  
- Lawyer review of drafts  

## 15. Remaining technical issues

- Upload signing not configured on this machine  
- Production deploy of deletion endpoint not verified here  
- WebView residual flakiness on some listing pages  

## 16. Remaining UI/UX

- Deeper accessibility pass optional  
- Guest alert “cancel” UX optional  

## 17. Testing performed

- `flutter analyze` on changed Dart files — clean  
- Django `test_account_delete` + `test_patch_me` — OK  
- Release APK + AAB builds — succeeded (debug-signed without key.properties)

## 18. Release build status

Built successfully with `API_BASE_URL=https://www.lesisearch.com`.

## 19. APK output

`D:\Github\lesi-search-mobile\build\app\outputs\flutter-apk\app-release.apk`

## 20. AAB output

`D:\Github\lesi-search-mobile\build\app\outputs\bundle\release\app-release.aab`

## 21. GitHub Release prep

1. Tag `v1.0.0`  
2. Attach `app-release.apk`  
3. Paste What’s New from `docs/release/store-listing-draft.md`  
4. Note: debug-signed unless you built with upload keystore  

## 22. Google Play publishing instructions

1. Configure upload keystore → rebuild AAB  
2. Host Privacy Policy + deletion instructions  
3. Deploy backend with deletion endpoint  
4. Create app in Play Console → fill Data Safety & checklists  
5. Upload AAB to internal testing → promote when ready  

## 23. Verdict

🟡 **MANUAL ACTION REQUIRED**

Blocking for **Play production**: upload keystore, hosted Privacy Policy, web deletion URL, production backend deploy + end-to-end deletion test.

Acceptable for **closed GitHub APK testing** with clear “not Play-signed” warning.

---

## Before I publish (your actions only)

1. Create upload keystore + `android/key.properties` (never commit)  
2. Rebuild AAB with that keystore  
3. Deploy backend including `/api/mobile/v1/account/delete/` to lesisearch.com  
4. Host Privacy Policy + Terms (+ account deletion section) on HTTPS  
5. Fill all `[INSERT …]` legal placeholders / get lawyer review  
6. Complete Play Console Data Safety + Account deletion URL  
7. Internal-test install, login, search, WebView, delete account on a real device  
8. Only then promote to production
