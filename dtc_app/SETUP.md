# Finishing the Flutter project setup

The source files here (`pubspec.yaml`, `lib/`) are ready, but this machine doesn't have the
Flutter SDK installed, so the platform folders (`android/`, `ios/`, etc.) haven't been generated
yet. Once you've installed Flutter:

```
flutter doctor          # confirm the SDK + a device/emulator are recognized
cd dtc_app
flutter create .        # fills in android/, ios/, and any other missing scaffold files
                         # (safe to run — it will not overwrite pubspec.yaml or lib/ since they already exist)
flutter pub get
flutter run
```

If `flutter create .` asks about the org/application id, use something like
`com.yourcompany.dtc_app` — this becomes the Android package name / iOS bundle id, so pick it
deliberately since changing it later touches multiple platform files.

## Next steps (per PROJECT_SPEC.md Section 11)

1. ~~Set up Supabase project, create schema, import Excel data~~ — see `../supabase/`
2. ~~Build the search screen~~ — `lib/screens/search_screen.dart`
3. ~~Build results/not-found screens, wire to a live Supabase query~~ — `lib/screens/results_screen.dart`, `lib/screens/not_found_screen.dart`, `lib/services/dtc_repository.dart`
4. ~~Add the consent screen + local "already agreed" persistence~~ — `lib/screens/consent_screen.dart`, `lib/services/consent_service.dart`
5. ~~Server-side daily quota logic~~ — built as Postgres RPC functions (`search_dtc`, `register_ad_view` in `supabase/schema.sql`) rather than an Edge Function, since Deno/the Supabase CLI aren't installable on this machine without Node. Same guarantee: rate limiting, the 3/day quota, and search logging all happen atomically server-side, and direct client access to `dtc_codes`/`search_logs` is now revoked — the RPCs are the only path in. Paywall screen: `lib/screens/paywall_screen.dart`.
6. ~~AdMob integration~~ — real SDK wired up (`lib/services/ad_service.dart`). **Revised after testing**: no forced interstitial anywhere anymore — ads are purely opt-in via the rewarded ad on the results screen (Section 4.4), which gates the detail unlock and only unlocks on a genuine earned-reward callback. Both the real **App ID** (`android/app/src/main/AndroidManifest.xml`) and the real rewarded **ad unit ID** (`lib/config/ad_config.dart`) are in place — this app is serving/requesting real ads, not test ones. Avoid excessive repeated watching during casual dev testing, and never click the ad content itself just to check it (invalid-traffic risk to the AdMob account, Section 6) — swap back to Google's public test unit via `--dart-define=ADMOB_REWARDED_UNIT_ID=ca-app-pub-3940256099942544/5224354917` if you need to do heavier testing.
7. Google Play Billing integration — **stubbed**: `lib/services/subscription_service.dart` always returns `false`, and the paywall's subscribe button just shows a "coming soon" message
8. ~~search_logs logging~~ — every search logs to `search_logs` via the `search_dtc` RPC, atomically with the quota check (no separate insert-only policy needed anymore)
9. ~~Offline-state detection~~ — `lib/services/connectivity_service.dart` + `OfflineScreen` in `lib/app.dart`
10. ~~Share button~~ — `lib/app.dart`'s `_shareResult`, using `share_plus`
11. End-to-end test, Play Store listing prep

## Post-spec additions (launch-prep polish, not in the original build order)

- ~~Rate-app prompt~~ — `lib/services/rate_prompt_service.dart`, using the native `in_app_review` API (not a custom dialog). Never on the first-ever successful search or right after a not-found result; re-asks every 5th qualifying successful search after that (there's no API to detect an actual completed rating, so "ask until they rate" isn't possible — Google's own review API enforces its own cooldown on how often the real dialog shows, so repeated requests are safe). **Note**: the native dialog generally only works for Play Store-installed builds — during `flutter run` sideloaded testing it will likely no-op even when the code runs correctly; check the `RatePromptService: count=X, isAvailable=Y` debug log line to confirm.
- ~~Settings/About screen~~ — `lib/screens/settings_screen.dart`, reached via a small gear icon on the search screen. Shows app version, support email (`lib/config/app_info.dart` — opens the device's mail app via `mailto:`), a Privacy Policy/Terms link, and a share-the-app action.
- ~~Privacy Policy hosting~~ — the code is on GitHub (`github.com/ymmkb92bk-design/code-car`) with Pages enabled from `master`/`docs`, serving the real Arabic-language policy page at `AppInfo.privacyPolicyUrl`. The source Markdown draft (`Privacy_Policy_and_Terms.md`, English, developer-facing) and the published HTML (`docs/privacy-policy.html`, Arabic, user-facing) are two different files — update both together if the policy changes, and remember the published one **still needs real legal review** before this app actually launches.
- Firebase Crashlytics — **pending**: blocked on the final Android package name (currently `com.example.dtc_app`, a placeholder — must be decided before creating the Firebase project, since Firebase ties its config to the package name).
- Package name decision — **pending user input**. Also blocks the Google Play Console app entry.

The `supabase_flutter` client is initialized in `lib/main.dart` with the project URL (defaulted
in `lib/config/env.dart`) and the **anon** key (never the service_role key, which must stay
server-side/in Edge Functions per Section 6). Run with:

```
flutter run --dart-define=SUPABASE_ANON_KEY=xxxx
```

Without that flag the app shows a "missing config" screen instead of crashing.

The Play Store link in the share text (`lib/app.dart`) is a placeholder
(`com.example.dtc_app`) — update it once you have a real package id / Play Store listing.
