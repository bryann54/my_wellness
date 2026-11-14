# Auth & Signup

> **Before building anything from this file, check it against the web
> platform** — the user web app, live on staging at https://staging.mywellnesshealth.co.ke/ (the source of truth).
> The mobile app implements exactly the regular-user features that exist
> and are usable there, with the same screens, labels and wording, and
> nothing more: no doctor, admin or organization-buyer features, no
> hidden UI, no mobile-only extras, and a feature behind one of web's
> build switches only behind the same switch. If something
> here doesn't match the web platform, or you think a feature is missing,
> don't build it — confirm with the product owner first.

Covers the web app's sign-in page (`/auth`) and "Forgot passcode?" page
(`/forgot-password`): **Create your account** (page 1 "Verify identity",
page 2 "Complete your details", including the DHA-trusted-phone skip-OTP
path), the **Enter your code** screens, **Sign in** (including the
`email_not_confirmed`/`phone_not_verified` auto-resend behavior),
**Two-factor verification**, sign-out and token refresh, **Reset your
passcode**, joining an organization from an invite link (`/invite/<token>`,
Step 2b), and where the health-profile questions actually get asked
(there is no post-login onboarding gate -- see Step 6). Account settings →
Security's **Two-step verification** section is documented here (Step
3a) because it shares the MFA endpoints; **Change password** and **Sign out
everywhere** are in [`account-and-profile.md`](./account-and-profile.md)
§7/§8, summarized here only where they affect tokens.

Out of scope for the mobile app (web-only organization-buyer features):
signing up on a company subdomain (web's `subdomain` signup field), the
`pending_subdomain_claim` → company setup redirect, and Organization Admin.

See [`README.md`](./README.md) for the shared envelope (error shape, auth
header, phone format) — not repeated here. Every error example below is
shown *inside* that envelope's `error.detail`, i.e. the real body is
`{"error": {"detail": <what's shown>, "status_code": 400}}`.

One terminology note before anything else: **"passcode" (web's sign-in,
signup and reset screens) and "password" (the API fields, and web's
Account settings → Security "Change password" dialog) are the same field.**
The backend's `password`/`new_password` fields on **signup and passcode
reset** are validated as an exactly-6-digit numeric string. There is no separate
"passcode" endpoint. Two exceptions to the 6-digit rule: **Sign in**
accepts whatever password an existing account already has (older accounts
may have longer/alphanumeric ones — web's sign-in form only requires a
non-empty string, and its Passcode field has no length lock), and **Change
password** (Account settings, see Step 5's last subsection) only runs
Django's `AUTH_PASSWORD_VALIDATORS` (min 6 characters), not the 6-digit
pattern.

## OTP mechanics shared by every code in this file

All signup/confirm/reset/verify codes follow the same rules:

- 6 digits, valid for **10 minutes**, at most **5
  wrong attempts** per code before a new one must be
  requested. Only the newest unconsumed code for a destination counts.
- Per destination: at least **60 seconds** between sends
  and at most **5 sends per hour**. The resend/login/reset endpoints swallow that
  limit and still ack success — the previous code simply stays valid and
  no new one is sent.
- Wrong-code errors are a plain `400` with no `code`, one of: `"Incorrect
  code."`, `"This code has expired. Please request a new one."`, `"Too
  many incorrect attempts. Please request a new code."`, `"No pending
  verification code for this destination."` — show the message as-is.
- **Dev/staging fixed SMS code:** when `OTP_SMS_TEST_CODE` is set
  server-side (dev/staging only, never production), every **SMS**-channel
  OTP uses that fixed code and no real SMS is sent. Email OTPs are always
  real. Ask the backend team for the value in the environment you're
  testing against.
- Separately from the per-destination limits, every *sending* endpoint
  (`signup/`, `signup/resend/`, `signup/phone/resend/`,
  `password-reset/request/`, `verify-contact/request/`) shares one DRF
  `otp_request` throttle bucket: **5/hour**, keyed by client IP
  (by user once authenticated). A `429` from any of them blocks all of
  them.

## Step 0 — "Verify my identity" (Create your account, page 1 of 2)

Signup cannot be called directly with a name/DOB the user types in. It must
first reference a server-verified identity record.

`POST /api/auth/verify-id/` (`AllowAny`; `id_verification` throttle
scope = **5/hour** per IP, shared with
`verify-id/manual/` — this costs real money per call against Peleza,
Kenya's ID-verification provider)

```json
// request
{ "id_type": "national_id", "id_number": "12345678" }
```

`id_type` is `"national_id"` or `"maisha_card"`; `id_number` must be 6–10
digits (at most 20 characters as sent; anything else is `400`
`{"id_number": ["Enter a valid ID number."]}`; web disables the button until
it matches `^\d{6,10}$`). `"passport"` is rejected here (`400`): a passport
can't be looked up and always goes through `verify-id/manual/` (below).
Web's page 1 ("Page 1 of 2 · Verify identity", **Create your account**)
shows a **National ID** / **Maisha Card** radio (default `national_id`).
**Passport** is a third option shown straight away only when the visitor
seems to be outside Kenya (the IP country Vercel reports, or, without it,
a browser time zone other than Africa/Nairobi); then the intro reads "Enter
your Kenyan National ID, Maisha Card or passport number to begin." and the
passport's issuing country and "Where do you live?" start on the detected
country. Otherwise the intro reads "Enter your Kenyan National ID or
Maisha Card number to begin." and Passport isn't offered at all (product
decision 2026-11-10). **Whether to offer Passport is the app's own choice:
the backend returns no field for it.** Offer it, as web does, only when the
device's region says the person is outside Kenya; the API accepts a
passport either way. The radio is followed by a **National ID number** / **Maisha Card number** /
**Passport number** field with the hint "We verify this against national
records to fill in your name, gender and date of birth automatically."
(hint hidden whenever the details are typed in instead). Picking the wrong one is harmless:
on a not-found the backend retries the other ID type once. The lookup tries
DHA's AfyaConnect Client Registry first and only falls back to Peleza
(cached permanently per ID; a "not found" is cached for 24h).

**Consent first (web parity):** page 1 shows one combined consent checkbox
("I agree to the Privacy Policy and Terms of Use, consent to identity
verification, and to the collection and processing of my personal and
health information.") *above* **Verify my identity**, and that button
stays disabled until it's ticked. That same answer is later sent as
`accepted_terms` on signup (Step 2).

```json
// response 200
{
  "verification_id": "uuid",
  "first_name": "JANE",
  "last_name": "WANJIRU",
  "other_name": "",
  "gender": "female",
  "date_of_birth": "1992-06-10",
  "phone": "0712345678",
  "from_afyaconnect": true,
  "phone_locked": true,
  "phone_normalized": "254712345678",
  "id_type": "national_id",
  "country_of_residence_locked": null,
  "county_id": 47,
  "sub_county_id": 312,
  "constituency_id": 290,
  "ward_id": 1450
}
```

- **Timeouts (2026-10-30):** the server waits up to **55 seconds** for
  Peleza (an ID lookup queries the government registry and its speed
  varies a lot; 10–20 seconds has been seen). Give this request a client
  timeout of at least **60 seconds**, and show a "Verifying…" state
  (web's button label while waiting) rather than failing early. A Peleza
  outage or timeout returns `503` with the retryable "Verification service
  is temporarily unavailable" message — let the user try again. The API's
  gateway cuts any request off at 60 seconds, so a lookup that runs long across both
  providers can also come back as a non-JSON `504` page — treat a
  `502`/`503`/`504` or an unparseable body as that same retryable state.
- `first_name`/`last_name`/`gender`/`date_of_birth` come straight from the
  government record — **never editable by the user, not even
  cosmetically**. On success web shows "Identity verified successfully"
  with read-only **Full name**, **Date of birth** and **Gender on record**
  rows and the note "From your verified ID — can't be edited here,
  including trying a different ID. Not you? Refresh this page to start
  signing up again.", then a **Continue** button to page 2 (web title-cases
  the ALL-CAPS names for display only). Once verified, page 1 offers no way
  to verify a different ID in the same session — the only way out is
  restarting signup from scratch. A record with no full name gets a `400` with `code: "identity_incomplete"`.
- `from_afyaconnect` is `true` whenever the identity came from DHA's
  AfyaConnect Client Registry, even when that record has no phone.
  `phone` is the registry's raw digits (`""` when there is none, and always
  `""` for a Peleza-sourced or manual identity); `phone_normalized` is the
  same number in `2547…` form (`""` when there is none). `phone_locked` is
  `true` only when both `from_afyaconnect` is true and a phone came back —
  that's the one flag to branch on. `other_name` is the record's middle
  name (`""` when none); web doesn't display it. Use
  `phone_normalized`. **When `phone_locked` is true, page 2's
  "Phone number" field must be pre-filled with this value and locked (not
  editable)** — this is what makes the later skip-OTP phone path
  (Branch B2 below) actually trigger; if the client lets the user enter a
  *different* phone number, the account falls back to the normal OTP flow
  instead.
- `county_id`/`sub_county_id`/`constituency_id`/`ward_id` are AfyaConnect's
  free-text location matched by name (ignoring case) against the geography lists
  (account-and-profile.md §2); each is independently `null` when there
  was no match (always `null` for a Peleza-sourced or manual identity).
  Web pre-selects them in page 2's location pickers but, unlike the phone,
  **leaves them editable**.
- `id_type` is the document that was verified: `"national_id"`,
  `"maisha_card"` or `"passport"`.
- `country_of_residence_locked` is `"KE"` when this identity fixes where
  the person lives, else `null` (Step 1 says what the app does with it).
- `verification_id` must be sent as `identity_verification_id` in the
  signup call that follows. It's single-use, tied to this
  `id_number`, and expires after **30 minutes**.

Errors (all `400` unless noted):

- `{"detail": "An account already exists for this ID. Please sign in instead.", "code": "account_exists"}`
  — web shows the message plus a **Sign in instead** link.
- `{"detail": "Something went wrong. Please try again."}` — this is the
  under-18 gate, deliberately vague. Don't try to special-case it.
- `{"detail": "ID number not found. Please check and try again.", "code": "identity_not_found"}`
  — the ID isn't on AfyaConnect or Peleza. Show the message **and** offer
  manual entry (below).
- `503` `{"detail": "...", "code": "identity_lookup_unavailable"}` — the
  providers couldn't be reached. Retryable (see Timeouts above), and manual
  entry is offered too.
- `{"detail": "...", "code": "identity_rejected"}` — any other provider
  rejection (e.g. a malformed number). Show as-is; no manual entry.

**After a failed lookup:** for `identity_not_found` and
`identity_lookup_unavailable` the server opens manual entry for **that
`id_number`** for 60 minutes. Web
shows the error with an **Enter my details myself** button under it; tapping
it reveals the manual fields (below) with the note "We couldn't confirm this
ID with national records, so enter your details exactly as they appear on
it." and **Verify my identity** then calls `verify-id/manual/`. Changing the
number or the ID type closes it again (the server only opened it for that
number). The app decides nothing here: show the button only on those two
codes.

**Manual entry:** `POST /api/auth/verify-id/manual/` takes
`id_type`/`id_number`/`first_name`/`last_name`/`other_name` (optional)/
`gender` (`"female"`/`"male"`)/`date_of_birth` and, for a passport,
`id_country` (ISO 3166-1 alpha-2, e.g. `"GB"`) directly from the user
instead of a provider, returning the same `200` shape as `verify-id/`
(including `id_type` and `country_of_residence_locked`). Same throttle, same
`account_exists`/under-18 errors. The server allows it when:

- `id_type` is `"passport"` (always typed in; `id_country` required —
  `400` `{"id_country": ["Select the country that issued your passport."]}`
  otherwise; for any other `id_type` it's ignored). A passport number is
  letters and digits, 5–20 long once spaces/dashes are removed, with at
  least one digit (at most 20 characters as sent); otherwise `400`
  `{"id_number": ["Enter a valid passport number."]}`. It's stored
  upper-cased (`"gb 123-456 78"` → `"GB12345678"`).
- the lookup for this `id_number` just failed (`identity_not_found` /
  `identity_lookup_unavailable`, above), or
- manual entry for everyone is switched on (`app-config/`'s
  `manual_identity_verification_enabled`, below).

`id_country` must be a code from **`GET /api/auth/countries/`** (`AllowAny`,
send no `Authorization` header; the response carries `Cache-Control:
public, max-age=86400`, so caching it for a day is fine):

```json
[{ "code": "AF", "name": "Afghanistan" }, ..., { "code": "KE", "name": "Kenya" }, ...]
```

A plain array, in name order, of every ISO 3166-1 alpha-2 code the API
accepts. Use it for the passport's issuing country here and for
`country_of_residence` (Step 1); don't hardcode a country list. Kenya is
`"KE"`.

Otherwise it's `400` `{"detail": "Please check your ID number first. You can
enter your details yourself if we can't find it.", "code":
"manual_entry_not_allowed"}` (it used to `404`). Web's manual fields are
**First name**, **Surname**, **Other name (optional)**, **Date of birth** (a
calendar with month/year dropdowns, placeholder "Select your date of birth",
where nothing later than exactly 18 years ago can be picked — the server's
under-18 refusal still applies) and **Gender** (Female/Male), all but Other name required before **Verify my
identity** enables. For a passport it also shows **Country that issued your
passport** (a searchable country list) under the number, and the note
"Enter your details exactly as they appear on your passport." A
manually-entered identity is recorded as `national_id_verification_source`
`"manual"`; a passport is never sent to DHA or SHA as a national ID.

**Which endpoint to call is the backend's decision:** read
`GET /api/auth/app-config/` (`AllowAny`, only the global `anon` 60/min, send no
`Authorization` header):

```json
{ "afyaconnect_identity_search_enabled": true, "manual_identity_verification_enabled": false }
```

While `manual_identity_verification_enabled` is `true`, show the manual
inputs straight away and use `verify-id/manual/` for every ID type;
otherwise use `verify-id/` for National ID / Maisha Card (also the fallback
if `app-config/` can't be fetched), `verify-id/manual/` for a passport, and
offer manual entry only after a failed lookup. Don't
probe the manual endpoint to find out — every call spends the 5/hour
budget. The same flag gates the manual inputs in Account settings'
**Update identity** dialog ([`account-and-profile.md`](./account-and-profile.md) §3).

## Step 1 — "Where do you live?", "Your location" and "Locality" (page 2, no separate endpoint)

Page 2's **Contact details** section starts with **Where do you live?** (a
searchable country list from `GET /api/auth/countries/`, Step 0), sent as
`country_of_residence` (a `code` from that list, default `"KE"`). Until the person picks one it starts on the
passport's issuing country (when signing up with a passport), else the
detected country when outside Kenya, else Kenya — so a passport holder
isn't asked for the same country twice; it stays editable.

**When the verify response's `country_of_residence_locked` is `"KE"`, it's
always Kenya.** Read that field from the Step 0 `200` (`verify-id/` or
`verify-id/manual/`); the backend sets it (today: a Kenyan ID or Maisha
Card typed in after a failed lookup, while manual entry for everyone is
off) and the app must not work it out itself. Then show Kenya without a
choice (web hides **Where do you live?** entirely), send
`country_of_residence: "KE"` and require the four locality fields: the
server treats the country as `"KE"` whatever is sent. When it's `null`,
the person chooses.

- **Kenya:** county/sub-county/constituency/ward are **all four required**
  (missing ones come back as `400` `{"county": ["This field is required."],
  ...}`), and the phone must be a Kenyan mobile.
- **Anywhere else:** there's no county etc. Web hides **Your location** and
  **Locality** entirely (desktop steps become Contact → Passcode → Terms;
  the phone-width progress card counts 3). Anything sent for the four is
  ignored and stored empty. **An email is required** (`400`
  `{"email": ["Add your email address. We send your sign-up code there when
  you live outside Kenya."]}`), because codes can only be texted to Kenyan
  numbers, so these signups always take Branch A. The phone becomes
  optional and may be from any country, but must include its country code
  (`"+44 7911 123456"` or `"0044..."`; stored as digits, `"447911123456"`);
  otherwise `400` `{"phone": ["Enter your phone number with its country
  code, e.g. +44 7911 123456."]}`. Web shows "We'll email your sign-up code,
  so an email address is needed. A phone number is optional and can be from
  any country." under the country, labels the phone **Phone number
  (optional)** with placeholder "e.g. +44 7911 123456", and shows "Include
  your country code, e.g. +44 7911 123456." for a bad number.

Page 2 collects the Kenyan locality *before* submitting signup, but there
is no separate "save my location" call: these are plain fields sent as part
of the signup request itself (Step 2 below). Two distinct hierarchies nest
under the same `county` string field:

- **"Your location"** ("Choose your county and sub-county."): **County** →
  **Sub-county** (`sub_county`, a `SubCounty` FK id).
- **"Locality"** ("Choose your constituency and ward."): **County** →
  **Constituency** → **Ward** (`constituency`/`ward`, FK ids).

Signup rejects a `sub_county`/`constituency` from a
different county than `county`, or a `ward` outside the chosen
`constituency` (`400`, keyed by the offending field). Changing county on
web clears all three dependent picks; changing constituency clears ward.

Fetch the pickers via the `AllowAny`, unpaginated `/api/geography/` list
endpoints — exact paths and shapes are in
[`account-and-profile.md`](./account-and-profile.md) §2.

## Step 2 — "Create my account"

Page 2 ("Page 2 of 2 · Complete profile", **Complete your details**) opens
with the read-only identity panel ("Identity verified successfully", **Full
name**, **Date of birth**, **Gender on record**) and a **These are not my
details** link back to page 1. Its other sections are **Contact details**
(**Phone number**, **Email address**) and **Create your passcode** ("Choose
and confirm six numeric digits."; **Six-digit passcode**, **Confirm
passcode**, a **Show passcodes** / **Hide passcodes** toggle covering both,
"Passcodes match" / "Passcodes do not match." under the confirm field). On
a phone-width screen web shows all sections on one scroll with a
**Registration progress** card ("N of 7"); tapping **Create my account**
while something is missing does not submit — the button reads **Create my
account · Check details** and a review list names each missing item
("Enter an email address, a phone number, or both." — or, outside Kenya,
"Enter your email address. We send your sign-up code there." — "Select your
county.", "Select your sub-county.", "Select your constituency.", "Select
your ward.", "Enter a 6-digit passcode.", "Confirm your passcode.",
"Passcodes do not match."). Once complete, **Create my account** calls one
endpoint, `POST /api/auth/signup/` (`AllowAny`, `otp_request` throttle),
which branches server-side on whether `email` is present.

```json
// request — common fields, both branches
{
  "email": "jane@example.com",            // omit entirely (or "") to go the phone-OTP branch
  "phone": "254712345678",                // optional alongside email; required if email is absent
  "password": "123456",                   // the six-digit passcode
  "national_id_number": "12345678",       // the same id_number verified in Step 0 (or the passport number)
  "identity_verification_id": "uuid-from-step-0",
  "accepted_terms": true,                 // REQUIRED, must be true (2026-10-29)
  "country_of_residence": "KE",           // optional, default "KE"; see Step 1
  "county": "Nairobi",                    // these four: Kenya only, omit otherwise
  "sub_county": 1,
  "constituency": 1,
  "ward": 1,
  "invite_token": "optional-token-from-an-invite-link"   // only when the user came from /invite/<token> (Step 2b)
}
```

(Web also has a `subdomain` field it sends when signing up on a company
subdomain — an organization-buyer feature that is out of scope; the mobile
app never sends it.)

At least one of `email`/`phone` is required (`"Provide an email address or
phone number."`). `first_name`/`surname`/`gender`/`date_of_birth` are
**never** part of this payload — they're pulled server-side from the
`identity_verification_id` record from Step 0, not from anything the
client sends. `accepted_terms` is page 1's single combined consent
checkbox (the server records when terms were accepted); `false` or missing is a
`400`.

Other `400`s worth handling specifically: `email`/`phone` "An account with
this email/phone number already exists.", `password` "Enter a 6-digit
numeric passcode.", and `{"detail": "Identity verification expired or
not found. Please verify your ID again."}` — the 30-minute verification
window lapsed, or it was already used; web just shows the message, and the
only way forward is restarting signup from Step 0 (page 1 can't re-verify
in the same session, see above). Web shows field errors by taking the first message of the
first field in the body.

`invite_token` (web sends whatever token the user arrived with from
`/invite/<token>`, Step 2b) **does not skip any OTP** (2026-10-28). Server-side it only matters
when it is a self-pay company's join token, and then only marks the
account as a real paying user (`demo_restricted=False`); any other token is
ignored here. Every signup with an `invite_token` goes through Branch A or
B1 exactly like any other — the actual join happens afterwards, via the
redeem call in "After any successful signup".

### Branch A — email given

```json
// response 201
{ "detail": "Verification code sent to your email.", "email": "jane@example.com", "channel": "email", "next_step": "otp" }
```

A `phone` sent alongside the email is stored as an unverified contact
number — unless it's the exact number DHA's Client Registry returned in
Step 0, in which case it's marked verified immediately (the profile's
`phone_verified` is then `true`). No SMS is ever sent on this
branch.

Next: web toasts "Check your email for a verification code" and shows the
**Enter your code** screen ("We've sent a 6-digit code to <email>.", a
**Verification code** field, **Verify and continue**, enabled once 6 digits
are entered).
Call `POST /api/auth/signup/confirm/` with
`{"email": "...", "code": "123456"}`. On success (`200`) the response is
the full auth payload (see Step 3, Sign in) — store the tokens
and treat the user as logged in. **Resend code** calls
`POST /api/auth/signup/resend/` with `{"email": "..."}` (always returns
`200` `{"detail": "If a pending signup exists for that email, a new code
has been sent."}` regardless of whether the email exists, by design —
anti-enumeration). **Web enforces a 30-second cooldown between resend
taps** ("Resend code (Ns)"), started as soon as the code screen opens
(https://staging.mywellnesshealth.co.ke/auth) — replicate that client-side.
Note the server's own per-destination minimum is 60 seconds (see "OTP
mechanics" above), so a resend between 30s and 60s is acked but sends
nothing; the earlier code is still valid. **Use a different email**: see
"Starting again with a different email or number" below.

Confirm errors (`400`): the OTP messages above, or `{"detail": "No pending
signup for this email address."}` (no inactive account with that email —
already confirmed, or never created). The phone confirm's equivalent is
`"No pending signup for this phone number."`.

**Starting again with a different email or number ("Use a different
email" / "Use a different number").** By the time the code screen appears,
the server has created the inactive account and used up the Step 0
`identity_verification_id`. So going back means verifying the ID again:
- Clear the pending email/phone, keep any invite token the person arrived
  with, clear the used `identity_verification_id`, and return to page 1
  ("Verify my identity") with the typed ID details still filled in.
- Verifying the **same ID** again succeeds: an account that was never
  confirmed and never signed into doesn't hold the ID.
- Submitting sign-up with the new verification **replaces** that
  unconfirmed account, so the person can use a different email or phone,
  or the same one again.
- A confirmed account, or one that was ever signed into, still holds its ID
  (`account_exists`), and another person's unconfirmed sign-up still holds
  its email and phone ("An account with this email/phone number already
  exists.").

### Branch B — email absent (phone signup)

The response shape has **two distinct outcomes**, and the mobile client
must branch on which one came back — this is the single most important
piece of behavior to replicate exactly, since getting it wrong means
either sending a pointless OTP to a number DHA already verified, or
leaving a DHA-trusted user stuck on an OTP screen with no code ever
coming:

**B1 — ordinary phone signup** (any number DHA's Client Registry did not
return for this identity in Step 0 — including every self-pay invite
signup):

```json
// response 201
{ "detail": "Verification code sent to your phone.", "phone": "254712345678", "channel": "sms", "next_step": "otp" }
```

Show the same **Enter your code** screen as Branch A (toast "Check your
phone for a verification code"; **Use a different number** instead of "Use
a different email"). Confirm via
`POST /api/auth/signup/phone/confirm/` with `{"phone": "...", "code": "123456"}`
→ `200` with the full auth payload. **Resend code** calls
`POST /api/auth/signup/phone/resend/` with `{"phone": "..."}` (same
always-ack-success convention, same 30s client-side cooldown to apply).

**B2 — DHA-trusted phone (skip-OTP)** — response has **no `channel` key at
all**:

```json
// response 201 — tokens issued immediately, no OTP step of any kind
{
  "access": "...", "refresh": "...",
  "user": { "id": "...", "email": null, "phone": "254712345678", "first_name": "Jane", "surname": "Wanjiru",
            "is_clinician": false, "health_profile_completed": false, "member_code": "..." },
  "pending_subdomain_claim": null,
  "shr_linkage_pending": true,
  "next_step": "signed_in"
}
```

Every signup `201` carries `next_step`: `"otp"` (Branch A or B1 — show the code screen for `channel`) or `"signed_in"` (this B2 shape). Web tells them apart by whether `channel` is present; either check gives the same answer. For this B2 shape, store tokens immediately: the account is
already fully active (and `phone_verified` is already true) — **never show
an OTP-entry screen for this response shape**. Web shows a "Welcome!"
toast and then the "Link your health records" step when
`shr_linkage_pending` is true (since the 2026-10-28 self-pay correction,
B2 only ever happens for the DHA-trusted phone, so it always is).

Why this exists at all: if AfyaConnect's Client Registry already verified
this exact phone number for this identity (Step 0's
`from_afyaconnect`/`phone`), sending our own OTP to a number DHA already
vouched for would be redundant and was a real, confirmed source of bugs
earlier in this project (sending our own SMS competing with DHA's). The
backend re-derives this trust independently at signup time from Step 0's
identity record, never trusting a flag the client echoes
back — the client has no way to request or suppress this behavior; it's
entirely server-decided based on Step 0's identity record.

### After any successful signup (A, B1 or B2) — web's post-signup sequence

1. **"Link your health records" step** — web toasts "Welcome!" and shows
   this after the Branch A/B1 confirm call and after a B2 response with `shr_linkage_pending`
   true. The backend
   has already queued DHA's own SHR-consent OTP in the background. See
   [`health-records-and-shr.md`](./health-records-and-shr.md) for what
   that screen does. It's optional: decline/skip/timeout changes nothing
   about account access. If DHA has no phone for the patient, no code is
   sent and the screen says why (`dha_phone_missing`).
2. **If the user arrived from an invite link** (Step 2b), web
   fire-and-forgets `POST /api/invite-codes/<token>/redeem/` right after
   tokens are issued (before step 1's screen). A failure only shows a
   toast ("We couldn't automatically apply your invite — you can try the
   link again from your email."); it never blocks signup. The pending
   token is then discarded either way.
3. **Redirect:** the dashboard. (Web's code still has a branch to package
   checkout for a package picked on the public homepage's pricing section,
   but that section is switched off, so it never runs — don't build it.)
   The redeem never changes this: a self-pay joiner (`self_pay: true`) is
   processed exactly like any other user, only attached to the
   organization. (`pending_subdomain_claim` in the auth payload drives a
   web-only company-setup redirect for organization buyers — out of scope;
   the mobile app ignores that field.)

Sign in and two-factor verification skip step 1 (no "Link your health
records" step) but run steps 2 and 3 the same way.

## Step 2b — Joining an organization from an invite link (`/invite/<token>`)

An organization shares a link `https://<web host>/invite/<token>` (web's
"Private invite" page, `https://staging.mywellnesshealth.co.ke/invite/<token>`). Two kinds of token
share it, told apart by `self_pay`:

- **Self-pay join link** (`self_pay: true`) — the user is only attached to
  the organization; everything else (payment included) works exactly as
  for any other user.
- **Covered-seats invite** (`self_pay: false`) — the organization has paid
  for specific assessment categories for a limited number of people.

**Preview** — `GET /api/invite-codes/<token>/` (`AllowAny`, send **no**
`Authorization` header — the view has no authentication classes):

```json
// 200
{ "organization": "Acme Ltd", "categories": [], "seats_total": null, "seats_remaining": null, "claimable": true, "self_pay": true }
{ "organization": "Acme Ltd", "categories": ["Cancer", "Mental health"], "seats_total": 50, "seats_remaining": 12, "claimable": true, "self_pay": false }
// 404 — body is {"error": {"detail": "Invite code not found."}}
```

`claimable` is decided by the backend: `true` for a self-pay join link,
otherwise `true` while seats remain. Show the invite and its claim button
only when `claimable` is `true`; when it's `false`, show the "fully
claimed" screen below. Don't work it out from `seats_remaining`.

Web's screens (copy to mirror):

- `404` → **Link not found** ("We couldn't find an invite for this link. It
  may have been mistyped.") with **Visit My Wellness Health**.
- `claimable: false` → **This invite has already
  been fully claimed** ("Please contact your organization or group admin if
  you believe this is a mistake.").
- Otherwise "You're invited" and either **Join {organization} on My
  Wellness Health** ("Join to be counted as part of your organization.
  Everything else works exactly as it does for any member.") or
  **{organization} has covered your wellness check-up** ("Claim this invite
  to unlock the assessments below at no cost to you — N of M spots
  remaining." plus one chip per `categories` entry).
- **Signed out:** **Create an account** / **I already have an account**.
  Both remember the token on the device and open signup / sign in; the
  token is sent as `invite_token` on signup (Step 2) and redeemed after
  any successful signup, sign-in or two-factor verification ("After any
  successful signup", step 2).
- **Signed in:** one button, **Join organization** (self-pay) or **Claim
  access** (covered seats), reading **Joining…** while the call runs,
  calling the redeem endpoint directly.

**Redeem** — `POST /api/invite-codes/<token>/redeem/` (authenticated, no
body):

```json
{ "redeemed_at": "2026-11-03T09:00:00Z", "granted_categories": [], "self_pay": true }
```

- `self_pay: true` → toast "You've joined {organization}." and go to the
  dashboard.
- `self_pay: false` → toast "Access claimed — check your dashboard." and
  show "Access granted. Head to your dashboard to get started." (web also
  links **Corporate Workplace Wellbeing check-in** under "Also unlocked"
  when `granted_categories` includes `"Workplace wellbeing"`).
- Redeeming the same covered-seats invite twice as the same user is a
  harmless no-op (no second seat used). `400`s:
  `{"detail": "This invite code has no seats remaining."}` or
  `{"detail": "Invite code not found."}` — show the message.

Footer copy: self-pay — "This link only tags you as part of your
organization — you use My Wellness Health like any other member, and what
you do stays private to you."; covered seats — "This link works once per
person and unlocks only the assessments listed above — any other
assessment you take is billed separately and stays private to you."

## Step 3 — "Sign in" ("Welcome back")

`POST /api/auth/login/` (`AllowAny`; no scoped throttle, only the global
`anon` 60/min)

```json
{ "identifier": "jane@example.com", "password": "123456" }
```

Web's screen ("Secure account access", **Welcome back**, "Sign in to
continue your wellness journey.") has **Phone number or email address**
(`identifier`, trimmed) and **Passcode** (`password`, with a show/hide eye
toggle), a **Forgot passcode?** link (Step 5) and a **Sign in** button;
under "New to My Wellness Health?", **Create an account** switches to
signup (and signup's "Already have an account? **Sign in**" switches back).
`identifier` is either an email or a phone number (any of the accepted
input formats — see the README's phone-number section); the backend
decides by whether it contains `@`. A phone abroad must be written with its
country code (`"+44 7911 123456"` or `"0044 7911 123456"`), or exactly as
it's stored (digits with the country code, no plus: `"447911123456"`); a
Kenyan number works in any local form. On success web toasts "Welcome back!".
A fresh sign-in (or two-factor verification) always starts in the person's
own account: stop sending any `X-Acting-For` header and clear data cached
for another account (see [`next-of-kin.md`](./next-of-kin.md)).

**Four possible outcomes:**

1. **Success, no two-factor** — `200` with the full auth payload (same
   shape as signup confirmation, see "Auth payload" below). Store tokens,
   done.
2. **Success, two-factor enabled** — `200` with
   `{"mfa_required": true, "mfa_token": "..."}`. No tokens yet. Go to
   Step 3a (Two-factor verification) immediately — `mfa_token` lives
   **5 minutes** (300 seconds).
3. **Credentials correct but account still pending confirmation** — `400`
   with `error.detail` =
   `{"detail": "Please confirm your email before logging in. We've sent a new code.", "code": "email_not_confirmed", "email": "jane@example.com"}`
   or
   `{"detail": "Please verify your phone number before logging in. We've sent a new code.", "code": "phone_not_verified", "phone": "254712345678"}`.
   **The backend has already sent a fresh code as a side effect of this
   exact call** (the per-destination send limit silently respected) — on this specific
   error code, show its `detail` as a toast, route straight to the
   matching **Enter your code** screen (Step 2's Branch A/B1 confirm
   screens) and start the 30s resend cooldown, rather than showing a
   generic sign-in error, exactly like web does. Confirming there runs the
   full post-signup sequence, "Link your health records" step included. **Use the `email`/`phone` from the error body, not the identifier
   the user typed** — the email gate fires even when the user signed in
   with their phone number.
4. **Wrong credentials** — `400` `{"detail": "Invalid credentials."}`, no
   code. Also: `{"detail": "Too many failed sign-in attempts. Try again in
   a few minutes.", "code": "account_locked"}` after **5** failures against
   the same identifier within **15 minutes** (the window
   is anchored to the first failure). Checked *before* password hashing
   runs, and it never reveals whether the account exists — show the
   message, don't retry automatically.

**Auth payload** shape, returned by every endpoint in this file that issues
real tokens (`signup/confirm/`, `signup/phone/confirm/`, a B2 signup,
login, MFA-verify):

```json
{
  "access": "...",
  "refresh": "...",
  "user": {
    "id": "uuid", "email": "jane@example.com", "phone": "254712345678",
    "first_name": "Jane", "surname": "Wanjiru",
    "is_clinician": false, "health_profile_completed": true,
    "member_code": "MWH-..."
  },
  "pending_subdomain_claim": null
}
```

Web only keeps the tokens from this; it reads profile data from
`GET /api/health-profile/` instead. `is_clinician` and
`pending_subdomain_claim` serve web-only clinician/organization-buyer
features — ignore them.

### Step 3a — "Two-factor verification"

`POST /api/auth/mfa/verify/` (`AllowAny` — no JWT exists yet; the
`mfa_token` itself is the proof step one passed; `mfa_verify` throttle,
**10/min** per IP)

```json
{ "mfa_token": "from-login-response", "code": "123456" }
// or, to use a backup code instead:
{ "mfa_token": "from-login-response", "backup_code": "3f9a1c07be" }
```

Web's screen: **Two-factor verification**, "Enter the 6-digit code from
your authenticator app." with an **Authenticator code** field and
**Verify and continue**; a **Use a backup code** / **Use authenticator
code** toggle swaps in a **Backup code** field ("Enter one of your unused
backup codes."; an empty one shows "Enter a backup code."); **Back to sign
in** discards the `mfa_token`. Send exactly
one of `code` (the authenticator's 6 digits) or `backup_code`. Backup
codes are 10 lowercase hex characters, compared exactly after trimming
whitespace — don't upper-case or reformat them — and each works once.

`200` → full auth payload. `400` `{"detail": "Incorrect code."}` on a
wrong code — the `mfa_token` is still valid for retrying until it
expires. `400` `{"detail": "This verification step has expired. Please log
in again."}` once it's past 5 minutes — only then go back to sign in.
Their `code`s are `mfa_incorrect_code` and `mfa_expired`. Sending neither
`code` nor `backup_code` is a `400` `{"non_field_errors": ["Provide either a
code or a backup code."]}` (web never sends that: its **Verify and continue**
stays disabled until 6 digits are entered, and an empty backup code shows
"Enter a backup code." without calling the API).

### "Two-step verification" (Account settings → Security)

Account settings → Security
(https://staging.mywellnesshealth.co.ke/account?tab=security) has a
**Two-step verification** section. It is optional for every regular
account. (The backend's `mfa_enrollment_required` error, which web answers
by redirecting to this step, only fires for staff/clinician actions — not
part of the patient app.)

- `GET /api/auth/mfa/status/` → `{"enabled": true|false}` drives one
  switch, **Enable additional sign-in protection** ("Adds a 6-digit code
  from an authenticator app to your sign-in, on top of your password."),
  shown on while `enabled` is true or an enrollment is in progress.
- **Turning the switch on** → `POST /api/auth/mfa/enroll/` →
  `{"secret": "...", "otpauth_url": "..."}` — render `otpauth_url` as a QR
  code client-side, next to "Scan this with your authenticator app (e.g.
  Google Authenticator, Authy). Can't scan it? Enter this code:
  **<secret>**". Re-calling it replaces any unconfirmed secret; `400` "MFA
  is already enabled -- disable it first to re-enroll." once enabled.
  **Cancel** (or switching it back off before confirming) just drops the
  unconfirmed enrollment client-side. Failure toast: the error message, or
  "Could not start two-step verification".
- **Enter the 6-digit code to confirm** (six single-digit boxes) →
  **Confirm & turn on** (reads **Confirming…** while busy, enabled once 6
  digits are in) → `POST /api/auth/mfa/confirm/` with `{"code": "123456"}`
  (the first code from the authenticator app) → `{"backup_codes": ["...",
  ...]}` (10 codes); toast "Two-step verification is on". `400`
  "Incorrect code." or "No MFA enrollment in progress -- start enrollment
  first.". **Show these backup codes to the user exactly once** (web:
  "**Save these backup codes somewhere safe.** Each can be used once if you
  lose your authenticator app. They won't be shown again." + **I've saved
  these codes**; the switch is disabled until that's tapped) — there's no
  way to retrieve them again except regenerating a fresh set.
- While enabled, a **Regenerate backup codes** button sits under the
  switch. Turning the switch **off** or tapping **Regenerate backup codes**
  first asks for the current password ("Enter your password to turn
  two-step verification off" / "Enter your password to regenerate backup
  codes", **Confirm** / **Cancel**) even though the session is already
  authenticated.
- **Off** → `POST /api/auth/mfa/disable/` with `{"password": "..."}` →
  `{"detail": "MFA disabled."}`; toast "Two-step verification is off".
  `400` "Incorrect password." otherwise.
- **Regenerate backup codes** →
  `POST /api/auth/mfa/regenerate-backup-codes/` with `{"password": "..."}`
  → fresh `{"backup_codes": [...]}` (shown the same show-once way; toast
  "New backup codes generated"), invalidating the old set.

None of these revoke any session/refresh token.

## Step 4 — Sign out / token refresh

**Don't attach `Authorization: Bearer …` to `token/refresh/`, `logout/`,
`login/` or any signup/confirm call.** They're `AllowAny`, but DRF still
runs `JWTAuthentication` on any request carrying that header, so an
expired access token in it turns the call into a `401` before the view
ever runs.

- `POST /api/auth/token/refresh/` with `{"refresh": "..."}` → new
  `{"access": "...", "refresh": "..."}` pair. The old refresh token is
  blacklisted the moment this succeeds — never reuse it, always store the
  new one returned here. An invalid, expired or blacklisted refresh token
  is a **`400`** (not `401`) with `error.detail` = `{"refresh": "<simplejwt
  message>"}` (e.g. `"Token is invalid"`, `"Token is blacklisted"`; a
  missing field is `{"refresh": "This field is required."}`) — that means
  "signed out, go to sign in". A network failure, `5xx` or `429` is
  transient: keep the stored tokens and retry later rather than signing
  the user out.
- Sign out: `POST /api/auth/logout/` with `{"refresh": "..."}` →
  `{"detail": "Logged out."}`, blacklisting just that one token. `AllowAny`
  and idempotent (signing out twice, or with an already-expired token, is
  not an error); omitting `refresh` is a `400`. Web clears its local
  session whether or not this call succeeds.
- **Sign out everywhere** (Account settings → Danger zone → "Sign out of
  other devices") and **Change password** (Account settings → Security):
  both blacklist every outstanding refresh token for the account, **this device's included**, and web then signs this device
  out immediately (the logout call above + clearing local tokens) and
  returns to sign in. Endpoints, labels and toasts are in
  [`account-and-profile.md`](./account-and-profile.md) §7 and §8. Be ready for
  the current session to die with no warning when the user does either of
  these (or resets their passcode, or schedules account deletion) from
  another device: that device's access token keeps working until it
  expires (≤30 minutes), then its refresh gets the `400` above.

## Step 5 — "Reset your passcode" (Forgot passcode?)

Entirely OTP-based — there is no clickable reset link anywhere in this
flow (web's old `/reset-password` URL just redirects to
`/forgot-password`).

`POST /api/auth/password-reset/request/` (`AllowAny`, `otp_request`
throttle)

```json
{ "identifier": "jane@example.com", "channel": "sms" }
```

`identifier` is web's **Registered phone or email** field. `channel` is
web's optional "Where should we send your verification code?" choice —
**SMS to registered phone** (`"sms"`) or **Registered email** (`"email"`);
leave it out when nothing is picked ("Leave unselected to use whichever
you typed above."). When given, it sends the code to the user's *own*
registered contact of that type regardless of which `identifier` they
typed. If the account has no contact of the requested type, nothing is
sent.

**Phones abroad.** SMS reaches Kenyan numbers only. A phone abroad, written
with its country code (`"+44 7911 123456"` or `"0044…"`), still identifies
the account, but its code goes to the account's **email**; `channel:
"sms"` for an account whose phone is abroad also goes to its email. If
that account has no email, nothing is sent. Confirm with the same
identifier the user typed (below).

Always returns `200` `{"detail": "If that account exists, a reset
code has been sent."}` regardless of whether the identifier matched a real
account (anti-enumeration) — never branch client-side on this response to
infer whether an account exists.

`POST /api/auth/password-reset/confirm/`

```json
{ "identifier": "jane@example.com", "code": "123456", "new_password": "654321" }
```

**Cross-channel resets work** (fixed 2026-10-30): confirm with the
identifier exactly as the user typed it, even when they chose the other
channel (typed their email, chose SMS), or typed a phone abroad whose code
went to their email. The server finds the newest
pending reset code across that one account's own email and phone. `200`
`{"detail": "Password updated successfully."}` on success; no tokens are
issued. **Every outstanding refresh token for this user is blacklisted as
a side effect** — if the client is mid-session on this same account
somewhere else, that other session dies at its next refresh.
`new_password` must match the 6-digit passcode pattern, same validation as
signup. Errors: the OTP messages above, or
`{"detail": "Invalid reset request."}`.

**Web's screen flow (https://staging.mywellnesshealth.co.ke/forgot-password)**: **Reset your
passcode** ("Confirm your registered contact details to choose a new
six-digit passcode."), a 3-step indicator, then — (1) **Find your
account** ("Use your verified phone number or email"): identifier +
channel choice → **Send verification code** (the request call; toast
"Code sent! Check your inbox or phone."); (2) **Verify your contact** ("We
sent a 6-digit code to <identifier>."): enter the 6-digit **Verification
code** → **Verify and continue**, held client-side only (there is no
verify-only endpoint; **Didn't get a code? Send again** goes back to step
1); (3) **Create a new passcode** ("Enter and confirm six digits"): **New
six-digit passcode** + **Confirm new passcode** → **Reset my passcode**
(the single confirm call; a mismatch shows "Passwords do not match"). A
wrong/expired code only surfaces on step 3, and web offers **‹ Back to
code** to re-enter it. Steps 2–3 also show **‹ Start over** (back to step
1), and every step has **‹ Back to sign in**. Done screen ("Passcode
recovery complete"): **Passcode reset successful**, "Your new six-digit
passcode has replaced the old one.", **Return to sign in**.

### "Change password" (Account settings → Security, not a reset)

`POST /api/auth/change-password/` with `{"new_password": "..."}` →
`{"detail": "Password changed."}`. No current-password re-entry required;
validated only by `AUTH_PASSWORD_VALIDATORS` (min 6 characters, not too
similar to the user's own details) — **not** the 6-digit pattern. It
revokes every refresh token, this device's included, so web signs this
device out right after it succeeds. Full dialog labels, client-side checks
and toasts: [`account-and-profile.md`](./account-and-profile.md) §7.

## Step 6 — Health-profile questions (no onboarding gate)

`GET`/`PATCH /api/health-profile/` (authenticated) — full field list and
the `?raw=1` rule are in [`account-and-profile.md`](./account-and-profile.md) §1.

Web does **not** route anyone into an onboarding wizard after
sign-in/signup. The only remaining profile question is gender: a
**"Gender"** dropdown (Female / Male) on the Blood Pressure / Blood Sugar
"Why are you monitoring?" set-up step, shown only when `profile.gender` is
blank (a legacy pre-ID-verification account) and saved with
`PATCH /api/health-profile/ { "gender" }` — see
[`vitals-medications-appointments.md`](./vitals-medications-appointments.md).
Mirror the per-field check (ask only when it's blank), not a single "done"
flag.

---

Last verified against the code on 2026-11-11.