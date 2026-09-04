# Privacy Policy (DRAFT)

**Effective date:** `[INSERT EFFECTIVE DATE]`  
**Service:** LesiSearch mobile application and related website services at `https://www.lesisearch.com`  
**Operator:** `[INSERT LEGAL ENTITY / OPERATOR NAME]`  
**Contact for privacy requests:** `[INSERT PRIVACY CONTACT EMAIL]`

> **Draft only.** This document describes practices inferred from the current LesiSearch mobile app and backend implementation. It is **not** legal advice and does **not** by itself make the operator GDPR/CCPA/or otherwise compliant. Have a qualified professional review before publishing.

---

## 1. Introduction

LesiSearch helps users search and compare used-vehicle listings from third-party websites (including ikman.lk and riyasewana.com) and optionally receive email alerts. This Privacy Policy explains what information we process when you use the LesiSearch mobile app.

## 2. Information We Collect

Depending on how you use the app, we may process:

### Account information (if you register or sign in)

- Email address  
- Password (processed by our authentication provider; we do not store your plaintext password in the mobile app)  
- First name and last name (optional profile fields)  
- Phone number (optional profile field, if you provide it)  
- Email verification status and one-time verification codes (hashed server-side)

### Alert preferences

- Vehicle search filters you choose (make, model, location, vehicle type, year range, price range)  
- Email address used for guest alert trials  
- Alert subscription status and expiry

### Search activity

- Search filters you submit to generate ranked results  
- Technical request metadata needed to operate the API (for example request identifiers)

### Device / app technical data

- IP address (processed by our servers and hosting infrastructure when you call the API)  
- Approximate device/browser characteristics when loading third-party listing pages in the in-app browser (WebView)

We do **not** intentionally collect contacts, precise GPS location, camera/microphone media, SMS, or advertising identifiers through the LesiSearch app permissions model (the app requests Internet access only).

## 3. Information Collected Automatically

- Server logs and security/rate-limit signals  
- Optional infrastructure metrics/observability signals configured on the backend (may include request timing and status attributes; not end-user advertising profiles)

## 4. How We Use Information

We use information to:

- Provide search and AI ranking features  
- Create and manage accounts  
- Send verification and alert emails  
- Secure the service (authentication, abuse prevention, rate limiting)  
- Improve reliability and diagnose failures  
- Comply with legal obligations when required

## 5. How We Share Information

We share information with processors that help us run the service, for example:

- Authentication provider (Firebase / Google Identity Toolkit) for sign-in  
- Email delivery provider (Brevo) for OTP and alert emails  
- Hosting / infrastructure providers for the website and API  
- AI inference provider used server-side to rank listings (search content/filters are processed to produce rankings; prompts are not stored in the mobile app)

We may also disclose information if required by law or to protect rights, safety, and security.

**Third-party listing sites:** When you open a listing, the in-app browser loads pages operated by third parties (such as ikman.lk or riyasewana.com). Those sites have their own privacy practices.

## 6. Third-Party Services

Non-exhaustive processors used by the backend/service (not embedded as advertising SDKs in the app):

- Firebase Authentication  
- Brevo (email)  
- AI ranking provider (server-side)  
- Optional metrics/observability backend if enabled by the operator

`google_fonts` may fetch font files from Google when the app loads fonts.

## 7. Data Storage

- Access tokens and the signed-in email are stored on-device using platform secure storage.  
- Account, profile, and alert data are stored on our backend databases.  
- Listing thumbnails may be cached on-device by the image library.

## 8. Data Retention

`[INSERT RETENTION PERIODS — e.g. accounts until deletion; guest alerts until expiry; server logs for X days]`

Bearer access tokens currently expire after a configured TTL (default on the order of days; see backend configuration).

## 9. Data Security

We use HTTPS for production API communication and store mobile session tokens in encrypted platform storage. No method of transmission or storage is 100% secure.

## 10. User Rights

Subject to applicable law, you may request access, correction, or deletion of personal data by contacting `[INSERT PRIVACY CONTACT EMAIL]` and/or using in-app account deletion (Profile → Delete account).

## 11. Account Deletion

Signed-in users can delete their account in the app (Profile → Delete account) by confirming with their password. This removes the LesiSearch account and related alert subscriptions associated with that account/email in our systems.

Web deletion / assistance request: `[INSERT WEB ACCOUNT-DELETION URL OR EMAIL PROCESS]`

## 12. Data Deletion Requests

Email `[INSERT PRIVACY CONTACT EMAIL]` with the subject “Data deletion request” and the email address used with LesiSearch.

## 13. Children’s Privacy

LesiSearch is not directed to children under `[INSERT AGE, e.g. 13 / 16]`. We do not knowingly collect personal information from children.

## 14. International Data Transfers

`[INSERT whether data is processed in Sri Lanka / other regions / cloud regions]`

## 15. Cookies / Tracking

The native app does not use advertising cookies. The in-app WebView may store cookies set by third-party listing websites.

## 16. Analytics

The current mobile app does **not** embed a third-party product-analytics SDK. Backend logs/metrics may still exist for operations.

## 17. Advertising

The current mobile app does **not** include an advertising SDK.

## 18. AI / LLM processing

Vehicle ranking is performed on our servers using an AI/LLM provider. Listing and filter-related content may be sent to that provider solely to generate rankings. Do not submit sensitive personal information in free-text fields beyond what the product asks for.

## 19. User-generated content

Profile names and optional phone numbers you enter are stored on your account. Alert filters you choose are stored for alert delivery.

## 20. Third-party links

Listings and search result links lead to third-party websites. We are not responsible for their content or privacy practices.

## 21. Changes to this Privacy Policy

We may update this policy. The effective date above will change when updates are published. Continued use after updates constitutes acceptance where permitted by law.

## 22. Contact Information

`[INSERT LEGAL ENTITY NAME]`  
`[INSERT POSTAL ADDRESS IF REQUIRED]`  
Email: `[INSERT PRIVACY CONTACT EMAIL]`

## 23. Effective Date

`[INSERT EFFECTIVE DATE]`
