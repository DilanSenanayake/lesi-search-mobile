# LesiSearch Mobile — Release-Readiness Audit (Phase 1)

**Date:** 2026-08-24  
**App:** `lesi_search_mobile` (`com.lesisearch.lesi_search_mobile`)  
**Version:** `1.0.0+1`  
**Stack:** Flutter 3.44 / Dart 3.12 · Android compile/targetSdk **36**, minSdk **24**

This audit is based on the codebase as inspected. It does **not** certify legal compliance or Play Store approval.

---

## Architecture summary

| Layer | Detail |
|--------|--------|
| Client | Flutter app; email/password via backend mobile API |
| Backend | Django `autoinsight` `/api/mobile/v1/` |
| Auth | Firebase Identity Toolkit on server; app stores Django Bearer token in `flutter_secure_storage` |
| Search | Optional auth; scrapes listing sites + LLM ranking on server |
| Alerts | Guest OTP trial or signed-in subscription; email via Brevo |
| Listings UI | In-app WebView for ikman / riyasewana |

**No** analytics, ads, crash-reporting, payments, camera, location, contacts, Bluetooth, or push-notification SDKs were found in the Flutter app.

---

## Findings

### CRITICAL

| ID | Finding | Notes |
|----|---------|--------|
| C1 | Release builds signed with **debug** keystore | `android/app/build.gradle.kts` — cannot publish to Play with debug signing |
| C2 | **No account deletion** API or in-app flow | Play requires account deletion for apps that create accounts |
| C3 | No hosted Privacy Policy URL wired for Play / Data Safety | App has accounts + email; Play requires a Privacy Policy |

### HIGH

| ID | Finding | Notes |
|----|---------|--------|
| H1 | `android:usesCleartextTraffic="true"` on main manifest | Allows HTTP in release; should be debug-only |
| H2 | Network errors may expose raw exception text | `ApiClient`: `Network error: $e` |
| H3 | No production upload keystore / Play App Signing plan | Manual business step |
| H4 | No web URL for account deletion requests | Play also expects a web deletion path for account-based apps |

### MEDIUM

| ID | Finding | Notes |
|----|---------|--------|
| M1 | README still documents emulator HTTP as default | Code default is already `https://www.lesisearch.com` |
| M2 | In-app Privacy / Terms links missing | Website has legal page; privacy draft needed |
| M3 | Guest alerts store email + filters without long-term deletion UX | Guest can stop via expire; no self-serve cancel in app |
| M4 | Firebase user may remain if only Django user is deleted | Deletion should re-auth and call Identity Toolkit `accounts:delete` when possible |
| M5 | `applicationId` TODO comment / first-release package finality | Changing later breaks updates |

### LOW

| ID | Finding | Notes |
|----|---------|--------|
| L1 | Limited Semantics / content descriptions | Accessibility |
| L2 | No crash reporting | Optional for v1 |
| L3 | Double-submit on some buttons partially guarded by `busy` | Mostly OK |
| L4 | WebView still imperfect on some listing sites | Improved; residual risk |

### OPTIONAL

| ID | Finding |
|----|---------|
| O1 | Obfuscation (`--obfuscate`) for Dart release |
| O2 | Split ABI APKs for smaller GitHub assets |
| O3 | In-app “deactivate alerts” for guests |

---

## Permissions

| Permission | Why |
|------------|-----|
| `INTERNET` | API + WebView + images |

No location, camera, mic, contacts, storage, or notification permissions declared.

---

## Third-party packages (client)

| Package | Role | Data notes |
|---------|------|------------|
| `http` | API | Sends auth + search payloads to LesiSearch backend |
| `flutter_secure_storage` | Token/email | Encrypted prefs on Android |
| `provider` | State | Local |
| `url_launcher` | External browser fallback | Opens https links |
| `cached_network_image` | Thumbnails | Loads remote image URLs; disk cache |
| `google_fonts` | Fonts | May fetch fonts from Google at runtime |
| `webview_flutter*` | Listings | Loads third-party pages; cookies in WebView |
| `intl` | Formatting | Local |

Server-side (not embedded in APK): Firebase Web API key, Groq, Brevo, OTEL — must never ship in the app.

---

## Data touched (inventory snapshot)

See `docs/release/data-safety-notes.md` for Play Console mapping.

---

## Initial verdict (pre-fix)

**🔴 BLOCKING ISSUE** — debug signing, missing account deletion, and missing Privacy Policy publication block a responsible first Play release.

GitHub Releases testing with a debug-signed APK is acceptable for closed testers only.
