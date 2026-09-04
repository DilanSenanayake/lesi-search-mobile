/// Placeholder legal copy for in-app display.
///
/// **Not legal advice.** Fill every TODO below before publishing to Play Store,
/// then have a lawyer review. Host the same text publicly over HTTPS for
/// Play Console's Privacy Policy URL.
class LegalCopy {
  LegalCopy._();

  // TODO(legal): Replace with your legal entity / operator name.
  static const String companyName = '[INSERT COMPANY / OPERATOR NAME]';

  // TODO(legal): Replace with a monitored support / privacy email.
  static const String contactEmail = '[INSERT CONTACT EMAIL]';

  // TODO(legal): Replace with governing law / venue (do not invent).
  static const String jurisdiction = '[INSERT JURISDICTION]';

  // TODO(legal): Confirm this public HTTPS deletion URL is live before Play submit.
  static const String accountDeletionWebUrl =
      'https://www.lesisearch.com/legal/#account-deletion';

  // TODO(legal): Bump when you publish revised legal text (keep in sync with website).
  static const String lastUpdated = '2026-09-05';

  // TODO(release): Keep in sync with pubspec.yaml `version:` (name before `+`).
  static const String appVersionName = '1.0.0';

  // TODO(release): Keep in sync with pubspec.yaml build number (after `+`); bump every Play upload.
  static const int appVersionCode = 1;

  static String get versionLabel =>
      'App version $appVersionName ($appVersionCode)';

  static String get termsMarkdown => '''
# Terms & Conditions

**Last updated:** $lastUpdated  
**Operator:** $companyName  
**Contact:** $contactEmail

> Draft placeholder for Play Store readiness. Replace all `[INSERT …]` markers and obtain legal review before relying on this text.

## 1. Acceptance of Terms

By downloading, accessing, or using LesiSearch, you agree to these Terms and our Privacy Policy. If you do not agree, do not use the service.

## 2. User Responsibilities

- Provide accurate account information and keep credentials confidential.
- Verify vehicle details with sellers and listing sites before any purchase.
- Use the app only for lawful personal research of publicly listed vehicles.

## 3. Prohibited Use

You must not:

- Abuse, scrape, or overload the service beyond normal app use
- Bypass authentication, rate limits, or security controls
- Access other users' accounts or data
- Use the service for fraud, spam, or unlawful surveillance
- Misrepresent AI rankings as guarantees of value, safety, or legality

## 4. Intellectual Property

LesiSearch branding, app UI, and original service materials are owned by $companyName or its licensors. Third-party listing content remains owned by those third parties.

## 5. AI Rankings Disclaimer

Rankings and summaries are automated and may be incomplete, outdated, or incorrect. They are informational only and are **not** professional advice.

## 6. Limitation of Liability

TO THE MAXIMUM EXTENT PERMITTED BY LAW, $companyName WILL NOT BE LIABLE FOR INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES ARISING FROM USE OF THE SERVICE.

*[INSERT: liability cap / mandatory consumer-law wording if counsel advises]*

## 7. Termination

We may suspend or terminate access for violations or legal risk. You may delete your account in the app (**Profile → Delete account**) or via our web instructions at $accountDeletionWebUrl.

## 8. Governing Law

These Terms are governed by the laws of $jurisdiction, except where mandatory consumer protections apply.

*[INSERT: dispute venue / arbitration process with counsel]*

## 9. Changes to Terms

We may update these Terms. The **Last updated** date above will change when we publish revisions. Continued use after changes constitutes acceptance where permitted by law.

## 10. Contact

**$companyName**  
Email: $contactEmail

*[INSERT postal address if required in your jurisdiction]*
''';

  static String get privacyMarkdown => '''
# Privacy Policy

**Last updated:** $lastUpdated  
**Operator:** $companyName  
**Privacy contact:** $contactEmail

> Draft placeholder describing practices inferred from the current LesiSearch app and backend. Replace all `[INSERT …]` markers and obtain professional review before publishing.

## 1. What Data We Collect

Depending on how you use the app, we may process:

- **Account:** email, password (via auth provider — not stored in plaintext in the app), optional first/last name, optional phone number
- **Alerts:** search filters (make, model, location, type, year/price range), guest trial email
- **Search:** filters you submit for AI ranking
- **Technical:** IP address and request metadata on our servers; WebView may expose typical browser characteristics to third-party listing sites

We do **not** request contacts, precise GPS, camera, microphone, SMS, or advertising ID permissions in this app.

## 2. How We Use Data

- Provide search and AI ranking
- Create and manage accounts; send OTP / alert emails
- Secure the service (auth, abuse prevention, rate limiting)
- Operate and improve reliability
- Comply with legal obligations when required

## 3. Third-Party Services / SDKs

**In this mobile app binary (current codebase):**

- HTTP API client (`http`) to LesiSearch backend
- Secure token storage (`flutter_secure_storage`)
- Image caching (`cached_network_image`)
- Font loading (`google_fonts` — may fetch fonts from Google)
- In-app browser (`webview_flutter`) for third-party listings
- Link opener (`url_launcher`)

**No advertising SDK, Crashlytics, or product-analytics SDK is embedded in the app today.**

**Backend / processors (server-side, not ad SDKs in the app):**

- Firebase Authentication / Google Identity Toolkit (sign-in)
- Email delivery (Brevo) for OTP and alerts
- Hosting / infrastructure for API and website
- AI ranking provider (server-side) for listing rankings

When you open a listing, third-party sites (e.g. ikman.lk, riyasewana.com) apply their own privacy practices.

## 4. Data Retention

*[INSERT retention periods — e.g. accounts until deletion; guest alerts until expiry; server logs for X days]*

Access tokens expire after a configured TTL on the backend. You can delete your account in-app at any time.

## 5. Your Rights

Subject to applicable law, you may request access, correction, or deletion by emailing $contactEmail, and/or using **Profile → Delete account**.

Web deletion instructions: $accountDeletionWebUrl

## 6. Children's Privacy

LesiSearch is not directed to children under *[INSERT AGE, e.g. 13]*. We do not knowingly collect personal information from children.

*[INSERT: confirm age gate for COPPA / local law. This app is not designed for children.]*

## 7. International Transfers

*[INSERT where data is processed — Sri Lanka / cloud regions / other]*

## 8. Changes

We may update this policy. The **Last updated** date above will change when updates are published.

## 9. Contact

**$companyName**  
Email: $contactEmail

*[INSERT postal address if required]*
''';
}
