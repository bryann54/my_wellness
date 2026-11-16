# Mobile (Flutter) API Integration Guide

<!-- guide-header:start -->
> **Guide set `2026-11-16.b9b79a`.** Every file in this guide carries this same line.
>
> **The other files in this guide:** `account-and-profile.md`, `annual-wellness-plan.md`, `assessments.md`, `auth-and-signup.md`, `bookings-and-consultations.md`, `health-records-and-shr.md`, `next-of-kin.md`, `payments-and-packages.md`, `push-notifications.md`, `reference-sexual-health-v15.md`, `vitals-medications-appointments.md`
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

**Who this is for:** an engineer or AI coding agent building the Flutter
mobile app for My Wellness Health, who needs to consume the exact same DRF
backend (`backend/CORE`) the web app (https://staging.mywellnesshealth.co.ke/) already
consumes. The app only consumes the API, as the website does. The API decides every
business rule, and the app sends requests and shows what comes back: never calculate
a price, score, band, date or eligibility in the app. This guide gives the endpoint,
payload, response and error codes, plus when to call and any polling or cooldown
timing.

If a page here still tells the app to work out a rule, it hasn't been updated yet.
Raise it with the backend team rather than building the rule into the app.

The one exception is offline assessments, where the app applies downloaded skip rules
until it reconnects. It covers every assessment (see [`assessments.md`](./assessments.md),
"Offline assessments").

**Ground truth, in priority order, whenever this guide and the running
code disagree:**
1. What the running API actually returns (the staging backend), plus its generated OpenAPI schema at `/api/schema/` for field types.
2. The live web app on staging, https://staging.mywellnesshealth.co.ke/ — the reference for screen wording and layout. Sign in with a test account and open the page a section links to. It is not a source of business rules. The web app's source code isn't available to the mobile team, so every "how web does it" pointer in this guide is a staging link, never a code path.
3. `docs/system-workflow.md` (this repo) — broad architecture narrative, useful for orientation, written for human engineers, not sequencing-precise.
4. `docs/api-request-samples.json` (this repo) — real sample request bodies per endpoint, cross-checked against serializers, but a flat endpoint list, not a sequencing guide, and **known to be stale** on anything newer (it predates the SHR/health-exchange endpoints and some newer package/consultation-lead additions).

**Scope:** the mobile app implements exactly the regular end-user
(patient) features of the web app, nothing more and nothing less. This
guide documents only what a signed-in patient can reach from web's real
UI: the sidebar, the dashboard, **Account
settings**, and the flows reachable from them, plus the few public
token pages a patient is sent to (`/invite/<token>`, `/p/<token>`,
`/visit-checklist/<token>`, `/visits/<id>/follow-up`). The names used
here are the labels web shows (sidebar titles like "Plans & Pricing",
"My Medical History", "My Annual Checkup"; button text; section titles),
alongside the exact endpoint paths and JSON field names.

Deliberately left out:
- **Other roles**: doctor/clinician, nurse, admin, county portal
  (`/api/admin/`, `/api/external-admin/`, `/api/portal/`, everything in
  `/api/clinical/` except My Medical History).
- **Organization-buyer features**: the Organization / Institution /
  Group checkup purchases (withdrawn 2026-11-14 with the individual
  check-up booking; the sidebar's **My Annual Checkup** at `/checkup` is now the annual
  wellness plan, see [`annual-wellness-plan.md`](./annual-wellness-plan.md))
  and paying their invoices, the
  **Organization Admin** sidebar section (purchased packages, join
  links, invite by email, members, reports), company-subdomain setup
  and claiming (`/company-admin/buy`), `/api/companies/`, and the org
  parts of `/api/invite-codes/`. *Joining* an organization from an
  invite link **is** in scope (see
  [`auth-and-signup.md`](./auth-and-signup.md) Step 2b).
- **Anything web hides**: routes nothing links to (e.g. `/dna-testing`),
  commented-out or `{false && ...}` UI (the homepage consultation form
  and pricing, the chat widget, the PWA install dialog, the AI
  medication photo scan), and backend endpoints the web app never calls.
  Features behind a web build switch that is off by default
  (manual ID entry for everyone, location facility recommendations) are documented only as off-by-default and gated.
  Manual entry for passports and after a failed ID lookup is always on.
- **The public marketing site** (home page, Resource Hub `/resources`
  via `/api/resources/`, blog `/blog` via `/api/blog/`, testimonials via `/api/reviews/`, terms): it's
  the public website, not the signed-in app, and no in-app page links
  to it.
- Anything mobile-only. If web doesn't do it, mobile doesn't either.

This guide is a snapshot. The backend moves fast (see any domain file's own
"last verified against" note). If something here disagrees with what the
API actually returns, the API wins: build against the real response and
tell the backend team so this guide gets fixed.

## Files in this guide

| File | Covers |
|---|---|
| [`auth-and-signup.md`](./auth-and-signup.md) | The sign-in/sign-up screen (`/auth`): identity verification, email and phone signup + confirmation, shared OTP limits, joining an organization from an invite link (`/invite/<token>`: preview, sign up / sign in, redeem; the button reads "Join organization" for a self-pay invite and "Claim access" for a paid-seat one), login, MFA, logout, token refresh, "Forgot passcode?" / reset. |
| [`account-and-profile.md`](./account-and-profile.md) | **Account settings** (`/account`) and its General / Security / Notifications / Next of kin / Privacy & data / Danger zone tabs (only General while using someone else's account as their next of kin): profile, location (geography), identity, SHA coverage and AfyaConnect sync cards, contact verification, password change and log out of all devices, data export, account deletion. |
| [`next-of-kin.md`](./next-of-kin.md) | **Account settings → Next of kin**: adding someone, the split code, accepting an invitation (`/next-of-kin/accept/<token>`), using another person's account (the `X-Acting-For` header), and what stays with the holder. |
| [`assessments.md`](./assessments.md) | **Assessments & Screenings** (and the Ebola, Women's Health, Cancer Awareness & Screening and Sexual & Urinary Health entry points): browsing, starting/resuming, the one-assessment-at-a-time rule, the question-answer loop, payment gating, results, PDF reports, health checks & follow-up. |
| [`payments-and-packages.md`](./payments-and-packages.md) | **Plans & Pricing**, the wellness packages / "My Custom Wellness Package" builder, M-Pesa STK push + settlement, choosing how to pay (`options/`: M-Pesa, card checkout, or a bank transfer with its own reference, confirmed by the bank), the manual payment fallback (pay by hand to a paybill or bank account, paste the confirmation message, staff approve it), the Endometriosis donation and "Apply for endometriosis subsidy" flow, `demo_restricted` accounts, **Billing** (Payments, Invoices, Receipts). |
| [`bookings-and-consultations.md`](./bookings-and-consultations.md) | The bookable services (the individual check-up booking was withdrawn 2026-11-14), facility selection and the "Find a health facility" dialog, viewing bookings, care-navigation referrals. My Health Journey is no longer on web. |
| [`health-records-and-shr.md`](./health-records-and-shr.md) | **My Medical History**: DHA Shared Health Record consent (OTP), requesting a fresh consent after expiry, syncing/fetching records, what shows up on the page and why, the post-visit "Did you make it to your appointment?" page (`/visits/<id>/follow-up`). |
| [`reference-sexual-health-v15.md`](./reference-sexual-health-v15.md) | Generated reference: the Sexual & Urinary Health V15 question bank and flow rules the app must port. |
| [`annual-wellness-plan.md`](./annual-wellness-plan.md) | **My Annual Checkup**: the annual wellness plan of suggested tests, built from the user's assessments and monitoring, its Mental Health / Sexual Health opt-ins and its PDF. |
| [`vitals-medications-appointments.md`](./vitals-medications-appointments.md) | **Vitals & Chronic Care** (Blood Pressure, Blood Sugar) including the vitals paywall, **Medications**, **Appointments**, the Women's Health Period & Pain Tracker. |
| [`push-notifications.md`](./push-notifications.md) | OneSignal (the native-app channel) vs. web push (reference only), the dashboard's **Enable reminders** button, **Account settings → Notifications**, every reminder/notification a patient can receive and what opens on tap, the doctor-visit checklist follow-up page (`/visit-checklist/<token>`), and **"Notify a partner anonymously"**. |

## Keeping the app in step with the website and WhatsApp

The app, the website (https://staging.mywellnesshealth.co.ke/) and the WhatsApp bot must
show the same features, wording and rules. A build made from part of this guide, or from an
older copy, drifts, so every file opens with a **guide-set line** and a list of **related
files**.

**For the AI agent, at the start of every task:**
1. Ask the developer for this README and the file(s) for the screens you're working on, if you
   don't have them.
2. Read the header at the top of each file. Ask the developer for every related file it lists
   that you don't have, naming them. If you can reach the backend, fetch them instead:
   `GET /api/mobile-guide/` lists every file with its `version` and `related` files.
3. Check that every file you hold shows the same guide-set line. If one differs, it's out of
   date: ask for the current copies before building anything.
4. Compare what the app already shows with the guide. Remove or update anything the guide
   no longer describes (a withdrawn feature, old wording, a removed card, a moved step), and
   list for the developer what you changed and anything you couldn't confirm.

Don't fill a gap from memory or an older copy. If the guide and the website disagree, the
website on staging wins: raise it with the backend team.

**For anyone editing this guide:** after changing any file, run
`python manage.py mobile_guide_headers` in `backend/CORE`. It updates the related-files lists
and gives the whole set a new guide-set line; a test fails until it has been run.



Site-wide since 2026-11-03; the domain files describe screens assuming these.

- **One typeface:** Poppins everywhere (the sidebar's font). No screen
  uses its own typeface any more.
- **Flat surfaces:** cards, tiles, buttons and inputs are separated by a
  1px border, never a drop shadow, glow or coloured accent stripe; cards
  don't lift on hover. Only floating layers (menus, dropdowns, popovers,
  sheets, the chat widget) cast a shadow.
- **Back navigation:** every page-level back control is the same outline
  pill, an arrow plus **"Back"**, top-left above the page heading. In-form
  "Back" step buttons sit beside "Continue" as outline buttons.
- **Dropdowns:** short lists open a menu of options; long lists (counties,
  sub-counties, constituencies, wards, years) open a searchable list that
  matches names containing the typed text. No native platform select.
- **Focus:** an input shows focus by its border colour only, one ring,
  no extra glow or outline.

## The envelope: shared conventions every domain file assumes

### Base URL and routing

The Django backend mounts every feature under `/api/...`. Top-level
prefixes (`CORE/urls.py`) the patient app uses, so you know where every
domain file's endpoints actually live:

```
/api/auth/              apps.accounts      -- ID verification, signup, login, MFA, token refresh/logout, password reset, contact verification, privacy toggles, data export, account deletion
/api/health-profile/    apps.accounts      -- the profile GET/PATCH (see account-and-profile.md §1)
/api/geography/         apps.geography     -- county/sub-county/constituency/ward lookups
/api/formulary/         apps.formulary     -- medication/generic-product search (the Medications form's pickers)
/api/                   apps.assessments   -- assessment/session/question/report endpoints, dependants, health checks, plus GET /api/dashboard/ (no extra prefix)
/api/                   apps.vitals        -- vitals (BP/BS), the vitals report, period & pain tracker, medications, insulin products, appointments (no extra prefix)
/api/payments/          apps.payments      -- service catalog, packages, custom pricing, STK push, card and bank payments (options/; card/webhook/ and bank/<provider>/notification/ are server-to-server), the manual payment fallback (manual-settings/, mine/<id>/manual-proof/), module access, payment history, Endometriosis donation/subsidy
/api/                   apps.bookings      -- service bookings, facilities, invoices, receipts, the doctor-visit checklist follow-up (checklist-response/<token>/) (no extra prefix)
/api/care-navigation/   apps.care_navigation -- referrals + facility suggestions after a result/reading, and the My Health Journey timeline (no longer shown on web)
/api/invite-codes/      apps.invite_codes  -- ONLY GET <token>/ (preview) and POST <token>/redeem/, for joining an organization from /invite/<token>
/api/clinical/          apps.clinical      -- ONLY GET /api/clinical/my-medical-history/ (the My Medical History page)
/api/push/              apps.notifications -- ⚠️ notification preferences, web push and partner notifications live HERE, under /push/, NOT under /api/notifications/ (see push-notifications.md)
/api/health-exchange/   apps.health_exchange -- DHA/SHR consent and visits, medical records sync, SHA eligibility, AfyaConnect re-sync
/api/next-of-kin/       apps.next_of_kin   -- next of kin: invitations, accepting, using another person's account (see next-of-kin.md)
/api/wellness-plan/     apps.wellness_plan -- My Annual Checkup: the annual wellness plan, its opt-ins and PDF (see annual-wellness-plan.md)
/api/mobile-guide/      apps.common        -- serves THIS guide itself over HTTP (see below) -- fetch it live instead of needing a checkout of this repo
/api/schema/            drf_spectacular    -- generated OpenAPI schema (/api/docs/ Swagger UI, /api/redoc/) -- useful for field types, but it doesn't capture sequencing
```

Every other prefix in `CORE/urls.py` is out of scope for the patient app:
`/api/companies/` and the rest of `/api/invite-codes/` (organization
buyer), `/api/admin/`, `/api/external-admin/`, `/api/portal/` (staff and
county portal), `/api/chatbot/` (the chat widget web hides),
`/api/resources/`, `/api/blog/` and `/api/reviews/` (public marketing site),
`/api/otp/` and `/api/whatsapp/` (not called by web).

### Fetching this guide itself, over HTTP

This whole guide is also served live by the running backend, gated by the
`X-Mobile-Client-Secret` header (see
"The mobile client secret" section below for where to get the real value).
No `IsAuthenticated` requirement here -- there's no per-user data in a
documentation file, so this works even before any real user is signed in.

```
GET /api/mobile-guide/                 -- [{"filename": "README.md", "title": "..."}, ...]  (sorted by filename; title = the file's first "# " heading)
GET /api/mobile-guide/<filename>/      -- that one file's raw markdown (Content-Type: text/markdown; charset=utf-8), NOT the JSON envelope
```

An unknown or malformed filename is a `404` ("No such guide file.").
Called without a bearer token, a missing/wrong secret comes back as
`401` ("Authentication credentials were not provided."), not `403`,
because DRF reports a failed permission on an anonymous request as
not-authenticated. Called *with* a valid bearer token it's `403`. Either
way the body is the usual error envelope.

A path like `<uuid:session_id>` in a domain file means: substitute a real
id you got from a prior response. Angle brackets are never sent literally.

### Authentication

JWT via `rest_framework_simplejwt`:

- Every authenticated request sends `Authorization: Bearer <access_token>`.
  `IsAuthenticated` is the project-wide default permission
  (`REST_FRAMEWORK["DEFAULT_PERMISSION_CLASSES"]`), so any endpoint a domain
  file doesn't explicitly call `AllowAny` needs it.
- **Every request** from the app, signed in or not and to any endpoint, also
  sends `X-Mobile-Client-Secret: <the app's build credential>` (see "The
  mobile client secret" below). Besides opening the guide endpoints, it is how
  the server knows a request came from the app. For example, next of kin
  activity is logged with `channel: "app"` only when it's present.
- Access tokens last **30 minutes**; refresh tokens last **14 days**, with
  rotation + blacklist-on-rotation (a used refresh token can never be
  reused). `POST /api/auth/token/refresh/` exchanges a refresh token for a
  fresh pair.
- An expired/invalid access token is a `401` (its `error.detail.code` is
  `"token_not_valid"`). Web
  reacts to **any** `401` with exactly one silent refresh + retry per
  request, and de-duplicates concurrent refreshes. A *refresh* that's
  rejected comes back as a `400` with a `refresh` key, not a `401` — treat
  that as signed out; treat network errors/`5xx`/`429` on refresh as
  transient and keep the tokens. That's exactly what web's refresh route does: it signs out on a `400` or
  `401` and keeps the session on anything else. Details in
  [`auth-and-signup.md`](./auth-and-signup.md) Step 4.
- **Don't send the `Authorization` header to the `AllowAny` auth endpoints**
  (`login/`, `token/refresh/`, `logout/`, signup/confirm/resend,
  `password-reset/*`, `mfa/verify/`, and `verify-id/` *during signup*).
  DRF still runs `JWTAuthentication` whenever the header is present, so a
  stale access token turns those calls into a `401 token_not_valid` before
  the view runs — including the refresh call you're making *because* the
  token expired. The one deliberate exception is `verify-id/` from Account
  Settings (account-and-profile.md §3): send a fresh token there, because
  the server uses it to exclude the user's own account from the "ID
  already in use" check.
- `POST /api/auth/logout/` blacklists the given refresh token immediately.
- A password reset, a password change, "log out of all devices", or
  scheduling account deletion blacklists **every** outstanding refresh
  token for that user — including the current device's (its access token
  keeps working until it expires, ≤30 min). Mobile must be ready to be
  logged out server-side with no warning after one of those events, same
  as web. Enabling/disabling MFA does **not** revoke anything.
- **Using someone else's account (next of kin):** while a signed-in user
  is using an account they are next of kin for, every request also sends
  `X-Acting-For: <grant id>` next to their own normal bearer token, and
  the API then answers as the account holder. Only some endpoints are
  allowed in that state; the rest return `403` with
  `code: "next_of_kin_not_allowed"`, and a grant that has ended returns
  `403` with `code: "next_of_kin_access_ended"`. Full rules and screens:
  [`next-of-kin.md`](./next-of-kin.md).

**Where to store tokens on Flutter:** web stores both tokens in httpOnly
cookies (`access_token`, `refresh_token`) and
calls Django through its own Next.js BFF proxy (`/api/proxy/...`), which
adds the `Authorization` header server-side, so browser JS never sees
either token. Flutter has no equivalent
same-origin cookie jar — use secure, encrypted local storage
(`flutter_secure_storage` or platform keychain/keystore) for both tokens,
never plain `SharedPreferences`. This is the one deliberate place mobile's
mechanics differ from web's; the *behavior* (expiry, rotation, blacklist
reaction) must still match exactly.

### Response envelope

**Success:** whatever shape the specific endpoint's serializer defines —
there's no single universal success wrapper (no `{"data": ...}` shell).
Read each domain file's own examples. Lists come in three shapes; the
domain files say which an endpoint uses:

- **Cursor-paginated** (25 per page):
  `{"next", "previous", "results"}`, no `count`. Used by the patient's
  own history lists: `GET /api/bookings/mine/`, `/api/invoices/mine/`,
  `/api/receipts/mine/`, `/api/payments/mine/`, and
  `/api/medications/` and `/api/appointments/` when called **without**
  `?condition=` (with `?condition=` they return a plain array). `next` is
  a full backend URL. Web
  reads only its `cursor` query param, re-requests the same path with
  `?cursor=<value>` until `next` is `null`, and shows the whole list at
  once (client-side paging in its tables). Do the same.
- **Page-number paginated** (DRF's default `PageNumberPagination`, 25 per
  page: `{"count", "next", "previous", "results"}`): generic DRF list
  views that don't override it.
- **Plain arrays**: views that don't paginate (e.g. the geography
  lookups, `GET /api/push/preferences/`).

**Error:** every *raised* DRF exception is wrapped by one global handler
into:

```json
{
  "error": {
    "detail": <DRF's error data, see below>,
    "status_code": 400
  }
}
```

`error.detail` takes one of these shapes — web handles exactly these, so
mirror it:

- **A message with an optional code** (what views raise on purpose):
  `{"detail": "Human-readable, safe to show.", "code": "email_not_confirmed", ...extra keys}`.
  `code` is present only for errors the frontend is expected to branch on.
  The ones web actually branches on: `email_not_confirmed`,
  `phone_not_verified` and `account_exists` (the `/auth` screen), and
  `assessment_in_progress`, `age_ineligible`, `gender_ineligible`,
  `dependant_consent_required`, `cancer_diagnosed_blocked` (starting an
  assessment), and `facility_not_suitable`, `consent_required` and `no_email`
  (referral visits, see `bookings-and-consultations.md`), and
  `next_of_kin_access_ended` (on any request, see `next-of-kin.md`). (Web also handles
  `mfa_enrollment_required`, but only doctor/admin actions raise it, so
  the patient app never sees it.) Any other keys next to it are data for that case (e.g.
  `email`/`phone` on the login codes, `blocking_slug`/`blocking_title` on
  `assessment_in_progress`) — web passes them through as `extra`.
- **Field validation errors**: `{"field_name": ["message", ...]}` (a list
  for serializer field errors; a plain string when a view raises a
  field-keyed error itself, e.g. `{"refresh": "Token is invalid"}`), or
  `{"non_field_errors": ["..."]}`. Web shows the first one.
- **A plain string** — only for `429`: `"Too many attempts. Please try
  again in about 12 minutes."` (humanized from DRF's wait time).
- DRF's own errors (`401` not authenticated, `403` permission denied,
  `404` not found) use the first shape with no `code`:
  `{"detail": "..."}`. The one exception is an expired/invalid JWT,
  whose `detail` also carries `"code": "token_not_valid"` and a
  `messages` list.

When none of these yield a message, web shows *"Something went wrong.
Please try again."*; when the body isn't JSON at all, it falls back to
the HTTP status text.

Exceptions to the envelope, which a robust client must tolerate:

- A few views *return* (rather than raise) an error body, which skips the
  handler and arrives unwrapped as `{"detail": "...", "code": "..."}` at the
  top level — notably the vitals paywall's `402`
  (`code: "vitals_access_required"`) and some assessment `404`s ("Unknown
  assessment."). Web's parser only reads `body.error.detail`, so these
  show its generic "Something went wrong. Please try again."; web avoids
  the `402` in practice by checking `GET /api/vitals/access/` first (see
  `vitals-medications-appointments.md`, "The paywall gate"). Do the same,
  and don't crash on the unwrapped shape. The wellness plan PDF's `409`
  is unwrapped too: `{"detail": "Your plan is not available yet.",
  "ineligible_reason": "..."}` (see `annual-wellness-plan.md`).
- Some `404`s have **no body at all**: the next of kin endpoints
  (`/api/next-of-kin/...`) answer a missing or not-yours id, or an
  invitation that is no longer valid, with an empty `404`. Web then falls
  back to the HTTP status text.
- A genuinely unexpected exception is logged server-side
  and Django returns its
  own plain `500` page — **not JSON**. Gateways can likewise return
  non-JSON `502`/`504`s. Never assume an error body parses.
- HTTP status codes are meaningful: `400` validation, `401` missing/expired
  auth, `402` payment required (vitals), `403` permission denied,
  `404` not found, `429` rate limited (DRF also sets a `Retry-After`
  header in seconds), `503` an upstream provider is down (e.g. Peleza),
  `500` genuinely unexpected.

### Phone numbers

Kenyan numbers are accepted interchangeably on input: `0712345678`, `+254712345678`,
`254712345678`, or the bare 9 digits `712345678` — the backend normalizes
these to bare `254XXXXXXXXX` (e.g. `"254712345678"`)
wherever a phone is a login/account identifier (signup, login, OTP
confirm/resend, password reset). A phone abroad (people living outside
Kenya, see `auth-and-signup.md` Step 1) is written with its country code
(`"+44 7911 123456"` or `"0044…"`) and stored and returned as digits with
the country code and no plus (`"447911123456"`). Sign-in accepts either
kind. Not every write path normalizes (e.g. the
profile's contact `phone` on `PATCH /api/health-profile/` is stored as
sent), so **send and display a Kenyan number in the bare `2547…`/`2541…`
form and a number abroad as its country-code digits**, the forms the API
returns. SMS codes only ever go to Kenyan numbers.

### Rate limiting

Every endpoint gets DRF's global throttles by default — `anon` **60/min**
(keyed by client IP) and `user` **300/min** (keyed by user). Sensitive
endpoint families instead set their own scoped throttle, which *replaces*
those defaults on that view.
The ones a patient-facing app can hit:

| Scope | Rate | Where |
|---|---|---|
| `otp_request` | 5/hour | signup, signup resends, "Forgot passcode?" request, verify-contact request — **one shared bucket** |
| `id_verification` | 5/hour | `verify-id/` and `verify-id/manual/` (passports, typed-in details after a failed lookup, or everyone while manual entry is switched on), one shared bucket |
| `mfa_verify` | 10/min | `mfa/verify/` |
| `data_export` | 5/hour | `export-data/` (Privacy & your data tab) |
| `report_email` | 10/hour | emailing a report: an assessment report (`/api/assessments/<slug>/session/<id>/report/email/`), the vitals report (`/api/vitals/report/email/`), the period & pain report (`/api/vitals/period-pain/report/email/`), the referral summary (`/api/bookings/<id>/email-summary/`). **One shared bucket** across all four |
| `afyaconnect_resync` | 10/hour | `POST /api/health-exchange/afyaconnect-resync/`, backstop behind the real 24h service-layer cooldown |
| `shr_resync` | 10/hour | `POST /api/health-exchange/shr-resync/` and `POST .../shr-resync/request-consent/` (one shared bucket), backstop behind the real 1h service-layer cooldown. The `status/` GETs aren't scoped |
| `next_of_kin_invite` | 10/hour | `POST /api/next-of-kin/` (adding a next of kin sends a real SMS/email). The list `GET` isn't scoped |
| `next_of_kin_accept` | 20/hour | `POST /api/next-of-kin/invitations/<token>/accept/` |

Scoped throttles key by user when authenticated, otherwise by client IP
(`NUM_PROXIES = 1`, so the address nginx saw) — on mobile networks behind
carrier NAT many users can share one IP for the unauthenticated ones. A
`429` means back off — read `Retry-After` (seconds), don't auto-retry in a
tight loop; show the user a "try again later" state the same way web's own
UI does for that specific flow (each domain file notes the real cooldown
window where one exists, e.g. SHR resync's 1-hour cooldown). Some limits
live in the service layer instead and don't surface as `429` at all —
e.g. the OTP service's own 60-second / 5-per-hour per-destination limit
(see auth-and-signup.md "OTP mechanics").

### Async side effects — expect eventual consistency, not an instant result

A lot of "something happened" responses (a payment settling, an SHR
records sync, a reminder notification) are deliberately **not** done inline in the
HTTP response — they're dispatched to Celery via `transaction.on_commit`,
so the response you get back confirms "this was accepted and queued," not
"this fully happened." Where web's own UI polls or re-fetches after a
delay to pick up the real result (a payment status check, an SHR
records-refresh), the matching domain file says so explicitly with the
real timing web uses — replicate that polling/delay pattern, don't assume
synchronous completion just because the HTTP call returned 200/201.

### The mobile client secret

The guide-fetching endpoint above is gated by the mobile client secret (so
is the offline assessment download, `GET /api/assessments/<slug>/offline/`,
see `assessments.md`; no other endpoint refuses a request without it): an
`X-Mobile-Client-Secret` header matching the server's configured value —
a static value meant to be baked into the Flutter app binary at
build time, checked with a timing-safe comparison.

**Send it on every request, not only the guide endpoints.** The server uses
it to tell app requests from web ones. Today that drives the next of kin
activity list: a request that carries the matching value is logged as
`channel: "app"` and reads "… in the app" to the account holder; without it the
request is logged as `web` (see [`next-of-kin.md`](./next-of-kin.md)). When the
setting is unset on the server, nothing is logged as `app`.

**This is currently unset in every environment by default** (it
fails closed — denies every request, not silently open) until someone
actually configures it and gives the mobile build that exact value. It is
*not* a secret the mobile engineer should generate themselves the way a
VAPID key pair gets generated per-app; it's a single shared value both this
backend and the Flutter binary must agree on. Get the real value from
whoever owns backend deploy config before calling anything gated by
it — you'll get a `403` ("This endpoint requires the
mobile app's client credential."), not a
helpful "not configured" message, if it's missing or wrong (a `401`
instead when no bearer token is sent — see the guide-fetching section
above).

The honest security properties: this is an interim deterrent
against casual scraping/replayed-bearer-token tools, not a real
attestation mechanism — the documented upgrade path once a real mobile app
exists is Android Play Integrity / iOS App Attest, which would retire this
header entirely. Don't architect anything mobile-specific assuming this
header is a permanent mechanism.

### Versioning and drift

There is no API version header/prefix today (no `/api/v2/`) — this is a
single, continuously-evolving backend both web and mobile hit directly.
There is no contract test or schema diff gate between this guide and the
real code; it will drift the moment someone ships a change here without
updating the matching file. The guide-set line at the top of every file
changes whenever any file changes (see "Keeping the app in step with the website and
WhatsApp"). Treat every endpoint path/shape in this guide
as "last verified against the code on" the date at the bottom of its file,
and check it against the real API response before
depending on it for anything you're about to ship, exactly as this
README's own "ground truth" section above says.

---

Last verified against the code on 2026-11-11.
