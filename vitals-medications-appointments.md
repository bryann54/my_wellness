# Vitals, Medications & Appointments

<!-- guide-header:start -->
> **Guide set `2026-11-16.b9b79a`.** Every file in this guide carries this same line.
>
> **Related files you need open with this one:** `README.md` (shared conventions), `account-and-profile.md`, `assessments.md`, `bookings-and-consultations.md`, `payments-and-packages.md`, `push-notifications.md`
>
> **AI agents, before building anything from this file:** check that you have each related
> file and that its guide-set line reads exactly `2026-11-16.b9b79a`. If a file is missing or its line
> differs, stop and ask the developer for the current copy, naming the files you need (or
> fetch them: `GET /api/mobile-guide/<filename>/`, README "Fetching this guide itself, over
> HTTP"). Never fill a gap from memory or an older copy. Anything the app already shows that
> this guide doesn't describe is out of date: the app must match the website and WhatsApp.
<!-- guide-header:end -->

> **Before building anything from this file, check it against the web
> platform** — the user web app, live on staging at https://staging.mywellnesshealth.co.ke/ (the source of truth).
> The mobile app implements exactly the regular-user features that exist
> and are usable there, with the same screens, labels and wording, and
> nothing more: no doctor, admin or organization-buyer features, no
> hidden UI, no mobile-only extras, and a feature behind one of web's
> build switches only behind the same switch. If something
> here doesn't match the web platform, or you think a feature is missing,
> don't build it — confirm with the product owner first.

The **Vitals & Chronic Care** pages (**Blood Pressure**, **Blood Sugar**),
with server-computed classification (the real thresholds never ship to a
client), the monitoring-profile onboarding each uses, and the vitals PDF
report. Then **Medications** (the dashboard's "My medications" card and
the `/medications` page), **Appointments** (the dashboard's "My
appointments" card and the `/appointments` page), and the Women's
Health **Period & Pain Tracker**. The vitals pages themselves show no
medication or appointment widget.

All endpoints below require `Authorization: Bearer <access_token>` and
live under the bare `/api/...` prefix (no extra segment). See the
[README](./README.md) for the shared envelope. Note: errors raised as
DRF exceptions arrive as `{"error": {"detail": <DRF detail>,
"status_code": N}}`, so a serializer error
is `error.detail.<field>` and a `{"detail": "…"}` error is
`error.detail.detail`. The vitals `402` below is the one exception: it's
returned directly, not through that handler, so it's **not** wrapped.

## The paywall gate (Monitoring access)

BP/BS logging is paywalled. **It is no longer a permanent one-time
unlock.** Access (`has_access` from `GET /api/vitals/access/`, below)
is true when the user has an **active (unexpired) `Monitoring`
`ModuleAccess` grant**, or a legacy `VitalsAccess` row (old one-time
buyers, kept forever), or the account is in its **free first month**:
the 30 days after sign-up (`date_joined`) are free for everyone, with no
purchase and no grant row. A `demo_restricted` account is always blocked
unless staff cleared it (`vitals_demo_cleared_at`), free month included.
Because Monitoring grants and the free month expire, re-check access
rather than caching it forever. Call:

```
GET /api/vitals/access/
→ 200 { "has_access": true|false, "demo_restricted": true|false, "state": "open"|"locked"|"demo_locked", "navigator_alerted_at": "<iso datetime>|null", "free_until": "<iso datetime>|null" }
```

`free_until` is when the free month ends. It is set only while the
account is in that month (even if it has also paid), and `null` after it
and for a blocked demo account. The backend decides access; use
`has_access`/`state` for the gate. Web doesn't show `free_until`
anywhere (no "free until" date or banner on any screen), so mobile
shouldn't either.

Use this endpoint, not `GET /api/payments/module-access/`'s
`unlocked["Monitoring"]`: only this one also counts the legacy grant,
the free month and the demo block. Web caches it for 60 seconds.

If `has_access` is `false`, these all return the same unwrapped `402`:
`POST /vitals/blood-pressure/`, `POST /vitals/blood-sugar/`,
`POST /vitals/blood-sugar/decision-preview/`,
`POST /vitals/classify-preview/`,
`PUT /vitals/bp/monitoring-profile/`,
`PUT /vitals/blood-sugar/monitoring-profile/`, `POST /vitals/bp/sessions/`
and every session sub-step, `POST /vitals/report/`,
`POST /vitals/report/email/`. `POST /vitals/bmi-preview/` returns the same
`402` only for a `demo_restricted` account staff haven't cleared
(`vitals_demo_cleared_at` unset); a cleared demo account gets `200`. It
ignores the other access rules.

```
402 { "detail": "A one-time payment unlocks day-to-day blood pressure/blood sugar logging. Buy the logging package, or a Basic/Plus/Pro wellness package, to continue.", "code": "vitals_access_required" }
```

(That copy is stale. It still says "one-time", but the gate is now the
expiring Monitoring access. Branch on `code`, and don't show `detail` as
the paywall text.)

Reads are **not** gated: reading lists, monitoring-profile `GET`s,
content, `summary`, and `report/email-prefill` all work without access.

**What web does (mirror it):**
`GET /api/vitals/access/` also returns `state`: `open`, `locked` or `demo_locked`.

- **`state: "locked"`** → the Blood Pressure and Blood
  Sugar pages **redirect straight to the Monitoring purchase flow**
  (`/wellness-packages?service=monitor`) before rendering anything (no
  onboarding wizard, no medications/appointments/history). The
  dashboard's two vitals cards do the same on tap
  (https://staging.mywellnesshealth.co.ke/vitals/blood-pressure,
  https://staging.mywellnesshealth.co.ke/dashboard). The purchase and
  post-payment wait follow [`payments-and-packages.md`](./payments-and-packages.md)
  (Monitoring → back to blood-pressure logging, waiting for
  `GET /api/vitals/access/` to show `has_access: true`). Because the
  redirect always fires first, the pages never show a locked logging card
  or take a payment themselves; mobile needs neither.
- **`state: "demo_locked"`** → no redirect. Web skips the whole
  onboarding wizard and shows the main page, with this card in place of
  the tips box and logging form, and hides the report buttons and the
  "Change monitoring reason" link. The history card (and Pathway D's
  not-on-medication card) still show. The card is titled **"Payment
  received"**:
  - Before an alert: *"When you're ready to complete this assessment over
    the phone, let our team know."* and an **"Alert Health Navigator"**
    button.
  - Once `navigator_alerted_at` is set: *"A member of our team will call
    you at <profile phone> within one business day to complete this for
    you over the phone."* and *"Nothing else to do on your end for now."*

**Demo-mode navigator alert:** `POST /api/vitals/alert-navigator/` (no
body) is that **"Alert Health Navigator"** button. It stamps
`navigator_alerted_at` (idempotent: a second call is a no-op) and returns
the same shape as `GET /vitals/access/`. Only offer it when
`demo_restricted` is `true` and `has_access` is `false`, and switch to the
already-alerted copy once `navigator_alerted_at` is set.

## Live classification preview (no DB write)

Web calls this as the user types, debounced **350ms**. Replicate that debounce; don't fire one request per
keystroke:

```
POST /api/vitals/classify-preview/
```

Accepts exactly **one** of these shapes per call (never mix):
- `{ "systolic": 150, "diastolic": 95 }`: BP preview.
- `{ "pulse": 110 }`: pulse preview.
- `{ "value": 7.2, "unit": "mmol/L", "reading_type": "fasting" }`: BS
  preview. `unit` is required except for `hba1c` (omit it). `meal_timing`
  (`less_than_2h` | `at_least_2h`) is **required** when `reading_type` is
  `post_meal`.
- `{ "weight_kg": 70, "height_cm": 170 }`: BMI preview.

→ BP: `200 { "classification": "orange_1", "alert": null }`. When `alert` isn't null it
is `{ "title", "text" }`: show it as an urgent panel.
→ BS: `200 { "classification": "<BS identifier>" }`.
→ Pulse: `200 { "classification": "blue" | "green" | "yellow" | "red" }`, the
monitoring tool's own 4-colour heart-rate scale,
not the 6-band pulse scale described under "BP band identifiers". BMI returns a different shape:
`200 { "bmi": 24.2, "classification": "underweight" | "normal" | "overweight" | "obese", "deficit_kg": <number|null> }`
Same input ranges as logging (systolic
50–300, diastolic 30–200, pulse 20–250). It's gated by the same access
check as logging (same `402`), so a blocked account can't
reverse-engineer the thresholds through it.

The preview returns only the identifier. Web turns it into text with its
own label tables (the BP and pulse tables below, the BS table under Blood
Sugar). Saved readings carry the server's own `classification_label`.

Where web shows it:
- The BP reading form colours the typed systolic/diastolic by the BP band
  and the pulse by the pulse colour, and shows the response's `alert`.
- Blood sugar no longer uses this endpoint for its form; it uses
  `/vitals/blood-sugar/decision-preview/` (see Blood Sugar).
- The BMI step doesn't use this endpoint (see "The BMI step").

## Blood Pressure

Web's Blood Pressure page (https://staging.mywellnesshealth.co.ke/vitals/blood-pressure,
its logging card) uses the
**session** flow below, not a single flat log call. Replicate the session
flow, or mobile will skip the mandatory-repeat/wellbeing logic web
enforces. **Drive the UI entirely off the session's `status`**, exactly
like web: `awaiting_second_reading` → repeat-reading form,
`completed` → result card. A new session only ever returns those two.
Web keeps the session in memory only and never reopens a saved one
(leaving the page starts a fresh "Log a BP reading" form next time), so
web never reaches `awaiting_wellbeing` or `awaiting_third_reading`
(old pre-redesign sessions only). Mobile, which also starts every
session fresh, doesn't need those steps (sections 4 and the third-reading
note below).

### 1. First-time setup (2026-11-03 redesign)

The whole Blood Pressure screen uses the redesign's own look (the app's
Poppins typeface like every other screen, full-width setup and logging,
no card frame around the reading form). The header is the site's
standard **"← Back"** pill, then the brand row: "MY WELLNESS HEALTH" /
**"Blood pressure monitoring"**. There is **no intro screen, no quick
profile questions and no tips screen** any more.

First-time setup is a few focused steps, with a progress box reading
"<step title>" and "Step N of M":

1. **"Your monitoring reason"**: "Why are you monitoring?" ("Choose the
   option that best describes you."), a **"Monitoring reason"** dropdown
   ("Select monitoring reason") with the `pathway_options` labels. If
   nothing is picked: "Please choose why you are monitoring." When
   `profile.gender` is blank (legacy accounts only) a **"Gender"** dropdown
   ("Select your gender", Female / Male; error "Please choose your
   gender.") shows under it and is saved with `PATCH /api/health-profile/
   { "gender" }` on Continue; Blood Sugar's set-up screen does the same.
   On Pathway D the optional "not taking medication" card (below) shows
   under it.
2. **"Your BMI check"**, only while the health profile's `bmi_prompt_due`
   is true (see "The BMI step" below).
3. **"Your dialysis schedule"** (`dialysis_setup_title`), Pathway E only:
   `dialysis_setup_hint`, then `kidney_treatment_question` ("Are you
   currently receiving dialysis?") with the `kidney_treatment_options`
   radios. Only for `hemodialysis`/`peritoneal`: `dialysis_days_question`
   ("Which days do you receive dialysis?"), a Mon–Sun day picker (enabled
   only for "Selected days"), the `dialysis_schedule_options` radios
   (Every day / Schedule varies / Selected days / Not sure yet) and
   `dialysis_days_hint`. (Server changed 2026-11-03; the old "1 to 3 days"
   rule is gone.)

The button reads **"Continue to BMI"**, **"Continue to dialysis
schedule"** or **"Continue to BP recording"**, whichever comes next
("Saving…" while it saves). The pathway (`PUT .../monitoring-profile/`)
is saved when the reason step's Continue leads to another step (so
leaving during the BMI step doesn't ask for the reason again), except on
Pathway E, which can only be saved once the dialysis step is answered; it
is otherwise saved on the last step. On the last step web also sends,
the first time, `PATCH /api/health-profile/ { "htn_onboarding_seen": true }`.

When it shows setup:
- `GET .../monitoring-profile/` returns `setup`: `full` starts from step 1, `bmi_only` shows
  the BMI step alone and Continue goes straight to logging, `dialysis`
  shows the dialysis step alone (below), `none` goes straight to logging.
  The server checks them in that order (`full`, then `bmi_only`, then
  `dialysis`). The app reads `setup` and never works these cases out itself.
- **"Change monitoring reason"** (a link under the history card) reopens
  step 1 and re-saves the pathway.
- **"← Back"**: during first-time setup, dialysis → BMI (or reason when
  there's no BMI step) and BMI → reason. On the first-time reason step,
  the BMI-only step and the logging screen it leaves the page. On the
  reason step opened from "Change monitoring reason" it returns to the
  logging screen without saving.
- **`setup: "dialysis"`** is a Pathway E profile saved before the
  dialysis question existed: no dialysis status yet, or haemodialysis/
  peritoneal dialysis on "Selected days" with no days saved. Web shows the
  one-time **"Your dialysis schedule"** step (step 3's content above) on
  its own before logging, with the footer "This is a one-time dialysis
  setup. Your schedule can be updated later." and the button **"Continue
  to BP recording"**. Before saving, web checks: no status picked →
  "Please choose your dialysis status."; "Selected days" with no day
  ticked → "Choose your dialysis days, Every day, Schedule varies or Not
  sure yet." Continue re-saves the pathway with the dialysis answers
  (`PUT .../monitoring-profile/`, the server's own Pathway E errors below
  still apply) and opens logging. "← Back" on this step leaves the page.
  The same step and footer also show during first-time setup on Pathway E.

```
GET /api/vitals/bp/monitoring-profile/
→ 200 { "pathway": "<choice>|\"\"", "provider_plan", "treatment_gap_reasons", "treatment_gap_other_text", "kidney_treatment": "ckd|hemodialysis|peritoneal|other|\"\"", "dialysis_schedule": "specific|daily|varies|unknown|\"\"", "dialysis_days": [0-6, ...], "dialysis_schedule_label": "<text>|null", "is_dialysis_day_today": bool, "dialysis_pre_logged_today": bool, "dialysis_post_logged_today": bool, "next_dialysis_phase": "pre|post|null", "setup": "full|bmi_only|dialysis|none", "updated_at" }
```

All setup copy (reason options, the not-on-medication question and its
options, dialysis question/hint, tips) comes from the content endpoint.
Don't hardcode it:

```
GET /api/vitals/bp/content/
→ 200 { "onboarding": { "intro": {...}, "tips": { "title", "intro", "items": [...] } }, "pathway": { "pathway_question", "pathway_options", "provider_plan_question", "provider_plan_options", "treatment_gap_question", "treatment_gap_hint", "treatment_gap_options", "treatment_gap_other_hint", "medication_step", "dialysis_setup_title", "dialysis_setup_hint", "kidney_treatment_question", "kidney_treatment_options", "dialysis_schedule_options", "dialysis_days_question", "dialysis_days_hint", "day_options" }, "repeat": { "title", "rest_instructions", "feeling_question", "feeling_options", "feeling_required_error", "symptom_detail_question", "symptom_detail_hint", "symptom_detail_options": [{ "value", "label", "serious": bool }], "symptom_detail_required_error", "medication_note" } }
```

(Static copy, server-cached 1h. Web keeps it for 5 minutes.) Web no longer
uses `onboarding.intro`, `provider_plan_*` or `medication_step`; only
`onboarding.tips.items` (the "Measure BP correctly" box) and the
`pathway` keys above.

Then set the pathway. Each pathway-specific field is rejected if sent for
a different pathway, so don't send fields from a previously-selected
pathway:

```
PUT /api/vitals/bp/monitoring-profile/
{ "pathway": "...", "treatment_gap_reasons": [...], "treatment_gap_other_text": "...", "kidney_treatment": "hemodialysis", "dialysis_schedule": "specific", "dialysis_days": [1, 3, 5] }
→ 200 <same shape as GET>
```

| `pathway` | Label (`pathway_options`) | What web sends |
|---|---|---|
| `routine` (A) | Routine / wellness check / hospital visit | nothing extra |
| `provider_directed` (B) | A healthcare professional asked me to monitor | nothing extra (web no longer asks the provider-plan question; `provider_plan` is optional server-side) |
| `diagnosed_on_medication` (C) | I have hypertension and take medication | nothing extra |
| `diagnosed_not_on_medication` (D) | I have hypertension and do not take medication | `treatment_gap_reasons` (optional list) and `treatment_gap_other_text` (only with `other`) from the card below |
| `kidney_dialysis` (E) | Kidney disease / dialysis monitoring | `kidney_treatment` **required** (`ckd`, `hemodialysis`, `peritoneal`, `other`). Only for `hemodialysis`/`peritoneal`: `dialysis_schedule` **required** (`specific`, `daily`, `varies`, `unknown`); only for `specific`: `dialysis_days` **required**, 1–7 distinct weekdays, `0`=Monday … `6`=Sunday. Sending a schedule for `ckd`/`other`, or non-empty days for a non-`specific` schedule, is a 400. |

Pathway E errors: `kidney_treatment` *"Please tell us whether you are
currently receiving dialysis."*; `dialysis_schedule` *"Please choose your
dialysis days or schedule."* / *"Only applies when you are receiving
dialysis."*; `dialysis_days` *"Choose 1 to 7 distinct days."* / *"Only
applies when your schedule is set to selected days."*. Any of the three on
another pathway: *"Only applies to Pathway E (kidney & dialysis
monitoring)."*

`is_dialysis_day_today` is true only when on dialysis and the schedule is
`daily`, or `specific` with today's weekday in `dialysis_days`; always
false for `ckd`, `other`, `varies` and `unknown` (no dialysis-day
requirements or reminders for those).

**Pathway D's "not taking medication" card** (optional, collapsed by
default; it never changes the result): its summary is
`treatment_gap_question`, opening to "<treatment_gap_hint> You can review
or update your response.", one checkbox per `treatment_gap_options`, and
a "<treatment_gap_other_hint>" text box when "other" is ticked. The line
under it reads "Tap the question to select all that apply. Your answers
will not change the monitoring result." (or "Response saved to your
health record. Tap to review or update." once saved). In setup it's saved
with the pathway; on the logging screen it has its own **"Save
response"** / **"Update response"** button, which re-sends the pathway
with the reasons. Treatment-gap reason values: `not_started`,
`provider_stopped`, `self_stopped`, `cannot_afford`, `out_of_stock`,
`facility_far`, `side_effects`, `forget`, `feel_well`,
`advised_without_medication`, `other`, `not_sure`.

**The logging screen**, top to bottom:
1. A collapsible **"Measure BP correctly"** box ("<N> quick tips"),
   listing `onboarding.tips.items`.
2. The **"Log a BP reading"** form (below), then the result after a save.
3. Pathway D's not-on-medication card.
4. **"My BP history"** with the report buttons.
5. The **"Change monitoring reason"** link and the line "Clinical
   guidance is general and does not replace individual advice or
   emergency care."

On Pathway E the dashboard also shows, above the vitals cards:
- `dialysis_schedule_label` from the monitoring profile, when it isn't null.
- When `is_dialysis_day_today` is true, a **"Today is a dialysis day"**
  card ("Don't forget your dialysis appointment today."). On web it also
  offers **Enable reminders** until push is on. The dialysis-day reminder
  itself is server-sent; see
  [`push-notifications.md`](./push-notifications.md).

### The BMI step (both tools)

"Body Mass Index (BMI)" with an **OPTIONAL** tag ("Your compact BMI
check" on BP, "Compact live BMI check" on Blood Sugar), "Weight (kg)"
(20–400) and "Height (cm)" (80–250; the server accepts the same ranges,
anything else is a `400`). Send both to `POST /api/vitals/bmi-preview/`
`{ "weight_kg", "height_cm" }`. It needs no Monitoring access; it
returns the unwrapped vitals `402` only for a `demo_restricted` account
staff haven't cleared (see the paywall gate above), and a cleared demo
account gets `200`. The response:

```json
{
  "bmi": 34.6, "category": "obese",
  "assessment": { "label": "Obese", "note": "...", "weight_action": "Lose about 28.0 kg to reach a healthy weight (...)." },
  "monitoring": { "category_label": "Well above reference range", "in_reference_range": false,
                  "tag": "Review weight", "reference_range": "53.5–72.0 kg",
                  "second_metric_label": "Weight difference", "second_metric": "28.0 kg", "guidance": "..." }
}
```

- Box: "YOUR CALCULATED BMI", `bmi` with "kg/m²" (green when `in_reference_range`, red
  otherwise), `category_label` and `tag`.
- Two small boxes: "Reference weight range" (`reference_range`) and `second_metric_label`
  (`second_metric`).
- `guidance` underneath.
- Before both are valid: "Enter both measurements to see your BMI and
  category."

There's no disclaimer or "BMI is optional…" note under the step (removed
2026-11-03). It's optional: leave both blank to skip; one blank or out of range gives
"Enter both valid measurements, or leave both blank to skip BMI." On
continue web sends `PATCH /api/health-profile/` with either
`{ "weight_kg", "height_cm" }` or `{ "bmi_prompt_skipped": true }`. The
profile's `bmi_prompt_due` is true while there's no BMI from the last
**four calendar months** and the step wasn't skipped in the last four
months (see [`account-and-profile.md`](./account-and-profile.md)). QA test accounts (`TEST_USER_EMAILS`) follow the same rule since 2026-11-03 (their BMI is no longer masked), so they see the step once per four months like everyone else.

### 2. Start a session (first reading)

```
POST /api/vitals/bp/sessions/
{
  "systolic": 150, "diastolic": 95, "pulse": 88,   // pulse optional (omit or null)
  "dialysis_phase": "pre",  // "pre" | "post"; only on a Pathway E dialysis day, and then REQUIRED
  "weight_kg": 70           // only on a Pathway E dialysis day, and then REQUIRED
}
→ 201 {
  "id": "<session uuid>",
  "first_reading": { "id": "...", "systolic": 150, "diastolic": 95, "pulse": 88, "classification": "orange_1", "classification_label": "High Blood Pressure", "pulse_classification": "green", "pulse_classification_label": "Normal Heart Rate", "dialysis_phase": "", "taken_at": "...", "notes": "" },
  "second_reading": null, "third_reading": null,
  "bp_category": "orange_1", "bp_category_label": "High Blood Pressure",
  "repeat_required": false, "repeat_wait_seconds": null,
  "wellbeing_question_text": "",
  "feeling": "", "symptom_detail": "", "is_emergency": false,
  "final_title": "High Blood Pressure",
  "final_cta": "visit_health_facility", "final_cta_label": "VISIT A HEALTH FACILITY", "final_recommendation": "<text>",
  "pulse_note": "",
  "result": {
    "colour": "orange", "colour_label": "Orange",
    "title": "Clinical Assessment Needed",
    "systolic": 150, "diastolic": 95, "pulse": 88,
    "recommendation": "Your blood pressure is elevated and needs further assessment.",
    "cta": "Visit a healthcare facility",
    "pulse_result": { "colour": "green", "title": "Normal Heart Rate", "recommendation": "Your resting pulse is in the usual adult range.", "cta": "Follow your usual monitoring plan" },
    "medication_advice": "", "hospital_note": true, "assessment": null
  },
  "status": "completed"
}
```

**`result` is what the result card shows** (UAT 2026-11-03): the design's
own per-monitoring-reason decision (the design's `getBPDecision`, made by
the server), `null` until `status` is `completed`.
Don't build the card from `final_title`/`final_cta_label`/
`final_recommendation`/`pulse_note` any more; those are the engine's
routing fields (referrals and reports key on `final_cta`). Each reading
also carries `monitor_band` (`blue`, `green`, `yellow`, `orange_1`,
`orange_2`, `red`), `monitor_band_label`, `needs_attention`,
`monitor_pulse_colour` (`blue`, `green`, `yellow`, `red`, or null without
a pulse), `weight_kg` and `created_at`; the monitoring tool's own scale
is the one used for history colours and tags (`classification` stays the
shared clinical band). The session also returns `pathway`, `context`,
`second_reading_role`, `repeat_prompt`, `offers_facility_booking`,
`effective_reading_id`, `asks_symptom_detail`, `medication_reminder`,
`pulse_category`, `average_systolic`/`average_diastolic`/`average_pulse`,
`emergency_symptoms`, `age`, `gender`, `weight_kg`, `height_cm`, `bmi`,
`bmi_classification`, `bmi_deficit_kg`, `started_at` and `completed_at`.

**The "Log a BP reading" form** ("Record values from your blood-pressure
monitor.", an "mmHg" pill): **"Systolic"** and **"Diastolic"** side by side
(units "SYS"/"DIA" inside the fields, placeholders 120/80), then
**"Heart rate (pulse) · optional"** ("bpm", "e.g. 72"). `systolic` and
`diastolic` are required; `pulse` is **optional** since the redesign (a
session without it has `pulse_category: ""` and no `pulse_note`). As
values are typed, web colours the numbers by the classify-preview band
(colours below) and shows the preview's `alert`. The button
is **"+ Save reading"** (disabled until systolic/diastolic are in range
and any pulse is 20–250), with "Orange 2 and Red readings prompt a repeat. This tool
does not diagnose hypertension or adjust medication." under it.

Colours (the design's palette, used for typed numbers, the result accent
and history values): `blue` #2379B1, `green` #168054, `yellow` #F7E36A,
`orange` (and the band identifiers `orange_1`/`orange_2`) #BD6D23, `red`
#C13743. `result.colour` uses `orange`, never `orange_1`/`orange_2`;
pulse colours are only `blue`/`green`/`yellow`/`red`.
The pill text is the server's `result.colour_label`.

On a Pathway E dialysis day (`is_dialysis_day_today` true), the server
rejects a reading without `dialysis_phase` (*"Select pre-dialysis or
post-dialysis for today's reading."*) or `weight_kg` (*"Weight is required
for a dialysis-day reading."*), both 400. Web guides the user through
pre-dialysis then post-dialysis from `dialysis_pre_logged_today`/
`dialysis_post_logged_today`; `next_dialysis_phase` (`pre`, `post`, or
null when both are logged or it isn't a dialysis day) gives the same
answer from the server:
- Chips "✓ Pre-dialysis logged" / "Pre-dialysis pending" and the same for
  post, plus "Now logging: Pre-dialysis reading".
- After both are logged: "Both dialysis readings are logged for today.
  Logging another reading?" with a manual Pre-/Post-dialysis pick.
- The weight field is labelled "Pre-dialysis weight (kg)" /
  "Post-dialysis weight (kg)" (above 0, up to 500).
- Web re-fetches the monitoring profile after each dialysis-day save.
  Each dialysis-day reading is its own session.

### What the engine decides

The API decides the outcome. What the app uses from each response:

- `status`: `completed` or `awaiting_second_reading`.
- `repeat_wait_seconds`: while `awaiting_second_reading`, count this down before
  allowing the repeat reading (120 after a red first reading, 60 after orange_2).
- `result`: everything the result card shows (section 5), including the
  displayed values (already the rounded mean after a repeat).

`final_cta`, `final_title`, `final_recommendation`, `average_*` and
`pulse_note` are the engine's routing fields; web doesn't display them.

`awaiting_third_reading` is never returned for new sessions. The third-reading
endpoint only finishes pre-existing ones, which web never reopens.

### 3. Repeat reading (only when `status` is `awaiting_second_reading`)

```
POST /api/vitals/bp/sessions/<uuid:session_id>/second-reading/
{ "systolic": 182, "diastolic": 112, "pulse": 90,   // pulse optional
  "feeling": "well" | "unwell",                      // REQUIRED
  "symptom_detail": "headache" }                     // see below
→ 200 <same session shape, second_reading filled in, status "completed">
```

`feeling` comes from `repeat.feeling_question` ("While you rest, how are
you feeling?"). When the session's `asks_symptom_detail` is true and feeling
is `unwell`, also send `symptom_detail` from `repeat.symptom_detail_options`
(`chest`, `breathing`, `weakness`, `speech`, `vision`, `confusion`,
`seizure`, `collapse`, `headache`, `dizziness`, `other`). Picking a
`serious: true` option should immediately call the emergency endpoint
(3b) instead of waiting for the repeat.

**What web shows** (the repeat step of the logging card):
"Repeat your BP reading" ("Your first reading has been saved."), a box
"FIRST READING SAVED" with the first reading coloured by its band and the session's
`repeat_prompt`. While the
countdown runs: "REST BEFORE YOUR REPEAT", the mm:ss timer,
"`rest_instructions` Repeat your BP after 1 minute / 2 minutes." and "The
next reading form will appear automatically when the rest period
finishes." Once it ends: "SECOND MEASUREMENT", "Please measure your blood
pressure again now.", Systolic/Diastolic only (no pulse) and **"Save repeat
reading"**. The feeling question shows in both phases ("How are you
feeling?" after the rest), then a "MEDICATION REMINDER" box when the session's `medication_reminder` isn't null, "Severely High Blood Pressure" when
the first reading's `classification` is `red`, and `repeat.medication_note`.
The symptom list ("`symptom_detail_question`", "`symptom_detail_hint`")
appears only when `asks_symptom_detail` is true and "unwell" is picked;
web checks the feeling and symptom are answered before saving, with
`repeat.feeling_required_error` / `repeat.symptom_detail_required_error`.
Once the session completes, the result card (section 5) is built from
`result`.

Errors (400): missing `feeling` → *"Please tell us how you are feeling."*;
orange_2 + unwell without `symptom_detail` → *"Please select the symptom
that best describes how you feel."*; `symptom_detail` in any other case →
*"Only applies when your first reading was very high (orange_2) and you
feel unwell."*; any other status → *"This session isn't awaiting a second
reading."*

### 3b. Emergency (only when `status` is `awaiting_second_reading`)

```
POST /api/vitals/bp/sessions/<uuid:session_id>/emergency/
{ "symptom_detail": "chest" }   // one of the 8 serious codes
→ 200 <session: status "completed", is_emergency true, second_reading null,
       feeling "unwell", final_cta "go_to_hospital_immediately",
       final_cta_label "SEEK EMERGENCY MEDICAL CARE NOW",
       final_title "Urgent Medical Attention Needed",
       final_recommendation "These symptoms may need emergency treatment.">
```

Non-serious code → 400 *"Only a serious symptom (chest, breathing,
weakness, speech, vision, confusion, seizure, collapse) triggers the
emergency path."*; wrong status → 400 as above; 402 without monitoring
access. The server accepts it for any session awaiting a repeat (orange_2
or red); web only reaches it on orange_2, the only case that shows the
symptom list.

### 4. Wellbeing question (only when `status` is `awaiting_wellbeing`)

Web never reaches this step (see the top of "Blood Pressure"); mobile
doesn't need it. Documented for completeness:

```
POST /api/vitals/bp/sessions/<uuid:session_id>/wellbeing/
{ "answer": true|false }
→ 200 <same shape, now with final_cta/final_cta_label/final_recommendation and status "completed">
```

Only sessions started before the redesign (old blue sessions and old
repeat sessions) reach this; new sessions never ask it.
The question text comes from `wellbeing_question_text` (*"Are you feeling
unwell or experiencing general body weakness?"*), shown as two large
radio options **Yes** / **No** and a **"Continue"** button. `true` means
"yes, I feel unwell".

### 5. Result card + what web does next

A **"Latest result"** card ("Personalised recommendation & next step")
built entirely from `result`: a top accent and pill in `result.colour`
(pill text `colour_label`; an emergency is `red`), `result.title`,
"Blood pressure · <result.systolic>/<result.diastolic> mmHg" (the two
readings' rounded mean after a repeat, coloured like the accent), then
**RECOMMENDATION** (`result.recommendation`), **NEXT STEP**
(`result.cta`, omitted when "") and, when `pulse_result` is set,
**HEART RATE · <result.pulse> BPM** ("**<pulse_result.title>**.
<pulse_result.recommendation> <pulse_result.cta>."; the number isn't
coloured). Then, when present: muted "**Medication:**
<medication_advice>"; "Already at a healthcare facility? Show this result
to your healthcare professional." when `hospital_note`; and the
**"METABOLIC HEALTH ASSESSMENT"** panel when `assessment` is set
(`assessment.guidance`, "Assessment status: <status_label>", a button
`action_label` opening `assessment.url`). Always: "This result is not a
diagnosis; individual targets and pregnancy-related thresholds may
differ." There's no "Log another reading" button: the "Log a BP reading"
form stays on screen above the card (web scrolls the card into view), and
typing a new value there clears the card. Then:
- **NEXT STEP** is a button with that text when the session's `offers_facility_booking` is true. It opens the facility flow ([`bookings-and-consultations.md`](./bookings-and-consultations.md) §6) for `effective_reading_id`. Otherwise it's plain text.
- **Every pathway except Pathway A (`routine`)**: the server creates the referral
  when the session completes. No facility card is shown to the patient. Web
  still calls `POST /api/care-navigation/referrals/from-bp-reading/<reading_id>/`
  (no `facility_id`) once for every completed non-routine session, with the
  device's coordinates when location was shared and without them otherwise.

`<reading_id>` is the session's `effective_reading_id`. Web asks for
location permission when the logging card opens.

### History and the dashboard card

```
GET /api/vitals/blood-pressure/   → 200 [ reading, ... ]   (own readings, newest first, most recent 100)
GET /api/vitals/summary/          → 200 { "latest_bp": <reading>|null, "latest_bs": <reading>|null }
```

- **"My BP history"** ("<N> completed sessions", "session" for one; N is
  the number of readings in the list): two boxes, **"Latest
  reading"** ("<systolic>/<diastolic> mmHg", not coloured) and
  **"Pulse rate"** (the number coloured by `monitor_pulse_colour`, "—"
  without one). There's no trend chart and no "show all": it lists only
  the 5 newest readings: "<systolic>/<diastolic> mmHg", "<date-time> · Pulse
  <pulse> bpm" (the pulse coloured by `monitor_pulse_colour`; + " · Pre-dialysis"/"Post-dialysis"), a tag from
  `monitor_band`: "Urgent review" (`red`), "Clinical review" (`orange_*`), "Monitor" (`yellow`),
  "Low BP" (`blue`) or "Recorded" (`green`), and a bin button. Empty
  state: "No readings yet. Your saved readings will appear here."
- The bin asks **"Remove reading?"** ("This removes your <s>/<d> mmHg
  reading from your history. This can't be undone.", Cancel / Remove),
  then `DELETE /api/vitals/blood-pressure/<id>/` → 204, toast "Reading
  removed".
- `summary` feeds the dashboard's two monitoring cards (2026-11-03
  design): **"BLOOD PRESSURE MONITORING"** (blue) and **"BLOOD SUGAR
  MONITORING"** (red). With no reading: "Log your first reading", "Track
  systolic, diastolic & pulse" / "Fasting, post-meal or random", "Start
  tracking →". With a reading (web's own addition; the design only shows
  the first-reading state): "<systolic>/<diastolic> mmHg" and
  "<classification_label> · <pulse> bpm", or "<value> <unit>" (one decimal
  for mmol/L and HbA1c) and the reading's `decision_title` (falling back to
  `classification_label`), then "Log a reading →". Both open the tool, or
  the monitoring package when vitals access is locked.

### BP band identifiers

Colour chips by the band identifier and show the server's label. Identifiers: `red`,
`orange_2`, `orange_1`, `yellow`, `blue` and `green`.

Pulse has its own 6-band classification sharing these same identifiers:
`blue` Low, `green` Normal, `yellow` Slightly High, `orange_1` High,
`orange_2` Very High, `red` Severely High Heart Rate. Only a saved
reading's `pulse_classification`/`pulse_classification_label` carry it.
The BP monitoring tool's screens use the separate 4-colour heart-rate
scale (`blue`/`green`/`yellow`/`red`) returned as `monitor_pulse_colour`,
`result.pulse_result.colour` and the pulse classify-preview.

## Blood Sugar

A flat log, no sessions (https://staging.mywellnesshealth.co.ke/vitals/blood-sugar), in the
same 2026-11-03 redesign look as Blood Pressure: brand row "MY WELLNESS
HEALTH" / **"Blood sugar monitoring"** (no back pill, except on the setup
screen opened from "Change monitoring reason", where "← Back" returns to
the logging screen without saving). Results
follow the redesign's **blood sugar rulebook**, computed and stored by
the server for every reading; mobile only
displays them.

```
GET /api/vitals/bs/content/                      → 200 { "onboarding": { "intro": {...}, "tips": { "title", "intro", "items": [...] } }, "pathway": {...} }   (BP's keys minus the dialysis ones and day_options; no "repeat" section)
GET /api/vitals/blood-sugar/monitoring-profile/   → 200 { "pathway", "provider_plan", "treatment_gap_reasons", "treatment_gap_other_text", "setup": "full|bmi_only|none", "form": {...}, "updated_at" }
PUT /api/vitals/blood-sugar/monitoring-profile/   { "pathway", "treatment_gap_reasons", "treatment_gap_other_text" }  → 200 <same shape>
```

`form` (server-decided from the pathway and the latest reading):

```
{ "pre_meal_offered": bool,            // offer the Pre-meal reading type
  "meal_timing_asked": bool,           // ask "When was this reading taken?" for post-meal
  "ask_diabetes_diagnosis": bool,      // ask "Have you previously been diagnosed with diabetes?"
  "diabetes_diagnosis": "yes|no|unsure|null",  // send this when not asking
  "hospital_note": "<text>|null",      // shown at the end of the result card
  "share_on_green": bool }             // the "SHARE MY BLOOD SUGAR RECORD" button on a Green result
```

**Setup is one screen** (no intro, profile or tips screens):
- **"Why are you monitoring?"** ("Just one selection to personalise the
  journey."), the "Monitoring reason" dropdown with `pathway_options`:
  `routine` "Routine / wellness check / hospital visit",
  `provider_directed` "A healthcare professional asked me to monitor",
  `diagnosed_on_medication` "I have diabetes and take medication",
  `diagnosed_not_on_medication` "I have diabetes and do not take
  medication". Shown when the monitoring profile's `setup` is `full`
  (only while no `pathway` is saved; `dm_onboarding_seen` doesn't affect
  it) and after **"Change monitoring reason"**. `setup: "bmi_only"` opens
  this screen with only the BMI card; `none` goes straight to logging.
  `provider_plan` and
  `treatment_gap_reasons` are both optional now.
- Pathway D: the same optional "not taking medication" card as BP.
- The optional BMI card (see "The BMI step" under Blood Pressure; here it
  keeps its card frame) while `bmi_prompt_due` is true.
- **"Start recording →"** (no note under it). On Start web saves the pathway (when the reason was
  shown), the BMI or `bmi_prompt_skipped`, and the first time
  `dm_onboarding_seen: true`.
- An already set-up user with `bmi_prompt_due` true (`setup: "bmi_only"`)
  sees this screen with only the BMI card.

**The logging screen**, top to bottom: a collapsible **"Measure blood
sugar correctly ·"** box ("<N> quick tips", `onboarding.tips.items`); the
**"Log a reading"** form; the **"Latest result"** card after a save; Pathway
D's not-on-medication card (with "Save response"/"Update response");
**"Reading history"**; **"Change monitoring reason"**; and "Adult reference guidance only.
Special targets apply in pregnancy, childhood, and certain illnesses. This
tool is not diagnostic or a substitute for urgent care."

**The "Log a reading" form** ("Choose the reading type and enter the
value."):
1. **"Reading type"** chips: Random (`random`), Fasting (`fasting`),
   Pre-meal (`pre_meal`, only when `form.pre_meal_offered` from the monitoring profile), Post-meal
   (`post_meal`), HbA1c (lab) (`hba1c`), 75 g OGTT (lab) (`ogtt`).
   Default Random. Changing type clears the value and the checkboxes.
2. Except HbA1c: **"Units on your glucometer"** pills mmol/L / mg/dL
   (default mmol/L), then "<Type> blood sugar (<unit>)" with the unit
   inside the field and "Equivalent: <n> mg/dL" (or "<n> mmol/L") under it
   (mmol = mg/dL ÷ 18.0182). HbA1c instead: "HbA1c from laboratory report
   (%)" and "Enter only an actual HbA1c laboratory result. Do not enter a
   glucose-meter reading here."
   - Post-meal: "Record an ordinary post-meal check 1–2 hours after
     starting your meal. It is not an oral glucose tolerance test." and,
     when `form.meal_timing_asked`, **"When was this reading taken?"**: "1–2 hours
     after starting the meal" (`less_than_2h`) / "Another time / unsure"
     (`at_least_2h`).
   - OGTT: "**Laboratory test only:** Enter the 2-hour result of a
     standardised 75 g OGTT, not an ordinary post-meal home reading." and
     the checkbox "I confirm this result comes from a laboratory 75 g
     OGTT." (`is_lab_ogtt`).
3. When `form.ask_diabetes_diagnosis` is true: **"Have you
   previously been diagnosed with diabetes?"** (Yes / No / I'm not sure →
   `diabetes_diagnosis` `yes`/`no`/`unsure`). Otherwise send `form.diabetes_diagnosis` when
   it isn't null.
4. **"How are you feeling right now?"**: "I feel well" / "I feel unwell"
   (`feeling`). Unwell adds "Which symptoms are you experiencing?" with
   checkboxes (`symptom_details`): `shaking` "Shaking, sweating or
   dizziness", `weakness` "Unusual weakness", `thirst` "Excessive thirst or
   frequent urination", `vomiting` "Vomiting or abdominal pain",
   `breathing` "Deep or unusually rapid breathing", `confusion` "Severe
   confusion or difficulty staying awake", `collapse` "Seizure, collapse
   or unconsciousness", `other` "Other symptoms".
5. When the preview says so (below): "My urine or blood ketone test showed
   high ketones (optional)." (`high_ketones`) and "This reading is still at
   or above 16.7 mmol/L after checking again." (`persistent_high`).
6. The live safety alert, if any, then **"✓ Save reading"** and "Date and
   time are captured automatically. The results are not a diagnosis and
   do not recommend medication doses."

Web checks before saving, in this order and wording: "Please select how
you are feeling before saving." / "Please choose the symptoms you are
experiencing." / "Only save a standard laboratory 75 g OGTT under this
test type; confirm the test source." / "Please select when the post-meal
measurement was taken." / "Please confirm whether diabetes has been
diagnosed, or choose I am not sure." / "Please enter the HbA1c value from
your laboratory report." or "Please enter your blood sugar reading." /
"Please check the HbA1c percentage (typically between 3% and 20%)." or
"Please check the reading and units against your glucose meter." (HbA1c
3–20 %, glucose 0.6–55 mmol/L). The server enforces the same rules
(field-keyed 400s).

**Live preview** as the user types (350 ms debounce, nothing saved):

```
POST /api/vitals/blood-sugar/decision-preview/
{ "value": 13.2, "reading_type": "random", "unit": "mmol/L", "meal_timing"?, "feeling"?, "symptom_details"?, "high_ketones"?, "persistent_high"?, "diabetes_diagnosis"?, "is_lab_ogtt"? }
→ 200 { "decision_colour": "orange"|...|null, "decision_colour_label": "Orange"|...|null, "mmol": 13.2|null,
        "live_advice": { "title", "body" }|null, "show_ketone_prompt": bool, "show_persistent_high_prompt": bool }
```

Web sends it only once the value is in range, colours the typed number by
`decision_colour`, shows `live_advice` as a red alert box (title + body),
and shows the ketone / persistent-high checkboxes from the two flags. Same
`402` gate as logging.

**Save:**

```
POST /api/vitals/blood-sugar/
{ "value": 13.2, "unit": "mmol/L", "reading_type": "random", "feeling": "well", "symptom_details": [], "high_ketones": false,
  "persistent_high": false, "diabetes_diagnosis": "yes", "is_lab_ogtt": false, "meal_timing"? }
→ 201 { "id", "value": "13.20", "unit", "reading_type", "reading_type_label", "meal_timing", "classification", "classification_label", "taken_at", "notes", "created_at",
        "feeling", "symptom_details", "high_ketones", "persistent_high", "diabetes_diagnosis", "is_lab_ogtt",
        "weight_kg", "value_mmol": <number|null>, "display_colour", "offers_facility_booking": bool,
        "decision_colour", "decision_colour_label", "decision_title", "decision_recommendation", "decision_cta", "decision_safety", "decision_note", "decision_pathway",
        "decision_assessment_prompt": bool,
        "metabolic_assessment": null | { "status": "not_started|in_progress|completed", "url": "/assessments/diabetes",
                                         "show": bool, "message": "<text>", "cta_label": "COMPLETE|CONTINUE METABOLIC HEALTH ASSESSMENT" } }
GET /api/vitals/blood-sugar/   → 200 [ reading, ... ]  (own readings, newest first, most recent 100)
```

`reading_type_label` is on every reading (saved, listed and in `summary`):
"Random test", "Fasting test", "Pre-meal test", "Post-meal test", "HbA1c
test" or "Oral glucose tolerance test".

**Metabolic Health Assessment prompt** (design `assessmentAction`):
`decision_assessment_prompt` is set at save time for a Pathway A green
result while the user's own **Diabetes Risk Assessment** (`diabetes`, the
Metabolic category's glucose assessment) isn't completed.
`metabolic_assessment` is `null` unless that flag is set; its `status` is
read live (`completed` once any completed session exists, `in_progress`
when only an unfinished one exists, else `not_started`), so render
`message` and a `cta_label` button linking to `url` only while `show` is
true.

`feeling` is required; `symptom_details` must be non-empty when `unwell`
and empty when `well`; `is_lab_ogtt` must be true for `ogtt`;
`diabetes_diagnosis` is required on Pathway B; `meal_timing` is required
for `post_meal` except on Pathway A. A monitoring pathway must be set (400
on `pathway` otherwise). Readings saved before the rulebook have every
`decision_*` field `""` (including `decision_colour_label`); web colours
them by `display_colour` and tags them "Unclassified" in the history.

**The "Latest result" card** (after a save): accent and pill in the
decision colour (pill = `decision_colour_label`), `decision_title`,
"<type> · <value_mmol> mmol/L" (HbA1c "<value> %"), **RECOMMENDATION**
(`decision_recommendation`), **NEXT STEP** (`decision_cta`, at the card's
12px body size), "**Safety:** <decision_safety>" in brown (#745046) when
present, `decision_note` muted, then `form.hospital_note` when it isn't null. A Green
result ends with a full-width **"SHARE MY BLOOD SUGAR RECORD"** button when
`form.share_on_green` is true (the same share as the history's Share). NEXT STEP (`decision_cta`) is a button into the facility flow when the reading's `offers_facility_booking` is true, otherwise plain text.
The old per-type guidance panels, the "Medication reminder" panel and the
"Your blood sugar has been persistently elevated" / "Book a consult" panel
are **gone**: the rulebook's result replaces them.

Colours (`display_colour`, which also covers old readings): `blue` #2479B6, `green` #168054,
`yellow` #F7E36A, `orange` #C26724, `red` #B63242, `neutral` #087D72.

**"Reading history"** ("<N> saved readings"): **"Latest glucose"** and
**"Latest HbA1c"** boxes (coloured by `display_colour`); a **"View
readings"** filter ("All types" + each type). There's no trend chart and
no "show all": it lists only the 8 newest readings in the chosen view:
"<value> <unit>" coloured by `display_colour`, "<type> · <date-time>", a
tag with the colour name (`decision_colour_label`: "Blue", "Green",
"Yellow", "Orange", "Red"; "Unclassified" when it's blank) in the same
colour, and a bin. Empty: "No readings in this view yet." The bin works
like BP's (`DELETE /api/vitals/blood-sugar/<id>/`, "Remove reading?",
"This removes your <value> <unit> reading from your history. This can't
be undone.").

The nurse outreach and WhatsApp flows still log without `feeling`; their
readings get blank `decision_*` fields and keep only `classification`
(unchanged; OGTT maps to
`within_general_target` below 7.8 mmol/L, else `above_general_target`).

## Vitals PDF report

```
POST /api/vitals/report/            { "report_type": "combined" | "bp" }   (default "combined")
→ 200 application/pdf (attachment; password-protected). Header X-Pdf-Password-Hint tells the user what the password is.
GET  /api/vitals/report/email-prefill/   → 200 { "email": "<address>|null" }
POST /api/vitals/report/email/      { "email": "...", "report_type": "combined" | "bp" }
→ 200 { "detail": "Report emailed." }   (sent in the background; throttled under report_email, 10/hour)
```

The server builds both PDFs; mobile only downloads, emails or shares
them. `"bp"` is the **Blood Pressure clinical report** (`blood-pressure-
report-<ref>.pdf`); `"combined"` (the default, sent by the Blood Sugar
page) is now the **Blood Sugar clinical report** (`blood-sugar-report-
<ref>.pdf`). The old all-vitals "Vital Signs Monitoring Report" (BP +
glucose tables and a "Recommended Routine Tests" table) is retired. Both
reports are 4 pages (more when the history runs long), cover the 14 days
ending on the latest reading, and use the app's letterhead and footer:
1. Patient card (name, age, BMI, the pathway sentence, the report period),
   monitoring consistency (streak, days recorded out of 14, records, a
   14-day calendar), the latest reading, and the 5 most recent entries.
2. The complete dated history. BP: a repeat session's readings are listed
   individually and its session value is their average (e.g. 172/104 and
   170/102 → 171/103). Blood sugar: every saved entry with its result,
   test type and notes ("Felt well" / "Felt unwell: <symptoms>", "; high
   ketones reported").
3. Trend charts. BP: systolic/diastolic and pulse. Blood sugar: one
   glucose test type (fasting when there is any) and HbA1c, never mixed.
4. The patient's data (BP: medication status and recorded reasons on C/D;
   blood sugar: monitoring context, reasons on D, recorded diabetes
   medicines on C/D), then the clinical team's patient-facing guidance for
   their pathway (BP A–E, blood sugar A–D, verbatim) and a closing "General patient safety message".

The site's report card (see [`assessments.md`](./assessments.md), "6. PDF report": "KEEP
YOUR REPORT", "Your health report", "Download your readings report to keep or bring to your
healthcare appointment.") sits at the bottom of both history cards, its three buttons
("Download Report", "Email", "Share") greyed out until there's a reading, with "Download
saves a password-protected PDF report. Email sends that PDF to you. Share sends the PDF when
your device supports it, otherwise a short summary." under them:
- The BP page sends `"bp"` (BP + heart rate only). The Blood Sugar page
  sends the default `"combined"` (BP + heart rate + glucose + HbA1c).
- **Download** ("Preparing…") → toast "PDF downloaded" with
  *"This report is password-protected. Open it with the <hint>."*
- **Share** fetches the same PDF and hands it to the OS share sheet; where
  files can't be shared it shares (or copies, "Summary copied") a one-line
  summary of the latest reading.
- **Email** → an "Email me this report" dialog ("We'll send the
  password-protected PDF to this address.", "Email address") pre-filled
  from `email-prefill`, with "Send report". Toast: "Report emailed to
  <address>" / "Check your inbox (and spam folder) in a few minutes."
- Both calls are gated by vitals access (`402`), and both buttons are
  hidden for a blocked `demo_restricted` account.

## Medications

Not paywalled (no `402`). Web has two surfaces:
- the dashboard's **"My medications"** card,
- the **Medications** page (`/medications`, in the sidebar).

The Blood Pressure and Blood Sugar pages have no medication widget.

```
GET /api/medications/?condition=hypertension      → 200 [ medication, ... ]   (plain array, no pagination; newest first)
GET /api/medications/?q=metformin                  → 200 { cursor-paginated }  (every condition; optional name search; newest first)
```

- `?condition=` (`hypertension` | `diabetes` | `other`) returns the plain
  array. No web screen uses it today. Any other value → 400.
- Without `condition`, the list is cursor-paginated. Web fetches every
  page. The dashboard sends no `q`; the Medications page sends `q` from
  its search box.

**The medication fields web reads:**
- Basics: `id`, `condition` (`hypertension` | `diabetes` | `other`),
  `name`, `dosage`, `frequency` (a `PrescriptionFrequency` value:
  `once_daily`, `twice_daily`, `three_times_daily`, `four_times_daily`,
  `every_other_day`, `weekly`), `notes`, `created_at`.
- `source`: `manual` | `photo` | `prescription`. `prescription` shows a
  "Prescribed" badge on the Medications page.
- `start_date`, `duration_value`, `duration_unit`, and `end_date`
  (server-computed from start + duration; `null` means ongoing).
- `reminder_times`: dose-reminder times (`"HH:MM"` strings), shown in
  the Medications page's "Reminders" column. Web's forms never set them.
- `quantity_per_dose`, `quantity_dispensed`, and `refill_due_date`
  (server-computed; `null` when it can't be honestly derived, never a
  guessed date). `refill_attention` (bool, server-computed: a
  `refill_due_date` today or within 7 days, overdue included) drives the
  Medications page's "Refill attention" tile.
- Also returned, not shown by web: `generic_product_code`, `dosage_form`,
  `last_refilled_at`, `prescription`.
- `side_effects`: `null` unless a pharmacist-approved profile exists for
  this exact drug, otherwise `{ "generic_name", "drug_class",
  "side_effects": [...], "safety_caution" }`.
- The refill and insulin fields in the next section.

### Refill settings, "as needed" and insulin (2026-11-02)

**More fields on a medication:**

- **Writable:**
  - `as_needed`: when true, `frequency` is cleared, there's no refill
    estimate and there are no dose reminders.
  - `refill_reminder_enabled`.
  - `reminder_channel`: `"whatsapp"` | `"email"` | `"sms"` | `"push"` |
    `""` (blank means every allowed channel).
  - `refill_arranged`: the refill watch's "Already arranged". It pauses
    refill reminders until the next confirmed refill clears it.
- **Read-only, server-computed** (render them, never re-derive):
  - `kind`: `"standard"` | `"insulin"`.
  - `refill_status`: `{ level, label, days_left, estimate }`. `level` is
    `critical` (≤ 2 days) | `soon` (≤ 3) | `ok` | `pending` | `course` |
    `completed`. `estimate` is true for an insulin figure estimated from
    logged injections (the daily average uses only complete days before
    today, once there are at least two).
  - `is_running`.
  - `insulin`: `{ product_id, ingredient, category, container: { id, label,
    volume_ml, units_per_ml, units_per_container }, containers_supplied,
    schedule, confirmed }`, or `null`.
  - `insulin_stock`: `{ total_units, injected_units, remaining_units,
    percent_remaining, ... }`, or `null`.
  - `injections`: `[{ id, units, injected_at }]`, newest first, at most 100.
  - `injection_count`: the full total.

Refill reminders (24 h lead for tablets, once per stock cycle for insulin)
respect `refill_reminder_enabled`, `refill_arranged` and `reminder_channel`.
A chosen channel narrows delivery to that one channel, push included. It
never overrides the user's notification preferences.

### Writes

```
GET    /api/formulary/search/?q=<text>                          → 200 [ { id, code, display } ]   (medicine search)
GET    /api/insulin-products/                                   → 200 [ { id, name, ingredient, category, aliases[], containers: [ { id, label, volume_ml, units_per_ml, units_per_container } ] } ]
POST   /api/medications/                                        → 201 <medication>
PATCH  /api/medications/<uuid:medication_id>/                   → 200 <medication>
DELETE /api/medications/<uuid:medication_id>/                   → 204
POST   /api/medications/<uuid:medication_id>/refill/            → 200 <medication>
POST   /api/medications/<id>/injections/        { "units": 12 } → 201 <medication>
DELETE /api/medications/<id>/injections/<injection_id>/         → 200 <medication>
```

Web debounces the formulary search by 300ms.

**What web's add/edit form sends** (used inline in the dashboard card and in the Medications page's "Add
medication" / "Edit medication" dialog):

```
// Standard medicine (tablets)
POST /api/medications/
{ "condition": "other", "generic_product_id": "<uuid>",
  "as_needed": false, "frequency": "twice_daily",          // "" when as_needed
  "quantity_per_dose": 1, "quantity_dispensed": 30,        // quantity_dispensed: add only, omitted if blank
  "start_date": "2026-11-02",
  "duration_value": 30, "duration_unit": "days",           // omitted for "Ongoing"
  "refill_reminder_enabled": true, "reminder_channel": "whatsapp" }

// Insulin
POST /api/medications/
{ "condition": "diabetes", "kind": "insulin", "insulin_container_id": "<uuid>",
  "containers_supplied": 2, "insulin_schedule": "1"|"2"|"3"|"4"|"varies",
  "insulin_confirmed": true, "start_date": "2026-11-02",
  "refill_reminder_enabled": true, "reminder_channel": "push" }
→ 201 <medication, kind "insulin", name = the product's name>
```

- **Editing** sends the same body as a PATCH, without `condition`,
  `kind` and `quantity_dispensed`. `generic_product_id` is only sent when
  the user picked a different medicine. The refill watch's "Already
  arranged" / "Resume reminders" sends just `{ "refill_arranged": true|false }`.
- **`generic_product_id`** is a real DHA/PPB registry id from
  `/formulary/search/`, never a free-text drug name. `name` is taken
  from the registry product.
- **Creating an insulin** needs no `generic_product_id`. Every insulin
  field and `insulin_confirmed: true` are required. Each missing one comes
  back as a `400` field error.
- **Kinds don't change.** A medication can't be turned from standard into
  insulin, or back. Web's edit search only offers insulins when editing an
  insulin, and only formulary products when editing a standard medicine.
- **Refill** (the "Confirm stock received" dialog): a standard medicine
  sends `{ "quantity_dispensed": 30 }` (total tablets/capsules now in
  hand), an insulin sends `{ "containers_supplied": 3 }` (full containers
  now in hand). Web only accepts a positive whole number. Server limits:
  `containers_supplied` 1–10000; `quantity_dispensed` at least 0.01
  (decimals allowed, no upper limit). Leaving out the field that applies to
  this medicine's kind is a `400` on that field: *"Enter a valid positive
  whole number of tablets or full insulin containers."* An optional
  `refilled_at` (`YYYY-MM-DD`, default today) is accepted; web never sends
  it. A refill starts a new
  refill-reminder cycle (see
  [`push-notifications.md`](./push-notifications.md)). An insulin refill
  also starts a new stock cycle: earlier injections stay in the history
  but stop counting against stock.
- **Logging an injection** records units the patient has *already*
  injected, timestamped now. `units` is a whole number from 1 to 999.
  More than the recorded remaining stock is a `400`: "Entry exceeds the
  recorded remaining supply…".
- **The insulin catalogue** is the design's 15 brand insulins with their
  containers. It's seeded by vitals migration 0030, admin-editable, and
  pending clinical sign-off. Web caches it for an hour.

### What web's dashboard "My medications" card shows

(On staging at https://staging.mywellnesshealth.co.ke/dashboard; mirror it.)

1. **Header:** "My medications", with "N recorded" (or "No medications
   added") and an **Add** / **Close** button. With no medications and the
   form closed: *"Keep your medicine schedule and refill dates in one
   place. Insulin users can record the units actually injected."*
2. **Tiles:** "Running medications" (count of `is_running`) and "Refills in
   3 days or less" (running with `refill_status.level` `critical`/`soon`,
   adding " · N urgent" for the `critical` ones, and the tile turns red).
3. **"Refill watch"**, one record for each of those medicines, fewest
   `days_left` first:
   - The name and `refill_status.label`, plus " · estimated from recorded
     injections" when `estimate` is true.
   - A reminder line: "Refill arranged — repeat notifications paused", or
     "Reminder due/upcoming via {channel}" ("your notification settings"
     for a blank channel), or "Reminders turned off".
   - Actions: "I have refilled" (the stock dialog) and "Already arranged" /
     "Resume reminders" (PATCH `refill_arranged`; toasts "Refill marked as
     arranged. Reminders paused." / "Refill reminders resumed.").
   - A tag: "RED · ≤2 days" or "Upcoming".
   - Under the list, the fixed note "Confirm actual stock before relying on
     these estimates. Red indicates estimated supply at two days or less;
     it does not indicate a medical diagnosis."
4. **"Record insulin injection"**, only when the user has an insulin and
   the form is closed:
   - Choice tiles ("{name}", "{category} · U-{units_per_ml}"),
     pre-selected when there's only one insulin. Subtitle "Choose the
     insulin, then record units injected." / "Record the units you have
     already injected."
   - "Recording for {name} · {container}", "Units injected" and Save →
     `POST …/injections/`. Note: "Current date and time are saved
     automatically. Enter only doses already injected."
   - Errors as toasts: "Please select the insulin before recording
     units." / "Enter a whole number of insulin units actually injected."
   - Feedback (also a toast): "{n} units recorded for {name} at {HH:MM}."
5. **Rows**, sorted by `refill_status` level (critical, soon, ok, pending,
   course, completed) then `days_left`, at most two, then "View all N
   medications" (to `/medications`) when there are more than two:
   - **Standard:** "{qty} tablet(s) · {frequency label}" (or "No schedule
     recorded"), or "As needed", then " · {Channel} alerts", " · Alerts
     on" (blank channel) or " · Alerts off".
   - **Insulin:** an "Insulin" chip, then "{container} · {schedule} · {n}
     injection(s) logged · {alerts}", with a "+ Record {name} injection"
     link. Schedule labels: Once daily, Twice daily, 3 times daily, 4 times
     daily, "Varies — follow my plan".
   - **Badge** (running medicines at `critical`/`soon` only): "Refill
     alert · {label}" (critical) or "Refill soon · {label}", or "Refill
     arranged".
   - **Expanded standard row:** the condition ("Blood pressure", "Blood
     sugar" or "Other") and duration ("30-day treatment" or "Ongoing
     treatment"), "Common side effects and safety advice" (only when
     `side_effects` is set), the "Understand your treatment alongside your
     readings" monitoring advice for hypertension and diabetes medicines,
     and Refilled / Edit / Remove.
   - **Expanded insulin row:** "{ingredient} · {category} · {container}",
     "Recorded frequency: …", "Estimated remaining" and "Logged injections
     total" tiles (`remaining_units`, `injected_units`), a progress bar
     from `percent_remaining`, the initial-stock footnote (`total_units`),
     "Refill nearly due" when `soon`/`critical`, a depleted warning when
     `remaining_units` is 0, the "Injection history for {name}" card, the
     last three injections with delete (toast "Injection entry removed.";
     "View all N injections" / "Show fewer entries"), monitoring advice,
     and Refilled / Edit / Remove.
6. **The add/edit form** ("Add medication" / "Edit medication"):
   - **Search.** One field, "Which medication are you taking?"
     (placeholder "Type 3 letters, e.g. nov, mix, lan or aml"). From 3
     letters it suggests matching insulins (up to 11) followed by `/formulary/search/` products. Web loads the
     whole insulin catalogue once and matches name, ingredient, category or
     alias itself; `GET /api/insulin-products/?q=<text>` returns the same up-to-11 matches from the server ("No
     matching medication found." otherwise). There's no free-text "not
     listed" entry.
   - **Tablet branch:**
     - "Times per day": Once daily, Twice daily, 3 times daily, 4 times
       daily, or "As needed". "Every other day" / "Weekly" appear only
       when an older record already uses one.
     - "Tablets per dose": "½, if prescribed", 1–4.
     - "Treatment duration": 7, 14, 30 or 90 days, or Ongoing.
     - "Quantity supplied": on add only; optional when "As needed".
     - "Supply start date" (defaults to today).
     - A live supply estimate: "Estimated supply: N days" and "Suggested
       refill reminder: <date>", or, for "As needed", "For as-needed
       medicines, a reliable daily refill date cannot be estimated." Web
       works this out on the device; mobile gets the same figures from
       `POST /api/medications/supply-preview/`
       `{ "frequency", "quantity_per_dose", "quantity", "duration_days", "start_date" }` (blank
       `frequency` for "As needed", no `duration_days` for Ongoing), which returns `estimated_days`,
       `suggested_refill_date` and `message` (any of them can be null). Once saved, the server's `refill_status` is the truth.
     - On edit: "To update the quantity in hand, use "Refilled" on the
       medication."
   - **Insulin branch:**
     - "Which insulin container do you use?", with "{mL} mL × {units/mL}
       units/mL = {units} units per vial / pen or cartridge".
     - "Containers supplied" (default 1) and "Prescribed frequency" (Once
       daily, Twice daily, 3 times daily, 4 times daily, "Varies /
       correction plan").
     - "Date supply started".
     - The confirmation checkbox "This insulin, concentration and frequency
       match my prescribed treatment and container label."
     - "Initial supply: N units".
     - A safety note.
   - **Both branches:**
     - "Send me refill reminders", with "Send reminders by" and the
       WhatsApp / Email / SMS / Push tiles (pick one) and the SMS charges
       note. A new record starts ticked, with WhatsApp.
     - Validation that stops at the first problem: that field gets a red
       outline and an inline message, is focused, and a toast repeats it.
       Insulin: "Please choose the insulin vial, pen or cartridge." /
       "Please enter the number of insulin containers supplied." / "Please
       select the prescribed frequency." / "Please enter the supply start
       date." / "Please confirm that these insulin details match your
       prescription and container label." Tablets: "Please select a
       medicine from the suggestions." / "Please select the prescribed
       frequency." / "Please select the tablets per dose." / (add only, not
       "As needed") "Please enter the quantity supplied." / "Please choose
       the supply start date."
     - "Cancel" and "Save medication" / "Save insulin" / "Update insulin".
       Toasts: "Medication saved", "Medication updated", "Insulin added.
       Record units after each injection.", "Insulin updated".
7. **"Confirm stock received"** (also used on https://staging.mywellnesshealth.co.ke/medications):
   - It asks for the *total current usable supply*, pre-filled with the
     current figure: "Total tablets/capsules now in hand", or for insulin
     "Number of full containers now in hand" (plus a note that a partly
     used vial or pen can't count as full). Buttons "Cancel" / "Confirm
     refill".
   - An invalid number shows "Enter a valid positive whole number of
     tablets or full insulin containers." Toast on success: "Stock updated
     for {name}."
8. **Remove** asks "Remove medication?" / "Remove **{name}** from your
   medications? This does not change a prescription." first, then
   `DELETE` (toast "Medication removed").

### The Medications page (`/medications`)

https://staging.mywellnesshealth.co.ke/medications, titled **"Medications"** (*"Everything
you're currently taking — hypertension, diabetes, or anything else."*):
- An **"Add medication"** button (the same form, in a dialog). New
  standard medicines are saved with `condition: "other"`.
- Two tiles: "My medications" (total, "Recorded medicines") and "Refill
  attention" ("Due or within 7 days": the count with `refill_attention: true`). Both count the
  whole list, whatever the search.
- A "Search by name…" box (sent as `?q=`, debounced 300ms).
- A table with Name (+ "Prescribed"), Category (Hypertension / Diabetes /
  Other), Dosage, Frequency (the label — "Twice daily" etc. — or "As
  needed"; an unrecognised stored value is shown as-is),
  Start date, End date ("Ongoing" when null), Reminders
  (`reminder_times`), Refill due (`refill_due_date`), Added, and per-row
  **Mark as refilled** (the stock dialog) / **Edit** / **Remove**. Empty
  cells show "—". Empty states: "No medications recorded yet." / "No
  medications match your search."
- Remove asks "Remove medication?" / "This will remove "{name}" from your
  medications. This can't be undone." (toast "Medication removed").

## Appointments

Not paywalled. Web has two surfaces:
- the dashboard's **"My appointments"** card,
- the **Appointments** page (`/appointments`, in the sidebar).

The Blood Pressure and Blood Sugar pages have no appointment planner.

```
GET    /api/appointments/?condition=hypertension   → 200 [ appointment, ... ]   (plain array, soonest first; no web screen uses it today)
GET    /api/appointments/?source=manual            → 200 { cursor-paginated, soonest first }   (every condition; optional ?q= clinic-name search, ?source= filter)
POST   /api/appointments/                          → 201 <appointment>
PATCH  /api/appointments/<uuid:appointment_id>/    → 200 <appointment>   (any subset of the POST fields)
DELETE /api/appointments/<uuid:appointment_id>/    → 204
```

```
POST /api/appointments/
{ "condition": "other", "clinic_name": "Diabetes clinic", "appointment_date": "2026-11-10", "appointment_time": "09:00",
  "notes": "Nairobi Hospital", "reminder_enabled": true, "reminder_channels": ["whatsapp", "push"] }
→ 201 { "id": "...", "condition": "other", "clinic_name": "...", "facility": {...}|null, "appointment_date": "2026-11-10",
        "appointment_time": "09:00:00"|null, "notes": "...", "source": "manual", "reminder_enabled": true,
        "reminder_channels": ["whatsapp", "push"], "booking": "<booking uuid>|null", "created_at": "..." }
```

`booking` (read-only) is the service booking a `follow_up` appointment
came from; it's null for manual ones.

- `condition`, `clinic_name` (≤200 chars) and `appointment_date` are
  required. `notes` is ≤300 chars.
- `appointment_time` is optional; reminders assume 08:00 when it's
  missing.
- `source` is read-only. An appointment created automatically from a
  real booking (a doctor-scheduled follow-up) has `source: "follow_up"`
  and is always filed under `condition: "other"`. The dashboard card and
  the Appointments page leave those out with `?source=manual`, because the booking itself
  already represents them.
- `facility_id` (optional uuid) links a registered facility; it comes
  back as `facility`. Only the Appointments page's "Edit appointment"
  dialog sends it (below).

**Reminder settings (2026-11-02).** Both optional:

- `reminder_enabled` (bool, default `true`): `false` means this
  appointment is never reminded.
- `reminder_channels`: a list of one or more of `"whatsapp"` | `"email"` |
  `"sms"` | `"push"` (duplicates are dropped, order kept). `[]` (the
  default) means every channel the user's notification preferences allow,
  which is what every appointment got before this setting existed and what
  you get if you never send the field. Any other value, including `""`, is
  a `400`.

The server sends reminders 24 hours and 2 hours before the appointment,
on every chosen
channel and only those (`["push"]` alone means the app notification only,
no message). Choosing a channel turns it on for that appointment, even if
the user's notification preferences have it off (new accounts start with
email and SMS off). With `[]`, those preferences decide. A patient DHA
records as deceased is never messaged. WhatsApp
only delivers within Meta's 24-hour window after the user last messaged
us, so a WhatsApp-only reminder can fail to arrive; nothing falls back to a
channel the user didn't choose.

**The clinic-appointment form** ("Add clinic appointment" / "Edit clinic appointment", used inline in the
dashboard's "My appointments" card and as a dialog on the Appointments
page; mirror it):

- Fields, stacked in this order:
  - "Type of clinic" ("Select clinic type"): a select over the fixed list
    "General medical clinic", "Hypertension clinic", "Diabetes clinic",
    "Cardiology clinic", "Oncology clinic", "Gynaecology clinic", "Mental
    health clinic", "Surgical clinic", "Other clinic". Picking "Other
    clinic" shows "Other clinic type" (free text, "Enter clinic type"),
    and that text becomes `clinic_name`. On edit, a `clinic_name` that
    isn't in the list opens as "Other clinic" with that text.
  - "Appointment date". A past date gets a `400` on `appointment_date`. An older appointment
    can still be edited as long as its date doesn't change.
  - "Time (optional)". Left blank, it's not sent.
  - "Facility (optional)", placeholder "Hospital or clinic name". It's
    saved as `notes`.
- A reminders box:
  - The checkbox "Remind me before this appointment" (→ `reminder_enabled`).
  - When it's ticked, "Send reminders by (choose one or more)" with four
    tiles, WhatsApp, Email, SMS and Push, each toggling on or off
    independently (→ `reminder_channels`, sent in the tiles' order).
  - The note "SMS: applicable charges apply. Delivery uses your verified
    contact details after consent and activation."
  - A new appointment starts ticked, with WhatsApp selected. Editing an
    older appointment whose `reminder_channels` is `[]` shows no tile
    selected, and web leaves the field out of the PATCH unless the user
    touches the tiles.
- A new appointment is sent with `condition: "other"`. An edit (PATCH)
  sends the same body without `condition`, so the appointment keeps its
  existing one (an older hypertension/diabetes appointment stays filed
  under it), and without `reminder_channels` unless the tiles were
  touched, as noted above.
- Validation runs on Save, in this order, stopping at the first problem:
  "Please select the clinic type." / "Please enter the clinic type." /
  "Please choose the appointment date." / (reminders on, tiles touched,
  none selected) "Choose at least one way to be reminded.", shown under
  the tiles. That field gets a red outline and
  the message under it, the form scrolls to it and focuses it, and a
  toast repeats the message.
- "Cancel" and "Save appointment". The toast says "Appointment saved"
  (add) or "Appointment updated" (edit).

**The dashboard "My appointments" card:**

- Header "My appointments", with "N recorded" (or "No appointments
  added") and an **Add** / **Close** button. With none and the form
  closed: "Keep track of your upcoming clinic visits."
- It lists `GET /api/appointments/` (`source: "manual"` only) and shows
  the first one, then "View all N appointments" (to `/appointments`) when
  there's more than one.
- Each row:
  - A calendar glyph and `clinic_name`.
  - A details line: the date (day-first, dd/mm/yyyy), then " · HH:MM" if
    there's a time, " · {notes}" if any, then the reminder state:
    - " · WhatsApp reminder" for one channel, or all of them joined, e.g.
      " · WhatsApp, SMS & Push reminders" (labels WhatsApp / Email / SMS /
      Push, in the tiles' order);
    - " · Reminders on" for `[]`;
    - " · Reminders off" when `reminder_enabled` is false.
  - Edit (opens the form above inline) and remove icon buttons.
- Remove asks first: "Remove appointment?" / "Remove **{clinic_name}**
  from your appointments? This does not cancel a clinic booking." Toast
  "Appointment removed".

**The Appointments page** (https://staging.mywellnesshealth.co.ke/appointments, titled
**"Appointments"**, *"Every clinic visit you have coming up — booked
consultations, screenings and check-ups, plus your hypertension/diabetes
monitoring appointments."*) **merges two lists**:
- the user's appointments from `GET /api/appointments/` (`source:
  "manual"` only), and
- their service bookings (see
  [`bookings-and-consultations.md`](./bookings-and-consultations.md)).

It shows:
- An **"Add clinic appointment"** button (the form above, in a dialog).
- A "Search by clinic or service…" box that filters the merged list
  client-side by `clinic_name` / `service_label`.
- A table, newest date first, with "Clinic / Service" (a booking links to
  `/bookings/<id>` and shows a "Follow-up" badge and "Follow-up to …"),
  "Category" (the appointment's condition: Hypertension / Diabetes /
  Other, or the booking's status), and "Date". Empty states: "No
  appointments scheduled yet." / "No appointments match your search."
- Edit/Remove on appointment rows only:
  - A `condition: "other"` row opens "Edit clinic appointment" (the form
    above).
  - A hypertension/diabetes row opens the older **"Edit appointment"**
    dialog: "Clinic *", "Link a facility (optional)" (a registered-facility
    search, see
    [`bookings-and-consultations.md`](./bookings-and-consultations.md) §3;
    picking one also sets the clinic name, and typing a new clinic name
    unlinks it), "Date * & time (optional)" and "Notes". It sends `condition`,
    `clinic_name`, `facility_id` (`null` when none), `appointment_date`,
    `appointment_time` and `notes`. It never sends the reminder fields,
    so editing leaves them unchanged. Toast "Appointment updated".
  - Remove asks "Remove appointment?" / "This will remove your appointment
    at "{clinic_name}". This can't be undone." first (toast "Appointment
    removed").

## Period & Pain Tracker (Women's Health)

Served under `/api/vitals/` too, but used by the Women's Health hub's
**Period & Pain Tracker** page
(https://staging.mywellnesshealth.co.ke/assessments/women-health/period-tracker), not the
vitals pages. **Not gated by vitals access.** One record per user per
calendar day, keyed by the date (no `id`):

```
GET  /api/vitals/period-pain/?start=YYYY-MM-DD&end=YYYY-MM-DD   → 200 [ entry, ... ]  (both params required)
PUT  /api/vitals/period-pain/<YYYY-MM-DD>/                      → 200 entry   (upsert)
GET  /api/vitals/period-pain/report/months/                     → 200 { "months": [ { "month": "2026-10", "label": "October 2026", "period": "12 Oct 2026 – 31 Oct 2026" }, ... ] }
POST /api/vitals/period-pain/report/  { "month": "2026-10" }    → 200 application/pdf (password-protected, X-Pdf-Password-Hint)
GET  /api/vitals/report/email-prefill/                          → 200 { "email": "<address>|null" }   (the shared vitals prefill)
POST /api/vitals/period-pain/report/email/  { "email": "...", "month": "2026-10" }  → 200 { "detail": "Report emailed." }  (report_email throttle)
```

The page (**"MY WELLNESS HEALTH · WOMEN'S HEALTH"** / **"Period & Pain
Tracker"**, "Understand your pain patterns.") follows MWH_Tracker.html
(11 Nov 2026). It has a month calendar starting on Monday. Web loads just
the shown month (`start` = the 1st, `end` = the last day). Period days are
tinted pink, days with `pain_level > 0` get a purple dot, future days
can't be picked, and you can't page past the current month. Changing month
clears the selection ("Select a date to create or edit its daily record.").
Picking a day opens its **"Daily record"** form, pre-filled from that day's
entry if any.

`PUT` body. Web always sends every key,
blank when not applicable:
- `on_period` (bool, "Were you on your period?") and `pain_level` (0–10,
  "How severe was your pain?") are always required. Pain can be any whole
  number: a face for every number from 0 to 10 (0 🙂, 1 😌, 2 😐, 3 😕, 4 🙁, 5 😟, 6 😣, 7 😫, 8 😖, 9 😩, 10 😭; one row of 11,
  or two rows on a narrow screen; the chosen face is pink) and a slider.
  The label under it reads "Pain level: {n}/10 · {word}", where the word
  is No pain (0), Mild (1–2), Moderate (3–4), Significant (5–6), Severe
  (7–8) or Worst pain (9–10) — the same words as `pain_level_label`.
- When `pain_level > 0`, you also need:
  - `locations` ("Where did you feel the pain?"): ≥1 of
    `central_lower_abdomen`, `left_lower_abdomen_pelvis`,
    `right_lower_abdomen_pelvis`, `lower_back`, `deep_rectal_area`,
    `bladder_area`, `other` (+ `other_location`). `buttocks_or_legs` is no
    longer offered and a save with it is refused (400); entries saved
    before 11 Nov 2026 can still contain it, so show its label from
    `locations_labels`, and leave it unselected when editing.
  - `qualities` ("How would you describe your pain?"): ≥1 of `cramping`,
    `aching`, `shooting`, `stabbing`, `burning`, `pressure`.
  - `spread` ("Did the pain spread somewhere else?"): `none`, `back`,
    `leg`, `other` (+ `other_spread`).
  - `impact` ("Did the pain affect your usual daily activities?"):
    `none`, `little`, `some`, `much`.
  - `took_painkillers` (bool, "Did you take any painkillers?"). If that's
    `true`, you also need `medications` (1–10 non-empty names, "Medication
    1", "Medication 2" … and "＋ Add another medication") and
    `medication_relief` ("Did the medication relieve your pain?":
    `complete`, `partial`, `none`, `not_noticed`).
- With no pain, web shows "No pain recorded for this day. The
  pain-specific questions below are not required." and sends
  `locations: []`, `qualities: []`, `medications: []`, blank strings, and
  `took_painkillers: null`.
- **"Save my record"** stays disabled until the record is complete. Until
  then web lists what's missing under "ⓘ Complete the remaining details to
  save." (Period status · Pain severity · Pain location · Pain description
  · Pain spreading · Daily activity impact · Pain medication · Medication
  name · Medication relief). A save shows "✓ Daily record saved", "Period:
  Yes · Pain: 7/10" and "The calendar and pain history have been
  updated." until the record is edited again.

The response echoes every field plus the date, display labels for the
coded ones (`pain_level_label`, `locations_labels`, `qualities_labels`, …),
and `created_at`/`updated_at`.

**"My pain history"** (collapsible, "Review pain during and outside
periods") lists the shown month's saved entries, newest first: the date
("17 Oct 2026"), "During period" / "Outside period" · `qualities_labels`
(or "No pain description"), and "{pain_level}/10". Tapping one opens that
day. Empty: "No saved records for this month."

**"My period & pain report"** ("Export saved entries for the displayed
calendar month. Unsaved changes are not included."), in the site's report card ("KEEP YOUR
REPORT" over the title, with "Download Report", "Email" and "Share"; see
[`assessments.md`](./assessments.md), "6. PDF report"),
covers the calendar month on screen: send it as `month` ("YYYY-MM"). A
month that hasn't started or comes before the first entry returns 400
`{"month": [...]}`. Three buttons:
- **Download** saves the PDF (`MWH_Period_Pain_YYYY_MM.pdf`) and says "4K
  PDF prepared for download. It includes saved records for {Month
  YYYY}." plus the password hint.
- **Email** sends it to the account's own address (from
  `report/email-prefill`) with `report/email/`: "Your report has been
  emailed to {email}. Check your inbox (and spam folder) in a few
  minutes." With no address on file: "Add an email address to your
  profile to email this report."
- **Share** downloads the same PDF and hands it to the phone's share sheet
  ("The PDF has been passed to your selected sharing app."), so it can go
  to a doctor by any app. Cancelling: "Sharing cancelled. No report was
  sent."

The PDF is password-protected (`X-Pdf-Password-Hint`). It's one A4 page,
a clinical tracking record (MWH_4K_Pain_Tracker_Adult_Developer.html, 12 Nov
2026): the person's name and age, the reporting period (a month still in
progress runs to today), four measures (Highest daily pain, Days pain /
recorded, Period days with pain, Entries completed), the average pain on pain
days, a daily pain graph (pink on period days; days without a pain score are
gaps, never zero), the most frequent locations, descriptions, spread and daily
impact, recorded pain medicine, an observed pattern, a summary and a
disclaimer. The app just downloads and shows it; nothing in it is computed on
the phone. `report/months/` still lists the months a report can cover, if
you want a month picker.

---
Last verified against the code on 2026-11-12.
