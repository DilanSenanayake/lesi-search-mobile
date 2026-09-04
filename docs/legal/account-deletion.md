# Account deletion

## In-app (implemented)

**Path:** Profile → **Delete account**  
**API:** `POST /api/mobile/v1/account/delete/`  
**Body:** `{ "password": "<account password>", "confirm": "DELETE" }`  
**Auth:** Bearer access token required

### What is deleted

- Django user account  
- User profile (name, phone, verification fields, Firebase UID link)  
- Alert subscriptions tied to the user and matching email  
- Pending guest alert OTP verification rows for that email (if any)  
- Firebase Auth user (best effort via password re-auth + Identity Toolkit `accounts:delete`)  
- Local app session (secure storage token/email cleared after success)

### What may be retained

- Server/application logs and security logs for a limited operational period (`[INSERT RETENTION]`)  
- Email delivery logs held by the email provider under their retention (`[CONFIRM WITH BREVO SETTINGS]`)  
- Aggregated metrics without direct identifiers, if enabled  

### Why retained

Security, abuse prevention, legal compliance, and operational diagnostics — only as long as needed (`[INSERT POLICY]`).

## Web / email request (required for Play)

Play Console expects a way to request deletion without only relying on the app binary.

**Publish one of:**

1. A public URL (recommended): e.g. `https://www.lesisearch.com/legal/` section “Delete my account” with instructions, **or**  
2. A monitored email: `[INSERT DELETION-REQUEST EMAIL]`

Suggested web copy:

> To delete your LesiSearch account, open the mobile app → Profile → Delete account, or email `[INSERT EMAIL]` from the address on your account with subject “Delete my LesiSearch account”.

## Operator checklist

- [ ] Deploy backend with `account/delete` endpoint to production  
- [ ] Publish Privacy Policy + deletion instructions on the website  
- [ ] Add the same URL in Play Console → App content → Account deletion  
- [ ] Test deletion end-to-end against production Firebase + DB
