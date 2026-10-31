# Mobile (Flutter) API Integration Guide

**Who this is for:** an engineer or AI coding agent building the Flutter
mobile app for My Wellness Health, who needs to consume the exact same DRF
backend (`backend/CORE`) the Next.js web app (`wellness-health`) already
consumes — and needs the mobile app's behavior to match web's **exactly**,
not just "work." Every domain file in this folder tells you not just which
endpoint to call, but **when** to call it, **in what order**, and what
timing/cooldown/polling behavior web relies on, so a user moving between
the web app and the mobile app never sees a different rule, a different
wait time, or a different state machine.

**Ground truth, in priority order, whenever this guide and the running
code disagree:**
1. The actual Django code (`apps/*/views.py`, `services.py`, `serializers.py`, `models.py`).
2. The actual Next.js frontend code (`wellness-health/app/**`, `wellness-health/lib/api/**`) — this is what defines "how web works," since that's the behavior to match.
3. `docs/system-workflow.md` (this repo) — broad architecture narrative, useful for orientation, written for human engineers, not sequencing-precise.
4. `docs/api-request-samples.json` (this repo) — real sample request bodies per endpoint, cross-checked against serializers, but a flat endpoint list, not a sequencing guide, and **known to be stale** on anything added after assessments/vitals/bookings/payments/clinical/chatbot/otp/notifications/admin were last refreshed (it predates SHR/health_exchange, the WhatsApp bot, and some newer package/consultation-lead additions — confirmed by reading it directly).

This guide is a snapshot. The backend moves fast (see any domain file's own
"last verified against" note). Before building against any flow here, grep
the actual current code for the exact endpoint/model/field names quoted —
don't trust this document blindly for anything you're about to ship.

## Files in this guide

| File | Covers |
|---|---|
| [`auth-and-signup.md`](./auth-and-signup.md) | Email signup+confirm, phone signup (incl. the DHA-trusted-phone skip-OTP path), login, MFA enrollment/verification, logout, token refresh, password/passcode reset, the health-profile onboarding gate. |
| [`account-and-profile.md`](./account-and-profile.md) | Profile view/update, post-signup email/phone verification (Account Settings "Verify" flow), notification preferences, data export. |
| [`assessments.md`](./assessments.md) | Category/catalog browsing, session start/resume, the one-assessment-at-a-time rule, the question-answer loop, payment gating, completion, risk scoring, PDF report retrieval. |
| [`payments-and-packages.md`](./payments-and-packages.md) | M-Pesa STK push + status polling, package/bundle pricing (including sexual/urinary health's age-tiered pricing), the custom package builder, receipts/invoices. |
| [`bookings-and-consultations.md`](./bookings-and-consultations.md) | Service bookings (Checkup, Second Opinion, DNA test, etc.), facility selection, HIE-managed vs. plain bookings, the "request a callback" consultation-lead flow, rebooking. |
| [`health-records-and-shr.md`](./health-records-and-shr.md) | DHA Shared Health Record consent (OTP), requesting a fresh consent after expiry, syncing/fetching medical history, what shows up on the Medical History page and why. |
| [`vitals-medications-appointments.md`](./vitals-medications-appointments.md) | Blood pressure/blood sugar logging and classification, medication management and reminders, appointments. |
| [`push-notifications.md`](./push-notifications.md) | Web-push subscription registration (VAPID), notification preferences, what event triggers what notification. |

## The envelope: shared conventions every domain file assumes

### Base URL and routing

The Django backend mounts every feature under `/api/...`. Top-level
prefixes (`CORE/urls.py`), so you know where every domain file's endpoints
actually live:

```
/api/auth/              apps.accounts      -- signup, login, MFA, password/passcode reset, roles
/api/health-profile/    apps.accounts      -- the one-off demographics onboarding PATCH
/api/geography/         apps.geography     -- county/sub-county/constituency/ward lookups
/api/formulary/         apps.formulary     -- medication/generic-product search
/api/                   apps.assessments   -- category/session/question/report endpoints (no extra prefix)
/api/                   apps.vitals        -- BP/BS/medication/appointment endpoints (no extra prefix)
/api/payments/          apps.payments      -- STK push, packages, custom pricing, receipts
/api/                   apps.bookings      -- service bookings, invoices, consultation leads (no extra prefix)
/api/care-navigation/   apps.care_navigation -- referrals
/api/invite-codes/      apps.invite_codes
/api/companies/         apps.companies     -- B2B/corporate wellbeing
/api/resources/         apps.resources     -- the resource hub (articles)
/api/reviews/           apps.reviews
/api/clinical/          apps.clinical      -- doctor-facing chart (not for the patient-facing mobile app)
/api/chp/               apps.chp           -- Community Health Professional flows
/api/admin/             apps.admin_api     -- wellness-admin console only, not for the mobile app
/api/chatbot/           apps.chatbot       -- support chatbot
/api/otp/               apps.otp           -- the OLDER generic email-only OTP pair; prefer apps.accounts's own identifier-based endpoints where both exist (see auth-and-signup.md)
/api/push/              apps.notifications -- ⚠️ web-push + notification preferences + partner notifications live HERE, under /push/, NOT under /api/notifications/ (a real bug was found and fixed in wellness-health's own frontend client over this exact mistake — see push-notifications.md)
/api/health-exchange/   apps.health_exchange -- DHA/SHR consent + medical records sync
/api/whatsapp/          apps.whatsapp      -- the WhatsApp bot's own webhook, not relevant to the mobile app
/api/mobile-guide/      apps.common        -- serves THIS guide itself over HTTP (see below) -- fetch it live instead of needing a checkout of this repo
```

### Fetching this guide itself, over HTTP

This whole guide is also served live by the running backend, gated by the
same `X-Mobile-Client-Secret` header as the offline-assessment endpoints
above (`apps.common.permissions.HasMobileClientSecret` -- see "The mobile
client secret" section below for where to get the real value). No
`IsAuthenticated` requirement here -- there's no per-user data in a
documentation file, so this works even before any real user is signed in.

```
GET /api/mobile-guide/                 -- [{"filename": "README.md", "title": "..."}, ...]
GET /api/mobile-guide/<filename>/      -- that one file's raw markdown (Content-Type: text/markdown)
```

A path like `<uuid:session_id>` in a domain file means: substitute a real
id you got from a prior response. Angle brackets are never sent literally.

### Authentication

JWT via `rest_framework_simplejwt`:

- Every authenticated request sends `Authorization: Bearer <access_token>`.
- Access tokens last **30 minutes**; refresh tokens last **14 days**, with
  rotation + blacklist-on-rotation (a used refresh token can never be
  reused). `POST /api/auth/token/refresh/` exchanges a refresh token for a
  fresh pair.
- `POST /api/auth/logout/` blacklists the given refresh token immediately.
- A password reset or MFA-related security event blacklists **every**
  outstanding refresh token for that user, not just the one in use —
  mobile must be ready to be logged out server-side with no warning after
  one of those events, same as web.
- Some endpoints (gated by `IsAdmin`/`IsClinician`) additionally require
  MFA enrollment (`apps.accounts.permissions._require_mfa_or_raise`) — not
  relevant to an ordinary patient-facing mobile session, but relevant if
  the mobile app is ever used by clinical staff.

**Where to store tokens on Flutter:** web stores the refresh token in an
httpOnly cookie via its own Next.js BFF proxy layer (the browser JS never
sees it) and the access token in memory. Flutter has no equivalent
same-origin cookie jar — use secure, encrypted local storage
(`flutter_secure_storage` or platform keychain/keystore) for both tokens,
never plain `SharedPreferences`. This is the one deliberate place mobile's
mechanics differ from web's; the *behavior* (expiry, rotation, blacklist
reaction) must still match exactly.

### Response envelope

**Success:** whatever shape the specific endpoint's serializer defines —
there's no single universal success wrapper (no `{"data": ...}` shell).
Read each domain file's own examples.

**Error:** every error response is wrapped by one global DRF exception
handler (`apps.common.exceptions.api_exception_handler`) into:

```json
{
  "error": {
    "code": "some_machine_readable_code",
    "message": "A human-readable message, safe to show the user.",
    "detail": { "field_name": ["Validation error for this specific field."] }
  }
}
```

- `code` is present for errors the frontend is expected to branch on
  specifically (e.g. `"email_not_confirmed"`, `"mfa_enrollment_required"`,
  `"consent_closed"`-shaped ones under health-exchange). Absent for a
  generic validation error — branch on HTTP status + `detail` shape
  instead.
- Never shows a raw Python traceback or exception message to the client;
  an unexpected 500 still returns this same envelope with a generic
  message, logged server-side with full detail.
- HTTP status codes are meaningful: `400` validation, `401` missing/expired
  auth, `403` permission/role/MFA gate, `404` not found, `429` rate
  limited (see Retry-After-style headers where present), `500` genuinely
  unexpected.

### Phone numbers

Accepted interchangeably on input: `0712345678`, `+254712345678`,
`254712345678` — the backend normalizes everything to bare
`254XXXXXXXXX` internally (`apps.common.phone.normalize_kenyan_phone`).
**Always send/display the bare `254XXXXXXXXX` form from the mobile app**
to match what every other client and every outbound SMS/WhatsApp message
in this system already assumes, even though the input field can accept
looser formats.

### Rate limiting

Redis-backed DRF `ScopedRateThrottle`s on sensitive endpoint families (OTP
requests, M-Pesa callbacks, consultation-lead creation, chatbot, AI photo
scans, report emails, SHR resync). A `429` means back off — don't
auto-retry in a tight loop; show the user a "try again later" state the
same way web's own UI does for that specific flow (each domain file notes
the real cooldown window where one exists, e.g. SHR resync's 1-hour
cooldown).

### Async side effects — expect eventual consistency, not an instant result

A lot of "something happened" responses (a payment settling, an SHR bundle
push, a WhatsApp notification) are deliberately **not** done inline in the
HTTP response — they're dispatched to Celery via `transaction.on_commit`,
so the response you get back confirms "this was accepted and queued," not
"this fully happened." Where web's own UI polls or re-fetches after a
delay to pick up the real result (a payment status check, an SHR
records-refresh), the matching domain file says so explicitly with the
real timing web uses — replicate that polling/delay pattern, don't assume
synchronous completion just because the HTTP call returned 200/201.

### The mobile client secret — read this before touching assessments

Some endpoints exist **only for the mobile app** and are not what web calls
at all — notably `AssessmentOfflineDetailView` and `SessionAnswersBatchView`
(`apps/assessments/urls.py`, see `assessments.md`'s own "offline sync"
section for the full shape). These are gated by **both** the normal
`IsAuthenticated` check **and** `apps.common.permissions.HasMobileClientSecret`,
which requires an `X-Mobile-Client-Secret` header matching the
`MOBILE_CLIENT_SECRET` setting — a static value meant to be baked into the
Flutter app binary at build time, checked with a timing-safe comparison.

**This is currently unset in every environment by default** (`default=""`,
fails closed — denies every request, not silently open) until someone
actually configures it and gives the mobile build that exact value. It is
*not* a secret the mobile engineer should generate themselves the way a
VAPID key pair gets generated per-app; it's a single shared value both this
backend and the Flutter binary must agree on. Get the real value from
whoever owns backend deploy config before attempting to call either of
those two endpoints — you'll get a 403 from `HasMobileClientSecret`, not a
helpful "not configured" message, if it's missing or wrong.

Read `apps.common.permissions.HasMobileClientSecret`'s own docstring (it's
thorough) for the honest security properties: this is an interim deterrent
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
updating the matching file. Treat every endpoint path/shape in this guide
as "last verified against the code on 2026-10-27" and re-verify before
depending on it for anything you're about to ship, exactly as this
README's own "ground truth" section above says.