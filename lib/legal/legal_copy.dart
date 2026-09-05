/// In-app Terms & Privacy copy for LesiSearch (personal project — no company).
///
/// Not legal advice. Host the same text publicly over HTTPS for Play Console.
class LegalCopy {
  LegalCopy._();

  static const String operatorName = 'the independent developer of LesiSearch';
  static const String contactEmail = 'diladws@gmail.com';
  static const String jurisdiction = 'Sri Lanka';

  static const String accountDeletionWebUrl =
      'https://www.lesisearch.com/legal/#account-deletion';

  static const String lastUpdated = '2026-09-05';

  /// Keep in sync with pubspec.yaml `version:` (name before `+`).
  static const String appVersionName = '1.0.0';

  /// Keep in sync with pubspec.yaml build number (after `+`); bump every Play upload.
  static const int appVersionCode = 1;

  static String get versionLabel =>
      'App version $appVersionName ($appVersionCode)';

  static String get termsMarkdown => '''
# Terms & Conditions

**Last updated:** $lastUpdated  
**Service:** LesiSearch (personal project)  
**Contact:** $contactEmail

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

LesiSearch branding, app UI, and original service materials are owned by $operatorName. Third-party listing content remains owned by those third parties.

## 5. AI Rankings Disclaimer

Rankings and summaries are automated and may be incomplete, outdated, or incorrect. They are informational only and are **not** professional advice.

## 6. Limitation of Liability

To the maximum extent permitted by law, $operatorName will not be liable for indirect, incidental, special, consequential, or punitive damages arising from use of the service. LesiSearch is provided "as is" without warranties of any kind.

## 7. Termination

Access may be suspended or terminated for violations or legal risk. You may delete your account in the app (**Profile → Delete account**) or via $accountDeletionWebUrl.

## 8. Governing Law

These Terms are governed by the laws of $jurisdiction, except where mandatory consumer protections apply.

## 9. Changes to Terms

These Terms may be updated from time to time. The **Last updated** date above will change when revisions are published. Continued use after changes constitutes acceptance where permitted by law.

## 10. Contact

Email: $contactEmail  
Website: https://www.lesisearch.com
''';

  static String get privacyMarkdown => '''
# Privacy Policy

**Last updated:** $lastUpdated  
**Service:** LesiSearch (personal project)  
**Privacy contact:** $contactEmail

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

**In this mobile app binary:**

- HTTP API client (`http`) to LesiSearch backend
- Secure token storage (`flutter_secure_storage`)
- Image caching (`cached_network_image`)
- Font loading (`google_fonts` — may fetch fonts from Google)
- In-app browser (`webview_flutter`) for third-party listings
- Link opener (`url_launcher`)

**No advertising SDK, Crashlytics, or product-analytics SDK is embedded in the app.**

**Backend / processors (server-side):**

- Firebase Authentication / Google Identity Toolkit (sign-in)
- Email delivery (Brevo) for OTP and alerts
- Hosting / infrastructure for API and website
- AI ranking provider (server-side) for listing rankings

When you open a listing, third-party sites (e.g. ikman.lk, riyasewana.com) apply their own privacy practices.

## 4. Data Retention

- Account and profile data are kept until you delete your account
- Guest alert subscriptions are kept until they expire or are removed
- Server logs may be retained for a limited period for security and operations
- Access tokens expire after a configured TTL on the backend

You can delete your account in-app at any time.

## 5. Your Rights

You may request access, correction, or deletion by emailing $contactEmail, and/or using **Profile → Delete account**.

Web deletion instructions: $accountDeletionWebUrl

## 6. Children's Privacy

LesiSearch is not directed to children under 13. We do not knowingly collect personal information from children. If you believe a child has provided personal data, contact $contactEmail and it will be removed.

## 7. Where Data Is Processed

Data is processed to operate LesiSearch for users in Sri Lanka, using cloud hosting and the third-party processors listed above (which may process data in other regions).

## 8. Changes

This policy may be updated. The **Last updated** date above will change when updates are published.

## 9. Contact

Email: $contactEmail  
Website: https://www.lesisearch.com
''';
}
