# Health Records & DHA Shared Health Record (SHR)

> **Before building anything from this file, check it against the web
> platform** — the user web app, live on staging at https://staging.mywellnesshealth.co.ke/ (the source of truth).
> The mobile app implements exactly the regular-user features that exist
> and are usable there, with the same screens, labels and wording, and
> nothing more: no doctor, admin or organization-buyer features, no
> hidden UI, no mobile-only extras, and a feature behind one of web's
> build switches only behind the same switch. If something
> here doesn't match the web platform, or you think a feature is missing,
> don't build it — confirm with the product owner first.

Covers linking a patient's account to Kenya's Digital Health Agency (DHA)
Shared Health Record (the OTP consent step), the **"Health record connection"** card,
the **My Medical History** page, the post-visit **"Did you make it to your
appointment?"** page, and the AfyaConnect sync and SHA coverage parts of
the Account page. Follow this file's exact shapes, not an older memory of the same
feature.

All endpoints below live under `/api/health-exchange/...` unless noted
(see this guide's `README.md` for the full prefix table). All require
`Authorization: Bearer <access_token>` and operate on the caller's own
data only (`request.user`). There is no cross-user access on any of
these.

## 1. DHA consent step (the OTP that opens an `SHRVisit`)

An `SHRVisit` is DHA's consent/visit record for one patient at one
facility (`apps/health_exchange/models.py`). Mobile never creates one
directly. The server opens it in the background, and web shows the OTP
step in exactly two places:
- **Right after a confirmed signup** (not after sign-in), the **"Link your
  health records"** step. When it shows is covered in
  [`auth-and-signup.md`](./auth-and-signup.md) (Step 2, `shr_linkage_pending`).
  There's no booking behind this visit.
- **Inside the booking dialog, right after a booking at a locked
  (pre-selected) facility** is created, the **"Confirm records sharing"**
  step. That's a booking made from a referral card or the "Find a health
  facility" dialog (see
  [`bookings-and-consultations.md`](./bookings-and-consultations.md) §6).
  The server only opens a visit when the booking's facility is
  HIE-managed (AfyaConnect), dispatched from
  `apps.health_exchange.signals._on_booking_saved`. Web can't tell that in
  advance, so for any other facility the step just keeps waiting until
  the user taps "Skip for now".

Either way, there is a real network round-trip to DHA in between, so
**mobile must poll, not assume the visit exists immediately.** The same
step is also reused by "Request DHA consent" (§2).

### Status enum (`SHRVisit.Status`, `apps/health_exchange/models.py`)

| Value | Meaning |
|---|---|
| `pending_otp` | Visit created, DHA has texted the patient an OTP, waiting on it. |
| `open` | Consent verified. This is the success state. |
| `pending_closure_otp` | A closure was requested; one more OTP needed to actually close it. |
| `expired` | Consent closed by DHA (see §4) or abandoned too long. |
| `closed` | Closed normally. |
| `rejected` | Patient declined consent. |

### Polling for the visit

```
GET /api/health-exchange/shr/visits/mine/                      -- signup step, and "Request DHA consent" (§2)
GET /api/health-exchange/shr/visits/by-booking/<booking_id>/   -- booking step
```

Both 404 while nothing exists yet. Web treats a 404 as "nothing yet",
because there's no way to tell "not applicable" from "not ready yet"
(`SHRVisitByBookingView` / `SHRVisitForCurrentUserView`). `by-booking` also 404s for a
booking that isn't yours. **Web polls every 3000ms**, and stops once status is
one of `open`, `expired`, `closed`, `rejected`. Note `open` counts as "stop polling": it's the success exit,
not a failure. Mobile must use the same 3-second interval and the same
stop condition.

While nothing has come back yet, web shows a spinner ("Linking your
existing health records…" at signup, "Setting up secure record sharing
with <facility>…" after a booking) with a **"Skip for now"** button, and
keeps polling indefinitely. There is deliberately no auto-skip timer (the
real DHA round trip has measured 7.5–10s+ with no upper bound). If
the visit comes back `expired`, `closed` or `pending_closure_otp`, web
just closes the step.

Response (`_shr_visit_to_dict`, `apps/health_exchange/views.py`),
the fields web reads:

```json
{
  "id": "uuid",
  "status": "pending_otp",
  "facility_name": "Example Health Centre",
  "attendance_confirmed": null
}
```

- `facility_name` can be `null` (the follow-up page falls back to "the
  facility"). The booking step's copy uses the booked facility's own name
  instead.
- `attendance_confirmed` is only used by the follow-up page (§5).

### Confirm / Decline / Resend code, once status is `pending_otp`

```
POST /api/health-exchange/shr/visits/<visit_id>/verify/        body: {"otp": "44012"}
POST /api/health-exchange/shr/visits/<visit_id>/reject/        body: {"rejection_reason": "..."}
POST /api/health-exchange/shr/visits/<visit_id>/resend-otp/    (no body)
```

All three return the same visit shape (200). A successful `verify` flips
status to `open`, and the server then starts reading the patient's
records in the background on its own. Mobile does nothing extra; just
re-render from the returned/polled visit. Every visit endpoint is
owner-only (`get_object_or_404(..., user=request.user)`): someone else's
visit id is a 404.

Request rules and errors (`SHRVisitVerifyView`, `SHRVisitRejectView`, `SHRVisitResendOtpView`):
- `otp` is required. A missing/blank one is a 400. **DHA's code length
  isn't fixed.** The sandbox code `44012` is 5 digits, a real send has
  come back as 4. Web's input takes up to 8 digits and enables **Confirm**
  from 4, and lets DHA's own verify decide. Don't
  hard-code a 6-digit field.
- `rejection_reason` is optional. It defaults to "Declined by patient".
- A wrong OTP, a visit in the wrong state, or DHA being unreachable all
  come back as a 400 in the standard error envelope, with the human
  message in `error.detail.detail` (e.g. `"Could not reach DHA: …"`):
  `{"error": {"detail": {"detail": "…"}, "status_code": 400}}`. Show it
  as a toast and leave the OTP screen up, the way web does.

Web's OTP screen:
- Title and body:
  - Signup: **"Link your health records"**, *"We can link any existing
    health records Kenya's Digital Health Agency already has for you.
    We've texted a verification code to your phone — enter it below to
    confirm."*
  - Booking: **"Confirm records sharing"**, *"{Facility Name} would like
    access to your shared health record for this visit. We've texted a
    verification code to your phone — enter it below to confirm."*
- The boxed consent notice (below), the OTP input, a **Confirm** button,
  and two small links: **Resend code** (toast "Code resent." on success)
  and **Decline**.
- **Decline** opens an optional-reason textarea ("Let us know why you'd
  rather not share your records (optional).") with **Confirm decline** /
  **Back**.
- A `rejected` visit shows **"Record sharing declined"**, *"You can still
  use the app as normal — your care team just won't have automatic access
  to your shared health record. You can change this later from account
  settings."*, with a Done button.
- An `open` visit shows a success screen with a Done button:
  - Signup: **"Health records linked"**, *"Your care team can now securely
    access your shared health record from Kenya's Digital Health Agency."*
  - Booking: **"Records sharing enabled"**, *"{Facility Name} can now
    securely access your shared health record for this visit."*
- Done and Skip for now just close the step. No outcome (linked,
  declined or skipped) changes whether the account or booking is usable.

**Mandatory consent-notice copy requirement (confirmed 2026-10-27):**
every screen where the user types this OTP must show, directly above the
input, an explicit sentence that entering the code **is** their consent
decision. Web shows it in a boxed notice prefixed **"Your consent:"**,
with two exact wordings:
- Booking flow: *"Entering this code confirms you consent to
  {Facility Name} and My Wellness Health fetching your shared health
  record from Kenya's Digital Health Agency (DHA) for this visit."*
- Signup flow (also reused by "Request DHA consent", §2): *"Entering
  this code confirms you consent to My Wellness Health fetching your
  existing health records from Kenya's Digital Health Agency (DHA)."*

This isn't cosmetic. It's a product/compliance requirement that applies
to every surface that collects this OTP, mobile included.

## 2. The "Health record connection" card (top of My Medical History)

Web redesigned this page on 2026-11-05. With no open visit the card says
"Consent not confirmed" with **Request DHA consent**. With an open visit it
says "Consent confirmed" with **Refresh from DHA**.

Two mutually-exclusive actions, gated by one shared 1-hour cooldown
(`SHR_RESYNC_COOLDOWN = timedelta(hours=1)`,
`apps/health_exchange/services.py`). Which one shows is decided by
`has_open_visit`, not by the client guessing:

```
GET /api/health-exchange/shr-resync/status/
```
```json
{
  "has_open_visit": true,
  "can_resync": true,
  "next_eligible_at": null,
  "records_fetching": false,
  "dha_phone_missing": false,
  "consent_request_status": null
}
```
(`get_shr_resync_status`, `services.py`. It also returns
`last_attempted_at`, which web doesn't show.)
`next_eligible_at` is only non-null while actually on cooldown. Display
it as-is; don't compute your own 1-hour offset client-side (it already
accounts for the test-account cooldown bypass). Web renders nothing for
this card until the first status response arrives.

`records_fetching` is `true` while a background DHA records read is
running for **any** of this user's open visits, whether this card's
button started it or the server did on its own. Web:
- **Polls this status endpoint every 3s while `records_fetching` is
  true, every 15s otherwise**, for as long as the My Medical History page is open.
- Shows a spinner line, *"Fetching your latest health records from DHA —
  this can take a few seconds…"*, while it's true, and **disables the
  button** while a request is sending, while `can_resync` is false, and
  while `records_fetching` is true.
- **Refetches medical history once each time `records_fetching` goes from
  `true` to `false`**, whatever started the fetch. This is the reliable
  "new data landed" signal. Mirror it.

The card's title is **"Health record connection"**, with a status chip
beside it: **"Consent confirmed"** when `has_open_visit` is true,
**"Consent not confirmed"** when false. Its body is one fixed paragraph,
whatever the state: *"Access to health records shared through Kenya's
Digital Health Agency (DHA) requires appropriate consent and an active
system connection. Records from other facilities will appear here only
when they have been securely retrieved."* Next to the button, a small
line reads *"Connection status: Active"* (open visit) or *"Connection
status: Awaiting verification"* (no open visit). While on cooldown
(`can_resync` false and `next_eligible_at` set) that line is replaced by
*"You can try again on <next_eligible_at, local date-time>."*

- **If `has_open_visit: true`** → the button reads **"Refresh from DHA"**
  ("Refreshing…" while sending):
  ```
  POST /api/health-exchange/shr-resync/          (no body)
  ```
  returns `{"queued_visits": 1}` immediately. It's fire-and-forget; the
  real DHA read happens in the background (7–10s+ per visit,
  `resync_shr_patient_records`). Web toasts *"Refresh requested — new records
  usually take a few seconds to appear below."*, refetches both the
  status and medical history right after the POST, and **refetches
  medical history once more 9 seconds later** as a backstop to
  the `records_fetching` transition above. Mobile should do both.
- **If `has_open_visit: false`** → the button reads **"Request DHA
  consent"** ("Requesting…" while sending). It covers both "never
  consented" and "consent expired"; the client doesn't need to tell them
  apart:
  ```
  POST /api/health-exchange/shr-resync/request-consent/      (no body)
  ```
  ```json
  { "status": "queued" }
  ```
  The DHA calls run in the background. Poll `GET /shr-resync/status/` every 3
  seconds while `consent_request_status` is `"pending"`. After 90 seconds the server reports
  `"not_possible"`. It then becomes one of:
  - `"no_dha_phone"` means DHA holds no valid contact to send the OTP to, so
    no consent was requested. Web shows an info toast: *"Kenya's Digital
    Health Agency has no phone number for you, so we can't link your records
    yet. Once your number is on your DHA record, you can link them from
    Medical History."* See "When DHA has no phone for the patient" below.
  - `"requested"` means a fresh `pending_otp` visit now exists. Web
    switches the card's body (still titled "Health record connection",
    chip "Consent not confirmed") straight into
    the §1 OTP step (with the signup wording throughout),
    polling `GET /api/health-exchange/shr/visits/mine/` the same 3-second
    way. Web refetches that query immediately on this result, so the
    first poll doesn't wait 3s. When the step closes (Done or Skip for
    now), the card goes back to its normal view.
  - `"not_possible"` means DHA has nothing resolvable for this account
    yet. It's an expected outcome, not an error. Web shows an info toast:
    *"DHA doesn't have a resolvable health record for your account yet.
    If you've recently registered, try again later."*

Both POSTs share the cooldown, and **an attempt is stamped before the
work starts**, so a failed attempt still uses up the hour
(`services.request_fresh_shr_consent`). Errors:
- On cooldown → `400`, message in `error.detail.detail`: *"You can try
  refreshing from DHA again after <iso>."* /
  *"You can try requesting a new DHA consent again after <iso>."*
- `POST /shr-resync/` with no open visit → `400` *"There's no active DHA
  health record link to refresh yet."*
- Both POSTs are throttled at `10/hour` per user (scope `shr_resync`) on
  top of the cooldown. Past it you get `429`
  `{"error": {"detail": "Too many attempts. Please try again in about N
  minutes.", "status_code": 429}}`. The status endpoint isn't throttled,
  so polling it is fine.

Web shows any of these as an error toast. Don't rely on them for UX:
check `/shr-resync/status/` first and disable the button client-side, as
web does.

## 3. My Medical History

Web's layout (https://staging.mywellnesshealth.co.ke/medical-history) is described
in full under "What the page shows" below.

```
GET /api/clinical/my-medical-history/
```

(Note the prefix here is `/api/clinical/`, not `/api/health-exchange/`.
This view aggregates every clinical-record source, SHR included.)

```json
{
  "diagnoses":         [{ "id", "condition", "severity", "details", "created_at" }],
  "allergies":         [{ "id", "allergen", "severity", "reaction", "notes", "created_at" }],
  "lab_results":       [{ "id", "test_name", "result_value", "unit", "reference_range", "interpretation", "specimen_type", "specimen_collected_at", "status", "notes", "result_date", "created_at" }],
  "procedure_records": [{ "id", "procedure_name", "notes", "performed_date", "created_at" }],
  "prescriptions":     [{ "id", "medication", "dosage", "start_date", "end_date", "instructions", "created_at" }],
  "immunizations":     [{ "id", "vaccine_name", "dose_number", "status", "occurrence_date", "notes", "created_at" }],
  "bp_attention_notice": null,
  "bp_readings":       [ /* blood-pressure reading shape */ ],
  "bs_readings":       [ /* blood-sugar reading shape */ ],
  "vital_signs": [
    {
      "id": "uuid",
      "vital_type": "heart_rate",
      "vital_type_label": "Heart rate",
      "value": "67.00",
      "unit": "/min",
      "notes": "",
      "taken_at": "2026-07-15T09:00:00+03:00",
      "created_at": "2026-10-27T10:05:00Z"
    }
  ]
}
```

(`MyMedicalHistoryView`, `apps/clinical/views.py`; the field lists
above are the ones web renders.) Each list is newest first and capped at
the **50 most recent** rows (`services.get_patient_chart`). Not
paginated. `bp_readings`/`bs_readings` use the same reading shapes as the
vitals pages (see
[`vitals-medications-appointments.md`](./vitals-medications-appointments.md)),
including self-logged readings, not only SHR-sourced ones.

`bp_attention_notice` is a server-written sentence about the latest blood
pressure reading, or `null`. Lab results also carry `interpretation_label`,
`specimen_type_label` and `status_label`.

`vital_signs` holds heart rate, body temperature, respiratory rate,
oxygen saturation, weight and height that arrived from DHA as standalone
FHIR Observations. `vital_type` is one of `heart_rate`, `temperature`,
`respiratory_rate`, `oxygen_saturation`, `weight`, `height`; show
`vital_type_label`. These are read-only: they only ever come from DHA,
and there's no way for the user to add one.

### What the page shows

Web's page (https://staging.mywellnesshealth.co.ke/medical-history, "My Medical History" in
the sidebar), top to bottom. Dates are shown as "05 Nov 2026".

- The **Back** pill, the eyebrow *"My Wellness Health · Patient record"*,
  the title **"My Medical History"** and the subtitle *"Review your
  documented medical conditions, allergies, laboratory results, treatment
  history and recorded health measurements in one place."*
- A row of jump links: **Recorded measurements**, **Clinical history**,
  **Investigations & treatment**, **Record connection**.
- The **"Health record connection"** card (§2).
- A spinner while the history loads; if it fails, *"We couldn't load your
  medical history. Please try again."*

**01 / MEASUREMENTS: "Recent clinical measurements"** (*"Measurements
recorded through health monitoring or connected records."*)

- Three tiles. With no data, each reads **"Not recorded"** with a sub-line
  (the first two say *"No reading available"*).
  - **Most recent blood pressure:** "<systolic>/<diastolic> mmHg", then
    "<date> · <`monitor_band_label`>". Uses the first `bp_readings`
    entry, and the value is in the alert colour when its `monitor_band`
    is `red`.
  - **Latest blood glucose:** "<value> <unit>" from the first
    `bs_readings` entry, with its `reading_type_label` underneath (e.g.
    "Fasting test", "HbA1c test").
  - **Allergy information:** "<n> recorded" with the allergen names
    joined by ", ". With none, the sub-line is *"Not equivalent to “no
    known allergies”"*.
- **"Blood pressure history"** card (*"Recorded systolic, diastolic and
  pulse values"*, with "<n> reading(s)" counting the filtered list):
  - When `bp_attention_notice` isn't null, a box reads **"Attention:"**
    followed by it.
  - Each reading shows "<systolic>/<diastolic> mmHg", then "<date>",
    "Pulse <pulse> bpm" when `pulse` is set, and "Pre-dialysis" /
    "Post-dialysis" from `dialysis_phase`, joined by " · ". `notes`
    follow, and the `monitor_band_label` pill sits on the right.
  - Pill colour by `monitor_band`: `red` red; `orange_2` and `orange_1`
    orange; `yellow` amber; `blue` blue; anything else green.
  - A filter offers **All readings**, **Needs attention**
    (`needs_attention: true`) and **Within monitoring range**
    (`needs_attention: false`). Only three readings show until **View
    all readings** (shown when more than three match), which then reads
    **Show recent readings**.
  - Empty states: *"No blood pressure readings are available in this
    record."*, or *"No blood pressure readings match this filter."*
  - Footnote: *"Blood pressure categories are monitoring indicators, not
    a medical diagnosis. For treatment decisions, consult your healthcare
    professional."*
- **"Blood glucose"** card ("<n> reading(s)" when there are any):
  - Only the latest reading shows until **View all readings** (shown when
    there's more than one), which then reads **Show latest reading**.
  - Each reading shows "<value> <unit>", its date and a pill, then
    `notes`.
  - The pill reads `classification_label`, except that a `not_classified`
    reading reads **"Not classified"** and adds *"Interpretation is
    unavailable because this is a random reading, not a fasting or
    post-meal measurement."*
  - Pill colour by `classification`: `not_classified` and
    `timing_not_met` grey; `red` red; `green`, `within_target_2h` and
    `within_general_target` green; anything else amber. The reading also
    carries the server's own `display_colour`, which the app can use
    instead of this mapping.
  - When `unit` is null (an HbA1c reading), web shows "%".
  - Empty state: *"No blood glucose readings are available in this
    record."*
- **"Other vital signs"** card: "`vital_type_label`: `value` `unit`",
  the date, `notes`. Empty state: *"No additional vital-sign observations
  are available in this record."*

**02 / CLINICAL HISTORY: "Conditions & allergies"** (*"Clinical diagnoses
and documented allergies or adverse reactions."*) and **03 / CARE RECORD:
"Investigations, treatment & prevention"** (*"Available laboratory,
procedure, prescription and immunization information."*)

Each record type is one row. It shows the label and either "<n>
record(s) available." followed by the records, or its empty line and a
pill (**"No record"**, or **"Not documented"** for allergies). Every
record ends with its date.

| Row label | Empty line | Each record shows | Date |
|---|---|---|---|
| Diagnoses & medical conditions | No clinical diagnoses documented in the available record. | `condition` + " (`severity`)" if set; `details` | `created_at` |
| Allergies & adverse reactions | No allergy or adverse-reaction information documented. | `allergen` + " (`severity`)" if set; "Reaction: `reaction`"; `notes` | `created_at` |
| Laboratory results | No laboratory investigation results available. | "`test_name`: `result_value` `unit`"; badges below; "Reference range: …"; "Specimen: `specimen_type_label` · collected <date>"; `notes` | `result_date`, else `created_at` |
| Procedures & interventions | No procedures or interventions documented. | `procedure_name`; `notes` | `performed_date`, else `created_at` |
| Prescriptions & medications | No prescriptions available in the connected history. | "`medication` — `dosage`"; "From <start_date> · Until <end_date>" (or "From <start_date> · Ongoing" with no end); `instructions` | `created_at` |
| Immunization history | No vaccination records available in this history. | `vaccine_name` + " (Dose `dose_number`)" if set; a grey status badge when `status` isn't `completed` (hyphens shown as spaces); `notes` | `occurrence_date`, else `created_at` |

Lab result badges:
- The `interpretation_label` badge shows only when `interpretation` is
  set. It's green for `N` and red otherwise.
- A grey `status_label` badge shows when `status` isn't `final`.

Below section 03: *"“No record” means information is not currently
available on this page. It does not confirm that a condition, medication,
procedure or vaccination has never occurred."* The page footer reads *"My
Wellness Health · Health information and care navigation. This page
summarizes recorded information and does not replace assessment or advice
from a licensed healthcare professional."*

Render every row even when empty, as web does, so a patient with no SHR
link yet still sees a coherent (empty) page.

## 4. When a consent has expired

DHA can report a consent as closed
(`_CONSENT_CLOSED_MARKERS`, `apps/health_exchange/services.py`).
When that happens during the server's own background fetches, the
backend marks the visit `expired` (`_expire_visit_for_closed_consent`).

Mobile doesn't need to parse DHA's message. The "Health record connection"
card from §2 is the recovery path: once the visit has expired,
`has_open_visit` reads `false` and the card offers "Request DHA consent"
instead. Web refetches `GET /api/health-exchange/shr-resync/status/` after
each successful POST, and its 15-second background poll (§2) picks up
any other change on its own while the page is open.

## 5. Post-visit follow-up ("Did you make it to your appointment?")

The hourly `reconcile_closed_shr_visits` job
(`services.reconcile_shr_visit_closure`) notices when
DHA no longer lists a visit as open, closes it, and notifies the patient
once (stamps `followup_notified_at`). No notification is sent, and
`followup_notified_at` stays null, for a signup visit (`requested_by` "MWH"
with no booking or referral) or a visit opened more than 7 days ago. It
otherwise sends one of two notifications, both
in the `appointment` preference category (see
[`push-notifications.md`](./push-notifications.md)):

| Case | Title | `data` |
|---|---|---|
| Records came through for the visit | "How was your visit?" | `{"type": "post_visit_followup", "visit_id", "has_data": true, "url"}`. For an Endometriosis booking it also carries `"assessment_slug": "endometriosis-followup"` and `url` is `/assessments/endometriosis-followup/start`; otherwise `url` is `/bookings/<booking_id>` (or `/dashboard` if there's no booking) |
| Nothing ever came through | "Did you make it to your appointment?" | `{"type": "post_visit_attendance_check", "visit_id", "has_data": false, "url": "/visits/<visit_id>/follow-up"}` |

Web's push handler opens `data.url`. The second one opens
web's follow-up page (`https://staging.mywellnesshealth.co.ke/visits/<id>/follow-up`). Mobile
should route the push to an equivalent screen:

```
GET  /api/health-exchange/shr/visits/<visit_id>/                         -- load it (404 not found / not yours)
POST /api/health-exchange/shr/visits/<visit_id>/attendance/   body: {"attended": true|false}   -> 200 visit
POST /api/health-exchange/shr/visits/<visit_id>/rebook/       body: {"new_date": "YYYY-MM-DD"} -> 201 ServiceBooking
```

- `attended` must be a real JSON boolean (400 *"attended must be true or
  false."* otherwise). Answering twice is a 400 (*"…attendance was
  already recorded."*).
- If `attendance_confirmed` is already set when the screen opens, don't
  ask again. Show the finished state: `true` → "Thanks for confirming!"
  ("Glad you made it to your appointment."), `false` → "No problem"
  ("Reach out any time if you'd like to rebook later.").
- Web's steps ("Loading…" while the visit loads):
  1. **"Did you make it to your appointment?"** ("We haven't heard back
     from <facility_name or "the facility"> about your recent visit.")
     with **Yes** / **No**. Each answer is saved straight away through
     `attendance/`.
  2. **Yes** → "Thanks for confirming!" + **Done**.
  3. **No** → "Sorry you weren't able to make it" ("Would you like to
     rebook?") with **Yes, rebook** / **No**. **No** → "No problem" +
     **Done**.
  4. **Yes, rebook** → **"Pick a new date"** ("What date would you like to
     rebook for, at <facility>?"), a date picker and
     **Confirm new date**. That calls `rebook/`, toasts "Your appointment
     has been rebooked." and opens the new booking (`/bookings/<id>`).
  - **Done** goes to Appointments. **Back** goes back (Appointments if
    there's no history).
  - Any failed call is shown as an error toast and leaves the step up.
- A load error shows "Not found" ("This visit could not be found.") for
  404, "Access restricted" ("You don't have access to this visit.") for
  403, otherwise "Something went wrong" ("Something went wrong loading
  this visit."), with a "Back to appointments" link.
- `rebook/` returns the new booking (`ServiceBookingSerializer`, see
  [`bookings-and-consultations.md`](./bookings-and-consultations.md)),
  not the visit. `new_date` is required (400 *"new_date is required."*).
  A date that isn't `YYYY-MM-DD` is a 400 *"Enter a valid date."*, and a
  date before today is a 400 *"The new date can't be in the past."* (web's
  date picker doesn't offer past dates). It's also a 400 unless attendance
  was recorded as `false` first, or if the visit has no booking to rebook
  from.
- WhatsApp-reachable users get the same conversation in chat
  (`apps/whatsapp/flows/post_visit_followup.py`), which calls the same
  service functions, so either channel leaves the visit in the same
  state.

## 6. Account page: "SHA coverage" and "AfyaConnect sync"

Web shows both on the Account page's **General** tab
(https://staging.mywellnesshealth.co.ke/account), not on My Medical
History: the "AfyaConnect sync" row at the end of the **Identity details**
section, and the SHA check in the **Membership & SHA coverage** section
further down.

**"AfyaConnect sync" row**: re-matches the user against DHA's Client
Registry by National ID (24-hour cooldown,
`AFYACONNECT_RESYNC_COOLDOWN`):

```
GET  /api/health-exchange/afyaconnect-resync/status/
→ 200 { "already_synced": bool, "has_national_id": bool, "can_resync": bool,
        "last_attempted_at": "<iso>|null", "next_eligible_at": "<iso>|null" }
POST /api/health-exchange/afyaconnect-resync/      (no body)
→ 200 { "status": "synced" | "not_found" | "unavailable" }
```

- Web hides the row entirely while the status is loading, when
  `has_national_id` is false, and while the user is using someone else's
  account as their next of kin (see [`next-of-kin.md`](./next-of-kin.md)).
- Title **"AfyaConnect sync"**. Line under it: *"Keep your dependants,
  phone number and address current."* when `already_synced`, otherwise
  *"No Client Registry record found yet. Try again if you've just
  registered for SHA."* On cooldown (`can_resync` false and
  `next_eligible_at` set) the line instead reads *"You can sync again on
  <next_eligible_at, local date-time>."*
- Button: **"Refresh"** when `already_synced`, otherwise **"Sync"**
  ("Syncing…" while sending). Disabled while `can_resync` is false.
- Result toasts:
  - `synced` (success): "Synced with AfyaConnect. Your details are now up to date."
  - `unavailable` (error): "We couldn't reach AfyaConnect just now. Nothing
    has changed, so please try again shortly." DHA couldn't be reached;
    this attempt doesn't start the 24-hour cooldown.
  - `not_found` when `already_synced` (info): "AfyaConnect has no newer
    data right now. Your existing details are unchanged."
  - `not_found` otherwise (info): "AfyaConnect doesn't have a matching
    record yet. If you've just registered for SHA, this can take a little
    time. Try again later."
  - A failed call: the error message, or "Could not sync with AfyaConnect".
- After the POST, web refetches the status and the health profile.
- Errors: a cooldown hit, or no National ID on file, is a `400` with the
  message in `error.detail.detail`. The POST is also throttled at
  `10/hour` (scope `afyaconnect_resync`, `429`).

**SHA coverage** (in **Membership & SHA coverage**, below a read-only
**Member code** field showing the profile's `member_code`, placeholder
"Assigned by My Wellness Health"): *"Check your Social Health Authority
(SHA) coverage using the National ID on file."*, followed by " SHA number:
<sha_number>." when the profile has `sha_number`.

```
GET /api/health-exchange/sha-eligibility/
→ 200 { "memberCrNumber": "...", "statusCode": "...", "statusDesc": "...",
        "schemes": [{ "schemeName": "UHC", "covered": true, "message": "...", "reason": "...",
        "possibleSolution": "", "startDate": "", "endDate": "" }] }
```

- Which state shows is decided by the health profile's
  `sha_eligibility_checkable` (see
  [`account-and-profile.md`](./account-and-profile.md)). Read that field;
  don't work out the ID-type rule in the app.
- When `sha_eligibility_checkable` is false, web shows a "National ID
  number" field (placeholder "e.g. 12345678") and **Save** ("Saving…")
  instead. That's a profile PATCH of `sha_beneficiary_id` +
  `sha_beneficiary_id_type: "national_id"`; toast "National ID saved", or
  the error message / "Could not save National ID". When a
  `sha_beneficiary_id` of another type is on file, it adds above the
  field: *"Your account has a {sha_beneficiary_id_type} on file, but
  eligibility checks only work with a National ID. Enter one below to
  enable this."*
- When it's true, web shows **"Check SHA eligibility"** ("Checking…") and
  under it "National ID on file: <id>". The ID is masked to its first two
  and last two characters, e.g. "12••••34" ("••••" if 4 characters or
  fewer). A failed check is an error toast with the message, or "Could
  not check SHA eligibility".
- The result box shows one row per scheme:
  - "{schemeName}: Covered" when `covered` is true (DHA's status `1`, the
    only value seen so far);
  - otherwise the scheme name, then `message` and `possibleSolution`.

  With no schemes it shows `statusDesc`, or *"SHA returned no coverage
  details."* when that's empty too. Then "Member CR number: …" when
  `memberCrNumber` is set. This is a summary: policy numbers and the
  principal contributor's details are deliberately not returned.
- The check uses the CR number when one is on file, otherwise the National ID.
- If DHA reports the patient as deceased, this and every other DHA action is
  blocked with a neutral message (`400`, *"We can't run this check for this
  account."*).
- A missing-profile-data problem or SHA being unreachable is a `400`
  (`"Could not reach SHA: …"`), shown as a toast.

---

Last verified against the code on 2026-11-09.

## When DHA records the patient as deceased

DHA requires us to block every further transaction, so requesting consent ends as
`"not_possible"`, verifying a code returns `400`, and records are no longer fetched or
pushed. Open visits are closed by the backend. Don't show wording about the death: someone
else may be using the account, and the responses deliberately don't mention it.

## When DHA has no phone for the patient

Before requesting consent, the backend asks DHA for the patient's valid contacts
(`GET /patients/contacts`). DHA texts its consent OTP to those contacts, so if it holds none
and the patient has no open visit, no consent request is made and `dha_phone_missing` on
`GET /api/health-exchange/shr-resync/status/` becomes true. It's set by a background job at
signup, so keep polling while there's no visit. The status endpoint is polled alongside the
visit (every 15s, §2).

While there's still no visit and `dha_phone_missing` is true, the consent step (§1) shows,
instead of the spinner:
- Signup (and "Request DHA consent"): **"Your account is ready"**, *"Kenya's Digital Health
  Agency has no phone number for you, so we can't link your records yet. Once your number is
  on your DHA record, you can link them from Medical History."*, with a **Continue** button
  that closes the step.
- Booking: **"Your booking is confirmed"**, *"Kenya's Digital Health Agency has no phone
  number for you, so {Facility Name} can't access your shared health record for this
  visit."*, with a **Continue** button that closes the step.

The request-consent endpoint checks DHA again, and `consent_request_status` becomes
`"no_dha_phone"` if there is still no contact. An outage or unclear answer from DHA never sets the flag.