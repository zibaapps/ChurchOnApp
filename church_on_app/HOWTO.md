# How-To — Church On App

## Create a Tenant (Church)
1. In Firestore, add a document under `churches/{churchId}` with:
   - name, iconUrl, theme seed color, active: true
2. (Optional) Map a web domain:
   - `domains/{host}` with `churchId`
3. Add tenant admins via `memberships` or Membership Admin screen

## Invite Members
- Share an invite code or direct users to select the church in Onboarding
- Users sign up with email/password and select the church

## Set Up Live Streaming
- Create a sermon (Admin) and set:
  - isLive: true, livePlatform, liveUrl (or rtmpUrl + streamKey for external cameras)
  - After live, set recordingUrl to VOD

## Zip Mode
- Admin → Profile → Zip Mode: toggle to restrict access during threats
- Zip Mode blocks major app interactions and sensitive writes

## Payments Webhooks (MTN/Airtel)
1. In Cloud Functions:
   - Set secrets: `firebase functions:config:set payments.mtn_secret="..." payments.airtel_secret="..."`
   - Deploy: `cd functions && npm install && npm run deploy`
2. Configure provider callbacks to Functions URLs
3. Verify header mapping for signature validation

## Remote Config
- Update domain/support values in Firebase Remote Config
- App fetches and applies without update

## Logos, App Icon & Splash
1. Provide a high-res square logo (PNG/SVG)
2. Place at `assets/images/logo.png` (or share the file and path)
3. I will wire:
   - App icon (Android/iOS assets)
   - Splash screen with `flutter_native_splash` using your logo and brand color

## Build & Deploy
- Web: `flutter build web --release`
- Android: `flutter build apk --release`
- iOS: `flutter build ios --release` (on macOS)

## Support
- Domain: churchapp.cloud
- Email: support@churchapp.cloud
- Phone: +260955202036