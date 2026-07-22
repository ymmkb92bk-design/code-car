# مشروع تطبيق أكواد الأعطال (DTC Lookup App) — Full Project Specification

This document is the single source of truth for building this app. Read this fully before writing any code.

---

## 1. What this app is

A single-purpose Arabic-language mobile app: the user types a vehicle diagnostic trouble code (DTC), and the app instantly returns a structured Arabic explanation. No browsing, no categories, no menus — code in, answer out. Fully online (no offline database bundled in the app).

Two attached reference files accompany this spec:
- `DTC_Arabic_Database_Template.xlsx` — the real content database (hundreds of DTC codes, fully written in Arabic)
- `dtc-app-prototype.jsx` — a working React prototype demonstrating the exact UI, input validation, and screen flow (build the real app to match this behavior, in whatever framework is chosen — Flutter, React Native, etc.)

---

## 2. Tech stack

- **Backend/database**: Supabase (Postgres). Start on the **free tier** — do not assume a paid tier is needed at launch.
- **Frontend**: Build in whatever framework the developer/user chooses (Flutter recommended for single-codebase Android+iOS, but React Native or another framework is acceptable). The attached `.jsx` prototype is a **behavior/logic reference**, not literally what must be used — it defines *how the app should work*, not the required tech stack.
- **Ads**: Google AdMob
- **Payments/subscriptions**: Google Play Billing
- **No third-party deep-linking service** — do not use Firebase Dynamic Links (discontinued August 2025). Use simple native App Links + a plain share message instead (see Section 8).

---

## 3. Database structure

### Source data
Import `DTC_Arabic_Database_Template.xlsx`, sheet `DTC_Data`, starting at row 3. Columns:
1. الكود (code) — primary key
2. مرجع (English) — **drop this column**, it's the content-writer's internal reference only, not for the app
3. المعنى (meaning) — Arabic description of the fault
4. الخطورة (severity) — one of: بسيط / متوسط / خطير
5. نوع السبب المحتمل (cause) — multi-line, bulleted with "• " prefix per line
6. ماذا تفعل (action) — recommended action text
7. علامات قد تلاحظها (symptoms) — observable symptoms

### Target Supabase schema

```sql
create table dtc_codes (
  code text primary key,              -- e.g. 'P0420'
  meaning text not null,
  severity text not null check (severity in ('بسيط','متوسط','خطير')),
  causes text[] not null,             -- split the bulleted cause field into an array, one item per bullet
  action text not null,
  symptoms text not null
);

create table users (
  user_id uuid primary key default gen_random_uuid(),
  device_id text unique,              -- used for free-tier daily limit tracking
  subscription_status text default 'free' check (subscription_status in ('free','active','expired')),
  subscription_expiry timestamptz,
  created_at timestamptz default now()
);

create table daily_usage (
  device_id text not null,
  usage_date date not null,
  search_count integer default 0,
  primary key (device_id, usage_date)
);

create table search_logs (
  id bigserial primary key,
  code text not null,
  brand text,                         -- optional, from the vehicle brand dropdown
  device_id text,
  found boolean not null,
  created_at timestamptz default now()
);
```

**Important:** when importing causes from the Excel bulleted text field, split on newline, strip the leading "• " from each line, and store as a Postgres array (`text[]`).

---

## 4. Screens (exact flow)

### 4.1 Consent screen (first launch only, shown once)
- Short data disclosure: collects only device ID, search history, subscription status — no name, no location
- Liability/informational-only disclaimer, shown as its own short line beneath the data disclosure (locked wording, see Section 9): "المعلومات في هذا التطبيق لأغراض معلوماتية فقط، وليست بديلاً عن الفحص عند مركز متخصص. لا نتحمل أي مسؤولية عن أي إصابة أو ضرر أو خسارة ناتجة عن استخدام هذه المعلومات."
- Checkbox: "بالمتابعة، أنت توافق على شروط الاستخدام وسياسة الخصوصية" with links to Terms/Privacy pages
- Button "موافق ومتابعة" — disabled until checkbox is checked
- Layout: everything vertically centered as one flowing block — do NOT use a top/bottom `space-between` layout that pushes the button far from the checkbox (this was a real bug caught and fixed in the prototype)
- Once agreed, never show again on that device

### 4.2 Search / Home screen
Two input fields:

**Field 1 — DTC code (required)**
- Auto-uppercase as the user types
- Strip any character that is not `a-z`, `A-Z`, or `0-9` (blocks Arabic letters, Arabic-Indic numerals, spaces, symbols) — validate on every keystroke, not on submit
- Max length: 5 characters
- First character must be **P, B, C, or U** — if the user's first typed character isn't one of these, reject/ignore the keystroke (don't let it enter the field at all)
- Placeholder text: "مثال: P0420" — must be styled in a visually dim/muted color, clearly distinct from the color used for real entered text, so it reads as a hint and not as pre-filled content (this was a real UX bug caught in testing — the placeholder looked identical to real input and confused the user into thinking they had to delete it first)

**Field 2 — Vehicle brand (optional)**
- Plain tap-to-select dropdown, no typing/filtering and no keyboard — select only from the fixed list (revised after hands-on testing: the original type-to-filter design popped the keyboard unnecessarily for a short, browsable list)
- Arabic brand names: تويوتا، هيونداي، كيا، نيسان، شفروليه، جي إم سي، فورد، هوندا، لكزس، مرسيدس، بي إم دبليو، مازدا (extend this list as needed)
- If left empty, log as "غير محدد" in search_logs
- This field is for analytics only — it does not affect the lookup result

Search button: disabled until code field has all 5 characters (revised after testing: originally 4+ characters, changed to require the full code before search is enabled).

On search: log the attempt to `search_logs` regardless of outcome (code, brand, device_id, found true/false).

### 4.3 Ad screen (brief, shown between search and results)
**Revised after testing**: this is now a plain loading state only — no ad plays here. The original design had a forced interstitial on every search, but stacking it with another interstitial on "search again" felt like a wall of ads and risked hurting retention/ratings for little extra revenue. Ads are now purely opt-in via the rewarded-ad button on the results screen (Section 4.4) — the app's only ad placement. This screen just covers the brief real network wait for the `search_dtc` RPC call.

### 4.4 Results screen (if code found)
- **Always shown instantly, never gated**: the code itself, the meaning, and a color-coded severity badge (🟢 بسيط / 🟡 متوسط / 🔴 خطير)
- **Gated behind one optional action**: a single button — "شاهد إعلان قصير لعرض التفاصيل الكاملة" — tapping it plays a rewarded video ad, then reveals: causes (as a bulleted list), action, and symptoms, all at once (not one-by-one, not further sub-gated). **Status: implemented** — details unlock only on a genuine earned-reward callback from the real AdMob rewarded ad, never just from tapping the button; also gated by the per-device daily rewarded-ad cap (Section 6).
- **Subscribers** (subscription_status = 'active'): skip the ad entirely, all sections show instantly
- Two buttons at the top of this screen, styled as real buttons (background + border, not plain text) — this was a real UX bug caught in testing where plain-text links were too easy to miss:
  - "→ بحث جديد" (search again) — clears state and returns to search screen instantly, no ad (revised after further testing: this went through two design changes — originally deferred the ad to the *next* search, then changed to play immediately on tap, now removed entirely per Section 4.3's revision to opt-in-only ads)
  - "مشاركة ⤴" (share) — see Section 8
- Persistent small footer disclaimer, always visible on this screen regardless of gating state (locked wording, see Section 9): "⚠️ هذه المعلومات لأغراض معلوماتية فقط ولا تغني عن الفحص عند مركز متخصص"

### 4.5 Not-found screen (if code not found)
- Message: "لم نجد هذا الكود بعد" / "نعمل على إضافة المزيد من الأكواد باستمرار." — nothing more. Do not tell the user their search was "logged" or "registered" — that happens silently in the backend, never announce it to the user.
- **One single button**: "بحث عن كود آخر" — do not duplicate this action with a second button elsewhere on the same screen (this exact duplication was a real bug caught in testing — there was a redundant second "بحث جديد" button at the top of this screen that did the same thing; it was removed)
- Tapping this button returns to the search screen instantly, no ad (revised — see Section 4.3)

### 4.6 Offline screen
- If the device has no network connection, show this instead of any other screen: "لا يوجد اتصال بالإنترنت" + explanation + "إعادة المحاولة" button
- Detect via the platform's standard network-status API (e.g., `navigator.onLine` equivalent, or Flutter's `connectivity_plus` package)

### 4.7 Settings/About screen (added post-spec, launch-prep requirement)
Not in the original screen list — added because Google Play requires a Privacy Policy link accessible from inside the app itself, not just on the Play Store listing page. Reached via a small settings icon on the search screen (doesn't interrupt the app's single-purpose flow). Shows: app version, support contact email (opens the device's mail app), a Privacy Policy/Terms link (opens in browser), and a "شارك التطبيق" share action.

---

## 5. Monetization logic

### Free tier
- **3 successful (found) lookups per day**, tracked server-side in `daily_usage`, keyed by `device_id` (not stored client-side only — must survive app reinstall being at least somewhat resistant, though device-ID-based tracking has known limits; this is an accepted tradeoff, not a bug)
- **Critical rule**: only searches where `found = true` decrement the daily quota. Not-found searches do NOT count against the 3/day limit — this protects users from losing a free search to a gap in the database that isn't their fault.
- **Revised after testing**: no forced ad plays on search anymore (originally spec'd as "one light ad on every search" — removed because stacking it with the ad on "search again" felt like a wall of ads). Ads are now purely opt-in.
- Optional rewarded ad unlocks full detail per search (see 4.4) — this is now the app's only ad placement

### Paid tier — 5 SAR/month
- Unlimited lookups, zero ads, all sections always instantly visible
- Managed entirely through **Google Play Billing** — do not build a custom payment/subscription system. Check subscription status by querying Google Play Billing's API / listening for its real-time developer notifications, and update `users.subscription_status` accordingly via webhook.

### After the 3rd free search of the day
Show a soft paywall: "استخدمت بحثك المجاني لهذا اليوم" with options to subscribe or wait until tomorrow (limit resets at midnight or on a rolling 24hr basis — either is acceptable, pick one and be consistent).

**Status: implemented** (`lib/screens/paywall_screen.dart`, quota enforced by the `search_dtc` RPC) — reset is midnight-based (`usage_date` is a date column, reset follows the Supabase Postgres server's timezone). The subscribe button is currently a placeholder (shows a "coming soon" message) until build-order step 7 wires up real Google Play Billing.

---

## 6. Anti-abuse (build these in from the start, not as an afterthought)

**Status: implemented** as Postgres `SECURITY DEFINER` RPC functions (`search_dtc`, `register_ad_view` in `supabase/schema.sql`) rather than an Edge Function — same server-side trust guarantee, chosen because Deno/the Supabase CLI weren't installable in this project's dev environment without Node. Direct client access to `dtc_codes` and `search_logs` has been revoked; the RPCs are the only path in, so quota/rate-limit checks can't be bypassed by calling the REST API directly.

- **Never trust the client for quota enforcement.** The daily search count must be checked and incremented server-side (a Supabase Edge Function or equivalent), not just tracked in local app storage.
- **Rate limiting**: cap requests per device/IP at a sane ceiling (e.g., 10/minute) regardless of daily quota, to block scripted/bot abuse. (Implemented per-device only for now; per-IP is a possible future enhancement using PostgREST's request header access.)
- **Rewarded-ad abuse cap**: limit rewarded-ad views to roughly 10-15/day per device as a safety margin on top of AdMob's own fraud detection — excessive rewarded-ad-watching on one device risks the entire AdMob account being flagged for invalid traffic, which is a severe, account-wide risk, not a minor issue.
- **Search log spam filtering**: when building the "most searched" analytics later, deduplicate rapid repeated searches of the same code from the same device before counting them toward demand rankings. (Not yet implemented — analytics queries in Section 7 don't dedupe yet.)

---

## 7. Analytics (for the app owner, not user-facing)

Build two simple queries/dashboards against `search_logs`:

```sql
-- Most searched codes
select code, count(*) as searches
from search_logs
group by code
order by searches desc;

-- Codes searched but not in the database (prioritized "add next" list)
select code, count(*) as times_searched
from search_logs
where found = false
group by code
order by times_searched desc;

-- Brand breakdown per code (optional, for future coverage decisions)
select code, brand, count(*)
from search_logs
group by code, brand
order by count(*) desc;
```

---

## 8. Sharing (no third-party service)

Firebase Dynamic Links is discontinued (shut down August 2025) — do not use it, and do not use a paid attribution platform (Branch, AppsFlyer, etc.) — those are enterprise-priced and unnecessary here.

**Share button behavior**: opens the native OS share sheet with a plain text message containing:
- The DTC code
- A one-line teaser (the meaning + severity, since that part is always free/instant anyway)
- A link to the app's Google Play Store listing

If the recipient already has the app installed, a standard Android App Link can open the app directly (free, native, no third-party service needed). If they don't have it, they land on the Play Store, install, then manually type the same code shown in the shared message — this small friction is an accepted tradeoff, not a bug to fix.

---

## 9. Content/terminology rules (apply consistently, do not deviate)

These terms are locked and must be used exactly as written throughout the app and any new content:

- **"مركز متخصص"** for any shop/garage/service center reference. Never use "ورشة."
- **"عطل في جهاز الكمبيوتر"** for any generic control-unit/ECU fault — do not name a specific module (engine computer, ABS computer, TCM, etc.) since a code can't always be attributed to one specific unit with certainty.
- **"مشكلة كهرباء"** for generic wiring/electrical faults.
- **"الحساس نفسه عطلان"** for "the sensor itself is broken" — do not use variants like "حساس عطلان", "عطل بالحساس نفسه", "حساس خربان", "عطل في الحساس".
- **"بوابة هواء دعسة بنزين"** for the throttle body / throttle-by-wire air valve.
- **"حساس سلك دعسة بنزين"** for the throttle-by-wire pedal/cable sensor (distinct from the above — one is the sensor, one is the physical air valve/body).
- Ignition coils are numbered (كويل الشرارة رقم ١ through ٨), never lettered (not أ ب ج د).
- Input/output transmission speed sensors use "الداخلي" (internal/input) and "الخارجي" (external/output).
- "يحتاج برمجة أو إعادة برمجة" for any calibration/relearn procedure — never use "معايرة" or similar.
- Steering angle sensor: "حساس زاوية الدركسون".
- Catalyst: "دبة الشكمان" only — never append "(المحول الحفاز)".
- All bulleted cause lists use plain "• " prefixes with no repeated "احتمال" on every line (the column header already conveys these are probable causes).
- EVAP-related action text should reference smoke-machine leak testing as the diagnostic method used at the service center.
- Transmission-related generic codes (internal TCM solenoid/pressure faults) should recommend checking transmission fluid level first, then a specialist — but ECU/computer-internal codes (memory, processor faults like P0601, P0603, P0604, P062F, P0605, P0606) are NOT transmission-fluid issues and must not include fluid-check advice.
- All temperature sensor codes (coolant, intake air, transmission fluid temp) and all throttle-position/throttle-by-wire codes are rated **خطير** (not بسيط/متوسط) — this reflects a deliberate content decision that these carry real driveability/limp-mode risk.
- **Liability/informational-only disclaimer** — locked wording, used in two forms:
  - Full form (consent screen, Section 4.1, and the Terms of Use page): "المعلومات في هذا التطبيق لأغراض معلوماتية فقط، وليست بديلاً عن الفحص عند مركز متخصص. لا نتحمل أي مسؤولية عن أي إصابة أو ضرر أو خسارة ناتجة عن استخدام هذه المعلومات."
  - Short form (results screen footer, Section 4.4): "⚠️ هذه المعلومات لأغراض معلوماتية فقط ولا تغني عن الفحص عند مركز متخصص"
  - The Terms of Use page (linked from the consent screen checkbox) must also carry a fully-worded liability clause covering: informational-only purpose, no DIY-repair guidance, and no liability for injury/damage/loss arising from use of the app's content. That page's exact legal drafting is outside this spec's scope — have it reviewed by a lawyer familiar with Saudi PDPL and consumer-protection rules before Play Store submission; do not rely on this spec's wording as the final legal text.

---

## 10. Known bugs already found and fixed in the prototype (do not reintroduce these)

1. **Input losing focus while typing**: caused by defining screen components *inside* the parent component's function body, which makes React (or equivalent) treat them as new component instances on every re-render, unmounting the input and losing keyboard focus. All screen components must be defined at the top level / module scope, never nested inside another component's render function.
2. **Placeholder text visually identical to real input**: placeholder must be a distinctly muted/dim color and different weight from real entered text.
3. **Consent screen button pinned far below content**: use a single vertically-centered flowing layout, not a top/bottom split.
4. **Duplicate "search again" buttons** on the not-found screen: only one action button should exist per screen for the same action.
5. **Low-contrast/small Arabic text**: body text should be sized generously (Arabic script needs slightly larger sizing than Latin text to feel equally readable at a glance) and muted-text colors must maintain real contrast against the dark background (avoid dim grays under roughly `#A0A8B5` on a dark navy background).

---

## 11. Build order (recommended)

1. Set up Supabase project (free tier), create the schema in Section 3, import the Excel data
2. Build the search screen with exact input validation from Section 4.2
3. Build the results screen and not-found screen, wire to a live Supabase query
4. Add the consent screen and local "already agreed" persistence
5. Add device-ID-based daily quota logic (server-side check)
6. Integrate AdMob (banner + rewarded video)
7. Integrate Google Play Billing for the 5 SAR/month subscription
8. Add search_logs logging on every search
9. Add offline-state detection
10. Add the share button (native share sheet, no third-party service)
11. Test end-to-end, then prepare Play Store listing (privacy policy, data safety form, screenshots)

---

## 12. What is explicitly NOT in scope for v1

- No offline/local database bundling — fully online only
- No category browsing / general search beyond exact DTC code lookup
- No user reviews or ratings on individual codes
- No cross-device search history sync (would require full account system beyond device ID)
- No Firebase Dynamic Links or paid attribution platforms
