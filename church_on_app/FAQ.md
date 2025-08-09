# FAQ — Church On App

## How do I create a new church (tenant)?
- Superadmin or designated admin creates a record in Firestore under `churches/{churchId}` with settings (name, icon, theme, active)
- Optionally map a custom domain (web) with `domains/{host}` → `churchId`

## How do members sign up and join a church?
- User signs up with email/password
- User selects a church (or uses an invite code) and a membership document is created
- Active church can be switched in Profile

## How does Zip Mode work?
- Admin toggles Zip Mode in Profile → church document updated
- The app blocks interactions and sensitive writes while Zip Mode is active

## How do payments work?
- Client initiates MoMo/Airtel/PayPal
- Server (Cloud Functions) finalizes status via webhook and writes fees to superadmin ledger
- Fee logic is 5% with K0.50 minimum

## How are live streams handled?
- Sermon has live fields (platform, URL, scheduled time)
- Support for external cameras via RTMP ingest (rtmpUrl, streamKey)
- Post-event, add recordingUrl for VOD

## How do reminders work?
- From the upcoming strip, tap Remind to trigger a local notification
- On mobile, we can enable scheduled notifications with timezone support

## How do I change support email/phone or domain later?
- Values are served via Remote Config (fallback to Firestore). Update remotely without an app update

## How do leaderboards work?
- Scores are saved per church, optionally to global (opt-in, anonymous allowed)
- Leaderboards aggregate scores with filters (all/week/month; per game)

## Where is the Bible reader?
- Bible & Resources is accessible from the Sermons screen
- We can integrate an online WebView reader, a public API, or offline packages (licensed)

## Emergency contacts and SOS
- Add contacts in Profile → Emergency Contacts
- Enable “Shake to SOS” in Profile to call/SMS contacts

## Ads and moderation
- Superadmin can seed ads in `superadmin_ads`
- Moderation available for announcements/news; leaderboards moderation can be added for superadmin