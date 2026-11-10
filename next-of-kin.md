# Next of kin

An account holder can let someone use their account. That person signs in with
their own login. All rules are enforced by the API, so the app only calls these
endpoints and shows what comes back.

All calls need the user's normal token. Errors use the standard envelope:
`{"error": {"detail": ..., "status_code": ...}}`. For a refused action, show
`error.detail.detail`. The one exception is `404` (an id that is missing or not yours,
or an invitation that is no longer valid), which comes back with **no body at all**.

On web this lives on **Account settings → Next of kin**
(https://staging.mywellnesshealth.co.ke/account?tab=next-of-kin). The screens are
described under "Screens" below.

## Holder endpoints

| Call | Body | Success |
|---|---|---|
| `GET /api/next-of-kin/` | | `200`, list of Grant |
| `POST /api/next-of-kin/` | `{phone?, email?, name?, consent}` | `201`, Grant |
| `POST /api/next-of-kin/<id>/resend/` | | `200`, Grant |
| `DELETE /api/next-of-kin/<id>/` | | `204` |
| `GET /api/next-of-kin/activity/` | | `200`, list of Activity |

`consent` must be `true`. Show this next to its checkbox, word for word:

> I agree that this person can see everything in my account, including any sexual
> health, HIV, mental health and cancer records. They can also log vitals, complete
> assessments, book visits and make payments for me, on this website and on WhatsApp.
> I can remove them at any time.

`POST /api/next-of-kin/` sends a real SMS and/or email, and is throttled at `10/hour`
(scope `next_of_kin_invite`). Refusals are a `400` with the message in
`error.detail.detail`, for example:
- "Enter their phone number, their email, or both."
- "Enter a valid Kenyan phone number."
- "This is your own contact. Add someone else's."
- "You have already added this person."
- "You can have up to 3 next of kin. Remove one first."
- "Please confirm that you understand and agree." (`consent` false, a field error on
  `consent`)

**Grant**

```json
{
  "id": "uuid",
  "name": "",
  "kin_name": null,
  "phone": "",
  "email": "kin@example.com",
  "status": "pending",
  "holder_digits": "915",
  "code_expires_at": "2026-11-13T09:34:37+03:00",
  "code_locked": false,
  "accepted_at": null,
  "created_at": "2026-11-06T09:34:37+03:00"
}
```

`status` is `pending` (invited, not yet accepted) or `active`. Ended grants aren't
listed. Show `holder_digits` when it isn't null; it's only set while `pending`.

Offer **Send new code** on every `pending` grant, as web does, whatever
`code_locked` says. `code_locked` is true after 5 wrong tries; web then also shows
the "Too many wrong tries" line (see "Screens"). A resend changes the digits, so show
the ones in its response. Resend refusals (`400`): "This invitation is no longer
waiting to be accepted.", "Please wait a moment before sending another code.", and
"Too many codes sent. Remove this invitation and add them again." (at most 5 codes per
invitation).

**Activity**

```json
{"id": "uuid", "at": "...", "who": "Mary", "event": "activity", "verb": "viewed", "area": "vitals", "channel": "app", "text": "Mary viewed your vitals in the app"}
```

Newest first, at most 100 entries. Show each entry's `text`: the sentence the server
writes, e.g. "Mary opened your account", "Mary accepted your invitation" or "Mary
viewed your vitals on WhatsApp". It ends in " in the app" or " on WhatsApp" for those
channels, on activity and account-opened entries. Don't build the sentence in the app.

The other fields are there if needed:
- `who` is the next of kin's name or contact, or "A former next of kin".
- `event` is one of `activity`, `accepted`, `declined`, `stepped_down`,
  `session_started` or `session_ended`.
- `verb` and `area` are only set for `activity`: `verb` is `viewed`, `updated`,
  `removed` or `downloaded`, and `area` is a plain-language area such as `vitals`,
  `assessments`, `medical history` or `annual wellness plan`.
- `channel` is `web`, `app` or `whatsapp`. The server logs `app` for requests that
  carry the app's `X-Mobile-Client-Secret` header, which the app sends on every
  request (see [`README.md`](./README.md), "The mobile client secret").

The time next to each entry is `at` as a local date and time, e.g. "6 Nov 2026, 9:34 am".

## Invited person endpoints

| Call | Body | Success |
|---|---|---|
| `GET /api/next-of-kin/invitations/<token>/` | | `200`, `{holder_name, code_expires_at}` |
| `POST /api/next-of-kin/invitations/<token>/accept/` | `{holder_digits, kin_digits}` | `200`, Account |
| `POST /api/next-of-kin/invitations/<token>/decline/` | | `204` |
| `GET /api/next-of-kin/accounts/` | | `200`, list of Account |
| `DELETE /api/next-of-kin/accounts/<id>/` | | `204` |

**Account**: `{"id": "uuid", "holder_name": "Jane Doe", "accepted_at": "..."}`

`holder_digits` and `kin_digits` are 3-digit strings. `holder_digits` comes from the
holder, and `kin_digits` from the invitation message. `accept` is throttled at
`20/hour` (scope `next_of_kin_accept`).

| Response | Meaning |
|---|---|
| `401` on the invitation calls | Not signed in. Keep the token, sign in or sign up, then call again |
| `404` on `GET` (empty body) | Invitation no longer valid (accepted, declined, cancelled or expired) |
| `400` on `accept` | Refused: show `error.detail.detail`, e.g. "Those digits don't match. Check both sets and try again.", "This code has expired. Ask them to send a new one.", "Too many incorrect attempts. Ask them to send a new code.", "You can't be your own next of kin.", "You are already their next of kin.", "This invitation is no longer valid." |
| `400` on `decline` | "This invitation is no longer valid." |

The invitation token comes from the link
`/next-of-kin/accept/<token>`.

### Sign-in before accepting

If the invited person's account isn't confirmed, sign-in returns
`email_not_confirmed` or `phone_not_verified`, and they must enter the account's
6-digit code first (see [`auth-and-signup.md`](./auth-and-signup.md)). That code is
not `holder_digits` or `kin_digits`. Say so on the screen when an invitation token is
being kept, and return to the invitation once they are signed in.

## Using the account

1. If the user is already inside someone's account (`GET /api/next-of-kin/session/`
   says `acting: true`), first `POST /api/next-of-kin/session/exit/` and stop sending
   the header. `enter/` is refused with `403 next_of_kin_not_allowed` while acting, so
   web always switches from the user's own account.
2. `POST /api/next-of-kin/accounts/<id>/enter/` returns Account (`404` if the grant is
   no longer active).
3. Send `X-Acting-For: <id>` with the user's normal token (and the app's usual
   `X-Mobile-Client-Secret`) on every request. Each
   endpoint then answers for the holder. Don't send it to the sign-in, sign-up, token
   refresh and logout calls; signing in or out ends acting.
4. Show the banner from `GET /api/next-of-kin/session/`:
   `{"acting": true, "grant_id": "uuid", "holder_name": "...", "kin_name": "..."}`,
   or `{"acting": false}`.
5. To leave, `POST /api/next-of-kin/session/exit/` (`204`), then stop sending the header.

Clear cached data when switching in either direction, because it belongs to a
different person. Web reloads the whole app on every switch and lands on the
Dashboard after entering, and on Account settings → Next of kin after leaving.

On web, acting lasts only for the browser session: closing the browser, signing in or
signing out returns the user to their own account. Nothing about it is stored on the
server beyond the grant itself.

### What a next of kin can reach

The API allows only some endpoints while acting. Anything else returns
`403 next_of_kin_not_allowed`:
- **Full access:** dashboard, health profile, assessments (consent for dependants and
  other adults stays read-only, and donations are refused), vitals, medications,
  appointments, payments, bookings, facilities, care navigation, the cancer-diagnosis
  answer, the annual wellness plan and its PDF.
- **Read only:** invoices, receipts, My Medical History, SHA eligibility, the AfyaConnect
  and SHR status reads, SHR visits, notification preferences, the geography and
  formulary lookups, and the session banner.
- **Refused:** everything else, for example security and login settings, account
  deletion, data export, privacy settings, notification-preference changes, the
  wellness plan opt-ins, DHA consent and refresh actions, partner links and managing
  next of kin.

Web also hides what a next of kin can't use:
- **Account settings** shows only the **General** tab.
- On General, the contact-verification rows and the "AfyaConnect sync" row are hidden,
  and phone and email changes aren't sent.
- The dashboard's dialysis-day **Enable reminders** button is hidden.

## Errors while acting

Both are `403`, with `error.detail` of `{"detail": "...", "code": "..."}`.

| `code` | What the app does |
|---|---|
| `next_of_kin_access_ended` | Web shows the message ("You no longer have access to this account.") as an error toast, stops sending the header and returns to the user's own Dashboard. Clear the cache |
| `next_of_kin_not_allowed` | Show `error.detail.detail` ("Only the account holder can do this.") |

## Screens

Web's wording, word for word.

### Account settings → Next of kin

**"Your next of kin"**, *"Someone you trust can use your account from their own login:
see your records, log vitals, complete assessments and make payments for you."*
- "Loading…" while the list loads; *"You haven't added anyone yet."* when it's empty.
- One box per Grant. The title is `name`, else `kin_name`, else the contacts. Under it,
  `phone` and `email` joined by " · ". A badge reads **"Waiting for them"**
  (`pending`) or **"Has access"** (`active`).
- On a pending grant with `holder_digits`: *"Your 3 digits. Tell them only when they
  contact you."*, the digits in large type, then *"They received the other 3 digits and
  a link. They need all 6 to accept."* When `code_locked` is true it adds *"Too many
  wrong tries. Send a new code to continue."*
- Buttons: **Send new code** (pending only; toast *"New code sent. Your digits have
  changed too."*, or the error / *"Could not send a new code"*) and **Cancel
  invitation** (pending) or **Remove** (active).
- Removing asks *"Cancel this invitation?"* (pending) or *"End {title}'s access now?"*
  (active), with **Yes, remove** / **Keep**. Success toasts *"Invitation cancelled"* or
  *"Access ended"*; failure shows the error or *"Could not remove them"*.
- **Add next of kin** button. Web disables it once the list has 3 entries and shows
  *"You can have up to 3. Remove someone to add another."* The server enforces the same
  limit (see the `400` above).

**"Add next of kin"** dialog, *"We'll send them an invitation with 3 digits. You'll see
the other 3 here, so they can only accept after speaking to you."*
- **Phone number** (placeholder "0712 345 678").
- **Email** (placeholder "name@example.com"), with *"Add either one, or both. We'll
  send the same 3 digits to each."*
- **Their name (optional)**, at most 150 characters.
- The consent checkbox with the text above.
- **Cancel** / **Send invitation**. Send is enabled once consent is ticked and a phone
  or email is filled in. Success toasts *"Invitation sent"* and closes the dialog;
  failure shows the error or *"Could not add them"*.

**"Accounts you can use"** (shown only when `GET /api/next-of-kin/accounts/` isn't
empty), *"You are next of kin for these people."* One row per Account with
`holder_name` and two buttons:
- **Open account** (see "Using the account"; failure toast: the error or *"Could not
  open this account"*).
- **Stop**, which asks *"Stop being their next of kin?"* with **Yes, stop** / **Keep**.
  Success toasts *"You no longer have access"* and reloads; failure shows the error or
  *"Could not do that"*.

**"Next of kin activity"**, *"What your next of kin did in your account, newest
first."*, each entry's `text`, or *"Nothing yet."*

### The banner while acting

Always on screen at the top while acting: *"You are using {holder_name}'s account as
their next of kin."* with a **Back to my account** button (leaves as in "Using the
account").

### Accepting an invitation (`/next-of-kin/accept/<token>`)

- Signed out: **"You've been asked to be someone's next of kin"**, *"Sign in or create
  your own free account to continue. You'll use your own login, never theirs."*, and
  *"If your account isn't verified yet, we'll first send you a separate 6-digit code.
  That code is not the 3 digits in your invitation, so keep those for the next step."*
  Buttons **Sign in** / **Create account**. Web keeps the invitation and returns to it
  after sign-in or sign-up.
- Valid invitation: **"{holder_name} wants you as their next of kin"**, *"If you accept,
  you'll be able to see all their health records, including sensitive ones, and log
  vitals, complete assessments, book visits and make payments for them. They can see
  what you do and can remove you at any time."* Two 3-digit inputs: **"The 3 digits we
  sent you"** (`kin_digits`) and **"The 3 digits from {holder_name}"**
  (`holder_digits`), then *"Contact {holder_name} and ask for the 3 digits shown in
  their account."* **Accept** is enabled once both are complete. **Decline** has no
  confirmation step. A failed call shows the error, or *"Could not accept this
  invitation"* / *"Could not decline this invitation"*.
- Accepted: **"You're now {holder_name}'s next of kin"**, *"They've been told. You can
  open their account now, or later from Account settings."*, with **Open their
  account** / **Go to my account**.
- Declined: **"Invitation declined"**, *"You won't have access to their account."*
- `404`: **"This invitation is no longer valid"**, *"It may have expired or been
  cancelled. Ask them to send you a new one."*

### Links from WhatsApp

WhatsApp messages to a next of kin can link to the web page
`/next-of-kin/open/<grant id>?next=<path>`. It signs the user in if needed, enters the
account (as in "Using the account") and opens `<path>`, or shows **"You can't open this
account"**, *"You may no longer have access, or you may be signed in with a different
login."* with **Go to my account**. It's a web link; the app doesn't need its own copy.

---

Last verified against the code on 2026-11-09.