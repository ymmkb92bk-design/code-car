# Privacy Policy & Terms of Use — DRAFT

> **This is a working draft, not a final legal document.** It was written to capture the
> compliance requirements this app needs to address (Saudi PDPL, Google Play Data Safety),
> not to serve as the actual published policy. Have a lawyer familiar with Saudi PDPL and
> consumer-protection law review and finalize the real text before this app goes live — PDPL
> fines can reach SAR 5 million per violation, and this draft has not been reviewed by anyone
> with a law license. The published in-app version also needs to be in Arabic (the app's
> only language); this draft is in English for internal working purposes.

---

## 1. What this document needs to cover

This app (أكواد الأعطال — DTC Lookup App) collects, at minimum:
- A device identifier (for daily free-tier quota tracking)
- Search history (the DTC codes looked up, vehicle brand if selected, timestamps)
- Subscription status (free / active / expired)

It does **not** collect: name, phone number, email, precise location, or payment details
(subscriptions are handled entirely by Google Play Billing — this app never sees payment info).

It also uses AdMob, which independently collects the device's Advertising ID and IP address
the moment the SDK initializes, for ad serving/measurement purposes, per Google's own policies.

---

## 2. Saudi PDPL (Personal Data Protection Law) — what applies

- **Applies regardless of company size or solo-developer status.** There is no small-business
  exemption. A single developer publishing this app is a data "controller" under PDPL.
- **Consent must be real**, not implied: an unchecked, opt-in checkbox the user must actively
  tick (already reflected in the consent screen spec — Section 4.1 of `PROJECT_SPEC.md` — do
  not pre-check it, do not bury it in a scroll the user won't read).
- **Right to deletion must be a working mechanism**, not just a promise in text.
  **Status: implemented** — a self-service "حذف بياناتي" (Delete my data) button in the
  Settings screen (`lib/screens/settings_screen.dart`) calls the `delete_my_data` Postgres RPC
  (`supabase/migrations/005_delete_my_data.sql`), which wipes the device's rows from
  `search_logs`, `daily_usage`, and `users` immediately — no manual developer processing
  required. The support email remains available as a fallback for anyone who can't use the
  in-app button.
- **72-hour breach notification duty** to SDAIA (Saudi Data & AI Authority) if a data breach
  occurs — this needs to be a real, actionable plan, not just a policy sentence.
- **Cross-border data transfer must be disclosed.** Supabase's servers are not physically
  located in Saudi Arabia; the policy text must say where data is actually stored/processed
  (check your specific Supabase project's region setting) and that it leaves the Kingdom.

---

## 3. Google Play — Data Safety requirements

- **Every SDK's data collection must match the Play Console Data Safety form exactly.** This
  includes AdMob and Supabase's own client libraries. Mismatches between what's declared and
  what the SDKs actually do are a common cause of Play Store enforcement action.
- **Device/Advertising ID counts as a declarable identifier** — must be listed in the Data
  Safety form since AdMob collects it.
- **A real, working data-deletion mechanism is required** for the Play Console's data-deletion
  requirements — not just a contact email with no defined process behind it.

---

## 4. Liability — who's responsible for what

| Component | Who's responsible if something goes wrong |
|---|---|
| Supabase data breach | The developer (as data controller) — though the data itself (device ID, search terms, subscription status) is low-sensitivity, limiting real-world exposure |
| AdMob data collection | The developer has a disclosure obligation — Google's SDK auto-collects Advertising ID + IP the moment it runs; no name/email/phone is ever extracted since the app never collects that |
| Google Play payment/billing breach | Not the developer — Google is merchant of record for all subscription payments; the app never touches payment data |

---

## 5. Liability / informational-only disclaimer (locked wording — see `PROJECT_SPEC.md` Section 9)

The in-app disclaimer text (consent screen + results screen footer) is:

- Full form: *"المعلومات في هذا التطبيق لأغراض معلوماتية فقط، وليست بديلاً عن الفحص عند مركز
  متخصص. لا نتحمل أي مسؤولية عن أي إصابة أو ضرر أو خسارة ناتجة عن استخدام هذه المعلومات."*
- Short form: *"⚠️ هذه المعلومات لأغراض معلوماتية فقط ولا تغني عن الفحص عند مركز متخصص"*

The full Terms of Use page must expand this into a proper liability-limitation clause covering:
informational-only purpose, not a substitute for professional diagnosis, no DIY-repair
guidance, and no liability for injury, property damage, or financial loss arising from use of
the app's content. **This is exactly the kind of clause that needs a lawyer's actual drafting**,
not just the placeholder short-form wording above.

---

## 6. Subscription terms (for the Terms of Use page)

- Free tier: 3 successful (found) lookups per day, tracked server-side by device ID.
- Paid tier: 5 SAR/month, unlimited lookups, no ads, all detail sections instantly visible.
- Billing is handled entirely through Google Play Billing — this app never processes payment
  details directly. **There is no in-app subscription-cancel button** — this is a deliberate
  choice, not an oversight: cancellation is always available independent of this app, through
  the user's own Google Play account (Play Store app → profile icon → Payments & subscriptions
  → Subscriptions → Cancel), since Google is the merchant of record.
- Rate limiting (Section 6 below) applies to **every** user, including active subscribers —
  paying for the service removes the daily search quota, not the anti-abuse rate limit.

### Grounds for subscription termination

The developer reserves the right to suspend or terminate any user's subscription/access upon
confirmed evidence of:
1. Automated/scripted extraction of the app's database ("scraping").
2. Abuse of the system that disrupts service availability for other users.
3. Payment fraud or chargeback abuse.
4. Republishing or redistributing the app's content without permission.

As of this writing, detection is manual (via `search_logs` patterns — e.g., abnormal volume, or
suspicious sequential code searches) and enforcement is manual via Google Play Console's
subscription revoke API, on a case-by-case basis. There is no automated enforcement system
built for this, and building one is not required before launch — this is a "handle it manually
if it genuinely happens" situation given the app's current scale, not something to
over-engineer preemptively.

---

## 7. Security posture (for reference, not user-facing text)

- Supabase's infrastructure holds SOC 2 Type 2, ISO 27001, and HIPAA-eligible certifications —
  the platform itself is not the primary risk. The realistic risk is **misconfiguration**
  (e.g., a Row Level Security policy left open, or a missing GRANT — both of which this project
  has already hit and fixed once during development; see `supabase/schema.sql`).
- Third-party SDKs (AdMob, Supabase client) are not a "backdoor" — they perform disclosed,
  documented data collection per their own published policies. The realistic risks are leaked
  API keys, outdated dependencies, and unsafe database queries — not the SDKs' mere presence.

---

## 8. App shutdown procedure (keep for future reference, not part of the published policy)

If this app is ever discontinued:

1. Give users advance notice before shutting down.
2. Explicitly cancel all active subscriptions via Google Play's API — don't just unpublish and
   assume billing stops on its own.
3. Refund any unused subscription time.
4. Unpublish the app, then request full removal from Play Console support.
5. Delete all Supabase data — the developer remains the data controller even after shutdown,
   so data must actually be deleted, not just left dormant.
6. Turn off AdMob.
7. Update the published privacy policy with a discontinuation date and confirmation that user
   data has been deleted.
