# Account & Profile

<!-- guide-header:start -->
> **Guide set `2026-11-16.b9b79a`.** Every file in this guide carries this same line.
>
> **Related files you need open with this one:** `README.md` (shared conventions), `assessments.md`, `auth-and-signup.md`, `health-records-and-shr.md`, `next-of-kin.md`, `push-notifications.md`
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

Covers web's **Account settings** page (`/account`, reached from the
sidebar/top-bar user menu): **Your profile** (contact details with
**Email verification**/**Phone verification**, **Identity details** with
**Update identity** for a legacy account that has none and **AfyaConnect
sync**, **Where you live** — the two location hierarchies —, **Occupation &
daily role**, **Membership & SHA coverage**), **Security** (**Change
password**, **Two-step verification**), **Notifications**, **Privacy &
your data** (SHA sharing, aggregate-reporting opt-out, **Download your
data**), **Danger zone** (**Sign out everywhere**, **Delete account**) —
plus the cancer-history answers given on the Cancer
Health Check package screens, which save to the same profile. See
[`README.md`](./README.md) for the shared envelope (auth header, error
shape, phone format) this file assumes throughout. Every endpoint here is
authenticated (`IsAuthenticated`, the DRF default) and acts only on
`request.user`, except the `AllowAny` geography lists in §2.

**Web's Account settings layout (https://staging.mywellnesshealth.co.ke/account), for
parity:** eyebrow "MY WELLNESS HEALTH · YOUR ACCOUNT", heading **Account
settings** ("Manage your profile, contact details, preferences and
privacy. Keep your information current so your health checks and follow-up
services can support you better."), an **Account overview** back link
(returns to General), then **six steps shown one at a time**, deep-linkable
via `?tab=`:

| `?tab=` | Step list label (phone chip) | Panel kicker / title | Contents |
|---|---|---|---|
| `general` (default) | General | "01 / 06 · Personal information" / **Your profile** | §1, §1a, §3, §5 |
| `security` | Security | "02 / 06 · Account protection" / **Security** | §7 Change password, Two-step verification ([`auth-and-signup.md`](./auth-and-signup.md) Step 3a), Devices & sessions |
| `notifications` | Notifications | "03 / 06 · Communication preferences" / **Notifications** | §6 |
| `next-of-kin` | Next of kin | "04 / 06 · Trusted access" / **Next of kin** | [`next-of-kin.md`](./next-of-kin.md) |
| `privacy` | Privacy & data (phone chip: Privacy) | "05 / 06 · Personal data" / **Privacy & your data** | §4, §7 Download your data |
| `danger` | Danger zone | "06 / 06 · Account management" / **Danger zone** | §8 |

On a phone the steps are a row of chips under a header showing the current
step's title and "N of 6" with a progress bar; on wide screens a **Your
settings** side list. The General entry shows a small count badge equal to
the number of entries in `pending_contact_verifications` (§5) when it's
above zero. Under every step: **Back** (disabled on the first step) and
**Continue** (on the last step it reads **Back to general**). An unknown
`?tab=` falls back to General. Every panel here that reads the profile uses
the `?raw=1` request (§1).

**"Your profile progress"** (wide-screen side list only): "Complete the
details most relevant to your account and care navigation.", a bar, "N of
8 fields" and the percentage. Read both from the profile's
`profile_progress` (§1), e.g. `{"filled": 5, "total": 8, "percent": 63}`:
show "{filled} of {total} fields", "{percent}%" and a bar at `percent`. Don't
count fields in the app. For reference, the backend counts these eight
details as filled when non-empty: `full_name`, `gender`, `date_of_birth`,
`email`, `phone` (or `account_phone` when `phone` is empty), `county`,
`ward`, `occupation`. Outside Kenya (`country_of_residence` isn't `"KE"`)
the country counts for both `county` and `ward`, so the profile can still
reach 100%.

**Next of kin using this account (acting).** While the app is sending
`X-Acting-For` ([`next-of-kin.md`](./next-of-kin.md)), web shows **only the
General step** — no step list entries, chips or Back/Continue for the
others; the other steps stay with the account holder and the API refuses
them anyway. Within General: **Email address** and **Phone number** are
disabled and never sent on save (the backend answers `403`
`{"detail": "Only the account holder can do this.", "code":
"next_of_kin_not_allowed"}` if `phone` or `email` is in the §1 `PATCH`),
the yellow contact-verification note and the Email/Phone verification rows
(§5) are hidden, and **AfyaConnect sync** (§1a) is hidden. Location,
occupation, SHA coverage and **Save changes** work as normal.

## 1. "Your profile": view and update

**One endpoint for everything** — `GET`/`PATCH /api/health-profile/`
(both return the profile shape below).

```
GET /api/health-profile/?raw=1
```

```json
{
  "email": "jane@example.com",
  "full_name": "Jane Wanjiru",
  "phone": "254712345678",
  "age": 34,
  "age_stale": false,
  "date_of_birth": "1992-03-14",
  "weight_kg": "62.50",
  "height_cm": "165.0",
  "bmi_stale": false,
  "bmi_prompt_due": false,
  "gender": "female",
  "country_of_residence": "KE",
  "county": "Nairobi",
  "sub_county": 12,
  "constituency": 45,
  "ward": 210,
  "occupation": "Teacher",
  "employment_type": "Formal",
  "sha_number": "SHA-00123456",
  "member_code": "MWH-00012345",
  "health_profile_completed": true,
  "has_hypertension": null,
  "on_htn_medication": null,
  "htn_medications": null,
  "has_diabetes": null,
  "on_dm_medication": null,
  "dm_medications": null,
  "htn_onboarding_seen": true,
  "dm_onboarding_seen": true,
  "email_verified": true,
  "phone_verified": false,
  "sha_eligibility_checkable": true,
  "pending_contact_verifications": ["phone"],
  "account_phone": "254712345678",
  "sha_beneficiary_id": "12345678",
  "sha_beneficiary_id_type": "national_id",
  "national_id_number": "12345678",
  "national_id_type": "national_id",
  "national_id_country": "",
  "analytics_opt_out": false,
  "sha_data_sharing_consent": true,
  "cancer_diagnosed": false,
  "cancer_diagnosed_declared_at": null,
  "cancer_diagnosis_type": "",
  "cancer_diagnosis_type_other": "",
  "cancer_diagnosis_year": null,
  "cancer_education_materials_requested": false,
  "profile_progress": { "filled": 8, "total": 8, "percent": 100 }
}
```

(The six `cancer_*` fields are explained in §4a.) **Your profile** ("These
details help us maintain a consistent profile across your assessments,
reports and care-navigation services.") shows, in order:

- When `pending_contact_verifications` isn't empty, a yellow note
  "**Contact verification** helps us protect your account and reach you
  when necessary."
- **Your contact details**: **Email address** and **Phone number**
  (placeholder "+254 7XX XXX XXX"), then the Email/Phone verification rows
  (§5).
- **Identity details** ("Your name, gender and date of birth come from your
  National ID, Maisha Card or passport.") — §3 — followed by **AfyaConnect
  sync** (§1a). For a passport (`national_id_type` `"passport"`) the ID
  field is labelled **Passport number ({country name of
  `national_id_country`})** instead of **National ID / Maisha number**.
- **Where you live** ("Your county and local administrative area help us
  provide geographically relevant care-navigation information."):
  **Country** (searchable, `country_of_residence`; the options come from
  `GET /api/auth/countries/`, see [`auth-and-signup.md`](./auth-and-signup.md)
  Step 0), then — only while it's
  Kenya — **County**, **Sub-county**, **Constituency**, **Ward** (§2).
- **Occupation & daily role** ("Choose the role that best describes your
  current situation. This field is optional.") — see `occupation` below —
  followed by a static "COMING SOON" box, **Occupation-informed mental
  health support** ("A future update may use this choice to offer relevant
  optional questions and guidance about work or daily-life stressors. Your
  occupation will not change the validated PHQ-9, GAD-7 or PSS-4
  scoring."), with no API behind it.
- **Membership & SHA coverage**: **Member code** (read-only, placeholder
  "Assigned by My Wellness Health"), then SHA coverage (§1a).
- **Save changes** (reads **Saving…** while busy). On success web shows
  "Changes saved." under the button and toasts "Account details updated";
  on failure it shows and toasts the error message.

`email` is the login email (`User.email`,
`null` for a phone-only account); `phone` is the profile's contact number
(`Profile.phone`). `sha_number` comes from the AfyaConnect Client Registry
record and is `""` when there isn't one (shown on the SHA coverage card,
§1a). The first `GET` also auto-fills `sha_beneficiary_id`/`_type` from the
verified `national_id_number` if they're blank, but only for a Kenyan
National ID or Maisha Card: a passport (`national_id_type` `"passport"`)
is never copied there, since SHA can't look one up. `bmi_prompt_due` says whether the
vitals tools show their optional BMI step (`bmi_stale`: no BMI recorded in
the last four calendar months; `bmi_prompt_due`: stale and the step not
skipped in the last four months), and `on_dm_medication` the Blood Sugar page.
`has_hypertension`/`on_htn_medication`/`htn_medications`/`has_diabetes`/
`dm_medications` are legacy answers web no longer asks or writes (the
vitals tools' own pathway questions replaced them) — read-only history; don't build UI to
edit them. `age_stale` is only ever true for a legacy account with no
`date_of_birth`, and `employment_type` (AfyaConnect's classification,
`""` when none) isn't shown anywhere on web — Occupation is always the
career dropdown below.

Two query-time behaviors that matter for parity:

- **`?raw=1`** — pass this on the Account settings screen specifically
  (web does). Without it, a handful of QA/test accounts
  get a masking override that force-blanks the
  condition answers, `health_profile_completed` (to `false`) and the two
  `*_onboarding_seen` flags — purely to keep the
  vitals onboarding flows re-triggering for those accounts during QA.
  `gender`/`date_of_birth` and (since 2026-11-03) `weight_kg`/`height_cm`/
  `bmi_stale`/`bmi_prompt_due` are never masked, so a QA account isn't
  asked for its BMI on every visit. A genuine "view/edit my
  settings" screen must use `?raw=1` or it will show blank values the user
  actually already set. Use the plain (masked-for-test-accounts) request
  wherever the app is deciding whether to show a vitals onboarding step.
  The `PATCH` response is never masked.
- `account_phone` is the sign-in phone (`User.phone`) — the number
  **Phone verification** (§5) texts and displays; `phone` is the editable
  contact number and can differ.
- `sha_eligibility_checkable` is `true` when a `national_id`-type
  `sha_beneficiary_id` is on file (drives §1a).
  `pending_contact_verifications` lists `"email"` and/or `"phone"` for each
  login contact that exists but isn't verified yet (drives §5). It never
  lists `"phone"` for a sign-in phone abroad: codes are texted to Kenyan
  numbers only.
- `age`/`age_stale`/`bmi_stale`/`bmi_prompt_due`/`email_verified`/`phone_verified`/
  `sha_eligibility_checkable`/`pending_contact_verifications`/`profile_progress`/
  `account_phone`/`sha_number`/`employment_type`/`member_code`/`health_profile_completed`/
  `national_id_number`/`national_id_type`/`national_id_country`
  are server-computed or read-only, never send them back
  (`national_id_type` is `"national_id"`, `"maisha_card"` or `"passport"`;
  `national_id_country` is the passport's issuing country code, `""`
  otherwise). (Every
  successful `PATCH` sets `health_profile_completed` to `true` as a side
  effect.)

**PATCH** — every field is optional and
independently omittable; an omitted field is left completely untouched
server-side (not reset to null). What web's **Your profile** step sends on
**Save changes**:

```json
PATCH /api/health-profile/
{
  "phone": "254712345678",
  "county": "Nairobi",
  "sub_county": 12,
  "constituency": 45,
  "ward": 210,
  "occupation": "Teacher",
  "email": "jane@example.com"
}
```

Fields web sends on this endpoint:

- `phone` (**Phone number**, ≤20 chars) — updates the profile's contact
  number only (`Profile.phone`), **not** the login phone (`User.phone`),
  and is stored verbatim (no normalization on this path; web sends exactly
  what was typed, trimmed, and omits it when blank or while acting).
- `email` — **only** accepted when the account has no email yet (a
  phone-only signup); `400` "Your account already has an email address."
  otherwise, or "An account with this email already exists.". It's saved
  as the account's real `User.email` (so it also becomes a login
  identifier, even though web's helper text says "A contact email for
  reports and notifications. You'll keep signing in with your phone number
  and password; adding this doesn't change that.") but starts unverified,
  which is what makes §5's **Verify** button appear for it. The field is
  labelled **Email address** for everyone; it's editable (placeholder
  "you@example.com", helper text above shown under the pair) only for
  phone-only accounts (`email` is `null`), and web sends it only when
  non-blank and not acting. For everyone else it's read-only and never
  sent.
- `country_of_residence` (ISO 3166-1 alpha-2; web always sends it). Any
  country but `"KE"` clears county/sub-county/constituency/ward server-side,
  whatever else is sent; web sends the four only while it's Kenya.
- `county` (string name, omitted when blank), `sub_county`/`constituency`/
  `ward` (ids — web always sends all three, `null` when unpicked, which
  clears them) — see §2. Mismatched areas get a `400` on the field.
- `occupation` (≤150 chars server-side, omitted when blank) —
  **Occupation** is a searchable career dropdown ("Select your occupation
  or current role", search "Search careers…", "No career found.") with an
  "Other" option that reveals a free-text **Please specify (optional)**
  input (placeholder "Your role", max 100 characters on web); a saved value
  that isn't in the list pre-selects "Other" with that value in the input.
  Clearing the dropdown (or leaving the input empty) just omits
  `occupation`, so the saved value is kept.
- `sha_beneficiary_id` + `sha_beneficiary_id_type` — sent by the SHA
  coverage card, always with `"national_id"` (§1a).
- `weight_kg` (0.01–500, 2 dp), `height_cm` (30–280, 1 dp) — sent by the
  vitals tools' BMI step; also stamps the BMI clock behind `bmi_stale`
  (four calendar months).
- `bmi_prompt_skipped` — only `true` does anything: sent when the user
  continues past the optional BMI step with both fields blank; holds
  `bmi_prompt_due` false for four calendar months.
- `gender` — fill-a-blank only (see below). Sent by the vitals tools'
  "Why are you monitoring?" step, which shows a **"Gender"** dropdown only
  when `profile.gender` is blank (legacy accounts).
- `htn_onboarding_seen`/`dm_onboarding_seen` — only `true` does anything
  (sent by the vitals onboarding flows).

Returns the same shape as `GET`. **Fields deliberately NOT accepted here,
ever**: `full_name`, `age`, `date_of_birth`, `national_id_number`. These are
verified (government-sourced) identity fields — see §3 for the only way
they ever get set. `gender` is a narrow exception: it can only ever **fill
a currently-blank** value (a legacy pre-verification account with none
yet) — it will never silently overwrite an already-known gender.

`analytics_opt_out`, `sha_data_sharing_consent` and the `cancer_*` fields
are present in the `GET` response but **read-only on this endpoint** —
PATCHing them here is silently ignored. Each has its own dedicated
endpoint (§4/§4a).

### 1a. "SHA coverage" and "AfyaConnect sync" (General step)

Both backed by `/api/health-exchange/`:

- **SHA coverage** (inside **Membership & SHA coverage**, under Member
  code) — "Check your Social Health Authority (SHA) coverage using the
  National ID on file." with " SHA number: <sha_number>." appended when
  `sha_number` isn't empty.
  - When a `sha_beneficiary_id` of another type is on file, web adds "Your
    account has a <sha_beneficiary_id_type> on file, but eligibility checks
    only work with a National ID. Enter one below to enable this." (the raw
    type value, e.g. `passport`).
  - While `sha_eligibility_checkable` is false: a **National ID number**
    input (placeholder "e.g. 12345678", pre-filled with any
    `sha_beneficiary_id`) and a **Save** button (**Saving…**; disabled while
    empty) that PATCHes
    `{"sha_beneficiary_id": "...", "sha_beneficiary_id_type": "national_id"}`
    to §1 → toast "National ID saved" (failure: the error, or "Could not
    save National ID").
  - While it's true: **Check SHA eligibility** (**Checking…**), then
    "National ID on file: <first 2 digits>••••<last 2 digits>" (just "••••"
    for 4 or fewer digits).
    `GET /api/health-exchange/sha-eligibility/` → a summary of DHA's
    response: `schemes[]` (`schemeName`, `covered`, `message`, `reason`,
    `possibleSolution`, `startDate`, `endDate`), `statusCode`, `statusDesc`
    and `memberCrNumber`. Web shows the result in a box under the button:
    per scheme, "<schemeName>: Covered" when `covered`, otherwise the
    `schemeName` followed by its `message` and `possibleSolution` (each only
    when non-empty); with no schemes, `statusDesc` or "SHA returned no
    coverage details."; then "Member CR number: <memberCrNumber>" when
    present. `reason`/`startDate`/`endDate`/`statusCode` aren't shown.
    `400` with a message (toast it; web's fallback "Could not check SHA
    eligibility") if no usable ID is on file, SHA can't be reached ("Could
    not reach SHA: …"), or "We can't run this check for this account.".
- **AfyaConnect sync** — a row at the end of **Identity details**, hidden
  until the status call returns `has_national_id: true` (and while acting).
  `GET /api/health-exchange/afyaconnect-resync/status/` →
  `{"already_synced": bool, "has_national_id": bool, "can_resync": bool, "last_attempted_at": iso|null, "next_eligible_at": iso|null}`
  (no throttle; `next_eligible_at` is only set while on cooldown).
  `POST /api/health-exchange/afyaconnect-resync/` →
  `{"status": "synced" | "not_found" | "unavailable"}`; there's a **24-hour** per-user
  cooldown (`400` inside it) plus an
  `afyaconnect_resync` throttle of 10/hour.
  Row title **AfyaConnect sync**; its text is, in priority order: "You can
  sync again on <next_eligible_at, local date and time>." while on cooldown,
  "Keep your dependants, phone number and address current." when
  `already_synced`, else "No Client Registry record found yet. Try again if
  you've just registered for SHA.". Button: **Refresh** when
  `already_synced`, else **Sync** (**Syncing…** while busy), disabled while
  `can_resync` is false. After the `POST` web re-fetches the status and the
  profile, and toasts: `synced` → "Synced with AfyaConnect. Your details
  are now up to date."; `unavailable` → "We couldn't reach AfyaConnect just
  now. Nothing has changed, so please try again shortly."; `not_found` →
  "AfyaConnect has no newer data right now. Your existing details are
  unchanged." (if `already_synced`) or "AfyaConnect doesn't have a matching
  record yet. If you've just registered for SHA, this can take a little
  time. Try again later.". A `400` toasts its message (fallback "Could not
  sync with AfyaConnect").
  `{"status": "unavailable"}` means DHA couldn't be reached: not a "no record" answer, and it uses no cooldown.

## 2. Location pickers: two distinct hierarchies, not one chain

All four are `AllowAny` and unpaginated (plain JSON arrays):

```
GET /api/geography/counties/           -> [{ "id": 1, "code": 1, "name": "Mombasa" }, ...]
GET /api/geography/sub-counties/?county=<id>    -> [{ "id": ..., "code": ..., "name": ..., "county": <id> }, ...]
GET /api/geography/constituencies/?county=<id>  -> [{ "id": ..., "name": ..., "county": <id> }, ...]
GET /api/geography/wards/?constituency=<id>     -> [{ "id": ..., "name": ..., "constituency": <id> }, ...]
```

**Critical for parity — these are two separate hierarchies under the same
county, not one chained drill-down:**

- **County → Sub-county** (signup's "Your location" section).
- **County → Constituency → Ward** (signup's "Locality" section) — see
  [`auth-and-signup.md`](./auth-and-signup.md) Step 1.

On Account settings the four pickers sit in **Where you live** (placeholders "Choose county" / "Choose sub-county" / "Choose constituency" / "Choose ward", or "Choose a county first" / "Choose a constituency first" while disabled; each searchable).
`sub_county`, `constituency` and `ward` are plain foreign-key ids, not
names; all four are required at signup, optional on §1's PATCH. Don't
build a UI that picks sub-county then tries to derive a constituency/ward
from it, or vice versa — query each independently, keyed only off the
selected county (or county then constituency, for ward). Changing county
clears sub-county/constituency/ward; changing constituency clears ward
(web does both). `county` itself is sent/stored as a plain string name
(not an id) on `Profile`, unlike `sub_county`/`constituency`/`ward` which
are ids — web matches the stored name case-insensitively against the
counties list to pre-select the dropdown.

## 3. "Verified identity" and "Update identity"

**Once an account has a `national_id_number`, its identity can never be
changed again through the API** — `update-identity/` refuses with `400`
"Your ID has already been verified and cannot be changed." (a correction
needs staff help).
Every account created through today's signup already has one, so this
flow only applies to a legacy account with `national_id_number` empty.
Web mirrors that in **Identity details**: a **Personal identification**
box reading "Verified once from your ID, and can't be changed again." (or,
when `national_id_number` is empty, "Add your National ID, Maisha Card or
passport to set these details." next to an **Update identity** button — the
button only renders then), followed by four read-only fields: **Full
name**, **Gender** (Female/Male), **Date of birth** and **National ID /
Maisha number**, shown masked as the first 2 digits + "••••" + the last 2
(just "••••" for 4 or fewer digits). Empty values show the placeholder
"Not provided". Under them a tag reads **Identity verified** (or
**Identity not verified** when `national_id_number` is empty).

The **Update your identity** dialog ("We'll verify your name, gender, and
date of birth against your ID again.") is two-step, same shape signup
itself uses: verify first, then apply.

**Step 1 — Verify ID** (web's **ID type** radio **National ID** / **Maisha
Card** / **Passport** — Passport shown only when the visitor seems to be
outside Kenya, never otherwise. That's the app's own choice from the
device's region, as in signup ([`auth-and-signup.md`](./auth-and-signup.md)
Step 0); the backend returns no field for it. Then a **National ID number** / **Maisha Number** /
**Passport number** field, then the **Verify ID** button, enabled once the
number is 6–10 digits — for a passport, once it's 5–20 letters/digits after
removing spaces and dashes, with at least one digit, and
**Country that issued your passport** is picked from
`GET /api/auth/countries/`. Either way `id_number` is at most 20
characters as sent):

```
POST /api/auth/verify-id/
{ "id_type": "national_id" | "maisha_card", "id_number": "12345678" }
```

Called while authenticated, the "ID already belongs to an account" check
excludes your own account. Throttle, timeouts and errors are exactly as in
[`auth-and-signup.md`](./auth-and-signup.md) Step 0. The button reads
**Verifying…** while waiting; an error shows under it (web's fallback
"Could not verify this ID").

**Manual entry — decided by the backend.** The dialog calls the manual
endpoint instead, adding **First name** / **Surname** / **Other name
(optional)** / **Gender** (Female/Male) / **Date of birth** inputs (the date
is a calendar with month/year dropdowns whose latest selectable day is exactly
18 years ago; all but Other name required before **Verify ID** enables), in exactly the cases
[`auth-and-signup.md`](./auth-and-signup.md) Step 0 lists: a passport
(always, with `id_country`), after a lookup error with code
`identity_not_found` / `identity_lookup_unavailable` (web then shows an
**Enter my details myself** button under the error; changing the number or
ID type hides it again), or while `GET /api/auth/app-config/` returns
`"manual_identity_verification_enabled": true` (treat a failed
`app-config/` call as off). Otherwise the manual endpoint answers `400`
`manual_entry_not_allowed`.

```
POST /api/auth/verify-id/manual/
{
  "id_type": "national_id",
  "id_number": "12345678",
  "first_name": "Jane",
  "last_name": "Wanjiru",
  "other_name": "",
  "gender": "female",
  "date_of_birth": "1992-03-14",
  "id_country": "GB"            // passport only
}
```

Both return (fields this flow uses):

```json
{
  "verification_id": "a1b2c3d4-...",
  "first_name": "Jane",
  "last_name": "Wanjiru",
  "gender": "female",
  "date_of_birth": "1992-03-14",
  "id_type": "national_id"
}
```

(The full response also has the signup-only fields described in
[`auth-and-signup.md`](./auth-and-signup.md) Step 0, such as
`country_of_residence_locked`; this dialog doesn't use them.)

Web then shows "ID verified" with **Name**/**Gender**/**Date of birth** and
two buttons, **Use a different ID** and **Apply**.

**Step 2 — Apply:**

```
POST /api/auth/update-identity/
{ "national_id_number": "12345678", "identity_verification_id": "a1b2c3d4-..." }
```

`national_id_number` must be the same `id_number` verified in step 1.
Returns the full profile shape (§1) with the new identity
fields applied (names title-cased); web toasts "Identity updated" and
closes the dialog (failure: toast the error, or "Could not update your
identity"; **Apply** reads **Applying…** while busy). **Use a different
ID** just returns to step 1 client-side, clearing what was typed. The `verification_id` from step 1 is
single-use, expires after 30 minutes, and is tied to the exact id number
verified — don't cache and reuse it for a later, different change.
`400` "Identity verification expired or not found. Please verify your ID
again." if it's stale.

## 4. "Exclude my activity from aggregate reporting" and "Share my health data with SHA"

The two switches under **Health information sharing** on the **Privacy &
your data** step ("Understand your data preferences and review what you
choose to share.", https://staging.mywellnesshealth.co.ke/account?tab=privacy),
each saving immediately on toggle through its own dedicated endpoint —
never through §1's PATCH:

```
PATCH /api/auth/analytics-opt-out/
{ "analytics_opt_out": true }
```

```
PATCH /api/auth/sha-consent/
{ "sha_data_sharing_consent": true }
```

Web's copy, in this order: **Share my health data with SHA** ("Your
logged readings, medications and appointments are shared with Kenya's
Social Health Authority (SHA) to support your care there. On by default;
you can turn it off at any time."; toasts "Sharing with SHA is on" /
"Sharing with SHA is off"), then **Exclude my activity from aggregate
reporting** ("When on, none of your activity counts towards the anonymous
totals on internal reporting dashboards. This never affects your own care
or account."; toasts "Excluded from aggregate reporting" / "Included in
aggregate reporting again"). Each switch is disabled while its own save is
in flight; a failure toasts the error (fallback "Could not update this
setting").

Both return the full profile shape. `sha-consent` additionally
writes an append-only consent record server-side on each actual
change (proof of when consent was granted/withdrawn) — it gates whether
this user's logged readings, medications and appointments sync to Kenya's
SHA/Afyalink exchange at all. It's on by default for new accounts (recorded as a
consent record at signup), and existing accounts keep their
choice. See
[`health-records-and-shr.md`](./health-records-and-shr.md) for the
separate DHA SHR consent.

## 4a. Cancer history (Cancer Health Check package screens)

Saved from the Cancer package journey,
not from Account settings, but it lives on the profile. One dedicated
endpoint, same "never through §1's PATCH" rule as §4. Two independent
writes share it:

```
PATCH /api/auth/cancer-diagnosis/

// "Have you ever been diagnosed with cancer?" -> "No, I have never been diagnosed"
{ "cancer_diagnosed": false }

// "Yes, I have been diagnosed" -> "Your Cancer History" screen; type and year are REQUIRED with true
{ "cancer_diagnosed": true, "diagnosis_type": "breast", "diagnosis_year": 2021 }
{ "cancer_diagnosed": true, "diagnosis_type": "other", "diagnosis_type_other": "Sarcoma", "diagnosis_year": 2021 }

// "Educational materials for your condition" opt-in on the follow-up guidance screen
{ "education_materials": true }
```

- `diagnosis_type` ("Which cancer were you diagnosed with?") is a code from
  `GET /api/assessments/cancer-pre-screening-content/`'s
  `gate.type_choices`. `other` requires `diagnosis_type_other` (≤100 chars).
  `diagnosis_year` must be between 1900 and the current year. Any violation
  is a `400` with the field named.
- **Every** explicit answer, yes or no, stamps `cancer_diagnosed_declared_at`.
  That timestamp is what separates "said never diagnosed" from "never asked":
  only the first skips the per-assessment cancer-history gate
  ([`assessments.md`](./assessments.md) §2.2). A "no" clears any previously
  recorded type/year.
- `true` blocks every Cancer assessment for this account: starting one
  fails with `code: "cancer_diagnosed_blocked"`.

Returns the full profile shape, which carries these read-only
fields (web shows type, year and "Educational materials: Requested/Not
requested" on "Cancer Follow-Up Guidance Complete"):

```json
"cancer_diagnosed": false,
"cancer_diagnosed_declared_at": "2026-10-30T10:00:00Z" | null,
"cancer_diagnosis_type": "" | "breast" | ... | "other",
"cancer_diagnosis_type_other": "",
"cancer_diagnosis_year": null | 2021,
"cancer_education_materials_requested": false
```

## 5. "Email verification" / "Phone verification" (post-signup, optional)

Distinct from the signup-time **Enter your code** confirmation (see
[`auth-and-signup.md`](./auth-and-signup.md)) — this is for an account
that's already active but has a contact that was never confirmed: a phone
given alongside an email at signup (unless it matched DHA's record), an
email added later through §1's PATCH on a phone-only account, or an older
self-pay join from before 2026-10-28. Nothing in the app gates on this;
it's purely optional. Operates on `request.user`'s own account only —
there's no client-supplied identifier, so (unlike the signup-time
endpoints) a genuine, specific error is returned rather than a blanket
"ok" ack.

**What web shows** (General step, under **Your contact details**; hidden
entirely while acting): always two rows, **Email verification** (value:
`email`) and **Phone verification** (value: `account_phone`, the sign-in
phone the code goes to). Each row's text is "No email added" / "No phone
number added" when the value is empty, "<value> · Verified" when
`email_verified`/`phone_verified` is true (plus a **Verified** label), or
"<value> · Not verified". A **Verify** button appears only on a row whose
channel is in `pending_contact_verifications`. When that list isn't empty,
the step also shows the yellow note "**Contact verification** helps us
protect your account and reach you when necessary." and the General step
entry carries a count badge (see the layout notes at the top).

Tapping **Verify** sends the code (toast "Verification code sent"; on
failure toast the error, fallback "Could not send verification code", and
drop back to the rows) and opens "Enter the 6-digit code we just sent"
(six single-digit boxes) with **Confirm** (enabled at 6 digits, reads
**Verifying…** while busy) and **Cancel**. A successful confirm toasts
"Email verified" / "Phone verified"; a failure toasts the error (fallback
"Incorrect code") and keeps the code entry open.

**Step 1 — Verify (request a code):**

```
POST /api/auth/verify-contact/request/
{ "channel": "email" | "phone" }
```

```json
{ "detail": "Verification code sent." }
```

Real SMS/email is sent to the account's login email/phone (`User.email`/
`User.phone`), via the same OTP mechanism as everything else in this app —
see auth-and-signup.md's "OTP mechanics" for code lifetime, attempts and
the dev/staging fixed-SMS-code escape hatch. Throttled
(the shared 5/hour `otp_request` bucket). The code
always goes to `User.phone` (`account_phone`), which is what the Phone row
displays — not the editable `phone` (`Profile.phone`) field above it, so
the two can show different numbers after a **Phone number** edit.

Errors (`400`, via the shared error envelope): "This account has no email
address." / "This account has no phone number.", or "This email address
is already verified." / "This phone number is already verified.", or, for
`channel: "phone"` when the sign-in phone is a number abroad, "We can only
send verification codes to Kenyan phone numbers." (SMS reaches Kenyan
numbers only, so such a phone can't be verified this way; it's never in
`pending_contact_verifications`, so web shows no **Verify** button for it).
Show these directly — don't retry.

**Resend limit:** a second request within 60 seconds of the last code to
that address, or more than 5 in an hour, returns `400` with
*"Please wait a moment before requesting another code."* / *"Too many
codes requested for this destination. Try again later."* (fixed
2026-10-30 — it used to escape as a `500`). Show the message.

**Step 2 — Confirm the 6-digit code:**

```
POST /api/auth/verify-contact/confirm/
{ "channel": "email" | "phone", "code": "123456" }
```

```json
{ "detail": "Verified." }
```

`400` with the usual OTP messages ("Incorrect code." etc.) or the
already-verified/no-such-channel ones above. On success, re-fetch the
profile (§1) to pick up the new `email_verified`/`phone_verified` flag and
update the row, same as web does.

## 6. "Notifications" step

https://staging.mywellnesshealth.co.ke/account?tab=notifications ("Choose
how you would like to receive reminders and account messages."): a **Push
notifications on this device** section first ("On. Reminders you allow by
Push below will arrive here." / "Off. Turn them on to get the reminders you
allow by Push below.", with a **Turn on push** button while off), then
**What to remind me about** ("Choose how you want to hear about each type
of reminder.") with one row of channel switches per category (see
[`push-notifications.md`](./push-notifications.md)) — note the URL mount: notification preferences live under
**`/api/push/`**, not `/api/notifications/` (see the README's routing
table).

```
GET /api/push/preferences/
```

```json
[
  { "category": "medication", "label": "Medication reminders", "required": true, "push": true, "email": false, "sms": false, "whatsapp": true },
  { "category": "appointment", "label": "Appointment and booking reminders", "required": false, "push": true, "email": true, "sms": false, "whatsapp": true },
  { "category": "screening", "label": "Screening reminders", "required": false, "push": true, "email": true, "sms": false, "whatsapp": true },
  { "category": "vitals", "label": "Vitals and dialysis reminders", "required": false, "push": true, "email": true, "sms": false, "whatsapp": true },
  { "category": "product_updates", "label": "New features", "required": false, "push": true, "email": true, "sms": false, "whatsapp": true }
]
```

(An example of a user who has saved choices. A category never saved
comes back with **every** channel `true`, `NotificationPreference`
defaults / `preferences.ALL_ON`.) Each row shows its `label`, with "At
least one channel must stay on." under it when `required` is true, and
three switches labelled **Push**, **Email**, **SMS**. While loading web
shows "Loading your notification choices…".

```
PUT /api/push/preferences/
[
  { "category": "medication", "push": true, "email": false, "sms": false, "whatsapp": true },
  { "category": "appointment", "push": false, "email": false, "sms": false, "whatsapp": true },
  ...every other category, all at once...
]
```

Each row must carry all four booleans (`push`, `email`, `sms`,
`whatsapp`) — the serializer requires each one. The server only updates the
categories you send, but web always submits the full list it got from
`GET` (with the user's edits) when the user taps **Save preferences**
(reads **Saving…** while busy) — it doesn't save per toggle. Do the same.
Responds with the full list again (web toasts "Notification choices
saved"; a failed save toasts the error, fallback "Could not save your
choices"; a failed `GET` shows "Could not load your notification
choices." instead of the rows).

Web shows only **Push / Email / SMS**; `whatsapp` isn't shown and is sent
back unchanged from the `GET`. The `medication` category is `required`.
Server-side, only a row with **all four** channels `false` is rejected
(`400` "At least one channel must stay on for this notification type.").
On a `required` row, the hidden `whatsapp` value counts towards "at least
one channel stays on", exactly as the server counts it: a visible switch is
disabled only when it's the last channel on, counting `whatsapp`. So while
`whatsapp` is on, every visible switch can be turned off. Still show the
`400` message if it ever comes back.

## 7. "Change password", "Devices & sessions" and "Download your data"

```
POST /api/auth/change-password/
{ "new_password": "..." }
```

→ `{"detail": "Password changed."}`. Security step
(https://staging.mywellnesshealth.co.ke/account?tab=security, "Manage how
you sign in and protect access to your personal health information.") →
**Password & sign-in** ("Changing your password signs you out everywhere,
including here. You then sign in with the new one."; for a phone-only
account, `email` null: "This is the password you use with your phone
number. Changing it signs you out everywhere, including here.") → a
**Change password** button opening a **Change password** dialog ("Use at
least 6 characters.") with **New password**, **Confirm password**,
**Cancel** and **Update password** (disabled until both are filled, reads
**Updating…** while busy). No current-password re-entry required.
Validated by Django's `AUTH_PASSWORD_VALIDATORS` only (min 6 characters,
not too similar to the user's details) — not the 6-digit signup pattern;
web checks client-side first ("Password must be at least 6 characters.",
"Passwords do not match.") and shows any error inside the dialog. Revokes **every** refresh token for the
account, this device's included, so on success web toasts "Password
updated. Please sign in with your new password.", signs this device out
(`POST /api/auth/logout/` + clearing local tokens, see
[`auth-and-signup.md`](./auth-and-signup.md) Step 4) and returns to the
sign-in screen. Do the same.

The Security step's last section, **Devices & sessions** ("If you think
another device might have access to your account, sign out everywhere from
the Danger zone."), shows a static **Current session** box ("This browser,
signed in now.") and a **Review sessions** button that just opens the
Danger zone step — there is no session list API. **Sign out everywhere**
itself is in §8.

```
POST /api/auth/export-data/?export_format=json   (default)
POST /api/auth/export-data/?export_format=csv    (a zip of one CSV per data section)
```

Privacy & your data step → **Download your data** ("Get a copy of
everything on your account, as a single JSON file or a zip of CSV files.
Keep the file private because it contains personal information."), two
buttons **Download JSON** and **Download CSV** (both disabled, the tapped
one reading "Preparing…", while an export runs; toast "Your data export
has downloaded"; failure toasts the error, fallback "Could not generate
your data export"). Deliberately `POST`, not `GET`. The query param is
**`export_format`**, not `format` (the latter is DRF's own reserved
content-negotiation parameter and would never reach this view). Response
is the raw file body (`application/json` or `application/zip`) with a real
`Content-Disposition: attachment; filename="..."` header
(`my-data-<user id>.json` / `.zip`) — read that header for the filename
rather than hardcoding one, and save/share it through Flutter's own file
APIs rather than assuming a browser-style download. Throttled
(`DataExportThrottle`, 5/hour) — don't expose a way to trigger it
repeatedly in a tight loop.

## 8. Danger zone: "Sign out everywhere" and "Delete account"

https://staging.mywellnesshealth.co.ke/account?tab=danger ("These actions
affect access to your account or the information linked to it."), opening
with a red note: "**Take care.** Signing out everywhere ends every
session, this one included. Deleting your account removes all of its data
30 days after you confirm."

**Sign out of other devices** ("Ends sessions on other phones or browsers.
This device is signed out too, so you'll sign in again.") → **Sign out
everywhere** (reads **Signing out…** while busy):

```
POST /api/auth/logout-all/
```

→ `{"detail": "Logged out of all devices."}`. Same token effect as
change-password: revokes **every** refresh token issued to the account,
this device's included — same "security event invalidates everything"
posture the README's Authentication section describes. On success web
toasts "Signed out of all devices. Please sign in again.", signs this
device out the same way as §7 and returns to sign in (failure: toast the
error, fallback "Could not sign out of other devices").

**Delete account** — schedule-then-purge, not immediate:

```
GET  /api/auth/delete-account/status/   -> { "pending": false, "scheduled_for": null }
POST /api/auth/delete-account/          { "password": "..." }  -> { "pending": true, "scheduled_for": "2026-11-29T10:00:00Z" }
POST /api/auth/delete-account/cancel/   (no body)              -> { "pending": false, "scheduled_for": null }
```

- Scheduling requires the current password (`400` "Incorrect password.")
  and sets deletion for **30 days** later; a
  daily server job does the actual delete. A
  confirmation email is queued.
- Scheduling also **revokes every refresh token**, this device's
  included (same effect as §7), so the current session lasts at most
  until its access token expires.
- The account stays active the whole time — the user can still sign in.
  **Signing in does not cancel the deletion by itself**; it only stops if
  the user calls `cancel/` (`400` "No deletion is scheduled for this
  account." when nothing is pending).
- Web, with nothing pending: a **Delete account** section ("Permanently
  deletes your account and its data: bookings, vitals, assessment history
  and reports. Deletion happens 30 days after you confirm, so you can still
  sign in and cancel.") with a **Delete account** button that opens a
  **Delete your account** dialog ("Your account and its data are deleted
  30 days after you confirm. Sign in before then to cancel."): **Type
  DELETE to confirm** (placeholder "DELETE"), **Your password**, **Cancel**
  and **Delete my account** (reads **Scheduling…** while busy). **Delete my
  account stays disabled until the first field is exactly `DELETE`
  (case-sensitive) and a password is entered** — a client-side gate only;
  the API takes just `password`. Errors show inside the dialog ("Enter
  DELETE exactly to continue.", "Enter your password to confirm.", or the
  API's message, e.g. "Incorrect password."). Success closes the dialog
  and toasts "Account deletion scheduled".
- While pending: an **Account scheduled for deletion** section ("Your
  account and all its data will be permanently deleted on **<date>**. You
  can cancel any time before then.", `scheduled_for` as a long local date,
  e.g. "29 November 2026") and a **Cancel deletion** button (**Cancelling…**;
  toast "Account deletion cancelled", failure toasts the error, fallback
  "Could not cancel deletion"). Re-fetch `status/` after either action.
  Web does **not** sign out after scheduling — the session simply ends
  when the access token next needs refreshing.

---

Last verified against the code on 2026-11-11.
