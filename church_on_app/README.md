# Church On App

A multi-tenant church platform built with Flutter + Firebase featuring sermons, events, chat, giving (MoMo/Airtel/PayPal), interchurch activities, programs, AR, invitations, and more. Web and mobile supported.

- Domain (current): churchapp.cloud
- Support: support@churchapp.cloud
- Phone: +260955202036

## Features
- Multi-tenancy: memberships, active church selection, tenant theming (name/icon/color)
- Auth: Firebase Auth (email/password), role-based (guest/user/admin/superAdmin)
- Content: sermons (video/audio/live), announcements, news, reports
- Events: RSVP, QR attendance (scaffold)
- Chat: threads, messages, reactions
- Interchurch: activities and year programs, invites and acceptance
- Giving: MTN MoMo, Airtel Money, PayPal (providers scaffold + callbacks), fee logic 5% or K0.50 minimum
- Finance: contribution pools, tithes (user and admin dashboards), payments history, CSV export
- Games: Bible Quiz, Memory Match, Verse Scramble; live leaderboards per church and global (opt-in, anonymous optional)
- Notifications: FCM scaffold
- Offline: Firestore persistence
- UI/UX: Material 3, Lottie animations, hero transitions, dynamic theming

## Getting Started
1. Flutter SDK installed
2. Firebase project configured; add `firebase_options.dart`, Android `google-services.json`, iOS plist
3. `flutter pub get`
4. Run:
   - Mobile: `flutter run`
   - Web: `flutter run -d chrome`
5. Build:
   - Web: `flutter build web --release`
   - Android APK: `flutter build apk --release`

## Cloud Functions
- `functions/` contains HTTP callbacks for MTN and Airtel to finalize payments and write fees to superadmin ledger.
- Deploy: `cd functions && npm install && firebase login && firebase use <project-id> && npm run deploy`

## Domains
For now, use `churchapp.cloud` for landing, deep links, and communications. These can be updated later.

## Privacy summary
We store essential profile and church membership data, content, payments metadata (not full card/wallet data), and optional game scores. For global leaderboards, players can opt in and choose to remain anonymous. See PRIVACY.md for full details.

## Support
- Email: support@churchapp.cloud
- Phone: +260955202036

## License
Proprietary. All rights reserved.
