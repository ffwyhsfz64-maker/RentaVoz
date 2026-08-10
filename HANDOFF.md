# RentaVoz — Project Handoff Document

> Generated: 2026-08-09  
> Purpose: Handoff to a new AI development agent (e.g., ChatGPT Codex) with full context to continue development without loss of work context.

---

## 1. Project Overview

**RentaVoz** ("Rental Voice") is a Flutter mobile application for **anonymous rental property reviews in Mexico**, initially targeting the **Querétaro** metropolitan area.

### Core Purpose
Allow renters to share honest, first-hand reviews of landlords and rental properties — including conditions, contract terms, deposit return history, and safety ratings — so future tenants can make better-informed decisions.

### Primary Users & Use Scenarios
- **Tenants** who have completed a rental and want to warn or recommend others
- **Prospective renters** searching for honest feedback about a neighborhood or specific address
- **Expatriates and foreigners** (Korean, Japanese, Chinese, English speakers) moving to Mexico who need reviews in their own language

### Current Development Stage
**Late MVP / Feature-complete alpha.** Core user flows are fully implemented: authentication, onboarding, writing reviews, viewing the feed and map, translating reviews, and verifying residency with a utility bill (comprobante). The app is not yet published to the App Store or Play Store.

---

## 2. Tech Stack

All information verified from actual code and config files.

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.x (Dart SDK `^3.12.2`) |
| **Mobile Targets** | iOS (primary), Android |
| **Database** | Cloud Firestore (NoSQL, real-time) |
| **Authentication** | Firebase Auth (email/password + Google Sign-In) |
| **File Storage** | Firebase Storage |
| **Maps** | Google Maps Flutter (`google_maps_flutter ^2.10.0`) |
| **Address Search** | Google Places API (REST, Places Autocomplete + Place Details) |
| **Document OCR** | Google Cloud Vision API (TEXT_DETECTION, for comprobante validation) |
| **Translation** | Google Cloud Translation API v2 |
| **Geolocation** | `geolocator ^13.0.2` + `geocoding ^3.0.0` |
| **Image Handling** | `image_picker ^1.1.2`, `file_picker ^8.1.7`, `cached_network_image ^3.4.1` |
| **Ratings UI** | `flutter_rating_bar ^4.0.1` (imported but star ratings are custom icons) |
| **Localization** | Flutter `flutter_localizations` + ARB files via `l10n.yaml` |
| **Persistence (local)** | `shared_preferences ^2.3.5` (locale setting, onboarding state) |
| **UUID generation** | `uuid ^4.5.1` |
| **App Icon** | `flutter_launcher_icons ^0.14.3` |
| **Splash Screen** | `flutter_native_splash ^2.4.5` |
| **Package Manager** | `pub` (Flutter's built-in) |
| **Backend Server** | **None** — all data operations go through Firebase SDKs directly |
| **Hosting / Deployment** | Not yet deployed; Firebase project ID: `rentavoz` |

---

## 3. Project Architecture

### Directory Tree

```
RentaVoz/
├── lib/
│   ├── main.dart                    # App entry point, locale management
│   ├── firebase_options.dart        # Auto-generated Firebase config (do NOT edit manually)
│   ├── config/
│   │   └── api_keys.dart            # ⚠️ SECURITY ISSUE — hardcoded Google API key
│   ├── models/
│   │   └── review.dart              # Review data model + Firestore serialization
│   ├── screens/
│   │   ├── auth_gate.dart           # Auth router (unauthenticated → login, authenticated → onboarding/home)
│   │   ├── auth/
│   │   │   ├── login_screen.dart    # Email + Google Sign-In
│   │   │   └── register_screen.dart # Email registration
│   │   ├── onboarding_screen.dart   # 5-page first-time intro (shown once per install)
│   │   ├── home_screen.dart         # Bottom nav shell (3 tabs + FAB)
│   │   ├── feed_screen.dart         # Review list with search, filter, sort
│   │   ├── map_screen.dart          # Google Maps with color-coded review pins
│   │   ├── review_detail_screen.dart # Full review view + translation
│   │   ├── write_review_screen.dart  # Create / edit review form
│   │   ├── my_reviews_screen.dart   # User's own reviews (edit / delete)
│   │   └── settings_screen.dart     # Language selection
│   ├── services/
│   │   ├── auth_service.dart        # Firebase Auth wrapper (static methods)
│   │   ├── review_service.dart      # Firestore CRUD for reviews
│   │   ├── storage_service.dart     # Firebase Storage upload (photos, comprobante)
│   │   ├── translation_service.dart # Google Translate API wrapper
│   │   └── vision_service.dart      # Google Vision API — comprobante date validation
│   ├── widgets/
│   │   ├── address_field.dart       # Places Autocomplete + GPS location widget
│   │   └── review_card.dart         # Review list card with badges
│   ├── data/
│   │   └── dummy_reviews.dart       # 4 hardcoded demo reviews (shown when Firestore is empty)
│   └── l10n/
│       ├── app_localizations.dart   # Auto-generated localizations class (alias: S)
│       ├── app_localizations_*.dart # Per-locale generated files
│       ├── app_es.arb               # Spanish strings (default / source language)
│       ├── app_en.arb               # English
│       ├── app_ko.arb               # Korean
│       ├── app_ja.arb               # Japanese
│       └── app_zh.arb               # Chinese (Simplified)
├── ios/                             # iOS platform code (Swift + Xcode project)
├── android/                         # Android platform code (Kotlin)
├── assets/
│   └── icon/
│       ├── app_icon.png             # App icon source (used by flutter_launcher_icons)
│       └── splash_logo.png          # Splash screen logo
├── pubspec.yaml                     # Dependency manifest
├── l10n.yaml                        # Localization config (ARB → dart generation)
├── firebase.json                    # Firebase CLI project config
└── analysis_options.yaml            # Dart linter config
```

### Architecture Pattern
- **No backend server.** The Flutter app talks directly to Firebase (Firestore, Auth, Storage) and Google Cloud APIs.
- **Service layer** (`lib/services/`) provides static-method wrappers; no dependency injection or state management library is used.
- **State management**: plain `StatefulWidget` + `setState`. No Provider, Riverpod, Bloc, or GetX.
- **Real-time data**: `StreamBuilder` on Firestore streams for feed and per-user reviews.

---

## 4. Frontend — Screen-by-Screen

### AuthGate (`screens/auth_gate.dart`)
- **Purpose**: Router that listens to `FirebaseAuth.authStateChanges()` stream and routes to LoginScreen (unauthenticated) or OnboardingGate (authenticated).
- **State**: `onboarding_done` boolean in `SharedPreferences`.
- **Implementation status**: Complete.

### LoginScreen (`screens/auth/login_screen.dart`)
- **Purpose**: Email/password login and Google Sign-In.
- **Features**: Email field, password field (toggle visibility), forgot password dialog (Firebase email reset), Google OAuth button.
- **iOS keychain workaround**: Auto-retries once on `keychain-error` code with 500ms delay.
- **Missing asset**: References `assets/google_logo.png` which does not exist in the repo. Falls back to `Icons.g_mobiledata`.
- **Partial i18n issue**: Some error/debug strings are in Korean instead of the localization system (e.g., `'네트워크 오류...'`, `'다시 시도해주세요.'`).
- **Implementation status**: Functionally complete; minor i18n gaps.

### RegisterScreen (`screens/auth/register_screen.dart`)
- **Purpose**: Email + password account creation with confirmation field.
- **Implementation status**: Complete.

### OnboardingScreen (`screens/onboarding_screen.dart`)
- **Purpose**: 5-page swipeable intro shown only on first launch (`onboarding_done` not set).
- **Pages**: (1) App intro, (2) Write reviews, (3) Verified badge, (4) Map, (5) Edit reviews.
- **Implementation status**: Complete.

### HomeScreen (`screens/home_screen.dart`)
- **Purpose**: Bottom NavigationBar shell with 3 tabs (Feed, Map, My Reviews) and a FAB for writing a new review.
- **Implementation status**: Complete.

### FeedScreen (`screens/feed_screen.dart`)
- **Purpose**: Shows all reviews as a scrollable list. Falls back to `dummyReviews` when Firestore returns empty.
- **Features**: SearchBar (address text filter), filter chips (All / House / Room), sort bottom sheet (Newest / Highest rating / Lowest rating).
- **Data source**: `ReviewService.feedStream()` — live Firestore stream, ordered by `createdAt` desc, limit 50.
- **Implementation status**: Complete.

### MapScreen (`screens/map_screen.dart`)
- **Purpose**: Google Maps showing color-coded pins for all reviews (green ≥4, yellow ≥3, red <3).
- **Default center**: Querétaro, Mexico (`LatLng(20.5888, -100.3899)`, hardcoded constant `_queretaro`).
- **Features**: Tap pin → review card at bottom, custom zoom buttons, legend card, review count badge.
- **"My location" button**: Centers to hardcoded `_queretaro` point, NOT the user's actual GPS location.
- **Data source**: Same `ReviewService.feedStream()`.
- **Implementation status**: Functionally complete; real GPS centering not implemented.

### ReviewDetailScreen (`screens/review_detail_screen.dart`)
- **Purpose**: Full review details — rating breakdown bars, address, dates/rent, contract badges, pros/cons with translation, photo gallery, comprobante (if verified).
- **Translation**: Calls Google Translate API on demand; caches result per session; toggle between original/translated.
- **Share button**: Exists in AppBar but has no implementation (`onPressed: () {}`).
- **Photo viewer**: Full-screen `PageView` with `InteractiveViewer` for pinch-zoom.
- **Implementation status**: Feature-complete except share functionality.

### WriteReviewScreen (`screens/write_review_screen.dart`)
- **Purpose**: Create or edit a review. Supports all Review model fields.
- **Accepts**: `existingReview` parameter for edit mode.
- **Comprobante flow**: File picker → if image, calls VisionService for date validation; if PDF, skips validation with "no date verification" message.
- **Upload error swallowing**: Storage upload errors are silently caught (`catch (_) {}`).
- **Implementation status**: Functionally complete; silent upload error handling is a minor reliability issue.

### MyReviewsScreen (`screens/my_reviews_screen.dart`)
- **Purpose**: List of the current user's reviews with edit/delete actions.
- **Actions**: Long-press → bottom sheet (Edit / Delete), swipe left → delete (with confirm dialog), Dismissible widget.
- **Not logged in**: Shows lock icon + login button.
- **Implementation status**: Complete.

### SettingsScreen (`screens/settings_screen.dart`)
- **Purpose**: Language selection (ES, EN, KO, JA, ZH). Persists to `SharedPreferences` and rebuilds the app locale via `RentaVozApp.of(context)?.setLocale(...)`.
- **Implementation status**: Complete.

---

## 5. Backend / API

There is **no custom backend server**. All "backend" functionality is Firebase or external Google Cloud APIs.

### Firestore — Collection: `reviews`

| Operation | How accessed | Auth required |
|-----------|-------------|---------------|
| Read all reviews (feed) | `ReviewService.feedStream()` | No (public read assumed) |
| Read user's reviews | `ReviewService.userReviewsStream(uid)` | Implicit (filters by userId) |
| Create / update review | `ReviewService.addReview(review)` | No enforcement in client code |
| Delete review | `ReviewService.deleteReview(reviewId)` | No enforcement in client code |

> ⚠️ **No Firestore security rules are defined in the codebase.** Rules must be configured in the Firebase Console. It is unknown whether write-protection rules (e.g., "only the owner can delete their review") are in place. This is a critical security gap to verify.

### Firebase Storage

| Operation | Path | Notes |
|-----------|------|-------|
| Upload comprobante | `comprobantes/{reviewId}.{ext}` | Single file per review |
| Upload photos | `photos/{reviewId}/{index}.{ext}` | Up to 5 photos per review |

### Google Places API (REST)

| Endpoint | Method | Purpose | Called from |
|----------|--------|---------|-------------|
| `/maps/api/place/autocomplete/json` | GET | Address autocomplete suggestions | `AddressField._fetchPredictions()` |
| `/maps/api/place/details/json` | GET | Resolve `place_id` → lat/lng | `AddressField._selectPrediction()` |

- **Auth**: API key in query param (`?key=$kGoogleApiKey`)
- **Restriction headers sent**: `x-ios-bundle-identifier: com.onuri.rentavoz`
- **Filter**: `components=country:mx` (Mexico only)

### Google Cloud Vision API (REST)

| Endpoint | Method | Purpose | Called from |
|----------|--------|---------|-------------|
| `/v1/images:annotate` | POST | OCR text extraction from comprobante image | `VisionService.validateComprobante()` |

- **Logic**: Extracts dates from OCR text; validates that at least one date is within the last 90 days.
- **PDF files**: Skipped — no Vision call, accepted without date verification.

### Google Cloud Translation API (REST)

| Endpoint | Method | Purpose | Called from |
|----------|--------|---------|-------------|
| `/language/translate/v2` | POST | Translate pros/cons to user's locale | `TranslationService.translate()` |

- **Target language**: Derived from `Localizations.localeOf(context).languageCode` at call time.

---

## 6. Database

### Database: Cloud Firestore

- **ORM / Client**: `cloud_firestore ^5.6.9` Flutter package (Firebase SDK)
- **No migrations**: Firestore is schema-less; the Dart model (`Review`) is the schema definition.

### Collection: `reviews`

| Field | Type | Notes |
|-------|------|-------|
| `userId` | String | Firebase Auth UID of the author |
| `address` | String | Full address from Places API |
| `lat` | Number | Latitude (from Place Details) |
| `lng` | Number | Longitude (from Place Details) |
| `moveInDate` | Timestamp | |
| `moveOutDate` | Timestamp | |
| `monthlyRent` | Number | In MXN |
| `landlordRating` | Number | 1–5 |
| `conditionRating` | Number | 1–5 |
| `locationRating` | Number | 1–5 |
| `securityRating` | Number | 1–5 |
| `rentalType` | String | `'house'` or `'room'` |
| `sharedBathroom` | Boolean | Only relevant if `rentalType == 'room'` |
| `sharedKitchen` | Boolean | Only relevant if `rentalType == 'room'` |
| `hadFormalContract` | Boolean | |
| `avalRequired` | Boolean | (Aval = guarantor requirement) |
| `depositReturned` | Boolean | |
| `utilitiesIncluded` | Boolean | |
| `pros` | String | Free text |
| `cons` | String | Free text |
| `photoUrls` | Array\<String\> | Firebase Storage download URLs |
| `comprobanteUrl` | String? | Nullable; Storage URL of utility bill |
| `createdAt` | Timestamp | |

**No other collections exist.** User profiles are not stored; only Auth UIDs link reviews to users.

### Computed fields (Dart only, not stored)
- `overallRating`: average of 4 rating fields
- `isVerified`: `comprobanteUrl != null && moveOutDate > now - 90 days`

### Document ID
UUID v4 generated in Dart at review creation (`const Uuid().v4()`).

---

## 7. Authentication & Authorization

### Login Methods
1. **Email/password** via `FirebaseAuth.createUserWithEmailAndPassword` / `signInWithEmailAndPassword`
2. **Google Sign-In** via `google_sign_in` package + `GoogleAuthProvider.credential`

### Password Reset
Firebase email reset link via `sendPasswordResetEmail`.

### Session Management
Firebase handles session persistence automatically. `authStateChanges()` stream drives the `AuthGate` router.

### User Profile
No display name or avatar is stored. Only `FirebaseAuth.currentUser.uid` is used as the user identifier.

### Authorization
- **Client-side only.** Review ownership is checked only in UI (MyReviewsScreen filters by `userId == currentUser.uid`).
- **Server-side rules**: Unknown — not visible in the codebase; must be verified in the Firebase Console.
- **Risk**: Without Firestore security rules, any authenticated (or even unauthenticated) user could potentially write or delete any review document.

### Protected Routes
- **My Reviews tab**: Shows login prompt if `AuthService.currentUser == null`, but does not block navigation.
- **Write Review FAB**: Accessible to any user; `AuthService.currentUser?.uid ?? 'anonymous'` is used as the userId — meaning anonymous (unauthenticated) users can technically write reviews.

### Key Auth Files
- `lib/services/auth_service.dart`
- `lib/screens/auth_gate.dart`
- `lib/screens/auth/login_screen.dart`
- `lib/screens/auth/register_screen.dart`

---

## 8. External Services / APIs

| Service | Purpose | Code Location | Required Config |
|---------|---------|--------------|----------------|
| Firebase Auth | User authentication | `lib/services/auth_service.dart` | `firebase_options.dart` (generated), `GoogleService-Info.plist` (iOS), `google-services.json` (Android) |
| Cloud Firestore | Review data storage | `lib/services/review_service.dart` | Same Firebase config |
| Firebase Storage | Photo and comprobante storage | `lib/services/storage_service.dart` | Same Firebase config |
| Google Maps SDK | Map display | `lib/screens/map_screen.dart` | `kGoogleApiKey` in `api_keys.dart`; also registered in `ios/Runner/Info.plist` (URL scheme) |
| Google Places API | Address autocomplete | `lib/widgets/address_field.dart` | `kGoogleApiKey` |
| Google Cloud Vision | Comprobante OCR/validation | `lib/services/vision_service.dart` | `kGoogleApiKey` |
| Google Cloud Translation | Review translation | `lib/services/translation_service.dart` | `kGoogleApiKey` |
| Google Sign-In | OAuth login | `lib/services/auth_service.dart` | `kGoogleApiKey` (via Firebase), OAuth client ID in `Info.plist` |

**Implementation status**: All services are implemented and integrated. Actual API call success depends on:
1. The Google API key being valid and unrestricted enough
2. The Firebase project (`rentavoz`) being active
3. Firebase credential files existing locally (they are gitignored)

---

## 9. Environment Variables

This project uses **no `.env` file**. Configuration is split between:

### Hardcoded in source (⚠️ security issue)
| Key | File | Purpose |
|-----|------|---------|
| `kGoogleApiKey` | `lib/config/api_keys.dart` | Google Cloud API key for Maps, Places, Vision, Translation |

### Firebase credential files (gitignored, must be obtained from Firebase Console)
| File | Platform | Purpose |
|------|---------|---------|
| `ios/Runner/GoogleService-Info.plist` | iOS | Firebase iOS SDK config |
| `android/app/google-services.json` | Android | Firebase Android SDK config |

### Auto-generated (committed to repo)
| File | Purpose |
|------|---------|
| `lib/firebase_options.dart` | Dart Firebase config (generated by `flutterfire configure`) |

### Stored locally at runtime
| Key | Storage | Purpose |
|-----|---------|---------|
| `locale` | `SharedPreferences` | User's selected language code |
| `onboarding_done` | `SharedPreferences` | Whether to show onboarding on next launch |

---

## 10. Implemented Features

All of the following are verified as connected end-to-end:

- [x] Email/password registration and login
- [x] Google Sign-In (with iOS keychain error retry)
- [x] Password reset via email
- [x] First-launch 5-page onboarding
- [x] Review feed (list view) with real-time Firestore updates
- [x] Address search (Google Places autocomplete, Mexico only)
- [x] GPS "use current location" in address field
- [x] Write review with all fields (type, address, dates, rent, 4 ratings, contract details, pros/cons)
- [x] Rental type selection (House vs. Room) with conditional shared-facility fields
- [x] Photo upload (gallery and camera, up to 5 photos, Firebase Storage)
- [x] Comprobante (utility bill) upload with image OCR date validation (Vision API)
- [x] PDF comprobante upload (no validation, accepted as-is)
- [x] Review edit (pre-filled form via `existingReview` parameter)
- [x] Review delete (from MyReviews — swipe or long-press)
- [x] Review detail screen with photo gallery and pinch-zoom viewer
- [x] Verified badge (shown when comprobante is within 90 days of move-out)
- [x] Google Maps view with color-coded pins (green/yellow/red by rating)
- [x] Pin tap → mini review card at map bottom
- [x] Custom zoom +/- buttons on map
- [x] Review translation to user's app language (Google Translate)
- [x] Multi-language support (ES, EN, KO, JA, ZH) via ARB localization
- [x] Language selection in settings (persisted)
- [x] Feed search by address text
- [x] Feed filter by rental type (All / House / Room)
- [x] Feed sort (Newest / Highest / Lowest rating)
- [x] Dummy/demo reviews shown when Firestore is empty
- [x] Light/dark theme (Material 3, system-following)
- [x] Custom app icon and splash screen

---

## 11. Work In Progress

### Comprobante PDF validation
- **Status**: PDF files are uploaded and accepted but no date extraction is performed.
- **Current behavior**: Shows "PDF adjunto (sin verificación de fecha)" — user gets the verified badge without actual date verification.
- **What's needed**: PDF-to-image conversion (e.g., `pdf_render` package) + Vision API call, or a backend function.
- **Related files**: `lib/services/vision_service.dart`, `lib/screens/write_review_screen.dart:130-137`

### Share review functionality
- **Status**: Share button exists in the AppBar of `ReviewDetailScreen` with an empty `onPressed`.
- **What's needed**: Implement deep link or text sharing using `share_plus` package.
- **Related files**: `lib/screens/review_detail_screen.dart:71`

### App icon and splash assets (uncommitted)
- **Status**: `assets/` directory and web/splash are in `git status` as untracked. The launcher icons were regenerated (`flutter_launcher_icons` was run) but not committed.
- **What's needed**: Stage and commit the updated icon and splash files.

---

## 12. Not Implemented Yet

The following features are **not present** in any code. Some are inferred from the app's concept.

| Feature | Evidence / Confidence |
|---------|----------------------|
| User profile page (name, avatar, review count) | No user collection in Firestore; no UI. Inferred need. |
| Push notifications | No `firebase_messaging` dependency. |
| Review reporting / moderation / flagging | No UI or data model field. |
| Map filter (by type, rating range, rent range) | Map shows all pins; no filter controls. |
| Real GPS centering on map | "My location" button centers to hardcoded Querétaro point. |
| Search on map screen | No search bar in `MapScreen`. |
| Deep links / universal links | No URL scheme setup for review deep links. |
| Admin panel | No admin role or separate interface. |
| Email verification after registration | Not called after `createUserWithEmailAndPassword`. |
| Offline support | No Firestore offline persistence explicitly enabled. |
| Pagination beyond 50 reviews | Feed is `limit(50)`; no infinite scroll. |
| City/region expansion beyond Querétaro | Map hardcoded to Querétaro; no region selector. |

Items marked as **inferred** are not confirmed by code, comments, or git history — they are reasonable product needs based on the app's concept.

---

## 13. Known Bugs / Issues

### Critical

**1. Hardcoded Google API key in source code**
- **File**: `lib/config/api_keys.dart:3`
- **Issue**: `const String kGoogleApiKey = 'AIzaSy...'` is committed to the repository. Anyone with repo access has the key.
- **Risk**: Key abuse, billing exploitation for Maps/Vision/Translation/Places.

**2. No Firestore write authorization enforcement on client**
- **File**: `lib/screens/write_review_screen.dart:512`
- **Issue**: `AuthService.currentUser?.uid ?? 'anonymous'` — unauthenticated users can write reviews with userId `'anonymous'`. There is no redirect-to-login if the user is not authenticated.
- **Risk**: Spam reviews from unauthenticated users (unless blocked by Firestore rules).

**3. Firebase credential files not in repo**
- **Files**: `ios/Runner/GoogleService-Info.plist`, `android/app/google-services.json`
- **Issue**: Gitignored. A new developer will not be able to build without obtaining these from the Firebase Console (`rentavoz` project).
- **Impact**: Build failure on fresh clone.

### Moderate

**4. Missing Google logo asset**
- **File**: `lib/screens/auth/login_screen.dart:293`
- **Issue**: `Image.asset('assets/google_logo.png', ...)` — this file does not exist. Falls back to `Icons.g_mobiledata`. Visually functional but incorrect.

**5. Silent upload error swallowing**
- **File**: `lib/screens/write_review_screen.dart:510`
- **Issue**: `catch (_) {}` swallows Storage upload errors. If photo/comprobante upload fails, the review is still submitted with no photos and no error message to the user.

**6. Hardcoded Korean strings in login error handling**
- **File**: `lib/screens/auth/login_screen.dart:173-175`
- **Issue**: `'네트워크 오류. 인터넷 연결을 확인해주세요.'`, `'다시 시도해주세요.'`, `'오류: $e'` are hardcoded Korean strings, not using the localization system. Non-Korean users see Korean error messages.

**7. Map "My Location" does not use GPS**
- **File**: `lib/screens/map_screen.dart:80-84`
- **Issue**: The my-location button animates the camera to the hardcoded `_queretaro` constant, not the user's actual position.

### Minor

**8. PDF comprobante bypasses date verification**
- **File**: `lib/screens/write_review_screen.dart:130-138`
- **Issue**: PDF files are marked valid without any date check. A user can upload any PDF and get the verified badge.

**9. `dummyReviews` shown to real users when Firestore is empty**
- **File**: `lib/screens/feed_screen.dart:165`, `lib/screens/map_screen.dart:31`
- **Issue**: When Firestore returns 0 reviews, the app falls back to `dummyReviews`. This is fine for demos but will confuse users in a production environment with zero real reviews.

**10. Uncommitted asset changes**
- **Status**: `git status` shows modified iOS/Android icon/splash files, and untracked dark-mode launch images. These need to be committed.

---

## 14. Security Review

### Confirmed Issues

**API key exposed in source (`lib/config/api_keys.dart`)**
The Google API key `kGoogleApiKey` is hardcoded and committed to the repository. This is the single most significant security issue in the codebase.

**Unauthenticated review submission possible**
The `WriteReviewScreen` does not require a logged-in user — it falls back to `'anonymous'` as the userId. Whether this results in actual Firestore writes depends on security rules.

### Items Not Confirmed as Issues (no evidence found)

- No sensitive data logging found (except `debugPrint` of Firebase error codes in LoginScreen, which is acceptable).
- No SQL injection risk (no SQL database used).
- No XSS risk (Flutter renders to native UI, not a browser DOM).
- No CSRF risk (no server-side session cookies).
- No hardcoded passwords or secrets beyond the Google API key.
- `.gitignore` correctly excludes Firebase credential files (`google-services.json`, `GoogleService-Info.plist`).
- Input validation exists on address, email, password, and date fields.

### Unknown (requires Firebase Console verification)

- **Firestore Security Rules**: Not visible in the codebase. If rules are set to `allow read, write: if true;` (the Firebase default for new projects), any user can read/write/delete any review.
- **Firebase Storage Rules**: Not visible. Should restrict upload to authenticated users and reads to public.
- **Google API key restrictions**: The key in `api_keys.dart` sends an `x-ios-bundle-identifier` header for some requests but not all. The Google Cloud Console restriction settings are unknown.

---

## 15. Important Technical Decisions

### Decision 1: No backend server
**What**: All operations go directly through Firebase/Google Cloud SDKs from the Flutter client.  
**Why**: Reason not explicitly stated in code or git history. Most likely chosen for development speed and simplicity for an MVP.  
**Consequence**: Security rules must be enforced at the Firebase layer, not in application code.

### Decision 2: Static methods for services
**What**: `AuthService`, `ReviewService`, `StorageService`, `TranslationService`, `VisionService` all use `static` methods.  
**Why**: Reason not stated (inasmuch as confirmed). Simplicity — avoids dependency injection.  
**Consequence**: Cannot be mocked for unit testing; testing requires real Firebase connections.

### Decision 3: Fallback to dummy reviews
**What**: `dummyReviews` (4 hardcoded Querétaro reviews) are shown when Firestore returns empty.  
**Why**: Likely for demo/cold-start purposes so the app doesn't appear empty to first-time users.  
**Consequence**: When the real database has 0 reviews, users see fake data.

### Decision 4: Spanish as default locale
**What**: `_locale = const Locale('es')` in `main.dart`; date formatting initialized for `'es'`.  
**Why**: App is targeted at Mexico; Spanish is the primary language.  
**Note**: The translation button on ReviewDetailScreen is disabled (`onPressed: null`) when the current locale is `'es'`, because content is already presumed to be in Spanish.

### Decision 5: Comprobante validation via Vision API
**What**: Rental utility bill (comprobante de domicilio) is validated by extracting dates via OCR and checking they are within 90 days.  
**Why**: To create a "verified resident" badge that adds credibility to reviews.  
**Limitation**: PDF files bypass this validation.

### Decision 6: iOS keychain error retry
**What**: Login screen retries once after 500ms on `keychain-error`.  
**Why**: Firebase Auth on iOS sometimes throws a keychain error on the first attempt, especially on fresh installs or after app data clears.  
**File**: `lib/screens/auth/login_screen.dart:41-45`

---

## 16. How to Run the App

### Prerequisites
- Flutter SDK (Dart `^3.12.2`) installed and on PATH
- Xcode (for iOS) or Android Studio (for Android)
- Access to the Firebase `rentavoz` project

### Step 1: Clone and install dependencies
```bash
cd /path/to/RentaVoz
flutter pub get
```

### Step 2: Add Firebase credential files
These files are gitignored and must be downloaded from the Firebase Console (project: `rentavoz`):

- Download `google-services.json` → place at `android/app/google-services.json`
- Download `GoogleService-Info.plist` → place at `ios/Runner/GoogleService-Info.plist`

Alternatively, re-run `flutterfire configure` with the Firebase CLI if you have project access.

### Step 3: Verify Google API key
Open `lib/config/api_keys.dart` and confirm `kGoogleApiKey` is set to a valid, enabled Google Cloud API key with the following APIs enabled:
- Maps SDK for iOS / Android
- Places API (New or legacy)
- Cloud Vision API
- Cloud Translation API

### Step 4: Run the app
```bash
# iOS simulator
flutter run -d ios

# Android emulator
flutter run -d android

# List available devices
flutter devices
```

### No database setup required
Firestore collections are created automatically on first write. No migrations needed.

---

## 17. Build / Test / Lint

### Development
```bash
flutter run
```

### Build (Release)
```bash
# iOS
flutter build ios --release

# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release
```

### Regenerate launcher icons (after changing `assets/icon/app_icon.png`)
```bash
flutter pub run flutter_launcher_icons
```

### Regenerate splash screen (after changing `assets/icon/splash_logo.png`)
```bash
flutter pub run flutter_native_splash:create
```

### Regenerate localizations (after editing `.arb` files)
```bash
flutter gen-l10n
```

### Lint / Analysis
```bash
flutter analyze
```

### Tests
```bash
flutter test
```

> **Note**: Only one test file exists (`test/widget_test.dart`) with the default "increment counter" smoke test — it tests the default Flutter counter app, not RentaVoz code. It will likely fail or be irrelevant. There are effectively no meaningful tests.

### Type check
Dart is statically typed; `flutter analyze` covers type checking.

---

## 18. Git Status

**Current branch**: `main`

### Modified files (staged — not committed)
These are all iOS/Android icon and splash assets generated by `flutter_launcher_icons` and `flutter_native_splash`:
- `android/app/src/main/res/drawable*/launch_background.xml` (splash background)
- `android/app/src/main/res/mipmap-*/ic_launcher.png` (app icons)
- `android/app/src/main/res/values*/styles.xml`
- `ios/Runner.xcodeproj/project.pbxproj`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/*` (all icon sizes)
- `ios/Runner/Assets.xcassets/LaunchImage.imageset/*` (splash images)

### Untracked files (not yet added to git)
- `assets/` directory (app_icon.png, splash_logo.png)
- `ios/Runner/Assets.xcassets/LaunchBackground.imageset/` (new dark launch background)
- `ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImageDark*.png` (dark mode splash)
- `web/splash/` (web splash generated files)
- `ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/`
- `ios/Runner.xcworkspace/xcshareddata/swiftpm/`

**Note**: `pubspec.yaml` is also modified (adding asset declarations for the new `assets/` directory).

---

## 19. Recent Git History

Listed from oldest to newest (10 commits total):

1. **`e80156d`** `feat: RentaVoz 초기 프로젝트 구조 (Flutter + Firebase 준비)`  
   Initial project scaffold — Flutter project created, Firebase dependencies added, basic screens stubbed.

2. **`bcca376`** `feat: Firebase Auth/Firestore 연동, Places 자동완성, 지도 화면, 자동 로그인`  
   Connected Firebase Auth and Firestore, implemented Google Places autocomplete in address field, built the map screen with Firestore-driven pins, and wired up automatic login via authStateChanges stream.

3. **`00409a7`** `feat: 다국어 지원, 지도 줌 버튼, 번역 기능, 인증 에러 현지화`  
   Added full i18n with ARB files for 5 languages, zoom +/- buttons on map, review translation via Google Translate API, and localized Firebase Auth error messages.

4. **`ea6b1a8`** `feat: 방 임대 유형 구분, 사진 업로드, 번역 API 수정, 로그인 안정성 개선`  
   Added `rentalType` field (house vs. room) with conditional shared-facility fields, implemented Firebase Storage photo upload (multi-image picker + camera), fixed the translation API call, and improved login error recovery.

5. **`31edd99`** `feat: 비밀번호 찾기 기능 추가 (Firebase Auth 이메일 재설정)`  
   Implemented "Forgot Password" dialog that sends a Firebase password reset email.

6. **`7a70485`** `feat: Google 로그인 추가`  
   Added Google Sign-In button and OAuth flow using `google_sign_in` package.

7. **`ad8e192`** `feat: 임대 유형 선택, 공용 시설, iOS 키체인 오류 처리`  
   Rental type selector (SegmentedButton), shared bathroom/kitchen switches for room type, and iOS keychain error retry workaround.

8. **`38bb0df`** `chore: Firebase 인증 파일을 gitignore에 추가`  
   Added `google-services.json` and `GoogleService-Info.plist` to `.gitignore` to prevent credential leakage.

9. **`a1bae0e`** `fix: Google 로그인 크래시 수정`  
   Fixed a crash in Google Sign-In flow (likely null check on cancelled sign-in).

10. **`d4e5636`** `feat: 피드 필터 및 정렬 기능 추가`  
    Added search bar, type filter chips (All/House/Room), and sort bottom sheet (Newest/Highest/Lowest rating) to FeedScreen.

---

## 20. Next Development Priorities

### P0 — Must fix before any production release

**P0-1: Secure the Google API key**  
Remove `kGoogleApiKey` from `lib/config/api_keys.dart` and replace with a platform-native approach:
- iOS: Store in `Info.plist` as a non-committed secret or use environment injection at build time
- Android: Store in `local.properties` / Gradle secrets or `google-services.json`  
- Alternatively, proxy sensitive API calls (Vision, Translation) through a Firebase Cloud Function  
- Related file: `lib/config/api_keys.dart`

**P0-2: Verify and harden Firestore security rules**  
Open the Firebase Console (`rentavoz` project → Firestore → Rules) and confirm rules require:
- Authentication to write reviews
- Users can only delete/edit their own reviews (`request.auth.uid == resource.data.userId`)
- Public read for all reviews  
- Related to: `lib/services/review_service.dart`

**P0-3: Require authentication before writing a review**  
`WriteReviewScreen` should redirect unauthenticated users to `LoginScreen` instead of submitting with `userId = 'anonymous'`.  
Related file: `lib/screens/write_review_screen.dart:512`

**P0-4: Add Firebase credential files setup instructions**  
The build will fail on a fresh clone because `google-services.json` and `GoogleService-Info.plist` are gitignored. Document or automate how to obtain them (see Section 16).

### P1 — Next core development

**P1-1: Commit and stabilize generated asset files**  
Stage and commit: the modified icon/splash iOS and Android assets, the `assets/` directory, and `pubspec.yaml`. The uncommitted state is a consistency risk.  
Related: Section 18 (Git Status)

**P1-2: Add the Google logo asset**  
Create `assets/icon/google_logo.png` (download from Google brand guidelines) and add to `pubspec.yaml` assets list so the Google sign-in button shows the proper logo.  
Related file: `lib/screens/auth/login_screen.dart:293`

**P1-3: Fix silent upload error handling**  
Replace the empty `catch (_) {}` in `WriteReviewScreen._submit()` with proper error feedback to the user.  
Related file: `lib/screens/write_review_screen.dart:510`

**P1-4: Fix Korean hardcoded error strings**  
Replace the 3 hardcoded Korean strings in `LoginScreen._authError()` and the catch block with proper `S.of(context)!` localization keys.  
Related file: `lib/screens/auth/login_screen.dart:173-175, 59`

**P1-5: Implement share functionality**  
Add `share_plus` package and implement the share button in `ReviewDetailScreen` to share a review via the system share sheet (text + address + rating).  
Related file: `lib/screens/review_detail_screen.dart:71`

### P2 — Important improvements

**P2-1: Real GPS centering on map**  
The "My Location" button should animate to `Geolocator.getCurrentPosition()` instead of the hardcoded Querétaro constant.  
Related file: `lib/screens/map_screen.dart:80-84`

**P2-2: Add user profile**  
Allow users to set a display name after registration. Store a `users` collection in Firestore. Show user name on reviews in the feed. Currently all reviews appear anonymous.

**P2-3: Email verification after registration**  
Call `user.sendEmailVerification()` after `createUserWithEmailAndPassword`. Optionally block certain actions until the email is verified.

**P2-4: Pagination for the feed**  
Replace the `limit(50)` query with proper cursor-based pagination (`startAfterDocument`) to support a growing review database.  
Related file: `lib/services/review_service.dart:7-11`

**P2-5: Handle dummy reviews in production**  
Add a flag or build variant to disable `dummyReviews` fallback in production builds.  
Related files: `lib/screens/feed_screen.dart:165`, `lib/screens/map_screen.dart:31`

### P3 — Nice to have / future

- **PDF comprobante date validation** (e.g., via Firebase Cloud Function with `pdf_render`)
- **Push notifications** (`firebase_messaging`) for new reviews in a followed area
- **Review reporting** (flag inappropriate content)
- **Map filters** (filter pins by rental type, rating range)
- **City/region expansion** beyond Querétaro (remove hardcoded `_queretaro` constant, allow city selection)
- **Unit and widget tests** — currently only a default smoke test exists
- **CI/CD pipeline** (GitHub Actions → `flutter test`, `flutter analyze`, `flutter build`)

---

## 21. AI Agent Continuation Notes

### Do NOT touch these without understanding the full impact

**`lib/firebase_options.dart`** — Auto-generated by the `flutterfire configure` CLI. Do not edit manually. Regenerate with `flutterfire configure` if you need to change Firebase projects.

**`lib/l10n/app_localizations*.dart`** — Auto-generated from `.arb` files by `flutter gen-l10n`. Do not edit these files. Edit only the `.arb` source files in `lib/l10n/`, then run `flutter gen-l10n`.

**Firestore data structure** — The `reviews` collection has live data (if any exists in the `rentavoz` Firebase project). Do not add required fields to the `Review.fromMap()` factory without providing defaults, or existing documents will throw null errors at runtime.

**`lib/config/api_keys.dart`** — Contains the Google API key. Do not commit additional secrets here. The first P0 task should move this key out of source code.

### Currently in progress (as of handoff)
- Generated icon/splash assets are modified but uncommitted (see Section 18). Commit these before starting new features to avoid merge confusion.

### Important dependencies
- The app requires both `GoogleService-Info.plist` (iOS) and `google-services.json` (Android) to build and run. These are gitignored. Without them, `Firebase.initializeApp()` will throw on startup.

### Database cautions
- Firestore is live; the `reviews` collection may contain real user data. Do not run destructive operations (`deleteMany`, clearing collections) on the production project without confirmation.
- Do not change field names in `Review.toMap()` / `Review.fromMap()` without providing backward-compatible migration, because existing documents use the old field names.

### Environment cautions
- There is only one Firebase environment (`rentavoz` project). There is no separate staging/dev Firebase project. All development against this project affects the same database real users may eventually see.

### Undecided/open questions
- Should the app support cities other than Querétaro? (Map is hardcoded to Querétaro coordinates.)
- Should reviews be publicly readable without login? (Currently yes, by convention — but depends on Firestore rules.)
- What should happen when a user uploads a comprobante PDF? Should it be rejected, or validated differently?
- Is the "verified" badge actually meaningful if PDF uploads bypass date checking?

### Best places to start new work
1. **Fix auth and security (P0)** — Start in `lib/config/api_keys.dart` and Firebase Console security rules.
2. **Commit pending assets** — Run `git add android/ ios/ assets/ pubspec.yaml` (carefully review what's included), then commit.
3. **Add Google logo asset** — Quick win, add `assets/icon/google_logo.png` and add to `pubspec.yaml` assets.
4. **For new UI features** — Follow the pattern in `lib/screens/` (StatefulWidget + StreamBuilder or plain setState, no framework).
5. **For new data fields** — Update `Review` model fields, `toMap()`, `fromMap()`, and all screens that display/input the field. Add an ARB key for any new UI label.
