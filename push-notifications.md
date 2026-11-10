# Push Notifications

> **Before building anything from this file, check it against the web
> platform** — the user web app, live on staging at https://staging.mywellnesshealth.co.ke/ (the source of truth).
> The mobile app implements exactly the regular-user features that exist
> and are usable there, with the same screens, labels and wording, and
> nothing more: no doctor, admin or organization-buyer features, no
> hidden UI, no mobile-only extras, and a feature behind one of web's
> build switches only behind the same switch. If something
> here doesn't match the web platform, or you think a feature is missing,
> don't build it — confirm with the product owner first.

Covers how a patient gets notifications on the native app (OneSignal),
web push (reference only), the dashboard's **Enable reminders** button,
**Account settings → Notifications**, every reminder and notification a
patient can receive (and what opens when they tap it), the doctor-visit
checklist follow-up page, and **"Notify a partner anonymously"**. Read
[`README.md`](./README.md) first for the shared envelope.

**Read this first:** there are two completely independent push channels
in this backend, and they are not interchangeable.

1. **Web Push** (VAPID, browser `PushManager`) — what the web app
   uses, because a browser tab is the only thing it has. **This does not
   apply to a native Flutter app at all.** A Flutter app has no browser
   `PushManager`, no VAPID keys to subscribe with, and nothing to
   register at the `PushSubscription` endpoint below.
2. **OneSignal** — the channel built specifically for a native mobile
   app, and the one Flutter should actually integrate.

Both are tried, independently, every time `send_push(user, title, body,
data)` fires (`apps/notifications/services.py`) — a user with a
registered browser subscription *and* the mobile app installed gets both
sends, not one or the other. Flutter only ever needs to care about the
OneSignal half.

## OneSignal integration — the one that matters for Flutter

There is **no backend device-registration endpoint for OneSignal, and
there never needs to be.** `send_onesignal_push` (`apps/notifications/services.py`)
targets a user by OneSignal's own `external_id` alias, matched against
`str(user.id)` (the Django user's primary key) — not a stored device/
player token:

```python
# apps/notifications/services.py, send_onesignal_push
"include_aliases": {"external_id": [str(user.id)]},
"target_channel": "push",
"headings": {"en": title},
"contents": {"en": body},
"data": data or {},
```

Each push carries `headings.en` (title), `contents.en` (body) and `data`
(the dict in the tables below). If `ONESIGNAL_APP_ID`/`ONESIGNAL_API_KEY`
aren't set on the server, the OneSignal send is silently skipped.

That means the entire integration, from Flutter's side, is:

1. Initialize the OneSignal Flutter SDK with your OneSignal App ID (same
   project the backend's `ONESIGNAL_APP_ID`/`ONESIGNAL_API_KEY` settings
   point at — these are server-side only, never shipped to the app;
   Flutter only needs the public OneSignal App ID for SDK init).
2. The **moment** the user is authenticated (right after login or
   signup, same moment the access/refresh tokens are stored — see
   `auth-and-signup.md`), call OneSignal's own native login API with the
   Django user's id as a string:

   ```dart
   OneSignal.login(userId.toString());
   ```

   This is the entire "registration" step. It happens **entirely on
   OneSignal's own servers** — nothing is POSTed to this Django backend
   to link a device. If you skip this call, `send_onesignal_push` will
   still "succeed" (OneSignal returns a request id) but silently reach
   zero devices, reported back as `errors: ["All included players are
   not subscribed"]` — which the backend treats as routine, not an
   error, so nothing will alert you that linking never happened. Verify
   it worked by checking the OneSignal dashboard's Audience view for
   that user id after a test login, not by watching for a backend error.
3. On logout, call `OneSignal.logout()` so a shared/reused device
   doesn't keep receiving a previous user's notifications. This has no
   backend-side equivalent either — purely a client-side unlink.

Asking the OS for notification permission is a separate step. Web asks
from two places: **Account settings → Notifications → "Turn on push"**
(any user, see the Notifications tab below) and the
dashboard's dialysis-day **Enable reminders** button.
`OneSignal.login()` alone doesn't show a permission prompt.

There is no unsubscribe/re-subscribe flow to build beyond that — no
`DELETE` call, no stored subscription row to manage. `PushSubscription`
(the model behind the VAPID web-push endpoints below) has nothing to do
with OneSignal/mobile at all; don't call `POST /api/push/subscribe/` from
Flutter — it expects a browser `PushSubscription.toJSON()` shape
(`endpoint` + `keys.p256dh`/`keys.auth`) that a native app has no
equivalent of, and doing so would create a junk `PushSubscription` row
that `send_push`'s web-push loop will then just fail to deliver to.

### Why this matters

`send_multichannel_notification`'s own docstring (`apps/notifications/tasks.py`)
states plainly: *"push alone reaches ~nobody: confirmed 0 of this
environment's users have ever registered a PushSubscription."* Today
reminders effectively land via email/SMS/WhatsApp, not push. Wiring
`OneSignal.login()` at the right moment is what lets push reach mobile
users at all, once they've granted permission.

### Patients DHA records as deceased

Reminders and other proactive messages stop on every channel (push, email, SMS,
WhatsApp) once DHA reports the patient as deceased. Things the account holder asks
for, such as a login code or a report sent to their email, still go out.

### What opens when the user taps a notification

Web opens `data.url` when the push has one, and **`/dashboard`
otherwise**. Only these carry a `data.url`, so every other notification
opens the **Dashboard**:
- the two post-visit pushes, "How was your visit?" and "Did you make it
  to your appointment?" (both the SHR-visit one and the Endometriosis
  follow-up prompt);
- the Sexual & Urinary 7-day check-in ("Your My Wellness Health
  check-in").

See the tables below. Mirror that: open the
screen for `data.url` when present, otherwise the Dashboard. Don't add
per-`data.type` routing that web doesn't have. `data.type` and the ids
next to it are still there if you need them for analytics.

## "Enable reminders" (dashboard)

Where web shows it (https://staging.mywellnesshealth.co.ke/dashboard): inside the amber
**"Today is a dialysis day"** banner ("Don't forget your dialysis
appointment today."). Both come from `GET /api/vitals/bp/monitoring-profile/`:
- **The block:** shown only when `pathway` is `"kidney_dialysis"`.
- **The banner:** inside the block, shown only when
  `is_dialysis_day_today` is true.
- **The schedule line:** under the banner (on any day), the profile's
  `dialysis_schedule_label` appears as a small line when it isn't null.

The **Enable reminders** button inside the banner shows only when push is
supported, this browser hasn't already enabled it (a flag the browser
stores after a successful subscribe), and the user is **not** using
someone else's account as their next of kin.

Tapping it (button reads **"Enabling…"** while working):
1. asks for browser notification permission,
2. subscribes the browser for web push with the VAPID key and sends the
   subscription to `POST /api/push/subscribe/`.

On success the toast is *"Reminders enabled — you'll get a notification
on dialysis days."* and the button disappears. On any failure (permission
denied, unsupported, a failed call) the toast is *"Couldn't enable
notifications. Check your browser's notification permission."*

Flutter equivalent: same banner, same conditions, same button and
toasts. Tapping it asks for OS notification permission through
OneSignal (`OneSignal.Notifications.requestPermission(true)`), with no
backend call. Hide the button once permission is granted (read
`OneSignal.Notifications.permission`) instead of using a stored flag.
The only wording that doesn't carry over is "browser's" in the failure
toast.

## Web Push endpoints (for reference only — not for Flutter)

Mounted at `/api/push/` (`CORE/urls.py` → `apps.notifications.urls`),
**not** `/api/notifications/` — there is no `/api/notifications/` mount
at all. If anything says `/api/notifications/vapid-public-key/` or
`/api/notifications/subscribe/`, that's wrong — use `/api/push/...`
(web does).

- `GET /api/push/vapid-public-key/` — `AllowAny`. Returns `{"public_key": "<vapid public key>"}`.
- `POST /api/push/subscribe/` — `IsAuthenticated` (DRF default, no explicit override). Body: `{"endpoint": "<browser push endpoint URL>", "keys": {"p256dh": "...", "auth": "..."}}` (`endpoint` must be a valid URL ≤500 chars, `keys` must include both). Upserts by `endpoint` — subscribing again from the same browser updates the row rather than duplicating it. Returns 201 with `{"id", "endpoint", "user_agent", "created_at", "last_used_at"}`.

Again: these two only make sense for a browser `PushManager`
subscription. Flutter should not call either of them.

## Account settings → Notifications

`GET`/`PUT /api/push/preferences/` (`NotificationPreferencesView`,
`apps/notifications/views.py`, `IsAuthenticated`) — the same
per-category channel toggle UI web exposes, and the mobile app should
expose the identical five categories with the identical rule.

Web's UI (the **Notifications** tab of **Account settings**,
https://staging.mywellnesshealth.co.ke/account?tab=notifications), top
to bottom:
- The panel heading: kicker *"03 / 06 · Communication preferences"*,
  title **"Notifications"**, intro *"Choose how you would like to receive
  reminders and account messages."*
- **"Push notifications on this device"** (described below).
- **"What to remind me about"**, *"Choose how you want to hear about each
  type of reminder."*, then one row per category:
  - The row's `label` in bold, and on a required row the small line *"At
    least one channel must stay on."*
  - Three switches labelled **Push**, **Email** and **SMS**. Web shows no
    WhatsApp switch.
  - On a required row, a switch is disabled only when it's the last channel
    still on, counting the hidden `whatsapp` value (as the server does).
- A **Save preferences** button (**"Saving…"** while working). Edits are
  saved together. Success toasts *"Notification choices saved"*; failure
  shows the error message, or *"Could not save your choices"*.

While loading it shows *"Loading your notification choices…"*; if the
`GET` fails, *"Could not load your notification choices."* Web still
sends `whatsapp` back unchanged, because it PUTs the full rows it got
from `GET`. To mirror web, hide WhatsApp too and send the stored value
back.

The Notifications tab isn't shown while the user is using someone else's
account as their next of kin. There `PUT /api/push/preferences/` is
refused with `403 next_of_kin_not_allowed` (see
[`next-of-kin.md`](./next-of-kin.md)).

**"Push notifications on this device"** (shown only where push is
supported): *"Off. Turn them on to get the reminders you allow by Push
below."* with a **Turn on push** button ("Turning on…"), or *"On.
Reminders you allow by Push below will arrive here."* with no button.
The button asks the OS for permission and registers this device
(on mobile: OneSignal's permission prompt, see above); success toasts
*"Push notifications are on for this device."*, failure *"Couldn't turn on
push notifications. Check that notifications are allowed for this
site."* The Push switches only choose which reminders may use push —
nothing arrives on a device that hasn't been turned on here (or via the
dialysis-day **Enable reminders**).

**Categories** (`NotificationPreference.Category`, `apps/notifications/models.py`):

| Value | Label |
|---|---|
| `medication` | Medication reminders |
| `appointment` | Appointment and booking reminders |
| `screening` | Screening reminders |
| `vitals` | Vitals and dialysis reminders |
| `product_updates` | New features |

**Channels** per category: `push`, `email`, `sms`, `whatsapp` — all
default to `true` for a category with no row yet (`apps/notifications/preferences.py`).

Rows show in the order the server returns them, labelled with each
row's `label` — don't hard-code the labels.

**The one validation rule that matters:** `medication` is a *required*
category (`REQUIRED_CATEGORIES`, `apps/notifications/preferences.py`)
— at least one channel must stay on for it. Submitting all four channels
off for `medication` fails with a 400:

```json
{ "error": { "detail": { "detail": "At least one channel must stay on for this notification type." }, "status_code": 400 } }
```

Show that message when it comes back.

`product_updates` ("New features") is shown as a row like the others,
but no backend job sends anything in that category yet.

### `GET /api/push/preferences/`

Response — a plain array, one object per category, always all five,
even if the user has never touched their preferences (defaults
synthesized on the fly, `preferences.all_preferences`):

```json
[
  {
    "category": "medication",
    "label": "Medication reminders",
    "required": true,
    "push": true, "email": true, "sms": true, "whatsapp": true
  },
  {
    "category": "appointment",
    "label": "Appointment and booking reminders",
    "required": false,
    "push": true, "email": true, "sms": true, "whatsapp": true
  }
]
```
*(trimmed — the real response includes all 5 categories)*

### `PUT /api/push/preferences/`

Send a list of the categories you want to change. **Each item needs
all four booleans**, `push`, `email`, `sms` and `whatsapp`, plus
`category`. Leaving one out is a 400. `label`/`required` are read-only
and ignored on write. Categories you don't send are left as they are.
Items are saved one by one: if a later item fails the medication rule,
earlier items in the same request are already saved. Web sends all five
rows every time. Returns the same full-list shape as `GET`, reflecting
what was actually saved.

```json
[
  { "category": "screening", "push": true, "email": false, "sms": false, "whatsapp": true }
]
```

## What triggers what (so mobile doesn't need its own, possibly-different reminder logic)

None of these is something the client calls. They just need to be
understood so you know *why* a push arrived and don't build a competing
client-side reminder scheduler that could drift out of sync with web's.

"push/email/sms/whatsapp" below means `send_multichannel_notification`
(`apps/notifications/tasks.py`): every channel the user's preference
for that category allows, with email only if the user has an email, SMS
only if they have a phone, and WhatsApp only if they have a linked
contact inside the 24h window. A notification sent with **no category**
ignores the Notifications tab entirely (every channel on).

### Scheduled reminders

Celery Beat jobs. Schedules come from `django_celery_beat` rows created
by data migrations (`apps/notifications/migrations/0002`, `0005`,
`0007`, `0010`, `0013`, `0015`, `0017`, `0018`;
`apps/health_exchange/migrations/0020`). There's no
`CELERY_BEAT_SCHEDULE` dict. Crontab times are Africa/Nairobi
(`CELERY_TIMEZONE = TIME_ZONE`). Task names are in
`apps.notifications.tasks` unless noted.

| Trigger | Task · schedule | Category | Channels | Title · `data` |
|---|---|---|---|---|
| Upcoming appointment (**Appointments**) | `send_appointment_reminders` · every 30 min | `appointment` | push/email/sms/whatsapp, exactly the channels picked under **Send reminders by** (`reminder_channels`, one or more) when any are set | "Upcoming appointment" · `{"type": "appointment", "appointment_id"}` — **two** reminders per appointment: `APPOINTMENT_REMINDER_LEAD_HOURS` (default 24h) before, and 2h before. None at all when **Remind me before this appointment** is off (`reminder_enabled: false`). A missing `appointment_time` counts as 08:00. Body names the facility and reason, e.g. "Your appointment at Nairobi Hospital is on Mon 9 Nov 2026 at 2:30 PM. Reason for visit: Diabetes clinic." Either part is left out when unknown. Sexual health, HIV, mental health and cancer visits say "Reason for visit: a confidential consultation." instead of the real reason, on every channel including push. A channel picked under **Send reminders by** is used even if the user's preferences have it off. No reminder when the linked booking is cancelled or completed. |
| Upcoming booking (a `ServiceBooking` with no linked appointment) | `send_booking_reminders` · every 30 min | `appointment` | push/email/sms/whatsapp | "Upcoming booking" · `{"type": "booking", "booking_id"}` — once, when `preferred_date` is within `BOOKING_REMINDER_LEAD_DAYS` (default 1 day). Same body as above. Not sent for a cancelled or completed booking |
| Doctor-visit checklist, 1h before a confirmed/paid booking's `appointment_time` | `send_doctor_checklist_reminders` · every 15 min | `appointment` | **One channel only, never push**: WhatsApp if reachable, else SMS, else email (`select_primary_channel`) | email subject "Before your appointment today" · no push. Only for bookings whose assessment + result has checklist items set up |
| Doctor-visit checklist follow-up, evening of the visit | `send_doctor_checklist_followups` · daily 20:00 | `appointment` | Same single channel, never push. WhatsApp gets an interactive chat; SMS/email (subject "How did your appointment go?") get a link to `/visit-checklist/<token>` (see "The doctor-visit checklist follow-up page" below) | no push |
| Package/module access expiring (within 7 days) | `send_screening_reminders` · every 30 min | `screening` | push/email/sms/whatsapp | "Your access is expiring soon" · `{"type": "screening_expiry", "category"}`. Cancer, mental health and sexual & urinary access doesn't name the category in the body |
| Re-assessment due (`ASSESSMENT_REASSESSMENT_COOLDOWN_DAYS` = 182 after a completed session) | same task | `screening` | push/email/sms/whatsapp | "You're due for a check-in" · `{"type": "screening_eligible", "assessment_slug"}`. Cancer, mental health and sexual & urinary assessments say "your last health check" in the body instead of the assessment's name |
| Next Corporate Workplace Wellbeing chapter unlocked (24h after the previous one, unless already started) | `send_corporate_wellbeing_chapter_reminders` · every 30 min | `screening` | push/email/sms/whatsapp | "Your next wellbeing session is ready" · `{"type": "corporate_wellbeing_chapter_ready", "assessment_slug"}` |
| Sexual & Urinary 7-day check-in due (once, 7 to 14 days after a health check that reported symptoms and reached care guidance; the wording stays general for lock screens) | `apps.assessments.tasks.send_sexual_health_checkin_invites` · every 6 hours | `screening` | push/email/sms/whatsapp | "Your My Wellness Health check-in" · `{"type": "sexual_health_checkin", "assessment_slug": "sti-uti-followup", "url": "/assessments/sti-uti-followup/start"}` |
| Dialysis day (per the BP monitoring profile's `dialysis_days`) | `send_dialysis_day_reminders` · daily 06:00 | `vitals` | push/email/sms only — **no WhatsApp branch**, to avoid double-sending alongside the WhatsApp bot's own identical dialysis reminder | "Treatment day today" (body deliberately doesn't name the condition) · `{"type": "dialysis_reminder"}` |
| Daily vitals-logging prompt | `send_daily_vitals_logging_reminder` · daily 08:00 and 20:00 | `vitals` | push/email/sms only, same WhatsApp-avoidance reasoning | "Time to log your vitals" · `{"type": "vitals_reminder"}` — goes to every active non-staff account not pending deletion, regardless of pathway or whether they already logged today (deliberately matching the WhatsApp bot) |
| Medication dose reminder (each `reminder_times` entry, within the course's start/end dates) | `send_medication_reminders` · every 15 min | `medication` | push/email/sms/whatsapp (ignores `reminder_channel`) | "Time for your medication" · `{"type": "medication_dose", "medication_id"}` — can arrive up to ~15 min after the set time. Web's medication form has no field to set `reminder_times`; it only lists existing ones in the **Medications** page table's **Reminders** column |
| Medication refill due | `send_medication_refill_reminders` · daily 09:00 | `medication` | push/email/sms/whatsapp, narrowed to the **Send reminders by** channel when set | "Time to refill your medication" · `{"type": "medication_refill", "medication_id"}` — only when **Send me refill reminders** is on (`refill_reminder_enabled`) and the refill isn't already arranged. A standard medication is due `MEDICATION_REFILL_REMINDER_LEAD_DAYS` (default 3) before its `refill_due_date`; an insulin when its stock estimate from logged injections is low ("soon" or "critical"). Once per refill cycle; marking it **Refilled** starts a new cycle |
| SHR visit closed at the facility (not sent for signup visits or visits opened over 7 days ago) | `apps.health_exchange.tasks.reconcile_closed_shr_visits` · hourly | `appointment` | push/email/sms/whatsapp, except that WhatsApp is swapped for an interactive chat for the attendance check and the Endometriosis follow-up | "How was your visit?" · `{"type": "post_visit_followup", "visit_id", "has_data": true, "url"}` or "Did you make it to your appointment?" · `{"type": "post_visit_attendance_check", "visit_id", "has_data": false, "url": "/visits/<visit_id>/follow-up"}` — see [`health-records-and-shr.md`](./health-records-and-shr.md) §5 |
| Endometriosis referral visit date passed 2-14 days ago and no facility reported it (once per booking) | `send_post_visit_followup_prompts` · daily 10:00 | `appointment` | push/email/sms/whatsapp | "How was your visit?" · `{"type": "post_visit_followup", "booking_id", "assessment_slug": "endometriosis-followup", "url": "/assessments/endometriosis-followup/start"}`. Open the follow-up assessment. |

### Event-driven notifications

Sent the moment something happens, not on a schedule.

| Trigger | Where | Category | Channels | Title · `data` |
|---|---|---|---|---|
| An admin approves the patient's **Apply for endometriosis subsidy** application (or grants a subsidy directly) | `apps/payments/services.py`, `grant_endometriosis_subsidy` | `screening` | push/email/sms/whatsapp | "You've been selected for a subsidized Endometriosis Assessment" · `{"type": "endometriosis_subsidy_grant", "grant_id"}` |
| An admin rejects that application | `reject_endometriosis_subsidy_application` | `screening` | push/email/sms/whatsapp | "Update on your Endometriosis Assessment subsidy application" (body includes the admin's reason) · `{"type": "endometriosis_subsidy_application_rejected", "application_id"}` |
| A facility checks the patient in for a referred booking (inbound HIE encounter `in-progress`) | `apps/health_exchange/inbound_clinical.py`, `sync_booking_status_from_inbound` | none | push/email/sms/whatsapp, ignoring preferences | "Your consultation has started" · `{"type": "consultation_started", "booking_id"}` |
| A facility sends diagnoses, prescriptions, treatment notes or lab results (inbound HIE, or an SHR visit's records) | `materialize_clinical_records` | none | push/email/sms/whatsapp, ignoring preferences | "Your consultation results are ready" · `{"type": "consultation_results_ready", "booking_id"}` (`booking_id` may be `null`) |
| A facility schedules a follow-up visit (inbound HIE) | `materialize_follow_up_booking` | none | push/email/sms/whatsapp, ignoring preferences | "A follow-up has been scheduled" · `{"type": "follow_up_scheduled", "booking_id"}` (the new booking) |

None of these carries a `data.url`, so on web a tap opens the Dashboard.

## The doctor-visit checklist follow-up page (`/visit-checklist/<token>`)

The evening SMS/email follow-up above links to a public web page
(`https://staging.mywellnesshealth.co.ke/visit-checklist/<token>`, no sign-in). WhatsApp-reachable
patients answer in the chat instead and never see it. The link is a
`FRONTEND_URL` web address and no push carries it, so it opens in the
browser. Mobile doesn't need its own copy of this page; this is here so
you know what the patient sees.

- `GET /api/checklist-response/<token>/` (`AllowAny`; token ≤22 chars) →
  `{"response": {"attended": true|false|null, "items": [{"text", "answer_type": "checkbox"|"text"}], "already_responded": bool}}`,
  or `{"response": null}` (not found: *"Link not found"*), or
  `{"response": null, "expired": true}` (*"This link has expired"*;
  links last 7 days).
- The page asks *"Did you make it to your appointment today?"* with
  **Yes, I went** / **No, not yet**. "No" (or "Yes" with no items) posts
  straight away. "Yes" with items shows *"What did the doctor say?"*:
  a checkbox or a text box (*"Type what the doctor told you…"*) per
  item, then **Submit**. Unticked checkboxes are sent as `false`.
- `POST /api/checklist-response/<token>/` with
  `{"attended": bool, "answers": {"<item text>": true|false|"text"}}`
  (`answers` optional, keyed by item text) → the same shape as `GET`.
  Resubmitting overwrites. Then *"Thanks for letting us know"*.
  An already-answered link shows *"You've already answered this one"*.

## "Notify a partner anonymously" (Sexual & Urinary Health result)

A patient feature on the `sti-uti` result page
(`https://staging.mywellnesshealth.co.ke/assessments/sti-uti/complete`). It opens a
dialog that creates a
shareable, anonymous link. It sends no notification itself — the
patient shares the link.

Show the button only when the result's `presentation.partner_notification_offered`
is true. The server sets it for every Sexual & Urinary result, including older
results without the dedicated layout. It's false, for example, for urgent-safety
results and for the `UNREVIEWED` and `KIDNEY_INFECTION` pathways. Its label
depends on the result layout (`presentation.layout`, see
[`assessments.md`](./assessments.md)):
- **"Request confidential partner notification support"** in the
  `sexual_health` layout;
- **"Notify a partner anonymously"** on an older result.

The dialog: title **Notify a partner anonymously**, *"Share a
confidential link with a recent partner so they can also get checked.
Your identity is not shared."*, an **Optional personal note** box
(*"(they will see this — no names recommended)"*, max 500 characters,
placeholder *"E.g. Please get checked when you can — it's free and
quick."*), the note *"The page they open will not reveal who sent the
link. Links expire after 60 days."* and a **Generate anonymous link**
button.

```
POST /api/push/partner-notifications/
{ "pathway": "sti", "message": "" }
```

- `pathway`: the result's `presentation.partner_notification_pathway`
  (`"sti"` or `"both"`; it's `null` only when no link is offered). (The server accepts any string
  ≤32 chars; the recipient page also knows `"uti"` and `"kidney"`, but
  web only ever sends these two.)
- `message`: the trimmed note, or `""` when empty (≤500 chars).
- `IsAuthenticated`. `201` →
  `{"id", "token", "pathway", "message", "created_at", "expires_at"}`
  (`expires_at` is 60 days out). On error web toasts the error message,
  or *"Could not create link"*.

The link is the **web** URL `<web origin>/p/<token>` (web uses its own
site origin; mobile should use the same public web origin), because the recipient opens it in a browser, usually without
the app. After creating it, the dialog shows **Your link** and four
buttons:
- **Copy link** (→ **Copied**; toast *"Link copied"*; on failure *"Copy
  failed — long-press the link to copy manually"*),
- **WhatsApp** (`https://wa.me/?text=<share text>`),
- **SMS** (`sms:?&body=<share text>`),
- **Email** (`mailto:?subject=A confidential health notice&body=<share text>`),

where the share text is *"I'd like you to see this confidential health
notice from My Wellness Health: <link>"*. Below them: *"You can generate
one link per partner. Links expire after 60 days."* and a **Create
another link** button
(clears the note and link). Closing the dialog also resets it.

Web has **no** revoke or "my links" screen. The backend's `GET /api/push/partner-notifications/mine/`
and `DELETE /api/push/partner-notifications/<id>/` exist but web never
calls them — don't build them.

The recipient's page (`/p/<token>`, public web, no sign-in) calls
`GET /api/push/partner-notifications/lookup/<token>/` (`AllowAny`,
token 8–64 chars). It returns `{"notification": {"pathway", "message",
"created_at", "expires_at"}}` (`message` is `null` when empty, no sender
details), `{"notification": null}` (not found or revoked), or
`{"notification": null, "expired": true}`. Every lookup counts as a
view. Mobile doesn't need its own copy of this page.

---

Last verified against the code on 2026-11-09.