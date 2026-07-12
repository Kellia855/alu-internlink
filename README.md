# InternLink

A Flutter + Firebase app connecting **students** with **startup** internship opportunities.
Both roles share one shell with four tabs (`Home · Discover · Applications · Profile`), but each tab renders different content depending on the signed-in user's role.

## Folder structure

```text
lib/
  models/            UserProfile, Opportunity, Application, AppNotification
  services/          AuthService (Firebase Auth + users/{uid}), FirestoreService
  providers/         UserProvider — live auth + profile state (ChangeNotifier)
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
```

## Features

- Role-aware app shell (student vs startup) with shared bottom navigation.
- Live user state via `UserProvider` (Firebase Auth + streaming `users/{uid}` profile).
- Student discovery: searchable list of **verified** opportunities.
- Student applications + status tracking.
- Startup dashboard: insights for posted opportunities and applicants.
- Bookmarks (Saved Opportunities) using a `savedOpportunityIds` array on `users/{uid}`.
- My Profile / Skills & Interests editor (updates limited fields enforced by Firestore rules).

## Tech stack

- **Flutter** (Dart)
- **Firebase Authentication** (email/password)
- **Cloud Firestore** (security rules + indexes)
- **Provider** pattern via `ChangeNotifier` (`UserProvider`)

## Getting started

1. **Create Firebase project** and enable **Auth (Email/Password)** + **Firestore**.
2. **Configure FlutterFire** so `firebase_options.dart` is generated/filled:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
3. **Deploy Firestore security rules and indexes**:
   ```bash
   npm install -g firebase-tools
   firebase login
   firebase use --add
   firebase deploy --only firestore:rules,firestore:indexes
   ```
4. **Run the app**:
   ```bash
   flutter run
   ```

## Data model (Firestore schema)

### `users/{uid}`
- `name, email, role` (`"student"|"startup"`)
- `skills: string[]`
- `verified: bool`
- `photoUrl: string|null`
- `createdAt: timestamp`
- `savedOpportunityIds: string[]` (bookmarks)

### `opportunities/{id}`
- `title, companyName, startupId`
- `verified: bool`
- `createdAt: timestamp`
- `imageUrl: string|null`
- `description` (plus optional listing metadata like category/skillsRequired/commitment)

### `applications/{id}`
- `opportunityId, studentId`
- `status: "pending"|"accepted"|"rejected"`
- `createdAt: timestamp`
- (optional denormalized fields written at submit time for faster list rendering)

### `notifications/{id}` (read-only from the client)
- `userId, title, body, read: bool`
- `createdAt: timestamp`

## Author

**Kellia KAMIKAZI**

---

Additional implementation notes are described below.

## Color palette

Every color in the app is sourced from `lib/theme/app_colors.dart` — never hard-coded inline — so the palette below stays consistent everywhere:


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

