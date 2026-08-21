# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Flutter Android Vietnamese lunar calendar app (`Lịch Âm Dương`): month
grid with solar + lunar dates, day/hour "hoàng đạo" (auspicious) info,
Can-Chi naming, fixed holidays, a solar↔lunar date converter, and personal
events (birthdays, giỗ...) keyed to a solar or lunar day/month that repeat
every year, with local reminder notifications. AdMob banner ad wired in,
intended for Google Play. There is no native `android/` (or `ios/`)
directory in this repo — see "Android project is generated, not committed"
below before assuming any Gradle/Manifest file exists locally.

**This repo is public** (deliberately switched from private) because
`docs/index.html` — the Privacy Policy + Child Safety Standards page
Google Play requires — is served via GitHub Pages, which only works on
the free plan for public repos. That page was originally a Claude
Artifact; Play Console rejected it ("Invalid published standards" / not
loading), most likely because Google's automated policy crawler can't get
past whatever bot protection claude.ai serves. GitHub Pages is a plain
static host with no such wall. Checked git history before flipping
visibility — no keystore/password/secret was ever committed (the real
release keystore lives outside the repo, see the signing section below).

## Commands

Flutter is installed locally in this dev environment (`C:\src\flutter`,
channel stable) but the Android SDK is not (`flutter doctor` reports
"Unable to locate Android SDK") — so real APK/AAB builds must happen in CI,
not locally:

```
flutter pub get                    # install deps
flutter analyze                    # static analysis (also run non-blocking in CI)
flutter run -d chrome              # fastest way to eyeball UI changes — no Android SDK needed
flutter create --platforms=android --org com.trungapps --project-name amlich .
                                    # regenerate android/ locally before a real device/emulator run
flutter build apk --release        # debug-signed test APK
flutter build appbundle --release  # AAB for actual Play Store upload (needs real signing config)
```

`test/lunar_calendar_test.dart` and `test/personal_event_test.dart` cover
the lunar conversion math (spot-checked against known Tết dates, round-trip
stability) and the personal-event recurrence math respectively — run with
`flutter test`.

Real APK builds happen in CI: push to `main` (or trigger
`workflow_dispatch`) and GitHub Actions runs
`.github/workflows/build-apk.yml`, which uploads `app-release.apk` and
`app-release.aab` as build artifacts.

## Android project is generated, not committed

`android/`, `ios/`, `web/`, etc. are gitignored on purpose. The CI workflow
regenerates `android/` from scratch on every run via `flutter create
--platforms=android --org com.trungapps --project-name amlich .`, then
patches the result before building:

1. Injects the AdMob App ID (`meta-data` in `AndroidManifest.xml`) — reads
   the `ADMOB_APP_ID` GitHub secret, falling back to Google's public test
   App ID if unset.
2. Adds the `INTERNET` and `POST_NOTIFICATIONS` permissions to the main
   manifest (Flutter's default template only grants `INTERNET` in the
   debug-variant manifest, and doesn't add `POST_NOTIFICATIONS` at all —
   needed for `flutter_local_notifications` to post reminders on Android
   13+, requested at runtime via
   `NotificationService.initialize()`).
3. Forces `minSdkVersion 24` / `compileSdk 36` in `android/app/build.gradle`
   (or `.gradle.kts`). `google_mobile_ads` requires minSdk 24+; without the
   override, the value falls through to Flutter's own
   `flutter.minSdkVersion` default, which can be lower.
4. Turns on `isMinifyEnabled`/`isShrinkResources` (or the Groovy
   equivalents) for the release build type, wires up `proguardFiles`, and
   appends `tool/proguard-rules-extra.pro` onto the freshly-generated
   `android/app/proguard-rules.pro`. That extra file's keep rules exist
   because recent AGP's R8 strips `androidx.work.impl.WorkDatabase_Impl`
   (only referenced via reflection) — WorkManager needs that class and gets
   pulled in transitively by `google_mobile_ads`. Without the keep rules, a
   *shrunk* release build crashes on launch with "Unable to get provider
   androidx.startup.InitializationProvider" / "Failed to create an instance
   of androidx.work.impl.WorkDatabase" (this is a known landmine, hit and
   fixed the same way in the sibling `chess-app` project — see that repo's
   CLAUDE.md if this resurfaces).
5. Appends a second `android { compileOptions { ... } }` +
   `dependencies { coreLibraryDesugaring(...) }` block onto
   `android/app/build.gradle(.kts)` (Gradle merges multiple `android {}`/
   `dependencies {}` blocks in one file, so appending is safe and avoids
   having to locate/patch a `compileOptions` block that may or may not
   already exist depending on the Flutter template version).
   `flutter_local_notifications` requires Java 8+ core library desugaring
   on Android — without this, `flutter build apk --release` hard-fails at
   the `:app:checkReleaseAarMetadata` Gradle task with "Dependency
   ':flutter_local_notifications' requires core library desugaring to be
   enabled for :app." This was caught by the first real CI run after the
   personal-events feature was added — `flutter analyze`/`flutter test`/
   `flutter build web` all stay green regardless, since desugaring is an
   Android-Gradle-only concern with no web/analysis equivalent.
6. Runs `dart run flutter_launcher_icons` if `assets/icon/icon.png` exists
   (it does — see `flutter: assets:` in `pubspec.yaml`), generating every
   mipmap-*/ic_launcher.png density from that source image. Verified
   locally once (regenerate `android/` via the same `flutter create`
   command, then `dart run flutter_launcher_icons`, then check
   `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` isn't broken)
   before trusting a fresh icon change to CI.
7. If `KEYSTORE_BASE64` (+ `KEYSTORE_PASSWORD`/`KEY_ALIAS`/`KEY_PASSWORD`)
   secrets are set, decodes the keystore, writes `android/key.properties`,
   then runs `tool/patch_signing.js` (a committed Node script, not inline
   sed — needs a proper multi-line block insert plus an import line for the
   Kotlin DSL case) to add a `release` `signingConfig` in
   `android/app/build.gradle(.kts)` and point the release build type at it
   instead of the debug key. Without these secrets the build silently stays
   debug-signed (fine to sideload, rejected by Play Console). The actual
   keystore file lives outside the repo (never commit one — `.gitignore`
   also blocks `*.jks`/`*.keystore`/`key.properties` as a backstop).

If you ever need to hand-edit Android native files, the intended path is:
install Android Studio/SDK locally, run `flutter create` once yourself,
remove `/android/` from `.gitignore`, and commit it — at that point it
stops being CI-regenerated and the workflow's `flutter create`/patch steps
should be dropped.

**Known upstream landmine:** some `google_mobile_ads` versions have shipped
with a broken `android/build.gradle` (5.3.1's `for (config :
configurations.all)` loop uses a property that doesn't exist on modern
Gradle's configuration container, hard-failing `assembleRelease`). If a CI
build fails inside `:google_mobile_ads`'s own Gradle configuration step,
suspect the pinned plugin version (`^9.0.0` in `pubspec.yaml`) before
anything else — check the package's published `android/build.gradle`
(download the archive from the `archive_url` field in
`https://pub.dev/api/packages/google_mobile_ads`) rather than assuming the
bug is in this repo's code.

## Architecture

**Lunar calendar math (`lib/lunar/lunar_calendar.dart`)** is a from-scratch
Dart port of the astronomical algorithm published by Hồ Ngọc Đức (new
moon + sun longitude, not a lookup table — accurate across centuries, not
just a hard-coded year range). `LunarCalendar.solarToLunar` and
`.lunarToSolar` are the two public entry points; everything else
(`jdFromDate`/`jdToDate`, `_newMoon`, `_sunLongitude`, `_lunarMonth11`,
`_leapMonthOffset`) is plumbing specific to that algorithm — don't rename
the private helpers without re-checking against the original reference
implementation, since the formulas are dense and easy to silently break
with a typo'd constant.

**Can-Chi (`lib/lunar/can_chi.dart`)**: day Can-Chi is keyed off the
Julian day number (`(jd+9)%10` for Can, `(jd+1)%12` for Chi) — that's the
canonical anchor, since it advances exactly one step per calendar day
regardless of month/year boundaries. Year/month/hour Can-Chi are each
separate formulas keyed off lunar year/month or the day's Can — see the
inline comments; these were verified by hand against known reference dates
(e.g. 1984 = Giáp Tý, 2024 = Giáp Thìn) rather than pulled from a citable
source.

**Hoàng đạo tables (`lib/lunar/hoang_dao.dart`)**: unlike the conversion
math, these are traditional fixed lookup tables (which day-Chi values are
auspicious for a given lunar month; which hour-Chi values are auspicious
for a given day-Chi), implemented from memory of the commonly-published
version. Flagged in the file's doc comment as worth spot-checking against
a printed almanac — folk sources vary slightly, and there's no live
citation backing the exact table used here.

**`DayInfo` (`lib/models/day_info.dart`)** is the single object the UI
consumes for any given solar date — bundles the lunar date, Can-Chi names,
hoàng đạo verdict, and holiday name (checked against both the solar and
lunar fixed-date lists in `lib/lunar/holidays.dart`). `DayInfo.fromSolar`
is the only constructor; screens never call the lunar/can-chi/hoang-dao
modules directly.

**Ads (`lib/services/ads_service.dart`)** is deliberately banner-only, no
interstitial — this app is opened many times a day for a quick glance, and
an interstitial on every open would undercut the "nhẹ, ít quảng cáo"
positioning the app is going for (see README's project description). Uses
Google's public test banner ad unit ID until real AdMob ad units exist.

**Personal events** (`lib/models/personal_event.dart`,
`lib/services/event_repository.dart`, `lib/services/notification_service.dart`):
- `PersonalEvent.year` is the recurrence switch: `null` means the event
  repeats every year on its day/month (the original/default behavior);
  a non-null value makes it a one-time event on that exact date, and
  `nextOccurrence`/`nextOccurrences` return `null`/`[]` once it's passed
  instead of searching forward (there's nothing to roll forward to). The
  add-event screen's `RadioGroup<bool>` (`_repeatsYearly`) drives this —
  when switching from one-time back to yearly, `copyWith` needs
  `clearYear: true` since `year ?? this.year` alone can't distinguish
  "leave unchanged" from "explicitly clear to null".
- `PersonalEvent.nextOccurrence`/`.nextOccurrences` resolve a day/month
  (solar or lunar) to upcoming solar dates, reusing
  `LunarCalendar.lunarToSolar`/`.solarToLunar` for lunar events rather than
  any separate date math — see those methods' doc comments for the known
  edge cases (lunar day 30 in a 29-day month, solar Feb 29 in a non-leap
  year) that are deliberately left as Dart's/`LunarCalendar`'s existing
  default behavior rather than special-cased.
- `EventRepository.eventsOn` matches a one-time event's exact year too
  (not just day/month), so it doesn't incorrectly show up on the same
  day/month in other years the way a yearly-recurring event does.
- `EventRepository` is a `ChangeNotifier` singleton
  (`EventRepository.instance`), persisted as one JSON blob in
  `shared_preferences`. Every mutation (`addEvent`/`updateEvent`/
  `deleteEvent`) calls into `NotificationService` to reschedule/cancel that
  event's notifications — the repository is the only place that should
  touch `NotificationService`, so screens never schedule notifications
  directly.
- There's no backend/push service, so **`NotificationService.scheduleEvent`
  pre-schedules only the next 5 yearly occurrences** as individual one-off
  `zonedSchedule` calls (`AndroidScheduleMode.inexactAllowWhileIdle`,
  chosen specifically to avoid needing the `SCHEDULE_EXACT_ALARM`
  permission). `EventRepository.rescheduleAll()` runs once on every app
  startup (see `main()`) to top up occurrences consumed since the last
  launch — if the app is never reopened for 5+ years, reminders lapse until
  it is. This is a deliberate, documented trade-off (see README), not a bug
  to fix.
- `CalendarScreen` wraps its whole build in a `ListenableBuilder` on
  `EventRepository.instance` — necessary because `HomeShell` (main.dart)
  keeps all 3 tabs alive via `IndexedStack`, so `CalendarScreen` doesn't get
  a fresh `build()` just from switching tabs; without the listener, adding
  an event in the Sự Kiện tab wouldn't show up on the calendar until some
  unrelated rebuild happened to fire.
- **Lesson from this feature, worth repeating for any future overlay
  widget**: a `FloatingActionButton` was first used for the calendar's
  "Hôm nay" button, and it silently hid the last giờ-hoàng-đạo tile
  whenever the page was short enough not to need scrolling — invisible to
  `flutter analyze`/`flutter test`, only caught by an actual screenshot.
  Moved to an AppBar action instead (see `calendar_screen.dart`). Any
  screen-fixed overlay added over scrollable content should get a real
  screenshot check, not just a green test run.
