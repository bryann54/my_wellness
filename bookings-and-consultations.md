# Bookings & Consultations

<!-- guide-header:start -->
> **Guide set `2026-11-16.b9b79a`.** Every file in this guide carries this same line.
>
> **Related files you need open with this one:** `README.md` (shared conventions), `annual-wellness-plan.md`, `assessments.md`, `health-records-and-shr.md`, `payments-and-packages.md`, `vitals-medications-appointments.md`
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

Covers: the **Individual check-up**, the booking requests raised from
assessment results and vitals (navigator requests and referral visits),
the four-step **facility booking** screen, the patient's own bookings on
**Appointments** and the booking-detail page, and care-navigation
referrals. **My Health
Journey** is no longer on web (§7). See [`README.md`](./README.md) for the shared envelope (auth
header, error shape, phone format, async-settlement semantics).

The bookings endpoints below are mounted with no extra prefix
beyond `/api/`, e.g. `POST /api/bookings/`. Referrals (§6) and My Health
Journey (§7) live under `/api/care-navigation/`. Everything here needs
auth.

Out of scope for the mobile app: the organization / institution and
group check-up booking pages (organization-buyer purchases), and
the off-by-default location recommendations in §6 unless the backend
team confirms the switch is on.

## 1. Service types the web app books

The web app creates bookings with these `service_type` values only:

| Value | Where web raises it | Price |
|---|---|---|
| `checkup` | **Individual check-up** (§2) only | The chosen package's price, charged through `package_id` (§2) |
| `screening` | Not used by web. Results-page screening CTAs go to the facility booking screen (`referral_visit`), and the dashboard has no screening section | none, free request |
| `navigator` | The results page's navigator CTAs ("Ebola screening follow-up", "Endometriosis care navigation", the Endometriosis result card's primary CTA), through the booking dialog | none, free request |
| `referral_visit` | The facility booking screen (§6). Every result CTA that isn't a navigator call goes there (consultation, screening, checkup and "Book" CTAs), plus the Blood Pressure / Blood Sugar facility buttons (on Blood Sugar, the result's "Next step" when the reading has `offers_facility_booking: true`) and health-check cards | none, free; facility locked to the referral's |

**Which way a results-page CTA goes.** Read the result's
`presentation.cta_actions[<cta key>]` (see [`assessments.md`](./assessments.md)):
`"find_facility"` opens the facility booking screen (§6), `"booking"` opens
the booking dialog (§2). Only navigator CTAs are `"booking"`. A CTA with no
entry follows the same rule: `navigator` → dialog, anything else → facility
screen. The per-CTA `facility_selectable` flag on the assessment config is
not what web reads.

The server sets the price of a booking and ignores any other `price_kes`. Only the Individual
checkup keeps the one it sends, as a record of the choice, and it's charged through its package
(see [`payments-and-packages.md`](./payments-and-packages.md) §2).

## 2. Creating a booking

```
POST /api/bookings/
Authorization: Bearer <access>
```

```json
{
  "service_type": "checkup",
  "service_label": "Individual check-up · Wellness Package",
  "price_kes": 500,
  "preferred_date": "2026-11-10",
  "preferred_facility": "Westlands",
  "facility_id": "<uuid>",
  "contact_phone": "254712345678",
  "notes": "Pathway: Individual · Package: Wellness Package (Ksh 500) · Age: 34 · Gender: female · Email: jane@example.com · Location: Westlands"
}
```

`service_type` and `service_label` (≤200 chars) are required. The other
fields web sends are all optional:

- `assessment_slug`, `session_id`: sent when booking from an
  assessment's results page. `session_id` is replaced by the referral's
  own session when `referral_id` is given and that referral has one.
- `price_kes`: only the Individual checkup sends it, and it never sets the charge.
- `preferred_date` (`YYYY-MM-DD`).
- `preferred_facility`: free text ≤200 chars (the picker's "Town" text).
- `facility_id`: a real active `Facility` row (§3). An unknown or
  inactive id is silently ignored. A real facility's `name` overwrites
  `preferred_facility`.
- `referral_id`: only links a referral the caller owns; anything else is
  silently ignored. When it links, `facility` is **forced** to the
  referral's `recommended_facility` (any `facility_id` sent is
  overridden) and the referral's `status` becomes `booked`.
- `contact_phone` (≤40), `notes` (≤1000).
- `consent_share_summary`, `consent_share_records`, `consent_acknowledged`:
  booleans, default `false`. Respectively: share the assessment summary
  with the facility, share additional health records, and confirm the
  facility is responsible for assessment and care.

**Consent rule.** For `service_type: "referral_visit"`,
`consent_share_summary` and `consent_acknowledged` must both be `true`
(`consent_share_records` is optional). Otherwise nothing is created and
the response is `400`:

```json
{ "error": { "detail": { "detail": "Please authorize sharing your assessment summary and confirm you understand the facility's responsibility.", "code": "consent_required" }, "status_code": 400 } }
```

When any consent is `true`, the server sets `consents_recorded_at` to
the creation time; otherwise it stays `null`. Other service types accept
the fields but never require them.

**Response — `201`, the full `ServiceBooking`.** These are the fields the
web app reads from it:

```json
{
  "id": "…",
  "service_type": "checkup",
  "service_label": "Individual check-up · Wellness Package",
  "price_kes": "500.00",
  "status": "pending",
  "preferred_date": "2026-11-10",
  "appointment_date": null,
  "appointment_time": null,
  "appointment_venue": "",
  "appointment_confirmed_at": null,
  "preferred_facility": "Nairobi Hospital",
  "facility": { "id": "…", "name": "Nairobi Hospital", "town": "Nairobi", "county": "Nairobi" },
  "checked_in_at": null,
  "follow_up_to": null,
  "follow_ups": [],
  "consent_share_summary": false,
  "consent_share_records": false,
  "consent_acknowledged": false,
  "consents_recorded_at": null,
  "created_at": "…",
  "is_hie_managed": false
}
```

The four consent fields are read-only and appear on every
`ServiceBooking` response (`POST /api/bookings/`, `GET /api/bookings/mine/`).

`follow_up_to` is a nested `ServiceBookingSummary` (§5) or `null`.

`appointment_date`, `appointment_time`, `appointment_venue` and
`appointment_confirmed_at` are read-only. They're set when an admin
confirms a second opinion appointment, which also emails the patient the
same details. `appointment_confirmed_at` is `null` until then.

A booking is **always created `pending` first, with no payment attached**.
Creating it and paying for it are two separate steps, never one call.
Once a payment for it settles, a `pending` booking moves to `confirmed`. Status
values are `pending`, `confirmed`, `paid`, `cancelled` and `completed`
(`paid` is only produced for booking types the app doesn't offer, but
render it if it appears).

### Booking requests

Navigator requests go through this dialog. Referral visits never do: they use the facility
booking screen (§6).

- **Title:** the request's `service_label`. **Description:** the CTA's
  own description, or "We'll record your request and a navigator will
  follow up to confirm."
- **Form:**
  - "Preferred date (optional)" (date only).
  - A facility picker (§3) for a `screening` request only. Navigator
    requests have none.
  - "Best phone to reach you" (empty by default).
  - "Anything we should know? (optional)".
- **Button:** "Submit booking request" ("Submitting…"). **Footer:** "No
  payment now. A navigator will confirm details by phone."

1. Call `POST /api/bookings/` to record the booking as `pending`. No
   payment step follows: none of these requests carry a price.
2. Toast "Booking request received — a navigator will be in touch."
3. Show "Request received": "We've recorded your request for
   <service_label>. A My Wellness Health navigator will call you to
   confirm." and a "Done" button.

### Individual check-up (withdrawn)

The individual check-up booking (`/checkup/individual`) and the group / institution check-up
purchases were withdrawn on 2026-11-14 (outdated payments and plans): there is no
"Book a medical check-up" card, no "Arrange clinical review" button on My Annual Checkup, and
the `checkup` service is no longer sold (the catalog leaves it out and a purchase of it is
refused: `400 "Not available: ['checkup']"`). Do not build these screens. A payment made for it
earlier returns `destination.screen = "dashboard"`. `/checkup` itself is **My Annual Checkup**
(see [`annual-wellness-plan.md`](./annual-wellness-plan.md)).

## 3. Facility selection

```
GET /api/facilities/match/?service_type=checkup&town=Westlands&user_lat=-1.286&user_lng=36.817
Authorization: Bearer <access>
```

The facility picker calls this:

- **Fields:** a "Town" field ("e.g. Westlands, Nairobi") and a "Use my
  location" button ("Locating…").
- **Query params**: `service_type`
  (required; the booking's own type), `town` (text ranking), and
  optional `user_lat`/`user_lng` (`-90..90`/`-180..180`). When
  coordinates are given, each `distance_km` is a real Haversine distance.
- **When web queries:** only once the town has 2+ characters, or a
  location is shared ("Finding nearby facilities…").
- **Response:** a list of `Facility` objects.
  - Each card shows `name`, `distance_km` ("<n> km away", only when not
    `null`) and `town`, `county`.
  - When `covers_sha` is true it adds "SHA · Level <keph_level>" and one
    badge per `sha_funds` entry (`PHF`, `SHIF`, `ECCIF`).
- **Picking a card:** this sets the Town text to the facility's name.
  Send the facility's `id` as `facility_id` on booking creation. Editing
  the Town text again clears the pick.

Note the path: `/api/facilities/…`, **not** `/api/bookings/facilities/…`.

Two more endpoints:

- `GET /api/facilities/patient-search/?q=<name>`: a name search (web
  sends it at 2+ characters) returning up to 20 `Facility` objects. With
  `&urgency=planned|urgent` each facility also carries `suitability`
  (§6). It backs step 2 of the facility booking screen (§6, with
  `urgency`) and the Appointments "Edit appointment" dialog's "Link a
  facility (optional)" (without it; see
  [`vitals-medications-appointments.md`](./vitals-medications-appointments.md)).
- `POST /api/facilities/create/`: **not used by web.** It creates a
  facility from `{ "name", "town", "county" }` (≤200/100/100) and returns
  `201` with a `Facility`. Web never offers adding a facility, so don't
  build it.

## 4. HIE-managed vs. plain bookings

`ServiceBooking.is_hie_managed` (read-only on every booking response) is
`true` once the booking is at a facility that receives it directly over
AfyaConnect. For one of these:

- **The facility reports check-in/completion itself**, over the inbound
  FHIR pipeline. `checked_in_at`/`status` can *only* ever change that way.
- Calling the complete endpoint on one returns `403` with `detail` *"This
  booking is managed by the facility via AfyaConnect -- its status is
  reported automatically and can't be set manually."*

For a **plain** (not HIE-managed) booking, the owner can self-report
completion:

```
POST /api/bookings/<uuid:booking_id>/complete/
Authorization: Bearer <access>
```

No body. Returns the updated `ServiceBooking`. Anyone other than the
booking's owner gets a 403.

Web has no "Mark as completed" button any more: it was on the referral
card, which was removed from result pages on 2026-11-10 (§6). A regular
user has no way to call this endpoint, so don't build it. The
booking-detail page (`/bookings/<id>`) is read-only.

## 5. Viewing bookings

```
GET /api/bookings/mine/
Authorization: Bearer <access>
```

Cursor-paginated (`{ next, previous, results }`, 25 per page, newest
first) list of the caller's own `ServiceBooking` objects. Web fetches
every page and merges them with the user's own clinic appointments on the
**Appointments** page (`/appointments`; the merged list, search box and
appointment rows are in
[`vitals-medications-appointments.md`](./vitals-medications-appointments.md)).
A booking row shows:

- **"Clinic / Service":** `service_label`, linking to `/bookings/<id>`.
  When `follow_up_to` is set, it adds a "Follow-up" badge and "Follow-up
  to <follow_up_to.service_label> (<follow_up_to.preferred_date>)",
  linking to that booking.
- **"Category":** the booking's `status`.
- **"Date":** `appointment_date` once `appointment_confirmed_at` is set,
  otherwise `preferred_date`, or "—".
- When `appointment_confirmed_at` and `appointment_time` are set, a line
  under the service reads "Confirmed: <appointment_time as 2:30 PM>" and,
  if `appointment_venue` isn't blank, " · <appointment_venue>".

Rows are sorted by date, newest first, with undated rows last. Booking
rows have no edit/remove actions.

```
GET /api/bookings/<uuid:booking_id>/timeline/
Authorization: Bearer <access>
```

Backs the booking-detail page (`https://staging.mywellnesshealth.co.ke/bookings/<id>`). For
the booking's owner, `booking` is a lean 8-field shape:

- `id`, `status`, `service_label`
- `preferred_facility`, `preferred_date`
- `checked_in_at`
- `follow_up_to`, `follow_ups`, both as nested booking summary
  objects (`id`, `status`, `service_label`, `preferred_date`,
  `checked_in_at`, `created_at`, `is_hie_managed`, `follow_up_to`,
  `can_mark_completed`, `visit_details_booking_id`, `is_active`), not bare ids. Inside
  a summary, `follow_up_to` is a bare id. `can_mark_completed` is true for
  a `pending`/`confirmed`/`paid` booking that isn't HIE-managed.
  `visit_details_booking_id` is the booking whose timeline holds the
  visit details: the earlier visit for a follow-up that hasn't started,
  otherwise the booking itself. `is_active` is true while the booking is
  still going ahead (`pending`, `confirmed` or `paid`; §6 "Already
  booked").

Someone else's booking is a 403, an unknown id a 404.

```json
{
  "booking": {
    "id": "…", "status": "confirmed", "service_label": "Checkup",
    "preferred_facility": "Nairobi Hospital", "preferred_date": "2026-11-02",
    "checked_in_at": null, "follow_up_to": null, "follow_ups": []
  },
  "timeline": [
    { "type": "event", "created_at": "…", "data": { "id": "…", "event_type": "created", "actor": "<user uuid>", "metadata": {}, "created_at": "…" } }
  ],
  "viewer": { "is_admin": false, "is_owner": true, "is_assigned_doctor": false }
}
```

`timeline` is one chronological list. Each item's `type` is one of:

- `event`: `data.event_type`, shown as "Booking created" (`created`),
  "Patient checked in" (`checked_in`), "Status changed" (`status_changed`,
  with "<metadata.from> → <metadata.to>"), "Follow-up scheduled"
  (`follow_up_scheduled`), "Doctor assigned", "Note added", "Diagnosis
  added", "Prescription added" and so on. Fall back to the raw value.
- `note` ("Clinical note": `data.note`, plus "Follow-up:
  <data.follow_up_plan>" when set).
- `diagnosis` ("Diagnosis: <data.condition> (<data.severity>)", then
  `data.details`).
- `allergy` ("Allergy: <data.allergen> (<data.severity>)", "Reaction:
  <data.reaction>", `data.notes`).
- `prescription` ("<data.medication> — <data.dosage>", "From <start_date>
  · Until <end_date>" or "Ongoing", `data.instructions`).
- `referral` ("Referral: <data.facility_name> (<data.specialty>)", then
  `data.reason`).

Each item also shows its `created_at`. An empty timeline shows "Nothing
here yet."

The booking-detail page has these parts:

- **Header:** a "Back" link, then `service_label` as the title, with
  `preferred_facility` · `preferred_date` under it and the `status` badge.
  It adds "Checked in <checked_in_at>" when set, and "Follow-up to
  <follow_up_to.service_label> (<date>)" linking to that booking.
- **Sections, each only when non-empty:** "Diagnoses", "Medications"
  (the `prescription` items), "Allergies", and "Follow-ups" (each
  follow-up's `service_label`, `preferred_date` and `status`, linking to
  its own page).
- **"Timeline":** always shown.
- **Errors:** "Not found" ("Booking not found.") for 404, "Access
  restricted" ("You don't have access to this booking.") for 403,
  otherwise "Something went wrong" ("Something went wrong loading this
  booking."). Each has a "Back to appointments" link.

## 6. Care-navigation referrals and choosing a facility

A `Referral` is the engine's "go to a facility for this" recommendation,
tied to a completed assessment session, a blood-pressure reading or a
blood-sugar reading. Own records only (someone else's id is a 404):

| Method & path | What |
|---|---|
| `POST /api/care-navigation/referrals/from-session/<session_id>/` | Generate (or re-pin) the referral for a **completed** session |
| `POST /api/care-navigation/referrals/from-bp-reading/<reading_id>/` | Same for a BP reading |
| `POST /api/care-navigation/referrals/from-bs-reading/<reading_id>/` | Same for a blood-sugar reading |
| `GET …/from-session/<id>/facility-candidates/` (also `from-bp-reading`/`from-bs-reading`) | Required services plus ranked facilities. Optional `?user_lat=&user_lng=` |
| `GET /api/care-navigation/referrals/mine/` | The caller's referrals, newest first. **Not paginated**: a plain array, capped at 100 |
| `GET /api/care-navigation/referrals/<uuid:id>/` | One of the caller's referrals, same shape as below (someone else's or an unknown id is `404`). Web doesn't call it |

**Generate request:**

```json
{ "user_lat": -1.286, "user_lng": 36.817, "facility_id": "<uuid>" }
```

All fields are optional. Generation is **idempotent per source** (one
referral per session or reading, updated in place), so calling it again is safe. `facility_id` pins
`recommended_facility` to a facility the patient picked themselves.

`facility_id` must be suitable for the result's urgency (the same rule as
each candidate's `suitability.ok`): `keph_level` 3 or above for `planned`,
5 or above for `urgent`; a facility with no level is never suitable. An
unsuitable facility is refused with `400` and the suitability `message`:

```json
{ "error": { "detail": { "detail": "Facility level or required clinical service has not been verified by the registry.", "code": "facility_not_suitable" }, "status_code": 400 } }
```

An unknown or inactive `facility_id` is `404`.

**Response** (`200`; the same shape as each `referrals/mine/` entry and the
single-referral `GET`):

```json
{
  "id": "…",
  "source_type": "assessment" | "vitals_bp" | "vitals_bs",
  "session": "<uuid>|null", "bp_reading": null, "bs_reading": null,
  "escalation_category": "routine" | "urgent" | "emergency",
  "escalation_category_display": "Routine Clinical Referral",
  "required_services": [{ "code": "…", "name": "…" }],
  "reason": "…",
  "recommended_facility": { /* Facility, §3 */ },
  "score_breakdown": { "service_match": 0.0, "...": 0.0, "total": 0.0 },
  "candidate_facilities": [{ "id": "<uuid>", "name": "…", "total_score": 87.5 }],
  "distance_km": "4.20", "travel_time_minutes": 12,
  "sha_accreditation_status": "accredited" | "not_accredited" | "unavailable",
  "booking": {                       // the NEWEST booking on this referral, or null
    "id": "…", "status": "pending", "service_label": "…",
    "preferred_date": "2026-11-20" | null, "checked_in_at": null,
    "created_at": "…", "is_hie_managed": false, "follow_up_to": "<uuid>" | null,
    "can_mark_completed": true, "visit_details_booking_id": "…",
    "is_active": true
  },
  "status": "generated" | "viewed" | "booked" | "completed" | "dismissed",
  "created_at": "…",
  "updated_at": "…"
}
```

- `recommended_facility` can be `null` when nothing matched.
- `distance_km` is a decimal string.
- `score_breakdown` is `{}` when the patient picked the facility.
- `candidate_facilities` is the ranked list the server considered (just the
  picked facility, with `total_score` 0, when the patient chose it). Web
  doesn't display it.
- `booking` is the same summary shape as §5's `follow_up_to`/`follow_ups`.
  `booking.is_active` is `true` while that booking is still going ahead
  (`pending`, `confirmed` or `paid`); it's what "Already booked" below
  keys off.
- `status` becomes `completed` once the facility reports the visit back
  over the HIE.

**Facility candidates response:**
`{ "urgency": "planned" | "urgent", "required_services": [{ "code", "name" }], "candidates": [{ "facility": {Facility}, "distance_km", "travel_time_minutes", "total_score", "suitability": { "ok", "title", "message", "urgent_note" } }], "reason": "…" }`.
`distance_km` here is a number or `null`; see "Choosing a facility" below.

### Where web generates referrals

- **Blood Pressure, non-routine pathways:** the server creates the referral
  when the session completes. Web then calls
  `POST .../from-bp-reading/<reading_id>/` once (no `facility_id`), with the
  device's coordinates when location was shared. Nothing is shown to the
  patient for it: there is no referral or facility card on result pages
  (removed 2026-11-10), see "Already booked" below and
  [`vitals-medications-appointments.md`](./vitals-medications-appointments.md).
- **Everywhere else**, only when the patient picks a facility on the
  facility booking screen (below).

Facilities appear only inside the facility booking screen.

### Choosing a facility: the facility booking screen

Every clinical follow-up or facility visit button opens this four-step
screen: assessment result buttons (every CTA whose `cta_actions` entry is
`"find_facility"`, §1), health-check cards, and a blood pressure or blood
sugar next step.
A session paused on a safety answer can use it too. Navigator phone calls
don't, and neither do paid checkup packages. To see it on web, choose a
facility button on a result page, e.g. from
`https://staging.mywellnesshealth.co.ke/assessments/<slug>/complete`.

**Its `service_label`**, in order: the button's own label; else the
result's `required_services[].name` joined with ", "; else the caller's
fallback label, when the calling screen passes one; else "Blood pressure follow-up", "Blood sugar follow-up" or "Clinical
follow-up" by source.

**Layout.** A top bar with "← <back label>" (the calling page's own text,
e.g. "← Back to your result"), and a step bar: "Result & route", "Find a
facility", "Consent & details", "Referral status". When `urgency` is
`urgent`, a sticky strip on every step: "Urgent result: seek emergency
assessment immediately. Do not delay care while arranging a referral
online."

**On open**, call the result's candidates endpoint, with no coordinates:

```
GET /api/care-navigation/referrals/from-session/<session_id>/facility-candidates/
GET /api/care-navigation/referrals/from-bp-reading/<reading_id>/facility-candidates/
GET /api/care-navigation/referrals/from-bs-reading/<reading_id>/facility-candidates/
→ { "urgency": "planned" | "urgent", "required_services": [...], "reason": "...",
    "timeframe": "Arrange an appointment within 1–2 weeks." | null,
    "candidates": [{ "facility": {...}, "distance_km", "travel_time_minutes", "total_score", "suitability": {...} }] }
```

A session that can't be referred is a `404`. `urgency` decides every
"planned vs urgent" text below. `timeframe` (session candidates only) is the
result's own clinical review timeframe, today only for Depression, Anxiety and
Stress, and `null` otherwise or when urgent. When it's set, it replaces every
"within one month" in the planned texts below: the result card's line, step 2's
"Arrange your visit within one month.", the summary's "Care priority", and step
4's "Visit within one month.". The referral summary email/PDF does the same. Each `suitability` is
`{ "ok", "title", "message", "urgent_note" }` (the nested `facility`
carries the same `suitability`).

**Step 1 — "Result & route".** "01 Completed health check", **"Your
recommended next step"**, "Your assessment has already determined the
level of follow-up required. Review your result and select how you would
like to find an appropriate healthcare facility."

- A result card, "YOUR ASSESSMENT RESULT" with the chip "Assigned by
  health check":
  - planned: "Clinical Follow-Up Needed" / "Arrange clinical review
    within one month, or sooner if advised by a clinician.", then
    "◷  Arrange your clinical review" / "Choose a facility that provides
    the recommended assessment. Seek care sooner if symptoms worsen or new
    warning signs develop."
  - urgent: "Visit a Healthcare Facility Immediately" / "Attend emergency
    care now. Do not wait for an appointment or referral confirmation.",
    then "⚠  Attend a healthcare facility immediately" and: "Your result
    requires urgent clinical assessment. Seek emergency care without
    delay. If you feel unwell, ask someone to assist with safe transport;
    do not drive yourself or wait for an online referral." For a blood
    pressure reading it starts "Your blood pressure result requires…", or
    "Your blood pressure reading was <systolic>/<diastolic> mmHg." (plus
    " You reported feeling unwell." when that session said so) followed by
    "Seek emergency assessment without delay. If you feel unwell, …".
- **"How would you like to choose your healthcare facility?"** "Select
  one option to continue. Your assessment result and recommended urgency
  will not change." Two options, each going straight to step 2:
  - **"Choose my preferred facility"** — "Select a facility you know. We
    will check whether it is suitable for the care recommended."
  - **"Find a suitable facility near me"** — "Use your location, with
    permission, to identify nearby facilities with the required
    services."

**Step 2 — "Find a facility".** "02 Suitable facility selection", **"Find
the right level of care"**, then "Choose a facility offering the
recommended clinical review. Arrange your visit within one month."
(urgent: "Your assessment calls for immediate care. Identify an
appropriately equipped emergency facility without delaying treatment.").
"Your selected referral approach" shows "My preferred healthcare
facility" / "Type your facility name and select a registry match for a
care-suitability check." or "System-assisted facility search" / "We will
show nearby facilities and check their care level.", with "Change" (back
to step 1).

- **Preferred facility.** Field "Preferred healthcare facility" ("Start
  typing the facility name or MFL/FID code. Select a matching facility to
  review its level of care.", placeholder "Type a hospital or facility
  name").
  - At 2+ characters call
    `GET /api/facilities/patient-search/?q=<text>&urgency=<urgency>` and
    list up to 10 results as "<name>" / "Level <keph_level>" (or "Level
    pending verification") "· <town> · <county>". No results: "No registry
    matches found. Check the spelling or enter the facility code."
  - Help line: "Enter at least two characters to search for a facility."
    under 2 characters, "Matches returned by the facility registry. Select
    a facility to review care suitability." when results show, otherwise
    "Search by name. Facility details will be completed from available
    registry records." Then "Cannot find your facility? Check the official
    National Health Facility Registry." (links to https://nhfr.dha.go.ke/).
  - Only a facility picked from the results counts; typing again clears
    the pick. Web never offers adding a facility
    (`POST /api/facilities/create/` is unused, §3).
  - Once picked, show a box with `suitability.title`, `suitability.message`,
    "Level <n> · <town> · <county> · Registry information only; receiving
    services and current capacity must be confirmed.", `urgent_note` when
    set, and "View national facility registry ↗".
  - If `suitability.ok` is false, add "Choose an eligible alternative or
    use system-assisted search." and up to 5 buttons ("<name> · Level <n>")
    from the on-open candidates whose `suitability.ok` is true; tapping one
    picks it.
- **Near me.** "◎  Your location, your choice" / "Location is requested
  only when you select “Use my current location”. Your device will ask
  for permission, and it is used only to find nearby facilities." A **"Use
  my current location"** button and a pill ("Location not shared",
  "Locating your device…", or "Your location · <address or lat, lng>").
  - With coordinates, call the candidates endpoint again with
    `?user_lat=&user_lng=` ("Finding nearby facilities…"). Before that:
    "Allow location access to sort facilities by proximity."
  - Web sorts `candidates` by `distance_km`, nearest first (missing
    distances last). Each row: name, "Level <n> · <town> · <county>",
    "<n> km away" ("<n> m away" under 1 km, "Distance unavailable" when
    null), a status "Potential match · confirm services" (`ok`) or "Not
    verified for this pathway", and `suitability.message`.
  - Tapping an unsuitable row only toasts "This facility is not cleared
    for the services required. Choose an eligible alternative." Tapping a
    suitable one keeps only that row, plus "Facility selected. Other
    facilities are hidden. Use Back if you want to choose a different
    facility."
  - Urgent with no suitable row: "No suitable emergency facility was found
    nearby. Seek immediate emergency stabilization at the nearest available
    emergency service; do not wait for the online search."
  - Also "Your location is displayed approximately. Only straight-line
    distance is calculated here. Actual journey distance, traffic, services
    and capacity must be confirmed with the facility."
- **Buttons:** "← Back" (step 1) and **"Continue with this facility →"**.
  It's always tappable and explains what's missing instead:
  - preferred, nothing typed: "Type the name of your preferred facility."
  - preferred, not picked from the list: "Select a facility from the
    search suggestions so its registry details can be checked."
  - preferred, unsuitable: "This facility is not verified for the assessed
    level of care. Select another facility or seek emergency assistance."
  - near me, no location: "Use your current location before continuing."
  - near me, nothing suitable picked: "Select a suitable facility from the
    list."

**Step 3 — "Consent & details".** "03 Referral details & consent",
**"Review your care arrangement"**, "Review the facility details and
choose what health information may be shared. No records are sent unless
you explicitly authorize sharing and the facility's secure receiving
channel is verified."

- A summary: "Care priority" ("Clinical follow-up within one month" /
  "Immediate emergency assessment — any day or time"), "Selected
  healthcare facility", "Facility level" ("Level <n>" or "Not
  confirmed"), "Estimated distance" ("<distance> · straight line", near me
  only) and "Service status" ("Registry information only; current service
  availability unconfirmed").
- Urgent only: "⚠  Immediate care — any day, any time" / "Attend an
  appropriate emergency service **immediately, including nights, weekends
  and public holidays**. No visit date, time slot or booking is required.
  Confirm emergency-department capability with the receiving service
  where possible without delaying care."
- **"Your visit details":** "Preferred visit date (optional)" (date,
  today or later; not shown when urgent) and "Best phone to reach you"
  (empty by default).
- **"Your authorization"**, three checkboxes, all unticked:
  1. `consent_share_summary` (required): "**Share my assessment and
     referral summary** with the selected facility once its authorized
     receiving channel is verified. This includes the concern, urgency and
     recommended clinical service."
  2. `consent_share_records` (optional): "**Also share relevant supporting
     health records** (such as the current BP reading, medications and
     available reports) where necessary and securely permitted."
  3. `consent_acknowledged` (required): "I understand that the receiving
     facility independently assesses my condition and confirms its
     ability to provide care. My Wellness Health does not guarantee
     admission, emergency response or appointment availability."
- "**Important:** Your consent is recorded with the facility, the
  purpose, the information you chose to share and the time you
  authorized it."
- **Buttons:** "← Back" and **"Prepare my care navigation summary →"**
  (urgent: "Prepare immediate-care summary →"; "Sending your request…"
  while working). Missing the first box: "Please authorize sharing the
  assessment summary before proceeding."; missing the third: "Please
  acknowledge the facility responsibility notice."

  The one button makes both calls, in order:
  1. The result's `POST .../from-session|from-bp-reading|from-bs-reading/<id>/`
     with `{ "facility_id", "user_lat", "user_lng" }` (coordinates only on
     the near-me route).
  2. `POST /api/bookings/` with `service_type: "referral_visit"`, the
     `service_label` above, `facility_id`, `referral_id` (the referral just
     returned), `preferred_date` (not when urgent; left out when empty),
     `contact_phone` (left out when empty) and the three consent booleans.
     The server stores the consents on the booking (§2, "Consent rule").

  Either error is shown under the buttons and toasted.
- Then, still on step 3, the DHA records-consent step for the new
  booking runs: [`health-records-and-shr.md`](./health-records-and-shr.md) §1,
  "booking step" (`by-booking/<booking_id>/`), including "When DHA has no
  phone for the patient". When it finishes, go to step 4.

**Step 4 — "Referral status".** "04 Your care navigation status", with a
tick:

- Title "Your facility selection summary" / "Your booking request has
  been sent. A My Wellness Health navigator will confirm the details with
  you. Visit within one month." (urgent: "Emergency care navigation
  summary" / "Seek immediate care at any hour, including nights, weekends
  and public holidays. Do not wait for online booking.").
- A box "Booking request received · Awaiting confirmation" / "A navigator
  will contact you to confirm your visit. Confirm outpatient hours
  directly with the facility." (urgent: "No booking needed for emergency
  care" / "Seek assessment immediately. Your request has been sent to the
  facility, but do not wait for a reply. Current emergency services,
  capacity and admission are confirmed by the facility.").
- "Facility & referral details": "Referral method" ("Preferred facility"
  / "System-assisted referral"), "Facility", "Location", "Facility level",
  "Distance" ("<distance> (straight-line estimate)", near me only), "Care
  priority" ("Clinical review within one month" / "Immediate emergency
  evaluation — any day/time"), "Appointment / referral status" ("Booking
  request received · a navigator will confirm" / "Seek immediate care ·
  request sent to the facility"), "Assessment summary sharing" and
  "Additional medical records" ("Authorized" / "Not authorized", from the
  booking's consent fields).
- Urgent only: "⚠  Seek immediate care now" / "Do not delay emergency care
  while waiting for referral coordination, facility acceptance or record
  transfer. Seek emergency assistance and attend a suitable healthcare
  facility immediately."
- **"↗ Open map / directions"** (a maps route to the facility's
  `latitude`/`longitude`, or its name and area; from the shared location
  on the near-me route) and **"↓ Download summary"**
  (`GET /api/bookings/<booking_id>/summary/`, below). Then "Opening
  directions may share your chosen origin and destination with the map
  provider. Road travel times and treatment capacity are not verified."
- "Your referral email": "We can email you your care-navigation details
  and a short explanation of Smart Referral." and **"Email my referral
  details"** ("Sending…", then "Referral email sent ✓") →
  `POST /api/bookings/<booking_id>/email-summary/` (below); success toasts
  "Your referral email is on its way.", an error toasts its message.
- Two information cards, "Care comes first" and "Facility services &
  responsibility". Copy their text from the staging screen.

### Referral summary: email and PDF

Both endpoints take the caller's own `referral_visit` booking that has a
`facility`. Any other booking id (someone else's, another service type,
no facility, unknown) is `404`.

```
POST /api/bookings/<uuid:booking_id>/email-summary/
Authorization: Bearer <access>
```

No body. Queues an email to the account's own email address and returns
`202` `{ "status": "queued" }`; the email is sent in the background.
Subject: "My Wellness Health | Your referral details and next steps".
It lists the facility, facility level, care priority, visit timing,
booking status and the two sharing consents, worded for the result's
urgency. If the account has no email address, `400`:

```json
{ "error": { "detail": { "detail": "Add an email address to your account to receive this summary.", "code": "no_email" }, "status_code": 400 } }
```

Throttled under the shared `report_email` scope (10/hour, see README).

```
GET /api/bookings/<uuid:booking_id>/summary/
Authorization: Bearer <access>
```

Returns `200` `application/pdf` with
`Content-Disposition: attachment; filename="MWH_Referral_Summary.pdf"`.
Not password-protected. It holds the same referral details as the email
plus the note "Facility services, capacity and appointment availability
must be confirmed with the facility. For emergencies, seek immediate
medical care."

### Already booked: the screen opens on its summary

**No facility is shown anywhere before the patient books one on this
screen** — never `referral.recommended_facility` while `referral.booking`
is null, and there is no referral or facility card on result pages
(removed 2026-11-10; the designs don't have one).

When the screen is opened for a session or reading whose referral
(`GET /api/care-navigation/referrals/mine/`, matched on `session` /
`bp_reading` / `bs_reading`) has `booking.is_active: true`, it skips
straight to step 4 ("Referral status") for that booking instead of
starting again. Read `is_active`; don't compare statuses in the app:

- Step bar: step 4 active, 1–3 done. Heading "Your facility selection
  summary" ("Emergency care navigation summary" when urgent).
- Status callout: `pending` → "Booking request received · Awaiting
  confirmation"; `confirmed`/`paid` → "Visit confirmed" ("Confirm outpatient
  hours directly with the facility."). Urgent keeps its emergency text.
- "Facility & referral details" from the referral and the full booking:
  Facility, Location, Facility level, Care priority, Appointment / referral
  status, and the two consent rows from `consent_share_summary` /
  `consent_share_records`. "Referral method" and "Distance" are left out
  (only known while booking).
  - Facility name, level and location: the referral's
    `recommended_facility` (the facility the patient picked; it carries
    `keph_level`).
  - Consents: only on the full booking from `GET /api/bookings/mine/`
    (cursor-paginated; page through it and match on
    `referral.booking.id`), which also has `facility` (`id`, `name`,
    `town`, `county`). There is no single-booking `GET` with these fields:
    `GET /api/bookings/<uuid:booking_id>/timeline/` (§5) gives the owner
    only `id`, `status`, `service_label`, `preferred_facility` (a name),
    `preferred_date`, `checked_in_at`, `follow_up_to` and `follow_ups`,
    with no `facility` object and no consent fields.
  - Status: `referral.booking.status` (the summary) is enough for the
    callout; prefer the full booking's when you have it.
- Directions, "Download summary" and "Email my referral details" work on
  that booking.

When `is_active` is `false` (a `completed` or `cancelled` booking), or
`booking` is `null`, it does not resume: the screen starts at
step 1 and a new booking is made (that is how a follow-up visit is booked).
Every entry button (result CTAs, Hypertension/Diabetes, blood pressure /
blood sugar next steps) stays visible after booking so the summary can be
reopened. Web shows a short "Loading…" while it checks, so step 1 never
flashes first.

## 7. My Health Journey (removed from web)

**Don't build this screen.** Web removed My Health Journey on 2026-11-05 in
favour of **My Medical History**, which comes from DHA, and `/health-journey`
now redirects to `/medical-history`. The backend still keeps these records
and the endpoint below still works, so it's documented for reference only.

```
GET /api/care-navigation/health-journey/
Authorization: Bearer <access>
```

Not paginated: one entry per **completed** assessment session, newest
first, capped at 50.

```json
[
  {
    "session_id": "…",
    "assessment_slug": "phq9",
    "completed_at": "…",
    "risk_score": { "band": "lower" | "average" | "higher", "band_label": "…", "band_blurb": "…", "has_active_warning": false },
    "referral": {
      "id": "…",
      "escalation_category": "urgent",
      "escalation_category_display": "Urgent Specialist Evaluation",
      "reason": "…",
      "recommended_facility_name": "Nairobi Hospital",
      "status": "booked",
      "bookings": [
        { "id": "…", "status": "pending", "service_label": "…", "created_at": "…", "timeline": [ /* §5 timeline items */ ] }
      ]
    }
  }
]
```

- `risk_score` and `referral` can each be `null`.
- `referral` only covers assessment-session referrals, not BP/blood-sugar
  ones.
- `bookings` is every booking on that referral, oldest first.

The page: "My Health Journey", "Every assessment you've completed, and
-- where one followed -- the referral, visits, and doctor notes that came
after it." With no entries: "No completed assessments yet." Each entry is
a card:

- **Title:** the assessment's title, looked up by slug from
  `GET /api/assessments/` (fall back to the slug), with `completed_at` as
  a long date.
- **Band:** a `band_label` badge and `band_blurb`. The card is coloured by
  `band`: higher red, average amber, lower (or no score) green.
- **Referral block** (when present): `escalation_category_display`,
  `recommended_facility_name`, `reason`, and "Not booked yet." when
  `bookings` is empty.
- **Bookings:** each one is a collapsible row ("<service_label> ·
  <created_at date>" plus a `status` badge) that expands to its timeline,
  rendered exactly as in §5.

---

Last verified against the code on 2026-11-11.
