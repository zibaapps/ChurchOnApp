# Church On App — Technical Blueprint

Domain: churchapp.cloud | Support: support@churchapp.cloud | Phone: +260955202036

## Architecture
- Flutter (mobile/web), Riverpod, GoRouter, Material 3
- Firebase: Auth, Firestore, Storage, Messaging, Crashlytics; Cloud Functions for payment callbacks
- Multi-tenant data: `churches/{churchId}/...` with per-tenant subcollections; public/global collections for domain mapping and global leaderboards
- Web-specific helpers via conditional imports

## Modules
- Auth: Email/Password, user profile, role (guest/user/admin/superAdmin)
- Tenancy: memberships, active church selection, theme (name/icon/color)
- Content: sermons (media + live), announcements, news, reports
- Events: RSVP, future QR attendance
- Interchurch: activities, invites, acceptance, year program
- Giving/Finance: payments (MTN/Airtel/PayPal), fees service, contribution pools, tithes (user/admin), payments history, CSV export
- Messaging: chat threads/messages, reactions
- Notifications: FCM (scaffold)
- AR: QR scan, web model viewer
- Games: quiz, memory match, verse scramble, leaderboards (church/global, opt-in, anonymous option)

## Data model (key collections)
- users/{uid}
- churches/{churchId}
  - sermons/{sid}
  - events/{eid}
  - announcements/{aid}
  - news/{nid}
  - reports/{rid}
  - payments/{pid}
  - tithes/{tid}
  - contribution_pools/{cid}
  - games_scores/{scoreId}
- interchurch_activities/{activityId}
- year_program_entries/{entryId}
- superadmin_ledger/{doc}
- superadmin_ads/{adId}
- global_games_scores/{scoreId}
- domains/{host}

## Security (high level)
- Role/membership checks for tenant writes
- `churchActive(churchId)` gates writes for unpaid tenants
- Tithes readable by owner or admins; payments readable to members
- Ads/ledger/global scores readable

## Payments
- Client: initiate (MTN/Airtel/PayPal), show status, display fee (5% min K0.50)
- Server: Functions callbacks finalize status and write fees to superadmin_ledger
- Next: add webhook signature validation and idempotency guards

## Leaderboards
- Per-church and global (opt-in)
- Anonymity toggle for global submissions
- Timeframes: all/week/month filters
- Next: per-game tabs and anti-abuse signals (rate limiting, outlier detection)

## UX
- Lottie animations for success and onboarding
- Hero animations for sermons
- Tenant theming applied across splash/app bar
- Future: more transitions and micro-interactions

## Rollout & Ops
- Environments: dev/staging/prod (Firebase projects)
- CI: Flutter analyze/test/build; deploy Functions
- Monitoring: Crashlytics, Firestore/Functions logs
- Backups: Firestore export (scheduled)

## Next roadmap
- Wire MTN/Airtel live with sandbox creds
- Firebase Dynamic Links for invites
- Admin editors for interchurch/year programs
- Attendance QR pass & scan
- Pastor analytics dashboards

## Appendices
- Privacy: see PRIVACY.md
- README: setup and support