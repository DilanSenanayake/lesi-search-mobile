# Google Play submission checklist

## Before upload

- [ ] Create upload keystore; fill `android/key.properties` (never commit it)
- [ ] Build **AAB** with production API:  
  `flutter build appbundle --release --dart-define=API_BASE_URL=https://www.lesisearch.com`
- [ ] Confirm AAB is **not** debug-signed
- [ ] Backend `account/delete` deployed to production
- [ ] Privacy Policy live on HTTPS
- [ ] Terms live on HTTPS (or combined legal page)
- [ ] Account deletion instructions on web + in-app tested
- [ ] Package name final: `com.lesisearch.lesi_search_mobile`
- [ ] `versionCode` / `versionName` set for this release

## Play Console declarations

- [ ] App access / login credentials for reviewers (if any gated features)
- [ ] Ads declaration: **No ads** (unless you add ads later)
- [ ] Content rating questionnaire completed
- [ ] Target audience / age (not primarily children)
- [ ] News app? typically No
- [ ] Data Safety form completed using `data-safety-notes.md`
- [ ] Privacy Policy URL
- [ ] Account deletion URL / instructions
- [ ] Financial features: none
- [ ] Health: none
- [ ] Government apps: No
- [ ] AI-generated content disclosure (rankings are AI-assisted informational output — answer per current Play questions)
- [ ] Photo/video permissions: none declared

## Store listing

- [ ] App name, short & full description (see `store-listing-draft.md`)
- [ ] High-res icon, feature graphic, screenshots (phone)
- [ ] Contact email / website

## Testing track

- [ ] Internal testing track first
- [ ] Closed testing if required by your Play status
- [ ] Production rollout when stable

## Do not claim

- Guaranteed vehicle value / safety  
- “100% secure / private”  
- Official affiliation with ikman or riyasewana unless true
