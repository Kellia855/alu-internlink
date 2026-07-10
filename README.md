# InternLink

A Flutter + Firebase app connecting **students** with **startup** internship
opportunities. Both roles share one shell with four tabs
(`Home · Discover · Applications · Profile`), but each tab renders
completely different content depending on the signed-in user's role.

## Color palette

Every color in the app is sourced from `lib/theme/app_colors.dart` — never
hard-coded inline — so the palette below stays consistent everywhere:

| Color | Hex | Used for |
|---|---|---|
| Maroon | `#8F0F07` | Primary buttons, CTAs |
| Navy | `#000767` | App bar, headers, gradients |
| Rust | `#B22B1D` | Alerts, reject actions, errors |
| White | `#FFFFFF` | Backgrounds, surfaces |
| Blue | `#27308A` | Links, tags, secondary accents |
| Charcoal | `#1B1C1C` | Primary text |
| Grey | `#A8A6A6` | Secondary text, icons |
| Light grey | `#C8C6C6` | Borders, dividers, chip backgrounds |

## Design notes: matching the reference UI

The screens (hero card, category row, filter pills, applications list,
profile menu) are structured to closely follow a reference mobile design,
restyled entirely into the palette above — the purple/pink gradient in
the reference becomes a maroon → rust ("dark red") gradient, and accents
that were purple become navy or maroon depending on context.

A few pieces of that reference UI go slightly beyond the original
feature spec, so here's how each is wired up for real rather than left
as decoration:

- **Bookmark icons** (on cards and the detail screen) toggle a
  `savedOpportunityIds: string[]` array field on the student's own
  `users/{uid}` document via `arrayUnion`/`arrayRemove` — no new
  collection needed, and it's already covered by the existing
  owner-only `users/{uid}` security rule.
- **Saved Opportunities** (Profile menu) reads that array back with a
  batched `whereIn` fetch.
- **Share icon** (opportunity detail) uses `share_plus` to open the
  native share sheet.
- **Notifications** (Profile menu) streams the existing `notifications`
  collection — read-only from the client, exactly as `firestore.rules`
  already specified; there's just no in-app screen wired to it, until
  now. Nothing currently writes to this collection — that's expected to
  happen from trusted backend logic (e.g. a Cloud Function) using the
  Admin SDK, which bypasses these rules entirely.
- **My Profile / Skills & Interests** (Profile menu) is a real editor
  that writes `name`/`skills` back to Firestore via
  `AuthService.updateProfile`, which the rules restrict to those two
  fields — `role` and `verified` stay immutable from the client.
- **Help & Support** is static content (FAQ + contact info) — no
  backend needed.

## Project structure

```
lib/
  models/            UserProfile, Opportunity, Application, AppNotification
  services/          AuthService (Firebase Auth + users/{uid}), FirestoreService
  providers/          UserProvider — live auth + profile state (ChangeNotifier)
  routes/            AppRoutes — shared route/tab identifiers
  theme/             AppColors, AppTheme
  widgets/           Reusable UI: cards, search field, status badges, etc.
  screens/
    auth/            LoginScreen, SignupScreen, AuthGate (root router)
    student/         Home, Discover, Applications
    startup/         Home (dashboard), Post Opportunity, Applicants
    profile/         Shared, role-aware ProfileScreen
    main_shell.dart  Bottom-nav shell; swaps in role-specific screens
  main.dart
  firebase_options.dart   placeholder — see setup step 3

firestore.rules
firestore.indexes.json
firebase.json
```

## How role-based routing works

1. `main.dart` wraps the app in a `ChangeNotifierProvider<UserProvider>` and
   sets `AuthGate` as `home`.
2. `AuthGate` watches `UserProvider.status`:
   - **unknown** → `SplashScreen` (resolving Firebase Auth)
   - **signedOut** → `LoginScreen` / `SignupScreen` (toggled locally, no
     navigator push — instant switch back after logout)
   - **signedIn** → `MainShell`
3. `UserProvider` listens to `FirebaseAuth.authStateChanges()`, and once a
   user is signed in, it *also* subscribes live to their `users/{uid}`
   document. That means role, `verified` status, and `skills` update the UI
   in real time — no manual refresh needed.
4. `MainShell` reads `profile.role` and picks one of two screen lists for
   the same four bottom-nav slots (`AppRoutes.home/discover/applications/profile`):

   | Tab | Student sees | Startup sees |
   |---|---|---|
   | Home | Featured + recommended opportunities | Dashboard: stats, recent applicants, posted opportunities |
   | Discover | Searchable list of verified opportunities | Post Opportunity form |
   | Applications | Their own applications + statuses | Applicants across all their postings |
   | Profile | Skills, stats, applications | Company info, posted opportunities |

## Setup

### 1. Create the Flutter project shell

This deliverable contains all `lib/` Dart code plus root-level Firebase
config, but not the native `android/`/`ios/` scaffolding (that's generated
by the Flutter CLI, which isn't available in the environment this was
written in). To get a runnable project:

```bash
flutter create --org com.internlink internlink_app
cd internlink_app
# Replace the generated lib/ and pubspec.yaml with the ones from this delivery
rm -rf lib
cp -r /path/to/this/delivery/lib .
cp /path/to/this/delivery/pubspec.yaml .
cp /path/to/this/delivery/firebase.json .
cp /path/to/this/delivery/firestore.rules .
cp /path/to/this/delivery/firestore.indexes.json .
flutter pub get
```

### 2. Create a Firebase project

In the [Firebase console](https://console.firebase.google.com):
- Create a project.
- Enable **Authentication → Email/Password**.
- Enable **Firestore Database** (start in production mode — the rules
  in `firestore.rules` handle access control).

### 3. Wire up Firebase config

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This overwrites the placeholder `lib/firebase_options.dart` with your real
project's keys and registers your Android/iOS/web apps automatically.

### 4. Deploy Firestore rules & indexes

```bash
npm install -g firebase-tools
firebase login
firebase use --add          # select your project
firebase deploy --only firestore:rules,firestore:indexes
```

### 5. Run

```bash
flutter run
```

## Firestore schema

**`users/{uid}`**
`name, email, role ("student"|"startup"), skills: string[], verified: bool,
photoUrl: string|null, createdAt: timestamp` (plus `savedOpportunityIds:
string[]`, used by the bookmark feature — see design notes above)

**`opportunities/{id}`**
`title, companyName, startupId, verified: bool, createdAt: timestamp,
imageUrl: string|null, description` (plus optional `location`,
`skillsRequired`, `category`, `commitment` used for richer cards)

**`applications/{id}`**
`opportunityId, studentId, status ("pending"|"accepted"|"rejected"),
createdAt: timestamp` (plus denormalized `startupId`, `opportunityTitle`,
`companyName`, `studentName` written at submit time for fast list rendering
and to support the security rules below without extra reads)

**`notifications/{id}`** *(read-only from the client)*
`userId, title, body, read: bool, createdAt: timestamp`

## Security rules summary (`firestore.rules`)

- `users/{uid}` — read/write only your own document; role and `verified`
  are immutable after creation (can't self-verify or change role).
- `opportunities` — any signed-in user can read, **except** students, who
  can only read documents where `verified == true`. Only startups can
  create, always starting `verified: false`, under their own `startupId`.
- `applications` — students create under their own `studentId`, only
  against opportunities that are already verified; both the applying
  student and the owning startup can read; only the startup can update
  `status`.
- `notifications` — read-only, scoped to `userId == request.auth.uid`.

## Known simplifications

- Startup `verified` flips from `false → true` only via the Firestore
  console or a backend admin tool — there's intentionally no client path
  to self-verify, matching the review-gated flow implied by the spec.
- Search on the Discover tab filters client-side over the already-fetched
  verified-opportunities stream (title/company/skills). For a larger
  catalog you'd want a dedicated search service (e.g. Algolia) instead.
