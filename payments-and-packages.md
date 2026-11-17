# Payments & Packages

<!-- guide-header:start -->
> **Guide set `2026-11-16.b9b79a`.** Every file in this guide carries this same line.
>
> **Related files you need open with this one:** `README.md` (shared conventions), `assessments.md`, `auth-and-signup.md`, `bookings-and-consultations.md`, `push-notifications.md`, `vitals-medications-appointments.md`
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

Covers M-Pesa STK push, the M-Pesa prompt dialog and the payment-outcome
screens, package pricing (including the Sexual & Urinary Health
assessment's age-tiered price) and the **"Assessment Locked"** paywall,
**Plans & Pricing** (the Wellness Packages screen: Standalone Packages,
Combined Packages, All-in-One and Create My Package), the endometriosis
donation and subsidy, `demo_restricted` account behavior, and **Billing**
(Payments, Invoices, Receipts) for the user's own purchases. Read
[`README.md`](./README.md) first for the shared envelope (auth header,
error shape, async-side-effect posture) — this file assumes it.

All payment endpoints live under `/api/payments/` unless noted.

Out of scope for the mobile app: buying packages for an organization or
group (Organization Admin, and the organization and group check-up
booking pages) and paying organization invoices. Joining an
organization from an invite link is in
[`auth-and-signup.md`](./auth-and-signup.md) Step 2b. A self-pay joiner
pays exactly as described here, and a covered-seats invite's categories
show up in `module-access` like any purchase.

## 1. Package catalog & pricing (including age tiers)

`GET /api/payments/packages/` — **public** (`AllowAny`), no auth required.
Web always fetches the full list (no query params) and picks packages by
`slug`. This is DB-backed and admin-editable — never hardcode a price
list in the mobile app; always read it live, same as web does.

```json
// GET /api/payments/packages/  (one entry shown)
[
  {
    "slug": "sexual_urinary",
    "label": "Sexual & Urinary Health assessment",
    "description": "...",
    "unlocks_vitals_logging": false,
    "price_rules": [
      { "min_age": 18, "max_age": 24, "price_kes": "200.00" },
      { "min_age": 25, "max_age": null, "price_kes": "500.00" }
    ],
    "categories": ["Sexual & urinary"]
  }
]
```

`price_kes` is a **decimal string**, not a number. Show `label` as the package name.

Web uses these packages:

| Slug | Shown as | Where |
|---|---|---|
| `core` | Screening Package | **Individual check-up** ([`bookings-and-consultations.md`](./bookings-and-consultations.md) §2) |
| `all` | Wellness Package | same |
| `premium` | Complete Care Package | same |
| `cancer`, `metabolic`, `mental_health`, `sexual_urinary`, `endometriosis` | the package `label` | An assessment's own **"Assessment Locked"** screen, one package per category: Cancer, Metabolic, Mental health, Sexual & urinary, Reproductive health |
| `workplace_wellbeing` | the package `label` | The same screen for a Corporate Workplace Wellbeing session. It's only reachable from the "Workplace Wellbeing check-in" card on the Dashboard, which shows when `profile.occupation` is set. The Plans & Pricing catalog leaves Workplace out (§1, "Plans & Pricing catalog") |
| `vitals_tracking` | the package `label` | **Not used by web.** Web sends a locked Blood Pressure / Blood Sugar user to `/wellness-packages?service=monitor` (§2, "Deep links") and never shows a KES card for this package. The package and its STK push still work; don't build a screen for it ([`vitals-medications-appointments.md`](./vitals-medications-appointments.md)) |

The **Plans & Pricing** screen (§3) doesn't use these packages; it uses
the separate custom-builder pricing.

**What gets charged.** The server always sets the amount, and ignores any `amount` sent. A
payment is for at most one of a session, a booking or an invoice, or for a package on its own
(`package_id` with no other target). A session is charged through a package covering its
category, and a checkup booking through `core`, `all` or `premium`. Anything else gets a `400`. A Paybill payment below the amount due doesn't settle: it stays pending for support.

**Price and eligibility.** The API decides these, so never work out a price from
`price_rules`:

- A locked session's response has `payment_offer`.
- For an account with no age on file, once `payment_offer.age_required` is true, ask for
  the age and call `GET /api/payments/packages/<package_id>/offer/?age=<age>`. A known age
  on the account always wins over a typed one.

```json
{ "package_id": "sexual_urinary", "service_id": "sexual", "price_kes": 200, "access_months": 2,
  "payable": true, "age_required": false, "ineligible_reason": null }
```

`price_kes` is null until there's a price. `ineligible_reason`, when set, is the message to
show. Send a typed age as `age` on the payment call.

### "Assessment Locked" (`https://staging.mywellnesshealth.co.ke/assessments/<slug>`)

Shown on an assessment's intro page while its session is
`awaiting_payment` (see [`assessments.md`](./assessments.md) for when
that happens):

- **"Assessment Locked"**, then, from `payment_offer`:
  - Sexual & urinary: "Complete payment of **KES {price_kes}** to unlock this
    assessment for {access_months} months."
  - Every other category: "Complete payment of **KES {price_kes}** to unlock
    this assessment and every other {category label} assessment for
    {access_months} months."
- **Button:** "Pay with M-Pesa · KES {price_kes}", enabled when `payable` is true, under it
  "🔒 Secure Safaricom STK Push — no manual code entry."
- **Age:** show a "Your age" field only when `age_required` is true. Show
  `ineligible_reason` when it's set.
- **Paying:** the button opens the M-Pesa prompt dialog (§2) with
  `session_id` + `package_id` (+ `age` for Sexual & urinary), then the
  payment-outcome screen (§2).
- **Endometriosis** (`endometriosis` and `endometriosis-dependent`) adds
  the subsidy link (§2, "Endometriosis donation and subsidy").

### Plans & Pricing catalog

`GET /api/payments/service-catalog/` — **public** (for a signed-in account known to be under 18 it
returns no services, combos or All-in-One and `adults_only: true`), the Plans & Pricing
catalog: service, combo and All-in-One entries with name, description,
icon, colors, benefits and report copy. Every price is computed live by
the server with the same rules as the quote (§3), so there's exactly one
source of truth. Shape:

```json
{
  "services": [
    {
      "service_id": "cancer",
      "name": "Cancer Awareness",
      "short_description": "...",
      "icon_key": "...", "accent_hex": "#...", "bg_hex": "#...",
      "unit": "...",
      "is_proposed": false,
      "benefits": [{ "title": "...", "description": "..." }],
      "report": ["..."],
      "base_price_kes": 200,
      "price_display": "KSh 200/year"
    }
  ],
  "combos": [
    { "combo_id": "cm", "name": "Cancer + Metabolic", "description": "...", "service_ids": ["cancer", "metabolic"], "price_kes": 350, "price_display": "KSh 350/year" },
    { "combo_id": "cs", "name": "...", "description": "...", "service_ids": ["cancer", "sexual"], "price_kes": 500, "price_display": "KSh 350 (18–24) / 500 (25+)" }
  ],
  "all_in_one": { "name": "All-in-One Wellness", "description": "...", "service_ids": ["cancer", "metabolic", "mental", "women", "sexual", "monitor", "checkup", "opinion"], "price_kes": 3500, "summary": "One annual payment. All eight service areas." },
  "adults_only": false,
  "price_options": {
    "monitor": [
      { "value": "monthly", "label": "KSh 200/month", "note": "Monthly monitoring covers the first month at checkout. Subsequent months remain KSh 200 each; the custom KSh 50 discount applies only once." },
      { "value": "annual", "label": "KSh 2,000/year", "note": "Free Metabolic Health Assessment and KSh 400 annual billing saving." }
    ],
    "opinion": [
      { "value": "gp", "label": "GP · KSh 1,000", "note": "" },
      { "value": "consultant", "label": "Consultant · KSh 2,500", "note": "" }
    ]
  },
  "account_sexual_age_tier": null,
  "unavailable_service_ids": []
}
```

- `services` are active entries in admin order: `cancer`, `metabolic`,
  `mental`, `women`, `sexual`, `monitor`, `checkup` and `opinion`. The
  server leaves `workplace` out of `services` and `all_in_one.service_ids`
  (it's paused), so show everything the catalog returns.
- `adults_only` is always present. When it's `true` (lists empty,
  `all_in_one: null`), web shows only this screen instead of Plans &
  Pricing: **"Packages are for adults"**, "My Wellness Health packages are
  for adults aged 18 and over. A parent or guardian can complete the
  Endometriosis Health Check for a young person from their own account."
  and a "Back to dashboard" link. That response has the same keys as any
  other, with `account_sexual_age_tier: null` and `unavailable_service_ids: []`.
- `base_price_kes` is `null` for `sexual`, `monitor` and `opinion`, which
  have variable prices. Show `price_display` for them, e.g.
  `"KSh 200–500/year"`, `"KSh 200/month or 2,000/year"`,
  `"KSh 1,000 GP / 2,500 Consultant"`. `price_display` is the price
  only; `is_proposed` is an internal marker and must not be shown.
- `combos` are `cm`, `cn`, `cw`, `cs`. Show `combos[].price_display` as
  the combo card's price line on Combined Packages (e.g. "KSh 350/year";
  Cancer + Sexual Health is "KSh 350 (18–24) / 500 (25+)").
  `combos[].price_kes` for `cs` is the 25+ price (500); the price actually
  charged comes from a quote.
- `all_in_one` can be `null` if no All-in-One row exists. Its `summary`
  ("One annual payment. All eight service areas.") is the line on the
  All-in-One card in Combined Packages.
- `price_options` holds the picker choices for services with more than
  one price: `monitor` (`monthly`/`annual`, sent as `monitor_term`) and
  `opinion` (`gp`/`consultant`, sent as `opinion_clinician_tier`). Each
  picker button shows `label`. Under the monitoring picker, show the
  chosen option's `note` (web adds a gift icon before the annual one).
  The opinion notes are empty.
- `account_sexual_age_tier` (`"youth"` | `"adult"` | `null`) is the
  Sexual Health tier the account's age decides. `null` means the age is
  unknown or the user is signed out, so the user picks (§2, "Age tier").
- `unavailable_service_ids` lists services this account can't buy on
  their own, e.g. `["cancer"]` once the account has reported a cancer
  diagnosis, otherwise `[]` (always `[]` signed out). Standalone Packages
  and Create My Package leave them out.

## 2. M-Pesa STK push — initiate, then poll the payment's status

`POST /api/payments/stk-push/` (auth required):

```json
// Request
{
  "phone": "254712345678",
  "amount": 200,
  "service_type": "Sexual & Urinary Health assessment",
  "session_id": "<uuid, if paying to unlock an assessment session>",
  "booking_id": "<uuid, if paying for a service booking>",
  "package_id": "sexual_urinary",
  "age": 22
}
```

At least one target must be present, otherwise the request fails with
400 *"At least one of session_id, booking_id, invoice_id or package_id is
required."* That one comes back as a list under `non_field_errors`
(`{"error": {"detail": {"non_field_errors": ["…"]}, …}}`), not as `detail`.
(`invoice_id` is only for organization invoices; mobile never sends it.)
Web always sends `package_id`, combined like this:

| Web flow | Sends |
|---|---|
| An assessment's "Assessment Locked" screen | `session_id` + `package_id` (+ `age` for Sexual & urinary); `service_type: "<short title> assessment"` |
| **Individual check-up** | `booking_id` + `package_id` (`core`/`all`/`premium`); `service_type: "Individual <package label> package"` |

Plans & Pricing doesn't use this endpoint; it has its own checkout (§3).

Field rules:

- `method` is optional: `"stk"` (default, sends the prompt), `"manual"`
  (reserves the payment for paying by hand, §2a), `"card"` (opens a card
  checkout, §2b) or `"bank"` (reserves a bank transfer with its own
  reference, §2b). Offer only what `GET /api/payments/options/` lists.
- `bank_account_id`: required with `"bank"`, one of the options'
  `bank_accounts` ids.
- `return_path`: optional, card only — a path on the website (e.g.
  `"/assessments/stress"`) the website return page opens after paying.
  Mobile doesn't need it (§2b).
- `phone` must match `^(?:254|\+254|0)?7\d{8}$`; it's required for
  `"stk"` and not sent for `"manual"`.
- `amount` is an integer from 1 to 150000.
- `service_type` is required, up to 120 characters; anything over 50 is
  trimmed to 50 (the stored length) — it's a display label, never
  priced from.
- `package_id` must be an active package slug.

`amount` and `service_type` are always required, but with `package_id`
the server **re-prices**:

- The charge is the package's price for the account's age (the same
  price `payment_offer` / `GET /api/payments/packages/<package_id>/offer/`
  returns, §1). The client `amount` is ignored (send the price you
  displayed).
- `service_type` is replaced by the package's `label` unless a
  `booking_id` is also present. So an assessment unlock is stored and
  billed under the package label, and the Individual checkup under
  "Individual <package label> package".

```json
// Response, 201
{
  "id": "<payment uuid>",
  "phone_number": "254712345678",
  "amount": "200.00",
  "service_type": "Sexual & Urinary Health assessment",
  "status": "pending",
  "method": "stk",
  "checkout_request_id": "ws_CO_...",
  "mpesa_receipt": "",
  "account_reference": "",
  "package_id": "sexual_urinary",
  "currency": "KES",
  "checkout_url": null,
  "bank_details": null,
  "created_at": "2026-10-27T10:00:00Z",
  "manual_review_status": null,
  "can_submit_manual_proof": false
}
```

(`can_submit_manual_proof` would be `true` here while manual payments are
switched on, §2a.)

This is the **payment shape** every payment endpoint returns (STK push,
custom checkout, the donation, the payments list). Its fields:

| Field | Meaning |
|---|---|
| `status` | `pending`, `success` or `failed` |
| `method` | How it is being paid: `stk` (the M-Pesa prompt), `paybill` (a Paybill account reference; web and mobile never create these), `manual_mpesa` (paid by hand to the M-Pesa paybill, confirmed by staff, §2a), `manual_bank` (paid by hand to the bank account, confirmed by staff), `card` (card checkout, §2b) or `bank_transfer` (paid into one of our bank accounts quoting `account_reference`, confirmed by the bank, §2b). It changes to `manual_mpesa`/`manual_bank` when a confirmation message is sent for a payment that started as `stk` |
| `currency` | Always `"KES"` today, cards included (the card's bank converts) |
| `checkout_url` | Card only: the card gateway's page to send the payer to, while the payment is `pending`; otherwise `null` |
| `bank_details` | Bank transfer only, otherwise `null`: `{bank, bank_name, account_name, account_number, branch, paybill_number, mpesa_account, reference}` — where to pay and the reference to quote (§2b) |
| `phone_number` | The number the prompt went to; `""` for a manual reservation (§2a) |
| `mpesa_receipt` | The M-Pesa receipt code once paid. For a payment approved by hand it's the transaction code taken from the pasted message, or `MANUAL-` plus 8 characters when a bank message had no code |
| `manual_review_status` | `pending_review`, `approved` or `rejected` for the latest confirmation message sent for it (§2a), else `null` |
| `can_submit_manual_proof` | `true` exactly when `POST /api/payments/mine/<id>/manual-proof/` would accept a confirmation message for this payment right now (§2a). Use it to decide whether to offer paying by hand for it; never work that out yourself |

A validation, pricing or guard failure returns `400` with the global error
envelope as `{"detail": "..."}`. Show the message and don't retry
automatically. Real messages:

- *"Age is required to price '…'."*
- *"This assessment is only available to users aged 18 and above."*
- *"A payment request is already pending for this assessment. Check your
  phone for the M-Pesa prompt, or wait a moment before retrying."* (or
  *booking* / *package* in place of *assessment*)
- *"This assessment is already paid for."* (also *booking*)
- *"This assessment is already unlocked — no payment needed."*
- *"Unknown package."*
- *"That package doesn't cover this assessment."* / *"That package doesn't
  cover this booking."*
- *"A payment can only be for one thing at a time."*
- *"Assessment session not found."* / *"Booking not found."*
- *"This booking can't be paid for directly."* (a checkup booking sent
  without `package_id`)
- The coded refusals in "Things the packages UI must also do" below
  (`adults_only`, `cancer_declaration_required`,
  `cancer_diagnosed_blocked`) and the manual payment ones in §2a
  (`manual_payments_only`, `manual_payments_off`) also carry `code` next
  to `detail`.

"Already pending" never comes from an unpaid manual reservation that has
no confirmation message yet (§2a, "An unpaid manual reservation"): a new
prompt for the same thing replaces it.

**Retries.** `POST /api/payments/stk-push/` (and
`POST /api/payments/custom-quote/checkout/`, §3) accept an optional
`Idempotency-Key` header, e.g. a UUID generated once per tap of the send
button. Repeating a request with the same key returns the payment it
already created instead of sending a second prompt. Web doesn't send it;
it's safe to add on a flaky connection.

If M-Pesa itself rejects the push, the reserved payment is marked
`failed`, so it doesn't block a retry, and M-Pesa's error comes back as a
400.

`status` is one of `pending`, `success` or `failed`. There is no
"cancelled" value. A user who dismisses the prompt shows up as `failed`
once Safaricom's callback arrives.

### The M-Pesa prompt dialog

Every payment in the app starts from the same dialog:

- **Title:** "Complete your payment". **Description:** "<label> ·
  KSh <amount>".
- **Body:** "We'll send an M-Pesa prompt to your phone — enter your PIN
  to pay instantly."
- **Field:** "M-Pesa phone number" (placeholder `2547XXXXXXXX`),
  prefilled from `profile.phone` (the Contact phone on the Individual
  checkup, empty for the donation).
- **Button:** "Send M-Pesa prompt · KSh <amount>" ("Sending prompt…"),
  disabled while the phone is empty.
- **On success:** toast "Check your phone for the M-Pesa prompt". A start
  failure toasts the server's `detail`.
- **What follows depends on the flow:**
  - Assessment Locked and Plans & Pricing close the dialog and open the
    payment-outcome screen (below).
  - The Individual checkup closes it and shows its own "Payment request
    sent" panel.
  - The donation keeps the dialog open on "Payment request sent to
    <phone>." / "Enter your M-Pesa PIN on your phone to complete the
    payment." / "Your PDF receipt will be available in Receipts once
    payment is confirmed." with a "Done" button.

Web never shows the old Paybill tab, and mobile must not call
`POST /api/payments/paybill-reference/`. Paying by hand goes through the
manual payment fallback instead (§2a), when wellness-admin has it switched on.

### What happens after the prompt

**It's entirely asynchronous and server-to-server.** The user enters
their M-Pesa PIN on their own phone, and Safaricom calls the backend's
callback directly. Nothing the mobile app does triggers it.

The callback sets the payment's `status` to `success`/`failed` straight
away. On `success` the backend then, in the background, unlocks the
session, updates the booking, grants module access and creates the
receipt. So `status: "success"` is visible a moment **before** the access
exists. This is why step 3 below waits for module-access.

Follow one payment with `GET /api/payments/mine/<payment_id>/` (auth),
using the `id` the STK push or checkout returned. It's the payment shape
above plus `destination`, `access_ready` and `manual_review`:

```json
// GET /api/payments/mine/<payment_id>/
{
  "id": "<payment uuid>",
  "phone_number": "254712345678",
  "amount": "350.00",
  "service_type": "Custom Wellness Package",
  "status": "success",
  "method": "stk",
  "checkout_request_id": "ws_CO_...",
  "mpesa_receipt": "SKA1B2C3D4",
  "account_reference": "",
  "package_id": "",
  "created_at": "2026-10-27T10:00:00Z",
  "manual_review_status": null,
  "can_submit_manual_proof": false,
  "destination": { "screen": "cancer_hub", "label": "Opening your cancer health checks…" },
  "access_ready": true,
  "manual_review": null
}
```

- `manual_review` is `null` unless a confirmation message was sent for
  this payment; otherwise it's the latest one, with the shape in §2a
  ("3. Follow it").
- `access_ready` is `false` until `status` is `success` and every
  assessment category (or Monitoring) the payment grants is present in
  `module-access`. It's `true` straight away when the purchase grants no
  category (checkup, second opinion, a donation).
- `destination` is where to go next (table in step 4 below).
- Someone else's payment, or an unknown id, is a `404`.

Web itself polls the first page of `GET /api/payments/mine/` and checks
`module-access` (and, for Monitoring, `GET /api/vitals/access/`) on its
own; this endpoint gives mobile the same answer without that work. Per
flow:

- **Paying to unlock an assessment session.** The session query itself
  polls in the background: every 5 seconds while its status is
  `awaiting_payment`, and not at all otherwise.
  It polls every 5 seconds while the status is `awaiting_payment` and
  stops the moment it changes, usually to `in_progress`, or to
  `awaiting_call` for a `demo_restricted` account (§4). Keep that
  interval and stop condition.

  On top of it, web shows the payment-outcome screen below. It requires
  only that assessment's own category in `module-access`, says "Opening
  your assessment…", then drops the user straight back into the
  questions. The failure screen's dismiss button is "Back to the
  assessment".
- **Paying for access** — a Plans & Pricing checkout (single service,
  combo, All-in-One, custom build) or an assessment's locked screen. Web
  follows the payment to its outcome in a full-screen overlay. Mirror it:
  1. **Wait for the payment:**
     - **"Confirm on your phone"** ("Enter your M-Pesa PIN on the prompt
       sent to your phone. This page updates as soon as the payment is
       confirmed."). Poll `GET /api/payments/mine/<payment_id>/`
       every 3 seconds. Stop when its `status` is
       `success` or `failed`.
     - **After 2 minutes:** switch to **"Still waiting for
       confirmation"** ("We haven't received the M-Pesa confirmation yet.
       If you completed the payment, your access will unlock automatically
       as soon as it arrives.") with a "Close" button, but keep polling.
  2. **`failed`:** show **"Payment Not Completed"**, with a back arrow,
     and then:
     - A "Payment unsuccessful" box: "Your M-Pesa payment was not
       completed. You have not been charged for this attempt." and "If
       money has been deducted, do not pay again until your payment status
       is checked by support."
     - While manual payments are on (§2a): "Pay manually instead" with the
       manual payment panel for this same payment. While they're off: the
       old static "Alternative payment details" card (M-Pesa Paybill,
       Business number `522533`, Account number `8097136`, "Use the account
       details only after confirming the intended business recipient. A
       manual payment does not activate access until the payment is
       verified by the My Wellness Health team."), display-only.
     - "Need help?": "Email support" (`mailto:info@mywellnesshealth.co.ke`,
       subject "Payment support request") and "Call 0706 349 849"
       (`tel:+254706349849`), plus "When contacting support, share your
       payment reference if available. Do not share your M-Pesa PIN or
       OTP."
     - **Buttons:** "Try Payment Again" reopens the prompt dialog. The
       dismiss button is "Back to Package Benefits" on Plans & Pricing
       (back to the detail screen) and "Back to the assessment" on an
       assessment.
  3. **`success`:** don't navigate straight away. The access grant follows a moment after
     `status` flips. Keep polling, for at most 20 seconds, until `access_ready` is true,
     then navigate. Arriving early bounces the user straight back to the paywall.

     The success screen ("Payment Successful", "Your payment was confirmed
     by M-Pesa.", plus `destination.label`) stays up for at least 1.9 s even if
     access is already there.

     For Monitoring, web waits on `GET /api/vitals/access/`'s `has_access`
     instead, while `access_ready` only checks the Monitoring grant. These
     differ for a `demo_restricted` account: the grant exists, so
     `access_ready` turns `true`, but `has_access` stays `false` (§4).
  4. **Where to go:** open `destination.screen`:

     | `screen` | Screen |
     |---|---|
     | `cancer_hub` | The Cancer hub ([`assessments.md`](./assessments.md) §8) |
     | `metabolic_assessments` | The Metabolic assessment list |
     | `mental_assessments` | The Mental health assessment list |
     | `women_hub` | The Women's Health hub |
     | `sexual_health_check` | The Sexual & Urinary Health check |
     | `workplace_assessments` | The workplace wellbeing sessions |
     | `blood_pressure` | Blood Pressure |
     | `dashboard` | Dashboard |

     From an assessment's locked screen, go straight back into that assessment instead.
- **Individual check-up.** No payment-outcome screen. After the
  prompt is sent it shows "Payment request sent" (see
  [`bookings-and-consultations.md`](./bookings-and-consultations.md) §2).
  The booking's status (`pending` → `confirmed`) is just re-fetched the
  next time Appointments is opened.
- **The donation.** No payment-outcome screen; the dialog's own "Payment
  request sent" view is the end of the flow.

`GET /api/payments/mine/` is a cursor-paginated list of the payment shape,
newest first, 25 per page, `?cursor=`. It returns
`{ "next", "previous", "results" }`. It backs **Billing → Payments**
(§5).

`GET /api/payments/module-access/` (auth) returns
`{ "unlocked": { "<Category>": "<expires_at ISO>" } }`. Only categories
that haven't expired are listed, each with its furthest-out expiry.

### Endometriosis donation and subsidy

- **The donation card** (on the Endometriosis Learn More page, reached
  from the Women's Health hub):
  - "Choose an amount": KES 50 (default), 100 or 200, or "Other amount
    (KES)". It shows "Selected: KES …", or "Enter an amount greater than
    zero." when the amount is invalid.
  - **"Donate to endometriosis awareness"** opens the M-Pesa prompt dialog
    (label "Endometriosis Awareness Donation"), which calls
    `POST /api/payments/donations/endometriosis-awareness/stk-push/`
    (auth). Body is `{ "phone", "amount" }` (amount 1–150000), with no
    target. The server sets `service_type` itself to
    `"Endometriosis Awareness Donation"`. It returns `201` with the
    payment shape (§2); refusals are `400` `{"detail", "code"}` like the
    STK push.
  - **Donations can only be made with the M-Pesa prompt.** There is no
    pay-by-hand path for them: while manual payments are `manual_only`
    (§2a) the donation is refused with `400`
    `code: "manual_payments_only"` ("M-Pesa prompts are unavailable right
    now…"). Show the message; don't offer the manual panel for a donation.
    A donation payment's `can_submit_manual_proof` is always `false`, and
    sending a confirmation message for one is refused with
    `code: "manual_not_supported"`.
- **"Apply for endometriosis subsidy if you can't afford it"** (under the
  Endometriosis "Assessment Locked" screen):
  `POST`/`GET /api/payments/donations/endometriosis-awareness/subsidy-application/`
  (auth).
  - The dialog is "Apply for a subsidized assessment" ("My Wellness
    Health funds subsidized Endometriosis Assessments through community
    donations. Tell us a little about your situation so we can review your
    application.").
  - Its fields: "Household income", "Employment status", "Number of
    dependents" and "Why do you need a subsidized assessment?". "Submit
    application" toasts "Application submitted — we'll review it and get
    back to you."
  - POST body: `{ "household_income_band", "employment_status", "dependents_count" (0–50), "reason" (≤1000) }`.
  - `household_income_band`: `under_10k` "Under KES 10,000/month",
    `10k_30k` "KES 10,000 - 30,000/month", `30k_50k` "KES 30,000 -
    50,000/month", `above_50k` "Above KES 50,000/month",
    `prefer_not_to_say` "Prefer not to say".
  - `employment_status`: `employed` "Employed", `self_employed`
    "Self-employed", `unemployed` "Unemployed", `student` "Student",
    `other` "Other".
  - GET returns the latest application,
    `{ id, status: pending|approved|rejected, decision_reason, created_at, reviewed_at }`,
    or **204** if the user has never applied.
  - Only one `pending` application is allowed at a time (400 *"You already
    have a subsidy application under review."*), and none once the user
    already has Endometriosis access.
  - Web hides the button while one is pending ("Your subsidy application
    is under review — we'll notify you once it's decided.") and after a
    rejection shows "Your previous subsidy application wasn't approved:
    <decision_reason>".

### Things the packages UI must also do

**Plans & Pricing** in the nav opens `/packages`, which redirects to the
Wellness Packages screen (`/wellness-packages`).

- **Cancer purchases ask first.** When the quote returns
  `requires_cancer_declaration: true`, "Choose This Package" opens the
  **"Before you continue"** screen ("Have you ever been diagnosed with
  cancer?") before review. "No" sends the answer to
  `PATCH /api/auth/cancer-diagnosis/` and continues to review; "Yes" opens
  the free diagnosed journey. Both are in [`assessments.md`](./assessments.md) §8.
  Checkout refuses until then with `400` and `code: "cancer_declaration_required"`.
  `POST /api/payments/stk-push/` applies the same check only to a
  package-only payment (`package_id` with no `session_id`, `booking_id` or
  `invoice_id`). An Individual check-up (`booking_id` + `core`/`all`/`premium`)
  is never asked, and web doesn't ask there. A Cancer-only package is
  refused for a recorded diagnosis on every path
  (`code: "cancer_diagnosed_blocked"`).
- **The Cancer details screen** ends with a panel under "Choose This
  Package". Not diagnosed: "Already diagnosed with cancer?", "You do not
  need to purchase the routine cancer risk assessment for an existing
  diagnosis. Access follow-up guidance at no charge." and "Continue to
  Free Follow-Up Guidance". Diagnosed (`profile.cancer_diagnosed`): "Your
  cancer follow-up guidance", "You told us you've been diagnosed with
  cancer, so the routine cancer risk assessment isn't needed. Your
  follow-up guidance is free." and "View My Follow-Up Guidance", with
  "Choose This Package" disabled. Both buttons open the diagnosed journey.
- **Under 18:** every payment is refused with `400` and `code: "adults_only"`. Show that a parent
  or guardian can pay from their own account.
- **Diagnosed users never see Cancer** in Standalone Packages or Create
  My Package: leave out every service in the catalog's
  `unavailable_service_ids` (§1), which is `["cancer"]` once the account
  has reported a cancer diagnosis. The quote, checkout and STK push calls
  refuse Cancer on its own with `400` and
  `code: "cancer_diagnosed_blocked"`. Bundles stay available.
- **The "Choose Your Package" screen** (https://staging.mywellnesshealth.co.ke/wellness-packages), top
  to bottom, under "Start with one health check, or choose complete
  wellness coverage for the year.":
  1. **"Choose What Works for You"** card: badge "For individual health
     needs", "From KSh {Cancer's `base_price_kes`} / year", "Explore
     individual services". Opens Standalone Packages.
  2. **"Everything in One Package"** card: badge "Complete annual
     package", `all_in_one.price_kes` / year, "One annual payment for all
     {N} service areas." (N = the number of `all_in_one.service_ids`,
     spelled out as a word, so "eight"), and four included-benefit lines.
     (Combined Packages' own All-in-One card uses `all_in_one.summary`
     instead, §1.)
     - **"Choose All-in-One · KSh 3,500"** goes **straight to review**
       (via the cancer question if needed), skipping the details screen.
       Back from review returns to Choose Your Package.
     - **"View Everything Included"** opens the All-in-One details screen
       (https://staging.mywellnesshealth.co.ke/wellness-packages, then that button): one card per included
       service. Each card's **"See benefits"** opens a separate benefits
       page for that service (scroll to the top), not an expanding panel:
       Back, "Included in {All-in-One name}", the service's hero, the
       Learn More card (below) for Cancer and Women's Health, the service's
       tabs, then the All-in-One price footer ("Pay once for 12 months",
       the price, "Billed annually", the included-services note and
       **"Choose This Package"** → review). Back returns to the details
       screen where the user left it.
- **Learn More cards inside packages.** The Cancer and Women's Health
  details screens (standalone, a combo's included services, and the
  All-in-One benefits pages) show a Learn More card between the title and
  the tabs:
  - Cancer: "Learn More About Cancer" ("Understand cancer, its risk
    factors, warning signs and when to seek help.") → `/assessments/cancer/learn-more`.
  - Women's Health: "Learn More About Endometriosis" ("Understand
    endometriosis, its symptoms and when to seek help.") →
    `/assessments/endometriosis/learn-more`.
  3. A **"MORE WAYS TO CHOOSE"** label, then three entry cards:
     - Standalone Packages ("Choose one health service.")
     - Combined Packages ("Choose a discounted bundle, including
       All-in-One.")
     - Create My Package ("Save KSh 50 on each additional paid service.")
- **Deep links.** `/wellness-packages?service=<service_id>` opens that
  service's details screen. `/wellness-packages?journey=diagnosed` (from
  the Cancer hub and Cancer Learn More) opens the diagnosed journey:
  "Your Cancer History", or "Your Follow-Up Guidance" when already
  diagnosed. The Blood Pressure / Blood Sugar pages send a locked,
  non-`demo_restricted` user (`GET /api/vitals/access/` `state: "locked"`)
  straight to `?service=monitor`; they never show a KES pay card.
  `state: "demo_locked"` shows the navigator block instead (§4).
- **Age tier.** Web shows a "Sexual Health age category" picker ("18–24 years" / "25+ years"
  on details screens, "18–24" / "25+" in Create My Package). When the catalog's
  `account_sexual_age_tier` (§1) is set, the picker is locked to that tier, with "Set from your
  account's age." under it. When it's `null`, the user picks. The server always prices from a
  known age whatever is sent, and the quote's `sexual_age_tier` echoes the tier it used. An
  under-18 account gets a `400`.
- **Monitoring's own details screen defaults the term to `monthly`**, so a
  price shows immediately. In Create My Package the term starts unset.
- **Picker and card price text comes from the catalog** (§1), never
  from fixed text in the app:
  - "BP and blood sugar monitoring" picker: one button per
    `price_options.monitor[]` entry, showing its `label`; the chosen
    option's `note` shows under it (with a gift icon for annual).
  - "Second-opinion appointment type" picker: one button per
    `price_options.opinion[]` entry, showing its `label`.
  - Combined Packages: each combo row's price is `price_display`, and the
    All-in-One card's line is `all_in_one.summary`.

  The price under each picker and on every footer comes from the quote
  (`total_kes`).
- **An incomplete selection isn't an error.** A quote `400` with
  `code: "selection_incomplete"` and a `field` means "pick that option". Web shows "Select an
  age category / a billing term / an appointment type above to see the price." for
  `sexual_age_tier` / `monitor_term` / `opinion_clinician_tier`, and disables "Choose This
  Package" instead of showing an error toast.
- **The review screen** ("Review Your Package", "SELECTED MEMBERSHIP")
  lists the quote's `lines`, then "Total".
  - For All-in-One it adds "Annual monitoring is included. Checkup
    assistance and the GP second-opinion review are each limited to one
    use." (no other extra lines).
  - Under the total: "Hospital and lab charges are excluded. All clinical
    opinions are subject to the booked provider's availability and agreed
    service scope.", then "Pay with M-Pesa" and "You'll get an M-Pesa
    prompt on your phone to confirm the payment."
  - "Pay with M-Pesa" opens the prompt dialog, labelled with the service,
    combo or All-in-One name, or "My Custom Wellness Package" for a custom
    build of several services. The dialog calls `custom-quote/checkout/`
    and then the payment-outcome flow above.

## 2a. Manual payment fallback (paybill or bank, confirmed by staff)

For when the M-Pesa prompt fails or Safaricom is down: the person pays by
hand, pastes the confirmation SMS, and staff approve it in wellness-admin.
Approval settles the payment exactly like an M-Pesa callback, so access
unlocks the same way and `access_ready` / `destination` work as usual.
Donations have no manual path (§2, "Endometriosis donation and subsidy").

**Is it on, and where to pay?** `GET /api/payments/manual-settings/` (auth):

```json
{ "mode": "off" }
// or
{
  "mode": "fallback",            // "fallback" | "manual_only"
  "method": "mpesa",             // "mpesa" | "bank"
  "bank_name": "",               // set for "bank"
  "paybill_number": "522533",
  "account_number": "8097136"
}
```

- `off`: M-Pesa prompt only; show nothing manual.
- `fallback`: prompt first; offer paying by hand after it fails, times out,
  or "didn't arrive".
- `manual_only`: no prompt at all. `stk-push`, custom checkout and the
  donation refuse a prompt with 400 `code: "manual_payments_only"`; go
  straight to the manual panel (not for a donation, which can't be paid by
  hand).

**1. A payment to attach the message to.** In `fallback` that's the payment
the prompt created. In `manual_only` (or to pay by hand from the start),
reserve one with the normal endpoints plus `"method": "manual"` and no
`phone`: `POST /api/payments/stk-push/` (§2) or
`POST /api/payments/custom-quote/checkout/` (§3). The server prices it the
same way, sends no prompt, and returns the usual `201` payment with
`"method": "manual_mpesa"` or `"manual_bank"`, `status: "pending"` and
`phone_number: ""`.
`"method": "manual"` while it's off is 400 `code: "manual_payments_off"`.

**An unpaid manual reservation** (no confirmation message sent yet) never
blocks the person:
- Asking again with `"method": "manual"` for the same thing (same session,
  booking, package on its own, or the same Create My Package selection) at
  the same price, while the same way of paying (`method` in
  `manual-settings`) is set, returns **the same payment** (same `id`,
  `201`). So reopening the manual panel is always safe.
- Anything else for the same thing (an M-Pesa prompt, a different price
  or selection, or a manual reservation after wellness-admin switched
  between M-Pesa and bank) creates a new payment and **replaces** the old
  one. The old one becomes `failed`, its `can_submit_manual_proof` is
  `false`, and sending a message for it is refused with
  `code: "payment_superseded"`. Earlier `failed` attempts at the same
  thing are replaced the same way, so only the newest attempt can ever be
  paid. Always attach the message to the payment the latest call
  returned.
- Once a confirmation message for it is waiting for review
  (`manual_review_status: "pending_review"`), the payment does block: a new
  prompt or reservation for the same thing is 400 *"A payment request is
  already pending…"* until staff approve or reject it.

**2. The pasted message.** `POST /api/payments/mine/<payment_id>/manual-proof/`
with `{"message": "<the whole SMS>"}` (max 2000). Offer it only for a
payment whose `can_submit_manual_proof` is `true` (it can be a pending or
`failed` prompt payment too; it goes back to `pending` and its `method`
becomes `manual_mpesa`/`manual_bank`). Returns `201` with the
payment-status shape below. 400 codes (`{"detail", "code"}`):

| code | When |
|---|---|
| `no_transaction_code` | M-Pesa method and no 10-character M-Pesa code in the message ("We couldn't find an M-Pesa transaction code in that message. Paste the whole confirmation message you received.") |
| `duplicate_code` | The code was already used for another payment or a submission still being checked |
| `already_submitted` | A message for this payment is already waiting for review |
| `already_paid` | The payment already succeeded |
| `payment_superseded` | A newer payment replaced this one (above); send the message for the newer one |
| `manual_not_supported` | A donation (donations can only be paid with the prompt) |
| `manual_payments_off` | Switched off meanwhile |
| `not_found` | Not the caller's payment |

Every code except `no_transaction_code`, `duplicate_code` and `not_found`
is exactly the case where the payment's `can_submit_manual_proof` is
`false`.

The server pulls the transaction code and amount out of the message; staff
see the whole text.

**3. Follow it.** `GET /api/payments/mine/<payment_id>/` now also has
`method` and `manual_review` (null unless a message was sent):

```json
"method": "manual_mpesa",
"manual_review": {
  "id": "<uuid>",
  "status": "pending_review",      // "pending_review" | "approved" | "rejected"
  "transaction_code": "SKL2XYZ123",
  "rejection_reason": "",
  "created_at": "…",
  "reviewed_at": null
}
```

- `pending_review`: web shows **"Checking your payment"** ("We've received
  your confirmation message (<code>). Our team is checking it, and your
  access unlocks as soon as it's confirmed. You can close this page; we'll
  let you know if there's a problem.") with "Close", polling every 15
  seconds.
- Approved → `status: "success"`: the normal success flow (web's text is
  "Your payment was confirmed." instead of "… by M-Pesa").
- `rejected` → `status: "failed"`: web shows the failure screen with
  "We couldn't confirm your payment: <rejection_reason>" and the manual
  panel again (the same code may be sent again after a rejection, and
  `can_submit_manual_proof` is `true` again). The customer is also sent
  the reason as the `manual_payment_rejected` notification (push, email,
  SMS and WhatsApp; see [`push-notifications.md`](./push-notifications.md),
  "Event-driven notifications").
- Approved: `mpesa_receipt` becomes the transaction code from the message,
  or `MANUAL-` plus 8 characters when a bank message had none; the receipt
  (§5) carries the same code.

The payments list (`GET /api/payments/mine/`) carries
`manual_review_status` (same values, or null) and `can_submit_manual_proof`
per payment, but not `manual_review`.

**Web's manual panel** (same everywhere):
- Box "Pay with M-Pesa Paybill" (bank: "Pay to our bank account") with
  Bank (bank only), "Business number" (bank: "Paybill number"), "Account
  number", "Amount" (KSh).
- Steps: (M-Pesa) "On M-Pesa, choose Lipa na M-Pesa, then Pay Bill, and pay
  the exact amount to the business and account number above." / (bank) "Pay
  the exact amount to the paybill and account number above, from M-Pesa or
  your bank app."; then "Copy the confirmation message you receive and paste
  it below."
- "Confirmation message" text box; button "Send confirmation" ("Sending…"),
  enabled from 10 characters; server errors shown under the box; note "Your
  access unlocks once our team confirms the payment. We'll let you know if
  there's a problem."

**Where web offers it:**
- The prompt dialog: in `manual_only` it shows "M-Pesa prompts are
  unavailable right now, so please pay using the details below." and the
  panel instead of the phone field; in `fallback`, after the prompt is sent,
  a link "Prompt didn't arrive or failed? Pay manually instead". After
  sending: "We've received your confirmation message." / "Our team is
  checking your payment. Your access unlocks as soon as it's confirmed, and
  we'll let you know if there's a problem." + "Done".
- The payment-outcome screen: the "Still waiting for confirmation" state
  adds "Prompt didn't arrive or failed?" + the panel; the failure screen
  replaces the static paybill card with it (above).
- Billing → Payments (§5): "Being checked" while `manual_review_status`
  is `pending_review`, otherwise "Paid manually?" (opens the panel for that
  payment) when `can_submit_manual_proof` is `true`.

## 2b. Choosing how to pay: M-Pesa, card or bank

**What to offer.** `GET /api/payments/options/` (auth) — the backend
decides; show exactly what it lists, in its order, with `default_method`
pre-selected:

```json
{
  "currency": "KES",
  "country_of_residence": "KE",
  "methods": ["mpesa", "card", "bank"],
  "default_method": "mpesa",
  "card_unavailable_reason": null,
  "bank_accounts": [
    {"id": "<uuid>", "bank": "equity", "bank_name": "Equity Bank", "account_name": "My Wellness Health Ltd",
     "account_number": "0123456789", "branch": "", "paybill_number": "247247"}
  ]
}
```

- People living abroad (`country_of_residence` not `KE`) get `card` first;
  M-Pesa stays on offer so a relative in Kenya can pay.
- `card` is listed only while card payments are on and the account has an
  email address. When card is on but the account has none,
  `card_unavailable_reason` is `"email_required"`: web shows "To pay by
  card instead, add an email address to your profile." under the choices.
- `bank` is listed only while at least one of our bank accounts is
  connected; `bank_accounts` lists them (empty otherwise).
- `mpesa` covers both the prompt and paying by hand (§2, §2a).

Web shows these as an **M-Pesa | Card | Bank** choice at the top of the
payment dialog (https://staging.mywellnesshealth.co.ke/wellness-packages →
any package → pay) — nothing when only M-Pesa is listed. Donations are
M-Pesa only: never offer card or bank there.

**Card.** `POST /api/payments/stk-push/` (or the custom checkout, §3) with
`"method": "card"` and no `phone`. 201 returns the payment with
`method: "card"`, `status: "pending"` and `checkout_url`. Open
`checkout_url` (in-app browser or the system browser); card details are
entered on the gateway's page, never in the app. Then poll
`GET /api/payments/mine/<id>/` every 3 seconds until `success` (unlock as
for M-Pesa, §2) or `failed` (declined, or nobody finished the checkout
within 30 minutes: "Your card payment was not completed. You have not
been charged for this attempt."). After paying, the gateway sends the
browser to the website's return page; close the browser as soon as your
poll sees `success`. Web's button reads "Pay by card · KSh <amount>", with
"You'll pay on Paystack's secure page with Visa or Mastercard. The price
is in Kenya shillings; if your card is in another currency, your bank
converts it."

**Bank.** Same endpoint with `"method": "bank"` and `bank_account_id`.
201 returns `method: "bank_transfer"`, `status: "pending"` and
`bank_details`. Show:
- "Your payment reference" — `bank_details.reference` (e.g. `MWH482913`),
  copyable, with "Quote it exactly — it's how we know the money is for
  this payment. Pay exactly KSh <amount>."
- "From M-Pesa" (only when `paybill_number` isn't blank): Paybill
  `paybill_number`, Account number `mpesa_account` (already combined with
  the reference the way that bank expects).
- "Bank transfer or branch deposit": `bank_name`, `account_name`,
  `account_number`, `branch` (when set), Reference / narration =
  `reference`.
- An **"I've paid"** button, then poll `GET /api/payments/mine/<id>/`
  (every 15 seconds is plenty) showing "Waiting for your bank payment" /
  "Your access unlocks automatically as soon as the bank tells us your
  money has arrived. M-Pesa payments take seconds; bank transfers can take
  a few hours. You can leave this page." and the reference. The bank's own
  notification settles it; nobody pastes a message. An unpaid bank
  transfer turns `failed` after 7 days.

With more than one account in `bank_accounts`, let them pick the bank
first (web: "Equity Bank | KCB Bank"); switching bank keeps the same
payment and reference, only `bank_details` changes.

**Switching or retrying.** An unfinished card checkout or unpaid bank
transfer never blocks the purchase: asking again with the same method
returns **the same payment** (same `checkout_url`, same reference), and
asking with another method replaces it (the old one turns `failed`). If
someone still pays a replaced one, staff are alerted to refund it — so
always show the newest payment's details.

**Errors** (400, `code` in the error envelope): `card_payments_off`,
`email_required` ("Add an email address to your profile to pay by card
-- the card receipt is sent there."), `card_checkout_unavailable` ("We
couldn't open the card payment page. Please try again in a moment, or
pay with M-Pesa."), `bank_payments_off` ("Paying by bank isn't available
right now. Please pay with M-Pesa."). Show the message and offer the
other methods.

## 3. Pricing a Plans & Pricing selection (Standalone, Combined, All-in-One, Create My Package)

Every Plans & Pricing purchase goes through this one pipeline: a single
standalone service, a combo, All-in-One or a Create My Package build. It
is two steps, stateless and then committed. Both endpoints **require
auth**, unlike the public catalog.

**Step 1 — live quote, as the user changes their selection** (no DB write):

```json
// POST /api/payments/custom-quote/
{
  "service_ids": ["cancer", "mental"],
  "sexual_age_tier": null,
  "monitor_term": null,
  "opinion_clinician_tier": null,
  "bundle": null
}
```

```json
// Response — recompute on every change, don't cache/derive the price yourself
{
  "requires_cancer_declaration": false,
  "sexual_age_tier": null,
  "lines": [
    { "service_id": "cancer", "price_kes": 200, "is_free": false, "is_discounted": false },
    { "service_id": "mental", "price_kes": 50, "is_free": false, "is_discounted": true }
  ],
  "discount_kes": 50,
  "total_kes": 250,
  "cheaper_combo": null,
  "bundle_id": null
}
```

Request rules:

- **`service_ids`:** no duplicates. **Order matters**: the first id is
  the full-price one.
- **`bundle`:** one of `cm`, `cn`, `cw`, `cs`, `all_in_one`. Either
  `service_ids` or `bundle` is required.
- **Bundles:** with `bundle` set, `service_ids`, `monitor_term` and
  `opinion_clinician_tier` are **ignored** and derived server-side. Web
  sends `{ "bundle": "all_in_one" }` or, for a combo,
  `{ "bundle": "<combo_id>", "sexual_age_tier": … }`.
- **Tier fields:**
  - `sexual_age_tier` (`youth` = 18–24, `adult` = 25+) is required when
    `sexual` is selected, and for `bundle: "cs"`.
  - `monitor_term` (`monthly`/`annual`) is required when `monitor` is
    selected.
  - `opinion_clinician_tier` (`gp`/`consultant`) is required when
    `opinion` is selected.
  - A missing tier is a 400 `{"detail": "<field> is required when '<id>' is selected.", "code": "selection_incomplete", "field": "<field>"}`
    (for `cs`: "sexual_age_tier is required for the cs bundle."). Other
    selection errors, such as "Select at least one service.", have no
    `code`.

Prices and discounts come only from the quote:

- **A bundle quote** returns every resolved service as a line with
  `price_kes: 0`. The bundle price is `total_kes`, with
  `discount_kes: 0`, `cheaper_combo: null` and `bundle_id` set.

Call `POST /api/payments/custom-quote/` on **every** selection change (web
does this exact round trip on every tap/toggle; never reproduce the
pricing rules client-side, even to show a quick optimistic number).
`cheaper_combo` (`{ "combo_id", "price_kes" }`), when non-null, means a
fixed combo would cost less than the current Create My Package
selection. It can only happen when exactly two selected services form a
combo. Web shows it in the builder as "A fixed bundle costs less — That
bundle costs KSh X instead of KSh Y" with a "View the lower-priced
bundle" button that opens that combo's details. Mirror that. The
builder's "View My Benefits" opens a benefits screen whose "Choose This
Package" goes to review.

**Step 2 — commit and pay** (creates the payment, initiates STK push in
one call):

```json
// POST /api/payments/custom-quote/checkout/
{
  "phone": "254712345678",
  "service_ids": ["cancer", "mental"],
  "sexual_age_tier": null,
  "monitor_term": null,
  "opinion_clinician_tier": null,
  "bundle": null
}
```

Send exactly the selection that was last quoted (for a bundle, e.g.
`{ "phone": "…", "bundle": "all_in_one" }`). `phone` uses the same regex
as §2. To pay by hand instead (§2a), send `"method": "manual"` and no
`phone`. Card and bank work here too (§2b): `"method": "card"`, or
`"method": "bank"` with `bank_account_id`, and no `phone`.

Returns `201` with the same payment shape as §2's STK push,
and the same payment-outcome flow afterward (§2, "Paying for access").
The server recomputes the total itself, so there is no `amount` field.

Things to know:

- **Labels.** The resulting payment always has
  `service_type: "Custom Wellness Package"` and `package_id: ""`, whatever
  was bought. Billing shows that label for it (Payments' "Service" and
  the receipt's `service_label`). Web shows its own label (the service,
  combo or All-in-One name) only on the prompt dialog.
- **Pending guard.** A second checkout while a custom-package payment is
  still `pending` fails with 400 *"A payment request is already pending
  for your custom package…"*. An unpaid manual reservation with no
  confirmation message yet doesn't count: the same selection with
  `"method": "manual"` returns that same payment, and anything else
  replaces it (§2a, "An unpaid manual reservation").
- **What settlement grants:**
  - **Categories:** an access grant per category service. Read the result from
    `GET /api/payments/module-access/`.
  - **`checkup` and `opinion` (the "medical checkup booking" and the
    "GP second-opinion review"):** no category and nothing for the app to
    redeem. The navigator team fulfils them. Web just routes the user to
    the Individual check-up page (checkup) or the dashboard (opinion).

## 4. `demo_restricted` accounts still pay — the unlock is different, not skipped

A `demo_restricted` account goes through the
**exact same** STK push / M-Pesa payment flow above — nothing about the
payment step itself is different, and the mobile app must never
special-case or skip payment for such an account. The only difference is
what happens *after* a successful payment settles:

- An ordinary account's paid assessment session moves to
  `in_progress` (the assessment questions become answerable).
- A `demo_restricted` account's session instead moves to **`awaiting_call`**
  — paid, but gated on a navigator phone call before the questions
  unlock. The session-polling behavior in §2 still applies identically;
  render `awaiting_call` as its own state rather than assuming any
  non-`awaiting_payment` status means "proceed to questions".
  - Web shows the "Payment received" navigator block.
  - Until the navigator has been alerted (`navigator_alerted_at` is
    `null`): "When you're ready to complete this assessment over the
    phone, let our team know." and an **"Alert Health Navigator"** button
    (`POST .../session/<session_id>/alert-navigator/`, see
    [`assessments.md`](./assessments.md)).
  - Afterwards: "A member of our team will call you at <phone> within one
    business day to complete this for you over the phone." and "Nothing
    else to do on your end for now."
- The same rule applies when a **package** payment unlocks other waiting
  sessions it covers. The access grant itself is identical for both kinds
  of account, so §2's module-access wait still completes normally.
- **Monitoring is the exception to that wait.** A `demo_restricted`
  account never gets BP/blood-sugar logging access from a purchase:
  `GET /api/vitals/access/`'s `has_access` stays `false` until a
  navigator clears the account. Web waits on `has_access`, so its
  payment-outcome wait for `monitor` runs the full 20 s before moving on.
  `access_ready` on `GET /api/payments/mine/<payment_id>/` only checks the
  Monitoring grant, which a `demo_restricted` purchase still gets, so it
  turns `true` at once; the Blood Pressure page then shows the navigator
  block rather than logging. See
  [`vitals-medications-appointments.md`](./vitals-medications-appointments.md)
  for the "Alert Health Navigator" path.

## 5. Billing (Payments, Invoices, Receipts)

**Billing** in the nav opens Payments; its three sub-pages are below.

- **Payments** (`/billing/payments`, "Every payment attempt on your
  account, successful or not."):
  - Calls `GET /api/payments/mine/` (all pages).
  - Columns: Date (`created_at`, date and time), Service (`service_type`),
    Amount ("KES <amount>"), Status (`status` badge), Receipt
    (`mpesa_receipt`, "—" when blank — for a card it's the gateway's
    transaction id, for a bank transfer the bank's), Paid with ("Card" for
    `method: "card"`, "<bank_name> · <reference>" for `bank_transfer`,
    otherwise `phone_number`).
  - A manual reservation's Phone is blank (`phone_number: ""`). An
    approved manual payment's M-Pesa Receipt is the transaction code taken
    from the pasted message, or `MANUAL-` plus 8 characters when a bank
    message had no code.
  - Last column, per row (§2a): "Being checked" when `manual_review_status` is `pending_review`;
    otherwise a **"Paid manually?"** button when `can_submit_manual_proof`
    is `true`, which opens a "Pay manually" dialog ("<service_type> · KSh
    <amount>") with the manual panel (§2a) for that payment. After sending:
    toast "Thanks — we'll check your payment and confirm shortly." and the
    list is re-fetched. Nothing otherwise. Decide this from the two fields
    only, never from `status` or `method`.
  - Empty: "No payments yet."
- **Invoices** (`/billing/invoices`, "Invoices generated from group and
  organization bookings."):
  - Calls `GET /api/invoices/mine/`, cursor-paginated, newest `issued_at`
    first (web fetches all pages).
  - Every `Invoice` has `account_type` `group` or `company`; the only
    thing that creates one is an organization/group package purchase.
    None of the user's own purchases (assessment unlocks, Individual
    checkup, Plans & Pricing, Monitoring, donations) produces an invoice.
  - So for a regular user this list is always empty and the page shows
    "No invoices yet." Mobile shows the same page and empty state. The
    row actions ("Pay", "PDF") only exist for organization invoices and
    are out of scope.
- **Receipts** (`/billing/receipts`, "Receipts generated automatically
  after a successful M-Pesa payment."):
  - Calls `GET /api/receipts/mine/`, cursor-paginated, newest `paid_at`
    first (web fetches all pages).
  - Each row: `{ id, receipt_number, amount_kes, mpesa_code, payer_name,
    payer_phone, service_label, payment_method, paid_at }`.
  - `payment_method` is `"mpesa"` (the prompt, Paybill, or paid by hand to
    the M-Pesa paybill) or `"bank"` (paid by hand to the bank account,
    §2a).
  - `mpesa_code` is the payment's code: the M-Pesa receipt code, or for a
    payment approved by hand the transaction code from the pasted message.
    For `"bank"` that is the bank's reference (or `MANUAL-` plus 8
    characters when the bank message had none), not an M-Pesa code.
    `payer_phone` is blank for a payment made by hand.
  - Columns: Receipt # (`receipt_number`), Paid (`paid_at`, date), Service
    (`service_label`), Amount ("KES <amount_kes>"), M-Pesa Code
    (`mpesa_code`, "—" when blank). Web keeps the "M-Pesa Code" heading
    for bank receipts too; mirror it.
  - Action "PDF": `GET /api/receipts/<uuid:receipt_id>/pdf/`
    (`application/pdf`,
    `Content-Disposition: attachment; filename="Receipt-<receipt_number>.pdf"`).
    A failure toasts "Could not download".
  - Empty: "No receipts yet."

The PDF download is **authenticated** (owner or admin, otherwise 403).
Web downloads it as a blob through its authenticated fetch, using the
`Content-Disposition` filename, not via a bare link. Do the same: send
the Bearer header and save the bytes.

Both list endpoints live under `/api/invoices/…` and `/api/receipts/…`,
not `/api/payments/`.

A receipt is created automatically when a payment settles, in the
background, so a moment after `status` flips to `success` (for a payment
made by hand, once staff approve it). Its `service_label` is the payment's
`service_type`:

- the package label (assessment unlocks),
- "Individual <package label> package" (Individual checkup),
- `"Custom Wellness Package"` (Plans & Pricing, including Monitoring), or
- `"Endometriosis Awareness Donation"`.

There is no separate "create my receipt" call; re-fetch `receipts/mine/`
after settlement.

---

Last verified against the code on 2026-11-11.
