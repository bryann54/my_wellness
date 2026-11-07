# Account & Profile

> **Before building anything from this file, check it against the web
> platform** — the wellness-health user web app (the source of truth).
> The mobile app implements exactly the regular-user features that exist
> and are usable there, with the same screens, labels and wording, and
> nothing more: no CHP, doctor, admin or organization-buyer features, no
> hidden UI, no mobile-only extras, and a feature behind one of web's
> build switches only behind the same switch. If something
> here doesn't match the web platform, or you think a feature is missing,
> don't build it — confirm with the product owner first.

Covers web's **Account settings** page (`/account`, reached from the
sidebar/top-bar user menu): **Profile details** (including the two
location hierarchies and the **Verified identity** box with **Update
identity** for a legacy account that has none), the **SHA coverage** and
**AfyaConnect sync** cards, **Verify your contact details**,
**Notifications**, **Change password**, **Sessions**, **Privacy & your
data** (**Download my data**, aggregate-reporting opt-out, SHA sharing),
**Delete account** — plus the cancer-history answers given on the Cancer
Health Check package screens, which save to the same profile. See
[`README.md`](./README.md) for the shared envelope (auth header, error
shape, phone format) this file assumes throughout. Every endpoint here is
authenticated (`IsAuthenticated`, the DRF default) and acts only on
`request.user`, except the `AllowAny` geography lists in §2.

**Web's Account settings layout (`app/(app)/account/page.tsx`), for
parity:** heading **Account settings** ("Manage your personal details,
security, and account."), a persistent **Verify your contact details**
card above the tabs (§5), then five tabs, deep-linkable via `?tab=`
(`general` — the default — `security`, `notifications`, `privacy`,
`danger`): **General** (Profile details + Verified identity §1/§3, SHA
coverage + AfyaConnect sync §1a), **Security** (Change password §7,
Two-factor authentication — see [`auth-and-signup.md`](./auth-and-signup.md)
Step 3a — and Sessions §7), **Notifications** (§6), **Privacy & your data**
(Download my data and the two checkboxes — §7/§4), **Danger zone** (§8).
Every card here that reads the profile uses the `?raw=1` request (§1).

## 1. Profile details: view and update

**One endpoint for everything** — `GET`/`PATCH /api/health-profile/`
(`apps.accounts.views.HealthProfileView`, `ProfileSerializer`).

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
  "account_phone": "0712345678",
  "sha_beneficiary_id": "12345678",
  "sha_beneficiary_id_type": "national_id",
  "national_id_number": "12345678",
  "analytics_opt_out": false,
  "sha_data_sharing_consent": true,
  "cancer_diagnosed": false,
  "cancer_diagnosed_declared_at": null,
  "cancer_diagnosis_type": "",
  "cancer_diagnosis_type_other": "",
  "cancer_diagnosis_year": null,
  "cancer_education_materials_requested": false
}
```

(The six `cancer_*` fields are explained in §4a.) Profile details shows:
the Verified identity box (**Full name**, **Gender**, **Date of birth**,
**National ID number**, all read-only — §3), then **Phone number**,
**County**, **Sub-county**, **Constituency**, **Ward**, **Occupation**,
**Email** (or **Email address (optional)**, see below) and **Member code**
(read-only, shown when present). `email` is the login email (`User.email`,
`null` for a phone-only account); `phone` is the profile's contact number
(`Profile.phone`). `sha_number` comes from the AfyaConnect Client Registry
record and is `""` when there isn't one (shown on the SHA coverage card,
§1a). The first `GET` also auto-fills `sha_beneficiary_id`/`_type` from the
verified `national_id_number` if they're blank
(`backfill_sha_beneficiary_id_from_national_id`). Elsewhere in the app,
`age` drives assessment/package age checks, `bmi_prompt_due` whether the
vitals tools show their optional BMI step (`bmi_stale`: no BMI recorded in
the last four calendar months; `bmi_prompt_due`: stale and the step not
skipped in the last four months), and `on_dm_medication` the Blood Sugar page.
`has_hypertension`/`on_htn_medication`/`htn_medications`/`has_diabetes`/
`dm_medications` are legacy answers web no longer asks or writes (the
vitals tools' own pathway questions replaced them, see
`lib/health-profile-steps.tsx`) — read-only history; don't build UI to
edit them. `age_stale` is only ever true for a legacy account with no
`date_of_birth`, and `employment_type` (AfyaConnect's classification,
`""` when none) isn't shown anywhere on web — Occupation is always the
career dropdown below.

Two query-time behaviors that matter for parity:

- **`?raw=1`** — pass this on the Account settings screen specifically
  (web's `useRawHealthProfile`). Without it, a handful of QA/test accounts
  (`is_test_account`) get a masking override that force-blanks the
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
  "Verify your contact details" texts; `phone` is the editable contact
  number and can differ.
- `age`/`age_stale`/`bmi_stale`/`email_verified`/`phone_verified`/
  `account_phone`/`sha_number`/`employment_type`/`member_code`/`health_profile_completed`
  are server-computed or read-only, never send them back. (Every
  successful `PATCH` sets `health_profile_completed` to `true` as a side
  effect.)

**PATCH** (`HealthProfileUpdateSerializer`) — every field is optional and
independently omittable; an omitted field is left completely untouched
server-side (not reset to null). What web's Profile details card ("This
information is used across your assessments and reports.") sends on
**Save changes** (toast "Account details updated"):

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
  what was typed, and omits it when blank).
- `email` — **only** accepted when the account has no email yet (a
  phone-only signup); `400` "Your account already has an email address."
  otherwise, or "An account with this email already exists.". It's saved
  as the account's real `User.email` (so it also becomes a login
  identifier, even though web's helper text says "A contact email for
  reports and notifications. You'll keep signing in with your phone number
  and password — adding this doesn't change that.") but starts unverified,
  which is what makes §5's Verify card appear. Web shows this input only
  for phone-only accounts, labelled **Email address (optional)**, and sends
  it only when non-blank; for everyone else **Email** is read-only.
- `county` (string name, omitted when blank), `sub_county`/`constituency`/
  `ward` (ids — web always sends all three, `null` when unpicked, which
  clears them) — see §2. Unlike signup, this path does **not** cross-check
  that they belong together, so keep the cascade consistent client-side.
- `occupation` (≤150 chars, omitted when blank) — **Occupation** is a
  searchable career dropdown ("Select your career…", "Search careers…")
  with an "Other" option that reveals a free-text "Enter your occupation"
  input; a saved value that isn't in the list pre-selects "Other".
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

### 1a. "SHA coverage" and "AfyaConnect sync" (General tab)

Two cards below Profile details, both backed by `apps.health_exchange`:

- **SHA coverage** ("Check your Social Health Authority (SHA) eligibility
  using the National ID on file.") — shows "SHA number: …" when
  `sha_number` is present.
  If there's no `national_id`-type `sha_beneficiary_id` on file, web shows
  a **National ID number** input with a **Save** button that PATCHes
  `{"sha_beneficiary_id": "...", "sha_beneficiary_id_type": "national_id"}`
  to §1 (toast "National ID saved"; only National ID is checkable today; if
  another type is on file web says so and asks for a National ID).
  Otherwise it shows "National ID on file: …" and **Check SHA eligibility**:
  `GET /api/health-exchange/sha-eligibility/` → a summary of DHA's response:
  `schemes[]` (`schemeName`, `covered`, `message`, `reason`, `possibleSolution`,
  `startDate`, `endDate`), `statusCode`, `statusDesc` and `memberCrNumber`
  ("Member CR number"). `400` with a message if no usable ID is on file or SHA can't be
  reached.
- **AfyaConnect sync** — hidden until `has_national_id` is true.
  `GET /api/health-exchange/afyaconnect-resync/status/` →
  `{"already_synced": bool, "has_national_id": bool, "can_resync": bool, "last_attempted_at": iso|null, "next_eligible_at": iso|null}`
  (no throttle; `next_eligible_at` is only set while on cooldown).
  `POST /api/health-exchange/afyaconnect-resync/` →
  `{"status": "synced" | "not_found" | "unavailable"}`; there's a **24-hour** per-user
  cooldown (`AFYACONNECT_RESYNC_COOLDOWN`, `400` inside it) plus an
  `afyaconnect_resync` throttle of 10/hour. Web disables the button while
  `can_resync` is false and shows "You can try again on
  <next_eligible_at>". Its label is **Refresh my AfyaConnect data** when
  `already_synced`, else **Sync with AfyaConnect**; the description is
  "Keep your AfyaConnect-sourced details current — including dependants,
  phone number, and address — by syncing again anytime." or "We couldn't
  find a Client Registry record for you yet. If you've recently registered
  for SHA, you can try syncing again." respectively. After the `POST` web
  re-fetches the status and the profile, and toasts: `synced` → "Synced
  with AfyaConnect — your details are now up to date."; `not_found` →
  "AfyaConnect has no newer data right now — your existing details are
  unchanged." (if `already_synced`) or "AfyaConnect doesn't have a matching
  record yet. If you've just registered for SHA, this can take a little
  time to propagate — try again later.".
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

On Account settings all five pickers sit side by side in Profile details.
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
"Your ID has already been verified and cannot be changed."
(`services.update_verified_identity`; a correction needs staff help).
Every account created through today's signup already has one, so this
flow only applies to a legacy account with `national_id_number` empty.
Web mirrors that: the **Verified identity** box always shows **Full
name**, **Gender**, **Date of birth** and **National ID number**
read-only, and the **Update identity** button (`UpdateIdentityDialog`)
only renders when `national_id_number` is empty (copy: "Verify your
National ID or Maisha Card to set your name, gender, and date of birth.");
otherwise the copy reads "From your National ID or Maisha Card — verified
once, and can never be changed again, including here." Empty values show
as "—".

The **Update your identity** dialog ("We'll verify your name, gender, and
date of birth against your ID again.") is two-step, same shape signup
itself uses: verify first, then apply.

**Step 1 — Verify ID** (web's **ID type** radio **National ID** / **Maisha
Card**, then a **National ID number** / **Maisha Number** field, then the
**Verify ID** button, enabled once the number is 6–10 digits):

```
POST /api/auth/verify-id/
{ "id_type": "national_id" | "maisha_card", "id_number": "12345678" }
```

Called while authenticated, the "ID already belongs to an account" check
excludes your own account. Throttle, timeouts and errors are exactly as in
[`auth-and-signup.md`](./auth-and-signup.md) Step 0.

**Manual entry — off by default, gated.** Only while web's build-time
switch `NEXT_PUBLIC_MANUAL_IDENTITY_VERIFICATION_ENABLED` is on (exactly
`"true"`; the 2026-10-15 Peleza-shutdown stopgap, paired with the
server's own `MANUAL_IDENTITY_VERIFICATION_ENABLED`) does web call the
manual endpoint instead and add **First name** / **Surname** / **Other
name (optional)** / **Gender** (Female/Male) / **Date of birth** inputs.
The client can't read the server flag; build this behind an equivalent
switch that is **off by default**. The manual endpoint `404`s while the
server flag is off.

```
POST /api/auth/verify-id/manual/
{
  "id_type": "national_id",
  "id_number": "12345678",
  "first_name": "Jane",
  "last_name": "Wanjiru",
  "other_name": "",
  "gender": "female",
  "date_of_birth": "1992-03-14"
}
```

Both return (fields this flow uses):

```json
{
  "verification_id": "a1b2c3d4-...",
  "first_name": "Jane",
  "last_name": "Wanjiru",
  "gender": "female",
  "date_of_birth": "1992-03-14"
}
```

Web then shows "ID verified" with **Name**/**Gender**/**Date of birth** and
two buttons, **Use a different ID** and **Apply**.

**Step 2 — Apply:**

```
POST /api/auth/update-identity/
{ "national_id_number": "12345678", "identity_verification_id": "a1b2c3d4-..." }
```

`national_id_number` must be the same `id_number` verified in step 1.
Returns the full `ProfileSerializer` shape (§1) with the new identity
fields applied (names title-cased); web toasts "Identity updated" and
closes the dialog. **Use a different ID** just returns to step 1
client-side. The `verification_id` from step 1 is
single-use, expires after 30 minutes, and is tied to the exact id number
verified — don't cache and reuse it for a later, different change.
`400` "Identity verification expired or not found. Please verify your ID
again." if it's stale.

## 4. "Exclude my activity from aggregate reporting" and "Share my health data with SHA"

The two checkboxes on the **Privacy & your data** tab, each saving
immediately on toggle through its own dedicated endpoint — never through
§1's PATCH:

```
PATCH /api/auth/analytics-opt-out/
{ "analytics_opt_out": true }
```

```
PATCH /api/auth/sha-consent/
{ "sha_data_sharing_consent": true }
```

Web's copy: **Exclude my activity from aggregate reporting** ("When on,
none of your activity contributes to anonymous, de-identified counts (e.g.
"how many prescriptions for X this month") shown on internal reporting
dashboards. This never affects your own care or account."; toasts "Opted
out of aggregate reporting" / "Opted back in to aggregate reporting") and
**Share my health data with SHA** ("When on, your logged readings,
medications, and appointments are shared with Kenya's Social Health
Authority (SHA) to support your care there. On by default — you can turn
this off at any time."; toasts "Sharing enabled with SHA" / "Sharing
with SHA turned off"). Each checkbox is disabled while its own save is in
flight.

Both return the full `ProfileSerializer` shape. `sha-consent` additionally
writes an append-only `ConsentEvent` record server-side on each actual
change (proof of when consent was granted/withdrawn) — it gates whether
this user's logged readings, medications and appointments sync to Kenya's
SHA/Afyalink exchange at all. It's on by default for new accounts (recorded as a
`ConsentEvent` with source `default_on_signup`), and existing accounts keep their
choice. See
[`health-records-and-shr.md`](./health-records-and-shr.md) for the
separate DHA SHR consent.

## 4a. Cancer history (Cancer Health Check package screens)

Saved from the Cancer package journey (`components/wellness-packages/cancer-journey.tsx`),
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

Returns the full `ProfileSerializer` shape, which carries these read-only
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

## 5. "Verify your contact details" (post-signup, optional)

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

**When to show this card at all**: only when `profile.email` (or
`profile.account_phone`, the sign-in phone the code is actually sent to —
not `phone`, the editable contact number) is set **and**
`profile.email_verified`/`.phone_verified` is `false` — web
renders nothing otherwise (`VerifyContactCard`: `if (pending.length === 0)
return null`). Web shows it above the tabs, non-dismissible ("You joined
without confirming this -- verifying is optional, but helps us reach you
and recover your account."; "this" becomes "your email and phone" when
both are pending), one row per pending channel (**Email** / **Phone**,
with the value: the email, or `account_phone`) and a **Verify** button; tapping it sends the code (toast
"Verification code sent") and swaps in "Enter the 6-digit code we just
sent" with **Confirm**/**Cancel**. A successful confirm toasts "Email
verified" / "Phone verified".

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
(`OtpRequestThrottle`, the shared 5/hour `otp_request` bucket). Note the
Phone row displays `profile.phone` (`Profile.phone`, which §1's PATCH can
change) while the code always goes to `User.phone`, so after a Profile
details phone edit the two can differ — web has the same behavior.

Errors (`400`, via the shared error envelope): "This account has no email
address." / "This account has no phone number.", or "This email address
is already verified." / "This phone number is already verified." Show
these directly — don't retry.

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
hide the row, same as web does by invalidating its own profile cache.

## 6. "Notifications" tab

Per-type channel toggles ("Choose how you want to hear about each type of
reminder."), with the **"Push notifications on this device"** panel and its
**Turn on push notifications** button above them (see
[`push-notifications.md`](./push-notifications.md)) — note the URL mount: `apps.notifications` is mounted at
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
defaults / `preferences.ALL_ON`.) Web shows each row's `label` in a
**Type** column.

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
`GET` (with the user's edits) when the user taps **Save choices** — it
doesn't save per toggle. Do the same. Responds with the full list again
(web toasts "Notification choices saved"; a failed `GET` shows "Could not
load your notification choices.").

Web's table (`components/account/notification-preferences.tsx`) shows
only **Push / Email / SMS** columns; `whatsapp` isn't shown and is sent
back unchanged from the `GET`. The `medication` category is `required`
(web: "At least one channel must stay on."): sending it with every channel
`false` is rejected (`400` "At least one channel must stay on for this
notification type."). The server counts all four channels; web enforces it
client-side by disabling the last checked box among its three visible ones
on a required row. Mirror that so the user gets instant feedback instead
of a round-trip error.

## 7. "Change password", "Sessions" and "Download my data"

```
POST /api/auth/change-password/
{ "new_password": "..." }
```

→ `{"detail": "Password changed."}`. Security tab → **Change password**
(**New password**, **Confirm password**, **Update password**, disabled
until both are filled). Card description: "Use at least 6 characters.
You'll be signed out everywhere, including here, and sign in again with
your new password." (phone-only accounts: "Use at least 6 characters. This
is the password you use with your phone number to sign in. You'll be asked
to sign in again."). No current-password re-entry required. Validated by
Django's `AUTH_PASSWORD_VALIDATORS` only (min 6 characters, not too
similar to the user's details) — not the 6-digit signup pattern; web
checks client-side first ("Password must be at least 6 characters",
"Passwords do not match"). Revokes **every** refresh token for the
account, this device's included, so on success web toasts "Password
updated. Please sign in with your new password.", signs this device out
(`POST /api/auth/logout/` + clearing local tokens, see
[`auth-and-signup.md`](./auth-and-signup.md) Step 4) and returns to the
sign-in screen. Do the same.

```
POST /api/auth/logout-all/
```

→ `{"detail": "Logged out of all devices."}`. Security tab → **Sessions**
("If you think another device might have access to your account, sign out
everywhere, including this device.") → **Log out of all devices**. Same
token effect as change-password: revokes **every** refresh token issued
to the account, this device's included — same "security event
invalidates everything" posture the README's Authentication section
describes. On success web toasts "Logged out of all devices. Please sign
in again.", signs this device out the same way and returns to sign in.

```
POST /api/auth/export-data/?export_format=json   (default)
POST /api/auth/export-data/?export_format=csv    (a zip of one CSV per data section)
```

Privacy & your data tab → **Download my data** ("Get a copy of everything
on your account, as a single JSON file or a zip of CSV files."), two
buttons **JSON** and **CSV** (both disabled, the tapped one reading
"Preparing…", while an export runs; toast "Your data export has
downloaded"). Deliberately `POST`, not `GET`. The query param is
**`export_format`**, not `format` (the latter is DRF's own reserved
content-negotiation parameter and would never reach this view). Response
is the raw file body (`application/json` or `application/zip`) with a real
`Content-Disposition: attachment; filename="..."` header
(`my-data-<user id>.json` / `.zip`) — read that header for the filename
rather than hardcoding one, and save/share it through Flutter's own file
APIs rather than assuming a browser-style download. Throttled
(`DataExportThrottle`, 5/hour) — don't expose a way to trigger it
repeatedly in a tight loop.

## 8. "Delete account" (Danger zone)

Schedule-then-purge, not immediate (`apps/accounts/account_deletion.py`,
`account_deletion_views.py`):

```
GET  /api/auth/delete-account/status/   -> { "pending": false, "scheduled_for": null }
POST /api/auth/delete-account/          { "password": "..." }  -> { "pending": true, "scheduled_for": "2026-11-29T10:00:00Z" }
POST /api/auth/delete-account/cancel/   (no body)              -> { "pending": false, "scheduled_for": null }
```

- Scheduling requires the current password (`400` "Incorrect password.")
  and sets deletion for **30 days** later (`DELETION_GRACE_DAYS`); a
  daily job (`purge_deleted_accounts`) does the actual delete. A
  confirmation email is queued.
- Scheduling also **revokes every refresh token**, this device's
  included (same effect as §7), so the current session lasts at most
  until its access token expires.
- The account stays active the whole time — the user can still sign in.
  **Signing in does not cancel the deletion by itself**; it only stops if
  the user calls `cancel/` (`400` "No deletion is scheduled for this
  account." when nothing is pending).
- Web's Danger zone tab: with nothing pending, a **Delete account** card
  ("Permanently deletes your account and all associated data — bookings,
  vitals, assessment history, and reports. Deletion happens 30 days after
  you confirm, giving you time to change your mind by simply logging back
  in and cancelling.") with a **Delete my account** button that reveals
  "Enter your password to confirm", **Confirm deletion** and **Cancel**
  (toast "Account deletion scheduled"); while pending, an **Account
  scheduled for deletion** card ("Your account and all associated data
  will be permanently deleted on <date>. You can cancel any time before
  then.") and a **Cancel deletion** button (toast "Account deletion
  cancelled"). Re-fetch `status/` after either action. Web does **not**
  sign out after scheduling — the session simply ends when the access
  token next needs refreshing.

---

Last verified against the code on 2026-11-03.