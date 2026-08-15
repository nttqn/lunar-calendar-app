# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Flutter Android Vietnamese lunar calendar app (`Lịch Âm Dương`): month
grid with solar + lunar dates, day/hour "hoàng đạo" (auspicious) info,
Can-Chi naming, fixed holidays, and a solar↔lunar date converter. AdMob
banner ad wired in, intended for Google Play. There is no native `android/`
(or `ios/`) directory in this repo — see "Android project is generated,
not committed" below before assuming any Gradle/Manifest file exists
locally.

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

There is no `test/` directory with automated tests yet, beyond whatever
ad-hoc scripts were used to spot-check the lunar conversion math during
development.

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
2. Adds the `INTERNET` permission to the main manifest (Flutter's default
   template only grants it in the debug-variant manifest).
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
5. Only runs `dart run flutter_launcher_icons` if `assets/icon/icon.png`
   exists (it doesn't yet in a fresh checkout — no custom launcher icon has
   been supplied). Once one is added, also add `assets/icon/icon.png` under
   `flutter: assets:` in `pubspec.yaml`.
6. If `KEYSTORE_BASE64` (+ `KEYSTORE_PASSWORD`/`KEY_ALIAS`/`KEY_PASSWORD`)
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
