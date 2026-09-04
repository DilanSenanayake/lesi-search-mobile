# Data Safety notes (Google Play Console)

Use these answers as a **starting draft**. Verify against production configuration before submitting.

## Data collected / shared

| Data type | Collected? | Shared? | Purpose | Optional? |
|-----------|------------|---------|---------|-----------|
| Email address | Yes (account / guest alerts) | Yes — email provider (Brevo); auth provider (Firebase) | Account, OTP, alerts | Required for account/alerts |
| Name | Yes (optional profile) | App backend | Profile | Optional |
| Phone number | Yes if user enters it | App backend | Profile | Optional |
| User IDs | Yes (internal user id / Firebase UID) | Auth provider | Account | Required for account |
| App interactions / search filters | Yes (API requests) | AI ranking provider (server-side) | App functionality | Required for search/alerts |
| Device or other IDs | Not by app SDKs; IP seen by servers | Hosting/infra | Security, networking | N/A (server logs) |
| Photos / files | No (only remote thumbnail URLs displayed) | No | — | — |
| Location | Approximate listing location text only if present in listings; app does not request GPS | Third-party listing pages via WebView | Show listing metadata | — |
| Financial info | No payments in app | No | — | — |
| Contacts / SMS / calendar | No | No | — | — |

## Encryption

- Data in transit: HTTPS to `https://www.lesisearch.com` in production builds  
- Data at rest on device: access token via encrypted shared preferences (`flutter_secure_storage`)

## Account deletion

- Users can delete accounts in-app  
- Provide web URL/email in Play Console (see `docs/legal/account-deletion.md`)

## Ads / analytics SDKs

- Ads: **No**  
- Independent product-analytics SDK in the app: **No**

## Privacy Policy URL

`[INSERT PUBLIC HTTPS URL TO HOSTED PRIVACY POLICY]`

## Data Safety form tips

- Declare email + personal info + app activity as collected.  
- Mark AI-related processing under app functionality if the form asks about data processed for app features.  
- Do not claim “no data collected.”
