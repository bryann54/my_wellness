# Vitals, Medications & Appointments

> **Before building anything from this file, check it against the web
> platform** — the wellness-health user web app (the source of truth).
> The mobile app implements exactly the regular-user features that exist
> and are usable there, with the same screens, labels and wording, and
> nothing more: no CHP, doctor, admin or organization-buyer features, no
> hidden UI, no mobile-only extras, and a feature behind one of web's
> build switches only behind the same switch. If something
> here doesn't match the web platform, or you think a feature is missing,
> don't build it — confirm with the product owner first.

The **Vitals & Chronic Care** pages (**Blood Pressure**, **Blood Sugar**),
with server-computed classification (the real thresholds never ship to a
client), the monitoring-profile onboarding each uses, and the vitals PDF
report. Then **Medications** (the dashboard's "My medications" card, the
`/medications` page and the per-condition widget on the vitals pages),
**Appointments** (the dashboard's "My appointments" card, the
`/appointments` page and the per-condition planner), and the Women's
Health **Period & Pain Tracker**.

All endpoints below require `Authorization: Bearer <access_token>` and
live under the bare `/api/...` prefix (no extra segment). See the
[README](./README.md) for the shared envelope. Note: errors raised as
DRF exceptions arrive as `{"error": {"detail": <DRF detail>,
"status_code": N}}` (`apps/common/exceptions.py`), so a serializer error
is `error.detail.<field>` and a `{"detail": "…"}` error is
`error.detail.detail`. The vitals `402` below is the one exception: it's
returned directly, not through that handler, so it's **not** wrapped.

## The paywall gate (Monitoring access)

BP/BS logging is paywalled. **It is no longer a permanent one-time
unlock.** `has_vitals_logging_access` (`apps/vitals/services.py:122`)
is true when the user has an **active (unexpired) `Monitoring`
`ModuleAccess` grant**, or a legacy `VitalsAccess` row (old one-time
buyers, kept forever). A `demo_restricted` account is always blocked
unless staff cleared it (`vitals_demo_cleared_at`). Because Monitoring
grants expire, re-check access rather than caching it forever. Call:

```
GET /api/vitals/access/
→ 200 { "has_access": true|false, "demo_restricted": true|false, "navigator_alerted_at": "<iso datetime>|null" }
```

Use this endpoint, not `GET /api/payments/module-access/`'s
`unlocked["Monitoring"]`: only this one also counts the legacy grant.
Web caches it for 60 seconds (`useVitalsAccess`, `staleTime: 60_000`).

If `has_access` is `false`, these all return the same unwrapped `402`:
`POST /vitals/blood-sugar/`, `POST /vitals/classify-preview/`,
`PUT /vitals/bp/monitoring-profile/`,
`PUT /vitals/blood-sugar/monitoring-profile/`, `POST /vitals/bp/sessions/`
and every session sub-step, `POST /vitals/report/`,
`POST /vitals/report/email/`.

```
402 { "detail": "A one-time payment unlocks day-to-day blood pressure/blood sugar logging. Buy the logging package, or a Basic/Plus/Pro wellness package, to continue.", "code": "vitals_access_required" }
```

(That copy is stale. It still says "one-time", but the gate is now the
expiring Monitoring access. Branch on `code`, and don't show `detail` as
the paywall text.)

Reads are **not** gated: reading lists, monitoring-profile `GET`s,
content, `summary`, and `report/email-prefill` all work without access.

**What web does (mirror it):**
- **Locked and not `demo_restricted`** → the Blood Pressure and Blood
  Sugar pages **redirect straight to the Monitoring purchase flow**
  (`/wellness-packages?service=monitor`) before rendering anything (no
  onboarding wizard, no medications/appointments/history). The
  dashboard's two vitals cards do the same on tap
  (`app/(app)/vitals/blood-pressure/page.tsx:79-86`,
  `app/(app)/dashboard/page.tsx` `vitalsLocked`). The purchase and
  post-payment wait follow [`payments-and-packages.md`](./payments-and-packages.md)
  (Monitoring → back to blood-pressure logging, waiting for
  `GET /api/vitals/access/` to show `has_access: true`). Because the
  redirect always fires first, the pages never show a locked logging card
  or take a payment themselves; mobile needs neither.
- **`demo_restricted` and locked** → no redirect. Web skips the whole
  onboarding wizard and shows the main page, with this card in place of
  the logging form, and hides the report buttons. The medication widget
  and appointment planner still show if a pathway was set earlier. The
  card is titled **"Payment received"**:
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

Web calls this as the user types, debounced **350ms**
(`useClassifyPreview` / `useBmiPreview` default delay in
`lib/api/vitals.ts`). Replicate that debounce; don't fire one request per
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

→ BP / pulse / BS: `200 { "classification": "orange_1" }` (see the band
identifiers below). BMI returns a different shape:
`200 { "bmi": 24.2, "classification": "underweight" | "normal" | "overweight" | "obese", "deficit_kg": <number|null> }`
(`apps/vitals/views.py:144-190`). Same input ranges as logging (systolic
50–300, diastolic 30–200, pulse 20–250). It's gated by the same access
check as logging (same `402`), so a blocked account can't
reverse-engineer the thresholds through it.

The preview returns only the identifier. Web turns it into text with its
own label tables (the BP and pulse tables below, the BS table under Blood
Sugar). Saved readings carry the server's own `classification_label`.

Where web shows it:
- The BP reading form colours the typed systolic/diastolic by the BP band
  and the pulse by the pulse band, and shows the "Very High Reading —
  Safety Alert" when the BP band is `red`.
- Blood sugar no longer uses this endpoint for its form; it uses
  `/vitals/blood-sugar/decision-preview/` (see Blood Sugar).
- The BMI step computes its display locally (see "The BMI step").

## Blood Pressure

Web's Blood Pressure page (`app/(app)/vitals/blood-pressure/page.tsx`,
logging card `components/vitals/bp-session-flow.tsx`) uses the
**session** flow below, not a single flat log call. Replicate the session
flow, or mobile will skip the mandatory-repeat/wellbeing logic web
enforces. **Drive the UI entirely off the session's `status`**, exactly
like web: `awaiting_second_reading` → repeat-reading form,
`awaiting_wellbeing` → the yes/no question, `completed` → result card.
Web keeps the session in memory only; leaving the page starts a fresh
"Log a reading" form next time.

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
schedule"** or **"Continue to BP recording"**, whichever comes next. On
the last step web saves the pathway (`PUT .../monitoring-profile/`) and,
the first time, `PATCH /api/health-profile/ { "htn_onboarding_seen": true }`.

When it shows setup:
- First time (`htn_onboarding_seen` false, or no `pathway` yet): from step 1.
- Already set up but `bmi_prompt_due` true: the BMI step alone; Continue
  goes straight to logging.
- **"Change monitoring reason"** (a link under the history card) reopens
  step 1 and re-saves the pathway.
- **"← Back"** steps back: logging → reason (or dialysis on Pathway E),
  dialysis → BMI/reason, BMI → reason; on the reason step it leaves the page.

```
GET /api/vitals/bp/monitoring-profile/
→ 200 { "pathway": "<choice>|\"\"", "provider_plan", "treatment_gap_reasons", "treatment_gap_other_text", "kidney_treatment": "ckd|hemodialysis|peritoneal|other|\"\"", "dialysis_schedule": "specific|daily|varies|unknown|\"\"", "dialysis_days": [0-6, ...], "is_dialysis_day_today": bool, "dialysis_pre_logged_today": bool, "dialysis_post_logged_today": bool, "updated_at" }
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
5. The medication widget for C, D and E ("My hypertension medications",
   or "My medications" on E) and the appointment planner for every
   pathway except A ("My hypertension appointments", or "My Renal clinic
   appointments" on E).
6. The **"Change monitoring reason"** link and the line "Clinical
   guidance is general and does not replace individual advice or
   emergency care."

On Pathway E the dashboard also shows, above the vitals cards:
- "Your dialysis days: Mon, Wed, Fri" from `dialysis_days` (sorted,
  Mon–Sun short names) for a `specific` schedule; "Every day" / "Schedule
  varies" / "Dialysis days not provided yet" for `daily`/`varies`/
  `unknown`; nothing for `ckd`/`other`.
- When `is_dialysis_day_today` is true, a **"Today is a dialysis day"**
  card ("Don't forget your dialysis appointment today."). On web it also
  offers **Enable reminders** until push is on. The dialysis-day reminder
  itself is server-sent; see
  [`push-notifications.md`](./push-notifications.md).

### The BMI step (both tools)

"Body Mass Index (BMI)" with an **OPTIONAL** tag ("Your compact BMI
check" on BP, "Compact live BMI check" on Blood Sugar), "Weight (kg)"
(20–400) and "Height (cm)" (100–250). Web computes the display locally
(it's arithmetic on the user's own numbers, not a classification): BMI =
kg / m², the reference range is the weight for BMI 18.5–24.9 at that
height.
- Box: "YOUR CALCULATED BMI", the BMI to one decimal with "kg/m²" (green
  when 18.5–24.9, red otherwise), the category ("Below reference range" /
  "Within reference range" / "Above reference range" / "Well above
  reference range"), and a tag "Reference range" or "Review weight".
- Two small boxes: "Reference weight range" ("<low>–<high> kg") and, when
  BMI ≥ 25, "Weight difference" (kg above the BMI-24.9 weight), otherwise
  "Current weight".
- BMI ≥ 25: "A BMI near 24.9 corresponds to approximately **<high> kg**.
  An illustrative first milestone is **<first> kg** (about <weight −
  first> kg body weight). Discuss goals with your clinician." where
  `first` is 5% of body weight, never more than the gap to 24.9. Below
  18.5: "Weight loss is not recommended based on this BMI. Consider
  discussing nutrition and your weight with a healthcare professional."
  Otherwise: "Your BMI is within the general adult reference range.
  Maintain healthy habits; BMI alone does not determine overall health."
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
own per-monitoring-reason decision (`apps/vitals/bp_decision.py`, a port
of the design's `getBPDecision`), `null` until `status` is `completed`.
Don't build the card from `final_title`/`final_cta_label`/
`final_recommendation`/`pulse_note` any more; those are the engine's
routing fields (referrals and reports key on `final_cta`). Each reading
also carries `monitor_band` and `monitor_pulse_colour`, the monitoring
tool's own scale used for history colours and tags (`classification`
stays the shared clinical band).

**The "Log a BP reading" form** ("Record values from your blood-pressure
monitor.", an "mmHg" pill): **"Systolic"** and **"Diastolic"** side by side
(units "SYS"/"DIA" inside the fields, placeholders 120/80), then
**"Heart rate (pulse) · optional"** ("bpm", "e.g. 72"). `systolic` and
`diastolic` are required; `pulse` is **optional** since the redesign (a
session without it has `pulse_category: ""` and no `pulse_note`). As
values are typed, web colours the numbers by the classify-preview band
(colours below); when the preview is `red` it shows **"Very High Reading —
Safety Alert"**: "If you have chest pain, severe breathlessness or sudden
neurological symptoms, seek emergency care now. Otherwise press Save
reading to record it and follow the repeat measurement step." The button
is **"+ Save reading"** (disabled until systolic/diastolic are in range
and any pulse is 20–250), with "Orange 2 and Red readings prompt a repeat. This tool
does not diagnose hypertension or adjust medication." under it.

Colours (the design's palette, used for typed numbers, the result accent
and history values): `blue` #2379B1, `green` #168054, `yellow` #F7E36A,
`orange_1`/`orange_2` both #BD6D23, `red` #C13743. The colour pill names
are "Blue", "Green", "Yellow", "Orange", "Red".

On a Pathway E dialysis day (`is_dialysis_day_today` true), the server
rejects a reading without `dialysis_phase` or `weight_kg` (400). Web
guides the user through pre-dialysis then post-dialysis, using
`dialysis_pre_logged_today`/`dialysis_post_logged_today`:
- Chips "✓ Pre-dialysis logged" / "Pre-dialysis pending" and the same for
  post, plus "Now logging: Pre-dialysis reading".
- After both are logged: "Both dialysis readings are logged for today.
  Logging another reading?" with a manual Pre-/Post-dialysis pick.
- The weight field is labelled "Pre-dialysis weight (kg)" /
  "Post-dialysis weight (kg)" (above 0, up to 500).
- Web re-fetches the monitoring profile after each dialysis-day save.
  Each dialysis-day reading is its own session.

### What the engine decides (`apps/vitals/bp_engine.py::evaluate`)

BP alone decides the outcome. Pulse never triggers a repeat or a
question; it only adds a `pulse_note`. Repeat flow from the 2026-11-03
redesign:

| First reading's band | What happens |
|---|---|
| `green`, `yellow` | `completed` at once. `final_cta` `none` (no CTA label), recommendation text only. |
| `orange_1` | `completed` at once. `final_cta` `visit_health_facility`. No repeat, no question. |
| `blue` | `completed` at once (no wellbeing question since UAT 2026-11-03). `final_cta` `none`. |
| `orange_2`, `red` | `awaiting_second_reading`, `final_cta` `repeat_reading`, `final_recommendation` = the rest-and-repeat prompt, **`repeat_wait_seconds`** = `120` (red) / `60` (orange_2). Count that down, ask the feeling question during the rest, then send Reading 2 **with** `feeling` (step 3). No separate wellbeing step. |

After Reading 2 the effective `bp_category` is the **most concerning** of
the two readings (blue < green < yellow < orange_1 < orange_2 < red), so a
lower repeat never downgrades the result; `average_systolic`/
`average_diastolic`/`average_pulse` hold the rounded mean of the two (pulse
mean of those entered) and are the value to display:

| Effective band | `feeling: "unwell"` | `feeling: "well"` |
|---|---|---|
| `red` | `go_to_hospital_immediately` | `visit_health_facility_now` |
| `orange_1`/`orange_2` | `visit_health_facility_now`, `final_title` "Clinical Assessment Needed", recommendation "You feel unwell with an elevated blood pressure reading." | `visit_health_facility` (the usual orange text) |

A serious symptom (see step 3b) at any point before the session completes
→ the emergency outcome.

The engine never returns `awaiting_third_reading` (old protocol); the
third-reading endpoint only finishes pre-existing sessions.

### 3. Repeat reading (only when `status` is `awaiting_second_reading`)

```
POST /api/vitals/bp/sessions/<uuid:session_id>/second-reading/
{ "systolic": 182, "diastolic": 112, "pulse": 90,   // pulse optional
  "feeling": "well" | "unwell",                      // REQUIRED
  "symptom_detail": "headache" }                     // see below
→ 200 <same session shape, second_reading filled in, status "completed">
```

`feeling` comes from `repeat.feeling_question` ("While you rest, how are
you feeling?"). Only when the **first reading was `orange_2`** and feeling
is `unwell`, also send `symptom_detail` from `repeat.symptom_detail_options`
(`chest`, `breathing`, `weakness`, `speech`, `vision`, `confusion`,
`seizure`, `collapse`, `headache`, `dizziness`, `other`). Picking a
`serious: true` option should immediately call the emergency endpoint
(3b) instead of waiting for the repeat.

**What web shows** (`RepeatStep` in `components/vitals/bp-session-flow.tsx`):
"Repeat your BP reading" ("Your first reading has been saved."), a box
"FIRST READING SAVED" with the first reading coloured by its band and, for
`red`, "This reading is very high. Visit a healthcare facility immediately.
Repeat if you feel well and it does not delay care." (Pathway D: "Repeat
the measurement after resting, then visit a healthcare facility to review
your treatment plan."; otherwise "Your blood pressure needs attention. Rest
and repeat the measurement before we recommend the next step."). While the
countdown runs: "REST BEFORE YOUR REPEAT", the mm:ss timer,
"`rest_instructions` Repeat your BP after 1 minute / 2 minutes." and "The
next reading form will appear automatically when the rest period
finishes." Once it ends: "SECOND MEASUREMENT", "Please measure your blood
pressure again now.", Systolic/Diastolic only (no pulse) and **"Save repeat
reading"**. The feeling question shows in both phases ("How are you
feeling?" after the rest), then on C and E a "MEDICATION REMINDER" box
(the result card's medication text), "Severely High Blood Pressure" for
`red`, and `repeat.medication_note`. The result card's title is
`final_title`; an emergency is shown in red.

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
access. Works for orange_2 and red sessions.

### 4. Wellbeing question (only when `status` is `awaiting_wellbeing`)

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
**HEART RATE · <result.pulse> BPM** ("<pulse_result.title>.
<pulse_result.recommendation> <pulse_result.cta>.", the number in
`pulse_result.colour`). Then, when present: muted "Medication:
<medication_advice>"; "Already at a healthcare facility? Show this result
to your healthcare professional." when `hospital_note`; and the
**"METABOLIC HEALTH ASSESSMENT"** panel when `assessment` is set
(`assessment.guidance`, "Assessment status: <status_label>", a button
`action_label` opening `assessment.url`). Always: "This result is not a
diagnosis; individual targets and pregnancy-related thresholds may
differ." Then a **"Log another
reading"** button that resets the flow. Then:
- **Pathway A (`routine`)**: when `final_cta` is `visit_health_facility`,
  `visit_health_facility_now` or `go_to_hospital_immediately`, the NEXT
  STEP text is a button that opens the **"Find a health facility"** dialog
  (`components/vitals/facility-choice-modal.tsx`):
  - On open, web calls
    `GET /api/care-navigation/referrals/from-bp-reading/<reading_id>/facility-candidates/`
    (no coordinates) only to name the booking: its `required_services`
    names, or "Blood pressure follow-up" when there are none.
  - Two tabs. **"Preferred facility"**: "Facility name" search, or "Add
    it as your facility" (Town, County, "Save and continue") when
    nothing matches. **"Use my current location"**: "Use my location",
    a map preview of the shared position, then "Use this location", which
    calls the same `facility-candidates` endpoint with
    `?user_lat=&user_lng=`.
  - The location tab only offers a facility when web's location
    recommendation switch is on, and **it's off by default** (see
    `bookings-and-consultations.md` §6). With it off, web shows *"Facility
    recommendations by location aren't available right now -- please use
    the "Preferred facility" tab to search for one by name."* (or "No
    facilities found nearby." when there are no candidates). With it on,
    it shows the top match as "Recommended facility: …" with
    **Navigate** / **Book Consultation**.
  - Picking a facility calls
    `POST /api/care-navigation/referrals/from-bp-reading/<reading_id>/`
    with `{ "user_lat", "user_lng", "facility_id": "<picked facility>" }`
    (coordinates only from the location tab), then opens the booking form
    locked to that facility as a `referral_visit`.
  - Once booked, web shows the referral card instead of the button. Web
    also hides the button when
    `GET /api/care-navigation/referrals/mine/` already has a referral whose
    `bp_reading` is this reading.
  - Shapes, the facility search/add endpoints and the booking step are in
    [`bookings-and-consultations.md`](./bookings-and-consultations.md)
    §3 and §6.
- **Every other pathway**: as soon as the session is `completed`, web
  auto-calls `POST /api/care-navigation/referrals/from-bp-reading/<reading_id>/`
  (with the device's coordinates if granted, no `facility_id`) and shows
  the auto-matched referral card. The CTA label stays plain text.

`<reading_id>` is the effective reading:
`third_reading ?? second_reading ?? first_reading`. Web asks for
location permission when the logging card mounts.

### History and the dashboard card

```
GET /api/vitals/blood-pressure/   → 200 [ reading, ... ]   (own readings, newest first, most recent 100)
GET /api/vitals/summary/          → 200 { "latest_bp": <reading>|null, "latest_bs": <reading>|null }
```

- **"My BP history"** ("<N> saved readings"): two boxes, **"Latest
  reading"** (systolic/diastolic, coloured by `monitor_band`) and
  **"Pulse rate"** (coloured by `monitor_pulse_colour`, "—" without one);
  a **"Recent trend"** chart of the last 7 readings (systolic and
  diastolic lines, "Last N readings"), or "Your trend will appear after
  at least 2 saved readings."; then the 5 newest readings ("Show all N
  readings" expands): "<systolic>/<diastolic> mmHg", "<date-time> · Pulse
  <pulse> bpm" (+ " · Pre-dialysis"/"Post-dialysis"), a tag from
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

### BP band identifiers (`apps/vitals/bp_engine.py::classify_bp`)

Web colours chips by the band identifier and shows the server's label.
The thresholds are listed for understanding only. **Don't hardcode them
into the Flutter app** beyond basic input-range checks; always use the
classification the API returns.

| Band | Label | Trigger |
|---|---|---|
| `red` | Severely High Blood Pressure | systolic ≥180 **or** diastolic ≥110 |
| `orange_2` | Very High Blood Pressure | systolic ≥160 **or** diastolic ≥100 |
| `orange_1` | High Blood Pressure | systolic ≥140 **or** diastolic ≥90 |
| `yellow` | Slightly Elevated BP | systolic ≥131 **or** diastolic ≥86 (the monitoring tool's `monitor_band`, session `bp_category` and classify-preview use ≥130 **or** ≥85) |
| `blue` | Low Blood Pressure | systolic <90 **or** diastolic <60 (checked only after every high band) |
| `green` | Normal Blood Pressure | none of the above |

Pulse has its own 6-band classification sharing these same identifiers:
`blue` Low, `green` Normal, `yellow` Slightly High, `orange_1` High,
`orange_2` Very High, `red` Severely High Heart Rate. Read it from the
preview or a saved reading's
`pulse_classification`/`pulse_classification_label`; never re-derive it.
The BP monitoring tool itself uses the design's 4-band heart-rate scale
(`monitor_pulse_colour` / `result.pulse_result`, and the pulse
classify-preview): `blue` <60, `green` 60–100, `yellow` 101–120, `red`
>120.

## Blood Sugar

A flat log, no sessions (`app/(app)/vitals/blood-sugar/page.tsx`), in the
same 2026-11-03 redesign look as Blood Pressure: brand row "MY WELLNESS
HEALTH" / **"Blood sugar monitoring"** (no back pill here). Results
follow the redesign's **blood sugar rulebook**, computed and stored by
the server for every reading (`apps/vitals/bs_decision.py`); mobile only
displays them.

```
GET /api/vitals/bs/content/                      → 200 { "onboarding": { "tips": { "items": [...] }, ... }, "pathway": {...} }   (same keys as BP, minus the dialysis ones)
GET /api/vitals/blood-sugar/monitoring-profile/   → 200 { "pathway", "provider_plan", "treatment_gap_reasons", "treatment_gap_other_text", "updated_at" }
PUT /api/vitals/blood-sugar/monitoring-profile/   { "pathway", "treatment_gap_reasons", "treatment_gap_other_text" }  → 200 <same shape>
```

**Setup is one screen** (no intro, profile or tips screens):
- **"Why are you monitoring?"** ("Just one selection to personalise the
  journey."), the "Monitoring reason" dropdown with `pathway_options`:
  `routine` "Routine / wellness check / hospital visit",
  `provider_directed` "A healthcare professional asked me to monitor",
  `diagnosed_on_medication` "I have diabetes and take medication",
  `diagnosed_not_on_medication` "I have diabetes and do not take
  medication". Shown the first time (`dm_onboarding_seen` false or no
  `pathway`) and after **"Change monitoring reason"**. `provider_plan` and
  `treatment_gap_reasons` are both optional now.
- Pathway D: the same optional "not taking medication" card as BP.
- The optional BMI card (see "The BMI step" under Blood Pressure; here it
  keeps its card frame) while `bmi_prompt_due` is true.
- **"Start recording →"** (no note under it). On Start web saves the pathway (when the reason was
  shown), the BMI or `bmi_prompt_skipped`, and the first time
  `dm_onboarding_seen: true`.
- An already set-up user with `bmi_prompt_due` true sees this screen with
  only the BMI card.

**The logging screen**, top to bottom: a collapsible **"Measure blood
sugar correctly ·"** box ("<N> quick tips", `onboarding.tips.items`); the
**"Log a reading"** form; the **"Latest result"** card after a save; Pathway
D's not-on-medication card (with "Save response"/"Update response");
**"Reading history"**; the medication widget ("My diabetes medications")
and appointment planner ("My diabetes appointments") for C and D only;
**"Change monitoring reason"**; and "Adult reference guidance only.
Special targets apply in pregnancy, childhood, and certain illnesses. This
tool is not diagnostic or a substitute for urgent care."

**The "Log a reading" form** ("Choose the reading type and enter the
value."):
1. **"Reading type"** chips: Random (`random`), Fasting (`fasting`),
   Pre-meal (`pre_meal`, **not offered on Pathway A**), Post-meal
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
     except on Pathway A, **"When was this reading taken?"**: "1–2 hours
     after starting the meal" (`less_than_2h`) / "Another time / unsure"
     (`at_least_2h`).
   - OGTT: "**Laboratory test only:** Enter the 2-hour result of a
     standardised 75 g OGTT, not an ordinary post-meal home reading." and
     the checkbox "I confirm this result comes from a laboratory 75 g
     OGTT." (`is_lab_ogtt`).
3. Pathway B only, until a reading has carried an answer: **"Have you
   previously been diagnosed with diabetes?"** (Yes / No / I'm not sure →
   `diabetes_diagnosis` `yes`/`no`/`unsure`). Web reuses the newest
   reading's `diabetes_diagnosis` after that instead of asking again.
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
→ 201 { "id", "value": "13.20", "unit", "reading_type", "meal_timing", "classification", "classification_label", "taken_at", "notes", "created_at",
        "feeling", "symptom_details", "high_ketones", "persistent_high", "diabetes_diagnosis", "is_lab_ogtt",
        "decision_colour", "decision_colour_label", "decision_title", "decision_recommendation", "decision_cta", "decision_safety", "decision_note", "decision_pathway",
        "decision_assessment_prompt": bool,
        "metabolic_assessment": null | { "status": "not_started|in_progress|completed", "url": "/assessments/diabetes",
                                         "show": bool, "message": "<text>", "cta_label": "COMPLETE|CONTINUE METABOLIC HEALTH ASSESSMENT" } }
GET /api/vitals/blood-sugar/   → 200 [ reading, ... ]  (own readings, newest first, most recent 100)
```

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
`decision_*` field `""`; show `classification_label` for those.

**The "Latest result" card** (after a save): accent and pill in the
decision colour (pill = `decision_colour_label`), `decision_title`,
"<type> · <value> mmol/L" (glucose always in mmol/L here, converting an
mg/dL entry ÷ 18.0182, one decimal; HbA1c "<value> %"), **RECOMMENDATION**
(`decision_recommendation`), **NEXT STEP** (`decision_cta`, at the card's
12px body size), "**Safety:** <decision_safety>" in brown (#745046) when
present, `decision_note` muted, and on Pathway A "Already at a healthcare
facility? Show this result to your healthcare professional." A Green
result on Pathway B (`provider_directed`) ends with a full-width **"SHARE
MY BLOOD SUGAR RECORD"** button (the same share as the history's Share). When
`decision_colour` is `orange` or `red`, NEXT STEP is a button that opens the
"Find a health facility" dialog (as BP Pathway A) with the `from-bs-reading`
endpoints:
`GET /api/care-navigation/referrals/from-bs-reading/<reading_id>/facility-candidates/`
and `POST /api/care-navigation/referrals/from-bs-reading/<reading_id>/`
with `facility_id` (the booking falls back to "Blood sugar follow-up").
Once booked (or when `GET /api/care-navigation/referrals/mine/` already has
a referral with this `bs_reading`) the referral card shows instead.
The old per-type guidance panels, the "Medication reminder" panel and the
"Your blood sugar has been persistently elevated" / "Book a consult" panel
are **gone**: the rulebook's result replaces them.

Colours (`decision_colour`): `blue` #2479B6, `green` #168054, `yellow`
#F7E36A, `orange` #C26724, `red` #B63242, `neutral` #087D72. For old
readings web maps the old band: blue/green/yellow/red as named,
`within_*` green, `timing_not_met`/`not_classified` neutral, everything
else orange.

**"Reading history"** ("<N> saved readings"): **"Latest glucose"** and
**"Latest HbA1c"** boxes (coloured); a **"View readings"** filter ("All
types" + each type); a trend of up to 7 readings of one type ("Recent
<type> trend", "<n> records · <unit>", "Only one reading type is plotted at
a time. Different meal timings should not be compared as equivalent.") or
"A trend appears after two saved readings of the same type."; then 8 rows
("Show all N readings" expands): "<value> <unit>" coloured, "<type> ·
<date-time>", a tag with `decision_title` (or `classification_label`) and a
bin. Empty: "No readings in this view yet." The bin works like BP's
(`DELETE /api/vitals/blood-sugar/<id>/`, "Remove reading?").

The CHP outreach and WhatsApp flows still log without `feeling`; their
readings get blank `decision_*` fields and keep only `classification`
(`apps/vitals/services.py::classify_bs`, unchanged; OGTT maps to
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
   their pathway (BP A–E, blood sugar A–D; `apps/vitals/report_guidance.py`,
   verbatim) and a closing "General patient safety message".

Three pill buttons sit at the bottom of both history cards
(`components/vitals/report-actions.tsx`, `variant="monitor"`), greyed out
until there's a reading, with "Download saves a password-protected PDF
report. Email sends that PDF to you. Share sends the PDF when your device
supports it, otherwise a short summary." under them:
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

Not paywalled (no `402`). Web has three surfaces:
- the dashboard's **"My medications"** card,
- the **Medications** page (`/medications`, in the sidebar),
- the per-condition widget on the Blood Pressure/Blood Sugar pages.

```
GET /api/medications/?condition=hypertension      → 200 [ medication, ... ]   (plain array, no pagination; newest first)
GET /api/medications/?q=metformin                  → 200 { cursor-paginated }  (every condition; optional name search; newest first)
```

- `?condition=` (`hypertension` | `diabetes` | `other`) returns the plain
  array. The vitals-page widget uses `hypertension` or `diabetes`. Any
  other value → 400.
- Without `condition`, the list is cursor-paginated. Web fetches every
  page. The dashboard sends no `q`; the Medications page sends `q` from
  its search box.

**The medication fields web reads (`MedicationSerializer`):**
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
  guessed date).
- `side_effects`: `null` unless a pharmacist-approved profile exists for
  this exact drug, otherwise `{ "generic_name", "drug_class",
  "side_effects": [...], "safety_caution" }`.
- The refill and insulin fields in the next section.

### Refill settings, "as needed" and insulin (2026-11-02)

**More fields on `MedicationSerializer`:**

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

**What web's add/edit form sends** (`components/medication-inline-form.tsx`,
used inline in the dashboard card and in the Medications page's "Add
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
  now in hand). A whole number from 1 to 10000. A refill starts a new
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

(`app/(app)/dashboard/page.tsx` with `components/medications/*`,
`medication-row.tsx` and `medication-inline-form.tsx`; mirror it.)

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
     letters it suggests up to 11 matching insulins (name, ingredient,
     category or alias) followed by `/formulary/search/` products ("No
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
     - A live supply estimate ("Estimated supply: N days", "Suggested
       refill reminder: <date>" three days before it runs out, or "No
       refill expected before this recorded course ends."). For "As
       needed": "For as-needed medicines, a reliable daily refill date
       cannot be estimated." It's a preview: once saved, the server's
       `refill_status` is the truth.
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
7. **"Confirm stock received"** (`mark-medication-refilled-dialog.tsx`, also
   used on `/medications`):
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

`app/(app)/medications/page.tsx`, titled **"Medications"** (*"Everything
you're currently taking — hypertension, diabetes, or anything else."*):
- An **"Add medication"** button (the same form, in a dialog). New
  standard medicines are saved with `condition: "other"`.
- Two tiles: "My medications" (total, "Recorded medicines") and "Refill
  attention" ("Due or within 7 days": `refill_due_date` within 7 days or
  overdue, `isRefillDueSoon` in `lib/api/medications.ts`). Both count the
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

### The vitals-page widget

On the Blood Pressure/Blood Sugar pages (`components/medication-capture.tsx`),
titled "My hypertension medications" / "My diabetes medications" (or "My
medications" on BP Pathway E). The same widget is the optional "Add your
medication" onboarding step:
- It lists `?condition=hypertension|diabetes`. Each row shows the name,
  "dosage · frequency" (frequency as its label, e.g. "Twice daily"; or
  "—"), `notes`, and
  "From photo" (for `source: "photo"`) or "Manual" · added date, with a
  Remove button. Empty state: "No medications recorded yet."
- **Add** opens a simple "Add medication" dialog: "Name *" (formulary
  search from 2 letters), "Dosage", "Frequency" ("Select a frequency…"
  plus the six `PrescriptionFrequency` values: Once daily, Twice daily,
  Three times daily, Four times daily, Every other day, Weekly), "Notes".
  "Save" stays disabled until a medicine is picked. It sends
  `{ "condition", "generic_product_id", "dosage", "frequency", "notes" }`.
  Toast "Medication added".
- Remove asks "Remove medication?" / "This will remove "{name}" from your
  medications. This can't be undone." (no toast).

## Appointments

Not paywalled. Web has three surfaces:
- the dashboard's **"My appointments"** card,
- the **Appointments** page (`/appointments`, in the sidebar),
- the per-condition planner on the Blood Pressure/Blood Sugar pages.

```
GET    /api/appointments/?condition=hypertension   → 200 [ appointment, ... ]   (plain array, soonest first)
GET    /api/appointments/                          → 200 { cursor-paginated, soonest first }   (every condition)
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
        "reminder_channels": ["whatsapp", "push"], "created_at": "..." }
```

- `condition`, `clinic_name` (≤200 chars) and `appointment_date` are
  required. `notes` is ≤300 chars.
- `appointment_time` is optional; reminders assume 08:00 when it's
  missing.
- `source` is read-only. An appointment created automatically from a
  real booking (a doctor-scheduled follow-up) has `source: "follow_up"`
  and is always filed under `condition: "other"`. The dashboard card and
  the Appointments page drop those, because the booking itself already
  represents them (the vitals planner never sees them).
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

The server sends reminders 24 hours and 2 hours before the appointment
(`apps.notifications.tasks.send_appointment_reminders`), on every chosen
channel and only those (`["push"]` alone means the app notification only,
no message). Choosing a channel turns it on for that appointment, even if
the user's notification preferences have it off (new accounts start with
email and SMS off). With `[]`, those preferences decide. A patient DHA
records as deceased is never messaged. WhatsApp
only delivers within Meta's 24-hour window after the user last messaged
us, so a WhatsApp-only reminder can fail to arrive; nothing falls back to a
channel the user didn't choose.

**The clinic-appointment form** (`components/appointment-inline-form.tsx`,
"Add clinic appointment" / "Edit clinic appointment", used inline in the
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
  - "Appointment date" (no past dates).
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
  existing one (a hypertension/diabetes appointment stays on its vitals
  page's planner), and without `reminder_channels` unless the tiles were
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

**The Appointments page** (`app/(app)/appointments/page.tsx`, titled
**"Appointments"**, *"Every clinic visit you have coming up — booked
consultations, screenings and check-ups, plus your hypertension/diabetes
monitoring appointments."*) **merges two lists**:
- the user's appointments from `GET /api/appointments/` (`source:
  "manual"` only), and
- their service bookings (`useMyBookings`, see
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

**The vitals-page planner** (`components/appointment-planner.tsx`),
titled "My hypertension appointments" / "My diabetes appointments" (or
"My Renal clinic appointments" on BP Pathway E), with the line "Keep
track of upcoming clinic visits for your {hypertension|diabetes} care —
clinic, date and time.":
- It lists `?condition=hypertension|diabetes`. Each row shows
  `clinic_name`, the date ("05 Nov 2026") and time ("9:00 AM"), and
  `notes`, with a Remove button. Empty state: "No appointments scheduled
  yet."
- **Add** opens an "Add appointment" dialog: "Clinic *", "Date * & time
  (optional)" (today or later), "Notes". It sends
  `{ "condition", "clinic_name", "appointment_date", "appointment_time",
  "notes" }` (blank time and notes left out) with no reminder fields, so
  the defaults apply (reminders on, every allowed channel). Toast
  "Appointment added".
- Remove asks "Remove appointment?" / "This will remove your appointment
  at "{clinic_name}" on {date}. This can't be undone." (no toast).

## Period & Pain Tracker (Women's Health)

Served by `apps.vitals` too, but used by the Women's Health hub's
**Period & Pain Tracker** page
(`app/(app)/assessments/women-health/period-tracker/page.tsx`), not the
vitals pages. **Not gated by vitals access.** One record per user per
calendar day, keyed by the date (no `id`):

```
GET  /api/vitals/period-pain/?start=YYYY-MM-DD&end=YYYY-MM-DD   → 200 [ entry, ... ]  (both params required)
PUT  /api/vitals/period-pain/<YYYY-MM-DD>/                      → 200 entry   (upsert)
POST /api/vitals/period-pain/report/                            → 200 application/pdf (password-protected, X-Pdf-Password-Hint)
GET  /api/vitals/report/email-prefill/                          → 200 { "email": "<address>|null" }   (the shared vitals prefill)
POST /api/vitals/period-pain/report/email/  { "email": "..." }  → 200 { "detail": "Report emailed." }  (report_email throttle)
```

The page ("Women's Health" / **"Period & Pain Tracker"**, "Understand
your pain patterns.") has a month calendar starting on Monday. Web loads
the visible month padded to whole weeks (`start` = the Monday on or before
the 1st, `end` = the Sunday on or after the last day). Period days are
tinted, days with `pain_level > 0` get a dot, and future days can't be
picked. Picking a day opens its **"Daily record"** form (pre-filled from
that day's entry, if any).

`PUT` body (`SavePeriodPainEntrySerializer`). Web always sends every key,
blank when not applicable:
- `on_period` (bool, "Were you on your period?") and `pain_level` (0–10,
  "How severe was your pain?") are always required. Web's pain picker
  only offers 0, 2, 4, 6, 8 and 10 (No pain, Mild, Moderate, Significant,
  Severe, Worst pain).
- When `pain_level > 0`, you also need:
  - `locations` ("Where did you feel the pain?"): ≥1 of
    `central_lower_abdomen`, `left_lower_abdomen_pelvis`,
    `right_lower_abdomen_pelvis`, `lower_back`, `deep_rectal_area`,
    `bladder_area`, `buttocks_or_legs`, `other` (+ `other_location`).
  - `qualities` ("How would you describe your pain?"): ≥1 of `cramping`,
    `aching`, `shooting`, `stabbing`, `burning`, `pressure`.
  - `spread` ("Did the pain spread somewhere else?"): `none`, `back`,
    `leg`, `other` (+ `other_spread`).
  - `impact` ("Did the pain affect your usual daily activities?"):
    `none`, `little`, `some`, `much`.
  - `took_painkillers` (bool, "Did you take any painkillers?"). If that's
    `true`, you also need `medications` (1–10 non-empty names, "Add
    another medication") and `medication_relief` ("Did the medication
    relieve your pain?": `complete`, `partial`, `none`, `not_noticed`).
- With no pain, web shows "No pain recorded for this day. The
  pain-specific questions below are not required." and sends
  `locations: []`, `qualities: []`, `medications: []`, blank strings, and
  `took_painkillers: null`.
- **"Save my record"** stays disabled until the record is complete. Until
  then web lists what's missing under "ⓘ Complete the remaining details to
  save." (Period status · Pain severity · Pain location · Pain description
  · Pain spreading · Daily activity impact · Pain medication · Medication
  name · Medication relief). A save shows "Saved." under the button.

The response echoes every field plus the date, display labels for the
coded ones (web shows `pain_level_label` and `locations_labels`), and
`created_at`/`updated_at`.

**"My pain history"** (collapsible, "Review pain during and outside
periods") lists the loaded entries that are period days or have a pain
level, newest first: the date, a "Period" tag, "Pain: N/10 ·
`pain_level_label` · `locations_labels`", and "Took: … · Pain control:
Complete / Partial / None / Not noticed yet". Empty: "No entries recorded
this month yet."

**"My pain report"** (`components/vitals/period-pain-report-actions.tsx`):
**Download report** (toast "PDF downloaded" with the password hint),
**Email report** ("Email me this report", pre-filled from
`report/email-prefill`) and **Share with my doctor** ("Share with your
healthcare provider", "Your provider's email address", starts blank).
Both email buttons call the same `report/email/` endpoint; only the
address differs.

---
Last verified against the code on 2026-11-03.