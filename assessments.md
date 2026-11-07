# Assessments

> **Before building anything from this file, check it against the web
> platform** — the wellness-health user web app (the source of truth).
> The mobile app implements exactly the regular-user features that exist
> and are usable there, with the same screens, labels and wording, and
> nothing more: no CHP, doctor, admin or organization-buyer features, no
> hidden UI, no mobile-only extras, and a feature behind one of web's
> build switches only behind the same switch. If something
> here doesn't match the web platform, or you think a feature is missing,
> don't build it — confirm with the product owner first.

Covers: how the web app surfaces each assessment, catalog browsing,
session lifecycle (including the one-assessment-at-a-time rule), the
question-answer loop, payment gating/auto-unlock, completion and the
result screens, PDF reports, the dashboard's "My Health Checks &
Follow-Up", and the Cancer journeys. See the [README](./README.md) for the
shared envelope (auth, error shape, base URL) this file assumes.

Everything below is what the web app calls and shows.

## The assessments the web app offers

Web surfaces 20 assessment slugs, each from a specific entry point. Labels
below are the exact text the web UI shows (sidebar from `lib/nav-config.ts`,
dashboard cards, hub titles).

| Web entry point (sidebar / dashboard) | Where it lands | Slugs (backend `category`) |
|---|---|---|
| Sidebar "Assessments & Screenings" → **"Cancer Awareness & Screening"**; dashboard card **"Cancer Awareness"** (hidden once `profile.cancer_diagnosed` is true) | The Cancer hub `/assessments/cancer`, titled "Cancer Health Checks" (§8). Cards read "Breast Cancer", "Cervical Cancer", "Oesophageal Cancer", "Colorectal Cancer", "Prostate Cancer". The **"Cancer"** card on the unfiltered `/assessments` page goes to `/assessments?category=Cancer` instead (see the category list layout below) | `breast-cancer`, `cervical-cancer`, `esophageal-cancer`, `colorectal-cancer`, `prostate-cancer` (`Cancer`) |
| Sidebar → **"Hypertension & Diabetes"**; dashboard card **"Metabolic Health"** | `/assessments?category=Metabolic`, headed "Metabolic Condition" | `hypertension`, `diabetes` (`Metabolic`) |
| Sidebar → **"Mental Health & Wellness"**; dashboard card **"Mental Wellbeing"** | `/assessments?category=Mental health`, headed "Mental Wellbeing" | `phq9`, `gad7`, `stress` (`Mental health`) |
| Sidebar → **"Women's Health"**; dashboard card **"Women's Health"** | The Women's Health hub `/assessments/women-health` (see "Hub and Learn More screens" below) → "Endometriosis Health Check" card → the Endometriosis help screen: **"For myself"** or **"For a young loved one"** | `endometriosis`; `endometriosis-dependent` for "For a young loved one" (`Reproductive health`) |
| Sidebar top-level **"Sexual & Urinary Health"**; dashboard card **"Sexual Health"** | `/assessments?category=Sexual & urinary`, headed "Sexual & urinary health" | `sti-uti`, which uses its own flow (see "Sexual & Urinary Health Check V15" below). `sti-uti-followup` is the day-7 check-in, reached only from its invitation. A Sexual & urinary package purchase lands on `/assessments/sti-uti` |
| Sidebar top-level **"Ebola"** (red); dashboard **"Ebola"** card under "Public Health Information" | The Ebola hub `/assessments/ebola` (see "Hub and Learn More screens" below). Its **"Ebola Symptom & Exposure Assessment"** card ("Start assessment") opens the "Ebola Health Check" picker directly; its **"Learn More About Ebola"** card opens the Learn More page, whose **"Start Ebola Health Check"** button opens the same picker: **"For myself"** / **"For an adult loved one"** / **"For my child"** | `ebola-screening`, `ebola-screening-assisted`, `ebola-screening-child` (`Public health screening`) |
| Dashboard card **"Workplace Wellbeing check-in"**; a **"Corporate Workplace Wellbeing"** card at the bottom of the Mental Wellbeing list | `/assessments/corporate-wellbeing`: three chapter cards (§2.4) | `corporate-wellbeing-1`, `-2`, `-3` (`Workplace wellbeing`) |

`endometriosis-dependent`, `ebola-screening-assisted` and
`ebola-screening-child` are `hidden_from_catalog=True`: they never appear in
`GET /api/assessments/` and are only reached through the pickers above
(§2.3).

**Paid-access gating on entry.** Every `/assessments?category=…` list, the
dashboard and `/assessments` category cards, the Cancer hub and the
Women's Health hub check `module-access.unlocked[<category>]` first (see
[`payments-and-packages.md`](./payments-and-packages.md)). When it's
missing, web skips the list and goes straight to that category's package,
`/wellness-packages?service=<id>`. The Ebola and Workplace hubs work
differently (below).

| Category | Package `service` id |
|---|---|
| `Cancer` | `cancer` (not when `profile.cancer_diagnosed`; that user gets the free guidance, §8) |
| `Metabolic` | `metabolic` |
| `Mental health` | `mental` |
| `Reproductive health` | `women` |
| `Sexual & urinary` | `sexual` |
| `Workplace wellbeing` | `workplace` (the Mental Wellbeing list's Workplace card only) |

The gate runs both when the screen loads and when a card is tapped. Web
shows a spinner until `module-access` has loaded, so the locked list never
flashes. A `?category=Public health screening` link always goes to the
Ebola hub instead.

Ebola has no package of its own. The hub hides its assessment card, and
the Learn More page shows "Health check locked" with a "View packages"
button (→ `/wellness-packages`), when `can-start` returns
`ebola_access_required` (§4). In that state the Learn More page never
opens the picker, even from a `?view=entry` link.

**Workplace Wellbeing** (paused on the packages screens since 2026-10-30,
but still reachable as below). Both Workplace cards show only when the
user has `module-access.unlocked["Workplace wellbeing"]` **or** an
`occupation` on their profile (the dashboard reads `profile.occupation`
from `GET /api/dashboard/`). Without access both add "KES 200 to unlock."
and the button reads "View". With access it reads "Continue". The two
cards differ when access is missing:

- **Dashboard card:** always opens the hub `/assessments/corporate-wellbeing`.
  The hub has no access gate. Chapter 1's own intro page then shows the
  normal "Assessment Locked" card (§2.2), which sells the
  `workplace_wellbeing` category package (see
  [`payments-and-packages.md`](./payments-and-packages.md)).
- **Mental Wellbeing list card:** goes to
  `/wellness-packages?service=workplace`. The packages page ignores a
  hidden service in that link, so the user just lands on the packages
  home screen with no Workplace option.

**Filtering the catalog list** (web does this client-side, so mobile must
too):

- Drop every slug ending in `-followup` from lists and grids.
- Hide an assessment whose `excluded_gender` equals the user's profile
  gender, **unless `dependant_variant_slug` is non-null** (today only
  `endometriosis`), so the Women's Health card stays for a man, who can
  still use "For a young loved one". On the Endometriosis help tab a male
  profile sees a note instead of the "For myself" option.
- The unfiltered `/assessments` page, "Health Assessments & Risk
  Screenings", shows four category cards in this order: "Cancer",
  "Women's Health", "Mental Wellbeing", "Metabolic Condition". Subtitles:
  "Cancer risks and screening", "Endometriosis and periods", "Mood,
  anxiety and stress", "Blood pressure and diabetes". Each has an
  "Explore" link. A category with no assessment left after filtering is
  dropped. Sexual & urinary, Public health screening and Workplace
  wellbeing are left out (they have their own entry points above). Above
  the grid, a **"View plans & pricing"** card ("Unlock every assessment in
  a category with one package, or pay for a single assessment as you go.",
  "See packages" → `/packages`) shows while the user still has a package
  left to buy.
- The dashboard's **"Explore Health Checks"** grid (2026-11-03 design)
  has five tiles, in this order, with their own wording: **"Cancer
  Awareness"** ("Know your risks and screening needs"), **"Metabolic
  Health"** ("Hypertension and diabetes assessments"), **"Mental
  Wellbeing"** ("Stress, anxiety and mood"), **"Women's Health"**
  ("Endometriosis, periods and pain") and **"Sexual Health"** ("Private
  and confidential care navigation"), each with "Explore ↗". Same catalog
  filters as above; a tile shows only when its category has an assessment
  left after filtering, and Cancer Awareness is hidden once
  `profile.cancer_diagnosed` is true. Cancer goes to the Cancer hub,
  Women's Health to its hub, the rest to `/assessments?category=…`; a
  locked category goes straight to `/wellness-packages?service=<id>`.

**Category list layout** (`/assessments?category=…`). A header with a back
button (→ `/assessments`), "My Wellness Health" and the category name.

- **Cancer, Mental health and Metabolic** use a hero plus one card per
  assessment. Each card shows `short_title`, a fixed one-line description
  (falling back to `tagline`) and "Start health check". A fixed disclaimer
  sits under the list.

  | Category | Hero heading | Hero text | Disclaimer |
  |---|---|---|---|
  | Cancer | "Understand your cancer screening needs." | "Learn about warning signs, review relevant risk factors, and find out which screening options may apply to you." | "Health checks provide educational guidance and care navigation. They do not diagnose cancer or replace recommended screening tests or a clinical consultation." |
  | Mental health | "Check in with your mind." | "Understand your emotional wellbeing with confidential checks for mood, anxiety and stress." | "Health checks provide educational guidance and care navigation. They do not diagnose a mental health condition or replace a clinical consultation." |
  | Metabolic | "Stay ahead of pressure and sugar." | "Understand your blood pressure and blood sugar health, and know when to seek care." | "Health checks provide educational guidance and care navigation. They do not diagnose hypertension or diabetes, or replace clinical measurement and consultation." |

  The card descriptions:

  | Slug | Description |
  |---|---|
  | `breast-cancer` | "Review symptoms, family history, lifestyle factors and screening options." |
  | `cervical-cancer` | "Check HPV and screening history, reproductive health factors and warning signs." |
  | `esophageal-cancer` | "Understand swallowing symptoms, lifestyle risks and when to seek care." |
  | `colorectal-cancer` | "Review bowel symptoms, family history and screening guidance." |
  | `prostate-cancer` | (none, so it uses `tagline`) |
  | `phq9` | "Understand how you've been feeling emotionally over the last 2 weeks." |
  | `gad7` | "Explore feelings of anxiety and worry over the last 2 weeks." |
  | `stress` | "Reflect on how stressful the past month has felt." |
  | `hypertension` | "Review your blood pressure history, lifestyle, family history and warning signs." |
  | `diabetes` | "Review your blood sugar history, lifestyle, family history and warning signs." |

  The Mental Wellbeing list ends with the "Corporate Workplace Wellbeing"
  card ("A confidential three-session check-in on your work and
  wellbeing.", "3 sessions"), when eligible (above).
- **Sexual & urinary** uses a plain grid. A line reads "1 assessment ·
  5–10 min each". Each card shows the category chip, `short_title`,
  `tagline` and "Start".

Every card opens `/assessments/<slug>`, the intro (§2.2).

### Hub and Learn More screens

- **Women's Health hub** (`/assessments/women-health`), titled "Women's
  Health". Hero: "Understand your body better." / "Explore your
  reproductive health and keep track of symptoms that matter." Three
  cards:
  - "Learn More About Endometriosis" ("Learn more") → the Learn More page.
  - "Endometriosis Health Check" ("Start health check") → the Learn More
    page opened at its help tab (`?tab=help`).
  - "Period & Pain Tracker" ("Track now"). See
    [`vitals-medications-appointments.md`](./vitals-medications-appointments.md).
- **Endometriosis Learn More** (`/assessments/endometriosis/learn-more`).
  - Opened normally, it's titled "Learn About Endometriosis". It shows a
    hero ("Understand your symptoms. Take the next step.") and four tabs:
    "About", "Symptoms", "Get Help", "Awareness". The About, Symptoms and
    Awareness tabs end with "Start an endometriosis health check", which
    switches to Get Help.
  - Opened with `?tab=help`, it's titled "Endometriosis Health Check" and
    shows only the help content, with no hero or tabs.
  - **Get Help:** "Your health matters", "Understand your symptoms. Know
    your next step.", then two options:
    - **"For myself"** ("I'm 18 or older and completing my own
      assessment.") → `/assessments/endometriosis`. A male profile sees a
      note instead: "This health check is for women and girls. If you're a
      parent, guardian or authorised adult helping someone under 18,
      continue below."
    - **"For a young loved one"** ("I'm a parent, guardian or authorised
      adult helping someone under 18.") → the dependant picker for
      `endometriosis-dependent` (§2.3).

    Then "The caregiver assessment includes separate consent and
    child-safeguarding steps." and a "Why your report matters" accordion.
  - **Awareness:** carries the donation card (see
    [`payments-and-packages.md`](./payments-and-packages.md)).
  - The educational copy on every tab is static text in
    `app/(app)/assessments/endometriosis/learn-more/page.tsx`. Copy it
    from there.
- **Ebola hub** (`/assessments/ebola`). Hero: "Know your risk. Act early."
  Two cards: "Learn More About Ebola" ("Learn more") and "Ebola Symptom &
  Exposure Assessment" ("Start assessment"). The second card is hidden on
  `ebola_access_required`.
- **Ebola Learn More** (`/assessments/ebola-screening/learn-more`), titled
  "Learn More About Ebola".
  - Four tabs: "Basics", "Symptoms", "Spread", "Next Steps". The static
    copy is in `app/(app)/assessments/ebola-screening/learn-more/page.tsx`.
  - "Ready to check your symptoms or exposure?" with "Start Ebola Health
    Check", or the locked card (above).
  - "Medical help and guidance" (`tel:719`).
- **Ebola Health Check picker** (the Learn More page's `?view=entry`).
  "Your health matters." / "Before starting, tell us who the health check
  is for." Three options:
  - "For myself" ("I am 18 or older and completing my own health check.")
    → `/assessments/ebola-screening`.
  - "For an adult loved one" ("I am authorised to assist an adult who
    needs help, with their consent or lawful authority.") → the
    adult-patient picker for `ebola-screening-assisted`.
  - "For my child" ("I am the verified parent or legal guardian of a child
    under 18.") → the dependant picker for `ebola-screening-child`.

  Then a "Do not delay emergency care" box ("… Kenya public health
  guidance: 719.") and "Back to Learn More".

### The old `/sexual-urinary` checker

This on-device checker is gone. Web redirects `/sexual-urinary` to `/assessments/sti-uti`, and
a Sexual & urinary package purchase opens `/assessments/sti-uti` directly. Don't port it.

## 1. Catalog browsing

```
GET  /api/assessments/                        AllowAny — public, pre-signup catalog
GET  /api/assessments/cancer-pre-screening-content/   IsAuthenticated — shared cancer gate/intro copy
GET  /api/assessments/<slug>/                  IsAuthenticated — full question bank
```

An unknown `<slug>` returns `404 {"detail": "Unknown assessment."}` on every
per-slug endpoint (detail, can-start, session).

`GET /api/assessments/` returns one entry per non-`hidden_from_catalog`
config. It's cached globally for 1 hour (`assessments:list:v3`):

```json
[
  { "slug": "breast-cancer", "category": "Cancer", "title": "Breast Cancer Risk Awareness", "short_title": "Breast cancer", "tagline": "...", "excluded_gender": "male", "dependant_variant_slug": null },
  { "slug": "endometriosis", "category": "Reproductive health", "title": "...", "short_title": "...", "tagline": "...", "excluded_gender": "male", "dependant_variant_slug": "endometriosis-dependent" },
  { "slug": "hypertension", "category": "Metabolic", "title": "...", "short_title": "...", "tagline": "...", "excluded_gender": null, "dependant_variant_slug": null }
]
```

The list's `short_title` is the card title in the Metabolic, Mental
Wellbeing and Sexual & urinary lists. The Cancer hub uses its own fixed
names and one-line descriptions instead.

`excluded_gender` comes from the static `GENDER_TERMINATE` map
(`breast-cancer`/`cervical-cancer`/`endometriosis` → `"male"`,
`prostate-cancer` → `"female"`). It isn't computed per user. Filter on it
as described above.

How the server enforces gender:

- **Breast/cervical/prostate cancer are not blocked or terminated by gender
  any more.** Their rewritten configs dropped `terminate_on="male"`, and
  the registry's `_with_gender` never touches these `LOCKED_SLUGS`. The
  rewrites document this in their own header notes (e.g.
  `engine/configs/breast_cancer.py`'s "(a) Male users are no longer fully
  excluded"). A user of the excluded gender who starts one gets the normal
  questionnaire. Gender only changes which questions are skipped and
  whether a screening recommendation is issued. Hiding the card is purely
  a UI default.
- **`endometriosis`** is the one hard gender gate. A known-male profile is
  refused *before* a session exists, with `code: "gender_ineligible"` plus
  `dependant_variant_slug` (§2.1). `can-start` reports this up front as
  `blocked_reason: "gender_ineligible"`.
- If the profile gender is unknown, nothing is blocked.

`GET /api/assessments/cancer-pre-screening-content/` (cached 1 hour)
returns the copy shared by all 5 cancers
(`engine/cancer_common.py:CANCER_HISTORY_GATE_CONTENT`/`BEFORE_YOU_BEGIN_CONTENT`).
Web uses it for the pre-screening gate (§2.2), the cancer intro (§8) and
the "Your Cancer History" type list (§8):

```json
{
  "gate": {
    "history_question": "Have you ever been diagnosed with any type of cancer?",
    "type_question": "Which type of cancer were you diagnosed with?",
    "year_question": "What year were you diagnosed?",
    "type_choices": [{"value": "breast", "label": "Breast cancer"}, ..., {"value": "other", "label": "Another type of cancer"}]
  },
  "before_you_begin": {
    "title": "Before You Begin",
    "intro_paragraphs": ["...", "...", "..."],
    "tier_legend": [{"emoji": "🟢", "label": "Green — Right Track", "meaning": "...", "action": "..."}, ...],
    "important_notes": ["...", "Screening does not affect your colour score, ...", "...", "..."]
  }
}
```

`tier_legend` is always ordered Green, Yellow, Orange, Red. `type_choices`
holds the 5 assessed cancers (`breast`, `cervical`, `prostate`,
`esophageal`, `colorectal`), 10 other common cancers, and `other` last.

`GET /api/assessments/<slug>/` (auth required — this is the full question
bank including each question's scoring-relevant `insight` text, deliberately
not exposed to an anonymous caller) returns:

```json
{
  "slug": "breast-cancer", "category": "Cancer", "title": "Breast Cancer Risk Awareness",
  "short_title": "Breast cancer", "tagline": "...", "disclaimer": "...", "reference_prefix": "BC-",
  "understanding_copy": "...",
  "before_you_begin": [],
  "cancer_history_type_code": "breast",
  "encouraging_fact": { "emoji": "💗", "text": "..." },
  "dependant_variant_slug": null,
  "questions": [
    { "key": "gender", "index": 0, "section": "Personal data", "prompt": "What is your gender?", "type": "radio",
      "options": [{"value": "female", "label": "Female"}, {"value": "male", "label": "Male"}],
      "insight": "...", "description": "", "min": null, "max": null,
      "exclusive_value": null, "optional": false }
  ],
  "ctas": [
    { "key": "consultation", "label": "Book a consultation", "service_type": "checkup",
      "service_label": "General health consultation", "price_kes": null, "description": "..." }
  ]
}
```

- `before_you_begin` is a **list** of `{heading, body}` pages for an
  assessment-specific "Before You Begin" read-through, one page per
  screen. It's `[]` for any config that doesn't set it (today only
  Endometriosis sets it). This is separate from the shared cancer "Before
  You Begin" object in `cancer-pre-screening-content`.
- `cancer_history_type_code` and `encouraging_fact` (`{emoji, text}`) are
  set only for the 5 cancers. Everything else gets `null`.
- `disclaimer` is shown as "**Disclaimer.** …" under the intro/payment
  card, and at the end of the cancer intro's "IMPORTANT DISCLAIMER" (§8).
- `ctas` are the config's bookable services. A result screen's CTA
  (`{key, label}`, §5) is resolved against this list **by `key`** to get
  the `service_type`/`service_label` for a booking. Web's `complete/page.tsx`
  does this with `ctaByKey`.
- `exclusive_value` is the "None of the above" value for a checkbox
  question: selecting it clears the other options, and selecting another
  option clears it. `optional: true` marks a question that can be left
  blank.

A `Profile.demo_restricted` account gets every scoring-relevant field
(`insight`, `options`, `min`/`max`, `description`) stripped to empty/null —
just enough shape to not crash a renderer, never cached under the shared
cache key (computed inline per-request instead, so it never leaks into a
real user's cached response or vice versa).

### Dashboard summary (`GET /api/dashboard/`)

`DashboardView` is mounted by this app at `/api/dashboard/` (not under
`/assessments/`). It returns
`{ profile, assessments, scores, recommendations, payments }`
(`services.get_dashboard_data`). The web dashboard reads only two of them:

- `profile`: `full_name` for the "Hello, {first name}" greeting, and
  `occupation` for the Workplace Wellbeing card (above).
- `assessments`: the user's 10 most recent `QuestionnaireSession`s (same
  shape as §2). Web no longer shows anything from it.

**The dashboard, top to bottom** (2026-11-03 design, phone and desktop):
"Hello, {first name}" / "Your wellness snapshot"; the **"VIEW OUR
PACKAGES"** card ("Individual or complete wellness packages", "Choose what
works for you", "Explore individual health checks from **KSh {Cancer
base price}/year** or the complete **All-in-One package at KSh {all-in-one
price}/year**." from `GET /api/payments/service-catalog/`, "Explore
packages →" → `/wellness-packages`); **"Public Health Information"** with
the Ebola card ("Learn about Ebola, symptoms and possible exposure.",
"Read More ↗" → `/assessments/ebola`); **"Explore Health Checks"** (above);
the Workplace Wellbeing card when it applies (above); on desktop only, the
"Book a medical check-up" card; Pathway E's dialysis-day card; the
**"BLOOD PRESSURE MONITORING"** and **"BLOOD SUGAR MONITORING"** cards (see
the vitals guide); "My medications"; "My appointments"; and "My Health
Checks & Follow-Up" (§7, without Ebola). There is no "Talk to a care
navigator" card or assessment count any more.

The dashboard's "My Health Checks & Follow-Up" section uses §7's
endpoint, not this one.

## 2. Session lifecycle

```
GET  /api/assessments/<slug>/can-start/
POST /api/assessments/<slug>/session/
POST /api/assessments/<slug>/session/<session_id>/alert-navigator/   -- awaiting_call only, see below
```

### Can I start this?

```
GET /api/assessments/<slug>/can-start/
→ { "allowed": true, "last_completed_at": null, "next_eligible_at": null,
    "blocked_reason": null, "prior_slug": null, "prior_title": null }
```

`services.can_start_assessment` never raises. It checks these in order and
returns the first one that applies:

| `blocked_reason` | When |
|---|---|
| `"cancer_diagnosed_blocked"` | Cancer slug and `profile.cancer_diagnosed == true` (§2.2, §8) |
| `"age_ineligible"` | Config has `min_age` (today only `endometriosis`, 18) and the profile age is lower or unknown |
| `"gender_ineligible"` | Known profile gender is excluded **and** the config has a `dependant_variant_slug` (today only a male profile on `endometriosis`) |
| `"ebola_access_required"` | Ebola ("Public health screening") with no access (§4), and there's no session yet or it's still `awaiting_payment` |
| `"assessment_paused"` | Ebola is disabled until further notice (`EBOLA_ASSESSMENT_PAUSED`). Show Learn More only. Creating a new session or saving answers returns an error; an existing session and its result can still be read |
| `"chapter_not_unlocked"` | `corporate-wellbeing-2`/`-3` whose prerequisite chapter isn't completed, or was completed less than `CORPORATE_WELLBEING_CHAPTER_GAP_HOURS` ago (§2.4). `prior_slug`/`prior_title` name the prerequisite |
| `null` with `allowed: false` | An ordinary same-slug retake still inside `settings.ASSESSMENT_REASSESSMENT_COOLDOWN_DAYS`. `next_eligible_at` says when |

If a non-completed session already exists for this slug, the chapter-gap
and cooldown checks don't apply and the result is `allowed: true`: the user
is resuming, not starting. `is_test_account` users skip the Ebola,
chapter-gap and cooldown checks. Nobody skips the first three rows (the
clinical gates), including test and `demo_restricted` accounts.

Web calls `can-start` on the intro page (blocked screens, §2.1), the result
page (whether to show "Retake this assessment"), the Ebola hub and Learn
More page (`ebola-screening` only, to hide or lock the assessment), and
each Workplace chapter card.

### Starting (or resuming) a session

```
POST /api/assessments/<slug>/session/
Body: {} | { "retake": true } | { "dependant_id": "<uuid>" } | { "manual_dependant_id": "<uuid>" } | { "assisted_patient_id": "<uuid>" }
```

- Omit the body (or send `{}`) for an ordinary page-load/resume check. It
  returns the latest session for this slug (and this
  dependant/patient). If that session was completed **more than the
  cooldown ago**, it creates a fresh one instead.
- **`retake: true` only does anything for an `is_test_account` user.** For
  them it skips the cooldown and creates a fresh session, discarding the
  just-completed one. So only send it when the user taps the real "Retake
  this assessment" button, never on a passive resume. For everyone else
  it's ignored: inside the cooldown you get the old completed session
  back. Web only shows the Retake button when `can-start` says
  `allowed: true` (`complete/page.tsx`). Mirror that. After a retake, web
  goes to the intro page if the new session is `awaiting_payment` or
  `awaiting_call`, otherwise straight to the questions.
- `dependant_id`/`manual_dependant_id`/`assisted_patient_id` only apply to
  the three picker-only variant slugs (see §2.3).
- Before looking up any session, this runs the age, gender and
  cancer-diagnosed gates, in that order. They apply on a passive re-fetch
  too, not only on creation.

Returns a `QuestionnaireSession`:

```json
{
  "id": "...", "assessment_slug": "phq9", "dependant": null, "manual_dependant": null,
  "status": "in_progress", "current_index": 0, "total_questions": 13,
  "completion_pct": 0, "reference_number": "", "paid_at": "2026-10-27T10:00:00Z",
  "started_at": "...", "completed_at": null, "navigator_alerted_at": null
}
```

`dependant`/`manual_dependant` are the dependant's id, or `null`. The
assisted-patient id isn't in this payload, so keep it client-side. `total_questions`
counts what the registry injects. For `phq9` that's 13: the safety check
and its "able to proceed?" question (`registry._with_safety_check`), then
`age`, an injected `gender` (`_with_gender`), then the 9 PHQ items. Always
render from the catalog's `questions`, never a hard-coded count.

Web polls this endpoint every 5 seconds while the session is
`awaiting_payment`, so the screen moves on by itself once payment settles.

**Status state machine** (`QuestionnaireSession.Status`):

```
(cancer only) needs_pre_screening ──(resolve_pre_screening: no / different cancer)──► same as "created" below
                                  └─(resolve_pre_screening: same cancer)──────────────► completed

created ──(no unlock yet)──► awaiting_payment ──(payment settles)──► in_progress ──(terminate_on / all questions answered)──► completed
        └─(already unlocked)───────────────────────────────────────► in_progress
awaiting_payment ──(demo_restricted account pays)──► awaiting_call ──(admin clears demo_restricted)──► in_progress
```

- If an `awaiting_payment` session's category has since been unlocked
  (e.g. by a bundle), it moves to `in_progress` (or `awaiting_call`) on the
  next `POST .../session/`, without charging again.
- A non-cancer session created while the user already has access starts
  directly at `in_progress`, or at `awaiting_call` for a `demo_restricted`
  account.

- `needs_pre_screening` — **only** the 5 cancer slugs ever start here (see
  §2.2); every other slug starts directly at `awaiting_payment`,
  `in_progress` or `awaiting_call`. A user who answered "No" on the
  packages screen never sees their *own* cancer sessions sit here (§2.2).
- `awaiting_payment` — created with no unlock yet. Web shows an
  "Assessment Locked" card with a "Pay with M-Pesa · KES {price}" button;
  see [`payments-and-packages.md`](./payments-and-packages.md) for how this
  flips to `in_progress`.
- `in_progress` — the status answers are meant for. `save_answer` also
  accepts `completed`, and that is **not** a no-op: the answer is
  overwritten and the session re-scored (`RiskScore` `update_or_create`).
  Treat a completed session as read-only on mobile. Answering against
  `needs_pre_screening`, `awaiting_payment` or `awaiting_call` returns
  `400`.
  **One assessment in progress at a time, across every slug** — if this
  user already has a *different* slug sitting at `in_progress`,
  `POST .../session/` fails with:

  ```json
  { "detail": "Finish \"PHQ-9\" before starting a new assessment.",
    "code": "assessment_in_progress", "blocking_slug": "phq9", "blocking_title": "PHQ-9" }
  ```

  Branch on `code` to link the user straight back to resuming
  `blocking_slug` instead of a dead-end error. `needs_pre_screening`/
  `awaiting_payment`/`awaiting_call` sessions don't count as "in
  progress" for this rule — only a real `in_progress` session blocks a new
  one. This rule is enforced once, here in the service layer, so it holds
  identically for web, the WhatsApp bot, and mobile — never re-implement it
  client-side as the sole guard.
- `completed` — scored (`RiskScore` row created), report-generatable. Web's
  intro page redirects straight to the result screen.
- `awaiting_call` — paid, but `Profile.demo_restricted` is true, so the
  session is never unlocked into `in_progress`; a human completes it by
  phone. Self-heals into `in_progress` the next time this endpoint is
  called after an admin clears the flag. Web shows an **"Alert Health
  Navigator"** button on this screen
  (`app/(app)/assessments/[slug]/page.tsx`). It calls
  `POST .../session/<session_id>/alert-navigator/` (no body), which stamps
  `navigator_alerted_at` and returns the session. The ops email is sent
  later by Celery. Calling it again is a silent no-op. Calling it on any
  other status returns `400`. Use `navigator_alerted_at != null` to show
  the "alerted" state.

**Gender and age are never re-asked once known on the account — including
on an explicit retake.** If `Profile.gender` is set, or an age can be
computed from `date_of_birth`, the session auto-answers those questions as
soon as it reaches them. That goes through the real `save_answer`, so
branching fires normally. An auto-answer only happens if the value is
valid for that question's `min`/`max`; otherwise the question is asked as
usual. Don't render a gender/age question until `GET .../answers/` and
`current_index` confirm it's still unanswered. Cancer sessions also
auto-reuse shared answers the same user gave on another cancer session in
the last 24 hours: BMI, tobacco, alcohol, activity and some symptoms
(`SHARED_SESSION_VARIABLE_KEYS`). Answering `gender` updates
`Profile.gender`.

### 2.1 Errors that must branch the UI, not just show a generic message

All of these are `400` from `POST .../session/` (`AssessmentSessionView`):

```json
{ "detail": "This assessment is only available to users aged 18 and over.", "code": "age_ineligible" }
{ "detail": "This assessment is not available for your profile. If you're completing it for your daughter, use the dependant assessment instead.", "code": "gender_ineligible", "dependant_variant_slug": "endometriosis-dependent" }
{ "detail": "This self-assessment isn't available based on your profile. Please continue following your doctor's existing treatment plan.", "code": "cancer_diagnosed_blocked" }
{ "detail": "Consent is required before starting this assessment for this dependant.", "code": "dependant_consent_required" }
{ "detail": "Finish \"PHQ-9\" before starting a new assessment.", "code": "assessment_in_progress", "blocking_slug": "...", "blocking_title": "..." }
```

What web's intro page shows for each, checked in this order. `age_ineligible`,
`gender_ineligible` and `cancer_diagnosed_blocked` also trigger from the
matching `can-start` `blocked_reason`.

- `age_ineligible`: a caregiver-information screen, "Information for
  Mothers, Parents and Caregivers: Young People Aged 17 and Under". It
  covers what to look out for, how to support the young person, and an
  urgent-help box, then ends with "Back to assessments". The copy is fixed
  text in `app/(app)/assessments/[slug]/page.tsx`. Copy it verbatim.
- `dependant_consent_required`: "Choose a dependant first" ("This
  assessment is completed on behalf of one of your dependants. Choose
  who it's for and confirm consent before continuing."), with a "Choose a
  dependant" button to `/assessments/<slug>/dependants` — or, for an
  assisted session (`ebola-screening-assisted`, started with an
  `assistedPatientId`), to `/assessments/<slug>/adult-patients` (§2.3).
  This code covers every dependant/patient
  eligibility or consent failure: not linked to your account, too old,
  the caregiver isn't a verified adult, or no consent yet.
- `gender_ineligible`: "Not available for your profile" ("This assessment
  is not available for your profile. If you're completing it for your
  daughter, use the dependant assessment instead."). A "Continue for a
  dependant" button goes to `dependant_variant_slug`'s dependant picker.
- `cancer_diagnosed_blocked`: "Not available for your profile" ("Cancer
  screening assessments aren't available on your account. Please continue
  following your doctor's existing treatment plan.") with a "Back to
  assessments" button. The free diagnosed-cancer guidance (§8) is offered
  from the Cancer hub, not from this screen.
- `assessment_in_progress`: "Finish your other assessment first", showing
  `detail`, with "Resume that assessment" (→ `/assessments/<blocking_slug>`)
  and "Back to assessments".

"Back to assessments" goes to the category list: the Cancer hub for
Cancer, the category list for Mental health and Sexual & urinary, and
`/assessments` for everything else.

Any other `SessionError` is `400 {"detail": "..."}` with **no `code`**.
Examples:

- "This assessment requires selecting a dependant." / "This assessment
  requires selecting a patient." (a `requires_*` slug without an id)
- "Select only one dependant."
- "Please complete corporate-wellbeing-1 before starting this session."
- "This session isn't available yet -- it unlocks <ISO datetime>."

For the two chapter errors (and a retake cooldown) `can-start` is
blocking, and web shows its intro card with the "Not yet available" panel
from `can-start` (§2.4). Any other session error without a handled code
gets a dedicated screen: a warning icon, **"We couldn't open this
assessment"**, the error's `detail` (or "Something went wrong. Please try
again."), **Try again** (re-requests the session; "Trying again…") and
**Back to assessments**.

The dependant/patient list and consent endpoints (§2.3) return
`400 {"detail": "slug is required.", "code": "slug_required"}` when `slug`
is missing.

### 2.2 The cancer pre-screening gate (5 cancer slugs only)

A brand-new session on `breast-cancer`/`cervical-cancer`/`prostate-cancer`/
`esophageal-cancer`/`colorectal-cancer` starts at `needs_pre_screening`, not
`awaiting_payment` — the user must answer a cancer-history intake (has the
*same* cancer already been diagnosed?) before ever being shown a pay button
or a question. Collect these three fields in your own local UI (mirroring
`app/(app)/assessments/[slug]/page.tsx`'s `PreScreeningGate`, which uses
the `gate` questions and `type_choices` from
`cancer-pre-screening-content`), then resolve in one call:

```
POST /api/assessments/<slug>/session/<session_id>/pre-screening/
Body: { "prior_cancer_history": "yes"|"no", "prior_cancer_type": "breast"|"cervical"|...|"other", "prior_cancer_year": 2019 }
→ QuestionnaireSession (now awaiting_payment / in_progress / awaiting_call, OR already completed)
```

Web sends only `prior_cancer_history` for "No". For "Yes" it sends
`prior_cancer_type` (required) and `prior_cancer_year` (optional, omitted
when blank).

**The gate screen** (web's `PreScreeningGate`):

- Back link to the category, then `title` and `tagline`.
- A "Your Health Information" pill, "Let's understand your health
  history" and "Your answers help us provide a more personalised
  assessment and guidance."
- `gate.history_question` with two options:
  - "Yes" ("I have been diagnosed with cancer in the past.")
  - "No" ("I have not been diagnosed with cancer.")
- On "Yes", a "Diagnosis details" box ("Please provide details about your
  cancer diagnosis.") with:
  - `gate.type_question` as a dropdown of `type_choices` ("Select cancer
    type").
  - `gate.year_question` as a dropdown from this year back to 1940
    ("Select year (e.g. 2020)").
- "Continue" ("Submitting…" while sending). A failure shows the error
  `detail`.

If `prior_cancer_history=="yes"` **and** `prior_cancer_type` matches *this*
assessment's own cancer type, the session completes immediately — no
payment, no questionnaire — with a "continue with your treating clinician"
result. Compare against `cancer_history_type_code` from `GET
/api/assessments/<slug>/`. That result is `kind: "generic"` with
`severity: "neutral"`. Any other answer resolves exactly like a normal
session creation (payment gate or immediate unlock), and the history is
kept on the session as clinical context. Calling this on a session that
isn't `needs_pre_screening` returns
`400 {"detail": "This session has already been screened."}`. A missing or
invalid `prior_cancer_history` returns `400 "Please answer the
cancer-history question."`.

Web's intro page (`app/(app)/assessments/[slug]/page.tsx`) loads the
config, `can-start` and `POST .../session/` (plus
`cancer-pre-screening-content` for a cancer). It then shows the first of
these that applies:

0. A `completed` session goes straight to the result screen. A blocking
   error goes to its screen (§2.1).
1. The pre-screening gate while `status == "needs_pre_screening"`.
2. The cancer intro (`components/cancer-intro`, §8). Cancer only.
3. The Encouraging Fact (§8). Cancer only, when `encouraging_fact` is set.
4. The config's own `before_you_begin` pages (today only Endometriosis).
   Each page has a "Before You Begin · {short_title}" kicker, "{n} of
   {total}", `heading` and `body`, and "Back" / "Continue" ("Continue to
   assessment" on the last page). The back link reads "All assessments".
   An unpaid user can read these before paying.
5. The plain intro card, when the session is `awaiting_payment` or
   `awaiting_call`, or `can-start.allowed` is `false` (below). Steps 2–4
   are skipped for `awaiting_call`.
6. Otherwise, straight into `/start` (the question screen). There's no
   per-assessment disclaimer tick or "Start assessment" click any more
   (removed 2026-10-29).

Steps 2–4 use local-only acknowledgements, so they reappear on every
fresh visit by design.

**The plain intro card**, top to bottom:

- Back link (the category name for Cancer, Mental health and Sexual &
  urinary, otherwise "All assessments").
- A hero with the `category` chip, `title`, `tagline` and "5–10 minutes".
- Three tiles:
  - "5–10 minutes" / "Short, self-paced questions."
  - "Confidential" / "Only you and your clinician see your answers."
  - "PDF report" / "Personalised report at the end."
- If `can-start` says `chapter_not_unlocked`: a **"Not yet available"**
  panel (§2.4).
- If `can-start` is `allowed: false` for any other reason: a
  **"Re-assessment available later"** panel. "You completed this
  assessment on {last_completed_at}. You can retake it from
  {next_eligible_at} (6 months after completion)." Then "View your last
  report" (→ the result screen).
- One of three blocks:
  - `awaiting_call`: the navigator block (below).
  - `awaiting_payment`: the **"Assessment Locked"** card. It reads
    "Complete payment of **KES {price}** to unlock this assessment and
    every other {category label} assessment for 6 months." The category
    label is "Cancer Awareness and Screening", "Hypertension and
    diabetes", "Mental health and wellness", "Reproductive health", or
    the raw category name for Workplace wellbeing. Then a "Pay with
    M-Pesa · KES {price}" button and "🔒 Secure Safaricom STK Push — no
    manual code entry.".
    - **Sexual & urinary** is different. If the profile has no age it
      first asks "Your age". Under 18 shows "This assessment is only
      available to users aged 18 and above." and disables the button.
      Otherwise the text is "…to unlock this assessment for 2 months.",
      priced by age tier.
    - **`endometriosis`/`endometriosis-dependent`** also get "Apply for
      endometriosis subsidy if you can't afford it". A pending application
      replaces it with "Your subsidy application is under review…". A
      rejected one adds "Your previous subsidy application wasn't
      approved…".
    - The price, the one category package (`CATEGORY_PACKAGE_ID`), the
      M-Pesa dialog, the "Opening your assessment…" outcome screen and
      the subsidy are all in
      [`payments-and-packages.md`](./payments-and-packages.md). After
      payment confirms, the 5-second session poll flips the session to
      `in_progress` and web opens `/start`.
  - Otherwise: a "Start assessment" / "Resume assessment" button
    (`current_index > 0`), disabled while `can-start.allowed` is `false`.
- "**Disclaimer.** {disclaimer}", keeping its line breaks.

**The navigator block** (`awaiting_call`, `components/pending-human-followup.tsx`):
"Payment received".

- Before alerting: "When you're ready to complete this assessment over the
  phone, let our team know." with an "Alert Health Navigator" button
  (`alert-navigator`, §2).
- Once `navigator_alerted_at` is set: "A member of our team will call you
  at **{profile phone}** within one business day to complete this for you
  over the phone." and "Nothing else to do on your end for now."

**Asked once, up front (2026-10-30):** the packages screen now asks "Have
you ever been diagnosed with cancer?" before a Cancer purchase, via
`PATCH /api/auth/cancer-diagnosis/` (see
[`account-and-profile.md`](./account-and-profile.md) §4a). The two answers
change this gate:

- **"No"** (`profile.cancer_diagnosed == false` *and*
  `profile.cancer_diagnosed_declared_at != null`): the server answers this
  gate as `"no"` itself. The user's **own** cancer sessions come back
  already past `needs_pre_screening` (`awaiting_payment`/`in_progress`),
  with `prior_cancer_history: "no"` recorded. Don't show the gate UI —
  just branch on the status you get back.
- **"Yes"** (`profile.cancer_diagnosed == true`): every Cancer assessment
  is blocked with `code: "cancer_diagnosed_blocked"` (§2.1). The Cancer
  hub offers the free diagnosed-cancer follow-up guidance instead (§8).
- **Never answered** (`cancer_diagnosed_declared_at == null`): the gate
  works exactly as described above.

### 2.3 Dependant and assisted-patient variants

Three slugs require picking who the assessment is actually about, while
the authenticated user stays the session owner/answerer throughout:

- `endometriosis-dependent` ("For a young loved one") and
  `ebola-screening-child` ("For my child") — `requires_dependant`. Web
  opens `/assessments/<slug>/dependants`. Pass `dependant_id` (a real
  AfyaConnect-verified `AfyaConnectDependant`) or `manual_dependant_id`
  (self-declared, no AfyaConnect record).
- `ebola-screening-assisted` ("For an adult loved one") —
  `requires_adult_proxy`. Web opens `/assessments/<slug>/adult-patients`.
  Pass `assisted_patient_id` (self-declared `ManuallyAddedAdultPatient`; no
  AfyaConnect-verified equivalent exists for an adult).

Supporting endpoints (all take the `slug`, scoped per-slug so a consent for
one variant assessment never silently reads as valid for another):

```
GET  /api/assessments/dependants/?slug=<slug>                              -- AfyaConnect-verified dependants
POST /api/assessments/dependants/<id>/consent/   { "slug", "minor_participation" }
GET  /api/assessments/manual-dependants/?slug=<slug>                       -- self-declared dependants
POST /api/assessments/manual-dependants/         { "slug", "first_name", "date_of_birth", "relationship" }
POST /api/assessments/manual-dependants/<id>/consent/   { "slug", "minor_participation" }
GET  /api/assessments/adult-patients/?slug=<slug>
POST /api/assessments/adult-patients/            { "slug", "first_name", "age", "relationship" }
POST /api/assessments/adult-patients/<id>/consent/   { "slug", "authority_basis", "report_access_authorized" }
```

Response shapes (`apps/assessments/serializers.py`):

- AfyaConnect dependant:
  `{ id, first_name, last_name, relationship, age, has_consent }`. Only
  dependants under 18 whose AfyaConnect relationship is "child" are listed.
- Manual dependant: `{ id, first_name, date_of_birth, relationship, age, has_consent }`.
  `relationship` is one of `mother`, `father`, `guardian`, `sibling`,
  `other`.
- Adult patient: `{ id, first_name, age, relationship, has_consent }`.
  `relationship` is one of `spouse_partner`, `parent`, `sibling`, `child`,
  `other`. `age` is 0–120, but the server only accepts an adult (18+) for
  this flow.
- `has_consent` is scoped to the `slug`. On the add POSTs the `slug` is
  optional and only feeds `has_consent` in the response; web always sends
  it.
- Enum values for the consent POST bodies, with web's option labels:
  - `minor_participation`: `together` ("Together, right now"),
    `unavailable` ("The young person isn't available right now"),
    `declined` ("The young person has declined to take part").
  - Adult `authority_basis`: `patient_consented` ("The patient has
    consented directly"), `lawful_representative` ("I am their verified
    lawful representative").
  - `report_access_authorized` defaults to `false`.
- Both POST-to-add and POST-consent return `201`.

Web's flow: list the people for this `slug`. Picking someone with
`has_consent: true` goes straight to `/assessments/<slug>?dependantId=…`
(or `manualDependantId=` / `assistedPatientId=`), and that id is sent on
`POST .../session/`. Without consent, web shows the consent step, POSTs
it, then continues the same way. A newly added person goes straight to
their consent step. The id stays on every later screen (intro, questions,
result, Retake) so each call uses the same dependant/patient.

**"Assess a Dependant"** (`/assessments/<slug>/dependants`):

- **List.** "Who is this assessment for?" / "Choose one of your
  dependants below, or add a new one if they're not listed yet."
  - The AfyaConnect dependants come first, then the manual ones. Each card
    shows the name and "{relationship} · {age} years old", with a "Ready"
    badge (`has_consent`) or "Consent needed". A manual relationship shows
    its label: "Mother", "Father", "Legal guardian", "Adult sister or
    brother", "Other authorised adult caregiver".
  - "Add another dependant" sits under the list.
  - With nobody listed: "No dependants added yet" ("If they're a verified
    AfyaConnect dependant, sync your AfyaConnect details again from your
    account page -- or just add them yourself below.") and "Add a
    dependant".
- **Add form.** "Add the young person you're completing this assessment
  for. They'll be saved to your account for future assessments too." Fields:
  - "First name" (e.g. Amani).
  - "Date of birth" (not in the future).
  - "Your relationship to them".

  Then "Continue" ("Adding…"). A failure shows the error `detail`.
- **Consent step.** It opens with "← Choose a different dependant" and the
  person's card, then an explanatory note:
  - AfyaConnect: "Being a relative, including an aunt or older sister,
    does not automatically establish authority to consent. This flow
    currently only supports a parent or legal guardian completing this
    assessment for their own child, verified through your own AfyaConnect
    record."
  - Manual: "{name} isn't yet a verified AfyaConnect dependant, so this is
    based on what you've told us. By continuing, you confirm you're an
    authorised adult caregiver responsible for their care and that what
    you've entered is accurate."

  Then "Is {name} able to take part right now?" with the three
  `minor_participation` options. Each has a hint:
  - "The young person is with you and can describe their own symptoms and
    choose their own pain score."
  - "You'll answer based on what you know -- never guess an answer they
    haven't shared with you."
  - "That choice is respected. You can still get general guidance for
    your concerns."

  A required tick box follows:
  - AfyaConnect: "I confirm I am {name}'s parent or legal guardian and
    consent to processing their health information for this assessment
    and its report."
  - Manual: "I confirm I am {name}'s {relationship label, lower-cased}
    and consent to …".

  Then "Confirm and continue" ("Confirming…").

**"Assist an Adult Loved One"** (`/assessments/<slug>/adult-patients`):

- **List.** "Who is this assessment for?" / "Choose the adult loved one
  below, or add them if they're not listed yet."
  - Cards show the name and "{relationship label} · {age} years old",
    with "Ready" or "Consent needed". The relationship labels are
    "Spouse or partner", "Parent", "Sibling", "Son or daughter", "Other
    authorised adult helper".
  - "Add another person" sits under the list.
  - With nobody listed: "No one added yet" ("Add the adult loved one
    you're assisting to get started.") and "Add a person".
- **Add form.** "Add the adult loved one you're completing this assessment
  for. They'll be saved to your account for future assessments too."
  Fields:
  - "First name" (e.g. Jane).
  - "Age" (18–120; the button stays disabled under 18).
  - "Your relationship to them".

  Then "Continue".
- **Consent step.** "← Choose a different patient", then "Being a
  relative, including a spouse or sibling, does not automatically
  establish authority to consent on someone else's behalf. The patient's
  own consent, or an established lawful representative basis, is
  required before you continue."
  - "On what basis are you assisting {name}?" with the two
    `authority_basis` options. Their hints are "They know you're
    completing this and have agreed to it." and "E.g. a formally
    appointed representative when the patient cannot consent
    themselves."
  - A required tick box: "I confirm the patient consent or lawful
    authority above is accurate and consent to processing {name}'s
    health information for this assessment."
  - An optional tick box that sets `report_access_authorized`: "Also
    authorise me to view {name}'s report. (Helping with answers does not
    automatically authorise report access -- this is a separate
    permission.)"
  - "Confirm and continue".

Consent must exist before `POST .../session/` with the matching id
succeeds, otherwise it raises `DependantConsentError` →
`{"code": "dependant_consent_required"}`. Sessions are scoped per
dependant/patient. One child's session is never handed back for another,
and none of them appear in §7's health checks.

### 2.4 Chapter-chained sessions (`corporate-wellbeing-2`/`-3` only)

The Workplace Wellbeing hub (`/assessments/corporate-wellbeing`) shows one
card per chapter and calls `can-start` for each. Chapters 2 and 3 unlock
only `CORPORATE_WELLBEING_CHAPTER_GAP_HOURS` after the prerequisite
chapter's own `completed_at` (`services.CHAPTER_CHAIN`). `can-start`
returns `blocked_reason: "chapter_not_unlocked"` with
`prior_slug`/`prior_title`, which tell you which chapter to finish ("Complete
<prior_title> first"). `next_eligible_at` tells you exactly when it
unlocks. It's `null` if the prior chapter was never completed. In this
case `last_completed_at`/`next_eligible_at` describe the *prerequisite*
chapter, not this one. If you `POST .../session/` too early you get a
code-less `400` (§2.1). When chapter 2 is created, the backend copies the
carried-over chapter-1 answers it needs into it (`_seed_prior_chapter_answers`).
No other assessment in the catalog is gated this way.

**What the hub shows.** The hub is titled "Corporate Workplace Wellbeing":
"A confidential three-session check-in, run like a counselling
conversation rather than one long form. Each session unlocks a day after
you finish the one before, so you have time to come back to it." Its back
link goes to the dashboard. The chapter cards:

| Slug | Title | Subtitle | Description |
|---|---|---|---|
| `corporate-wellbeing-1` | "Session 1" | "Work Context & Workload" | "Your work setting, workload, and everyday wellbeing. About 10 minutes." |
| `corporate-wellbeing-2` | "Session 2" | "People & Psychosocial Safety" | "Workplace relationships, management, and psychosocial safety. About 10 minutes." |
| `corporate-wellbeing-3` | "Session 3" | "Recovery & Support" | "Recovery, personal impact, and the support you need. About 10 minutes." |

A card whose `can-start.allowed` is `false` (any reason, including an
ordinary cooldown) is greyed and not tappable. It reads one of:

- "Locked — complete the previous session first." when
  `next_eligible_at` is null.
- "Locked — available again shortly." when it's an hour or less away.
- "Locked — available in about N hours." when it's under a day away.
- "Locked — available {date} at {time}." otherwise.

An allowed card opens `/assessments/<slug>`. On the intro page, a too-early
chapter shows the **"Not yet available"** panel. It reads "**{prior_title}**
was completed on {last_completed_at}. This session unlocks on
{next_eligible_at}.", or "Complete **{prior_title}** first to unlock this
session." when the prior chapter isn't done.

## 3. The question-answer loop

```
GET  /api/assessments/<slug>/session/<session_id>/answers/
POST /api/assessments/<slug>/session/<session_id>/answers/
POST /api/assessments/<slug>/session/<session_id>/bmi-metrics/       -- only for a "bmi"-type question
```

All three endpoints are owner-scoped. Someone else's session, or a slug
that doesn't match the session, returns `404`.

`GET .../answers/` returns every answer so far, ordered by `question_index`:
`[{ "question_key": "age", "question_index": 1, "answer": 42, "answered_at": "..." }, ...]`.
This includes auto-answered and seeded rows. It also includes extra
non-question rows, such as `weight_kg`/`height_cm` from `bmi-metrics` and
answers carried over from a prior chapter. Match rows to questions by
`question_key`, not by position.

**Web's pattern is one `POST .../answers/` call per question answered,
immediately, no local batching.** Replicate this.

```
POST /api/assessments/phq9/session/<session_id>/answers/
Body: { "question_index": 0, "answer": "2" }
→ { "next_index": 1, "terminate": false, "completed": false, "reference": null }
```

- `answer` is a bare JSON value matching the question's own type (a string
  option value for `radio`, a number for a numeric question, etc.) — not
  wrapped in any envelope of its own.
- `next_index` is where to render next — **not necessarily
  `question_index + 1`.** The server evaluates every subsequent question's
  `skip_if`/`auto_answer_if` against all answers given so far and may skip
  several, or auto-answer one invisibly, before landing on the next one a
  human actually needs to see.
- `terminate: true` means this exact answer matched the question's
  `terminate_on` — the session is `completed` right now, with no more
  questions, regardless of how many remain in the catalog.
- `completed: true` (with or without `terminate`) means route straight to
  the results screen; `reference` is the session's generated reference
  number (assigned on first completion only).
- **You cannot go back and change `gender`/`age` after the session has
  moved on, for Cancer/Metabolic category assessments** — `save_answer`
  permanently rejects a replay of either question's index once
  `current_index` has passed it (`SessionError`, no special code — show a
  generic "this answer can no longer be changed" message). Every other
  question *can* be revisited; changing an earlier gating answer correctly
  re-reveals/re-hides/clears whatever came after it.
- `question_index > session.current_index` (answering ahead of where the
  session actually is) is rejected outright — never let the UI get ahead
  of the server's own `current_index`.
- `question_index` must be 0–200 (serializer), and `answer` must pass the
  question's own validation (`is_answer_valid`: option values, `min`/`max`,
  required-ness).
- Every rejection is a code-less `400 {"detail": ...}`. The messages are:
  - "Please answer the previous question first."
  - "Please answer this question before continuing." (invalid value)
  - "Invalid question."
  - "Please complete payment before answering questions."
  - "Please complete the cancer-history screening before answering questions."
  - "Session not active."
  - "This answer can no longer be changed."
- Mental health (`phq9`/`gad7`/`stress`) always opens with an injected
  safety check (`engine/crisis.py`). Answering "Yes"/"Unsure" shows an
  "are you able to proceed?" question. Answering "no" to that terminates
  the session with the "Immediate support recommended" result. Answering
  "yes" continues the questionnaire, but the result stays at the crisis
  tier.

### The question screen (`/assessments/<slug>/start`)

The question screen is `app/(app)/assessments/[slug]/start/page.tsx`.
Mirror it.

- **Redirects.** It renders `questions[current_index]` from the session.
  - `completed` → the result screen.
  - `needs_pre_screening`, `awaiting_payment` or `awaiting_call` → back
    to the intro.
  - After each save it renders `next_index` straight away, without
    waiting for a refetch.
- **Header.**
  - `short_title` over "My Wellness Health". Endometriosis instead shows
    "Adult Health Check" over "My Wellness Health · Women's Health".
    Tapping it returns to the intro.
  - "Your Assessment" and an **"Exit"** button. Exit opens "Exit
    assessment?" ("Your answers so far are saved automatically. You can
    resume this assessment any time from the assessments page — you'll
    continue from where you left off."), with "Stay" and "Exit & save
    progress". Exit goes to the Cancer hub for Cancer, the category list
    for Mental health and Sexual & urinary, otherwise `/assessments`.
  - A section box: the current `section` name, "In progress", one bar per
    distinct `section` in catalog order, and "Progress by section, not by
    number of questions".
  - Endometriosis no longer uses this question loop. See "Endometriosis Health
    Check" near the end of this guide.
- **The question card.**
  - The `section` kicker, `prompt` as the heading, then `description`.
  - For checkbox questions, "Select all that apply." is stripped from the
    prompt and description, because the options show it.
  - A **"Why we ask this question"** accordion holds `insight` (hidden
    when empty).
  - **"Back"** and **"Next"** ("Finish" on the last question, "Saving…"
    while saving).
  - "Next" stays disabled until the answer is valid (`isAnswerValid` in
    `lib/assessments/utils.ts`, a mirror of the server's check). A failed
    save shows the error `detail`.
- **Back.** It walks back to the nearest earlier question that has a
  stored answer (skipped questions have none). It never goes below index 2
  for Cancer and Metabolic (their locked gender/age, above) or index 0
  otherwise.
- **What each `type` sends as `answer`:**

  | `type` | Control | `answer` |
  |---|---|---|
  | `radio` | One choice card per option | the option `value` |
  | `select` | A dropdown ("Select an option") | the option `value` |
  | `checkbox` | Choice cards under "Select all that apply." (`symptoms` shows a two-column grid with no hint) | the selected values joined with `,` (no spaces). `exclusive_value` (and `none_symptom` for the `symptoms` key) disables the other options while it's picked, and vice versa |
  | `text` | A text area ("Type your answer here"), up to 2000 characters | the text |
  | `number` | A number field (placeholder "Your age" for `age`, else "Enter a number"), plus one choice card per `options` entry (e.g. "I don't know") | a number, or the chosen option's string `value` |
  | `number`, Endometriosis 0–10 questions | A pain-face picker ("Choose a face or slide to your pain level."), the note "This scale is for symptom reporting. A pain score alone does not diagnose endometriosis or determine the assessment outcome.", plus the fallback option cards | a number, or the option `value` |
  | `date` | A date field plus fallback option cards (e.g. "I don't remember") | `YYYY-MM-DD`, or the option `value` |
  | `bmi` | "Weight (kg)" (20–400) and "Height (cm)" (80–250) fields with a live "Your calculated BMI" panel | the bucket: `underweight` (<18.5), `normal` (<25), `overweight` (<30) or `obese`. Then `bmi-metrics` (below) |
  | `info` | `prompt` and `description` with a "Continue with assessment..." button | `"acknowledged"` |

  An untouched `optional` question sends `""`.
- **The BMI panel.** It shows the category ("Underweight", "Normal
  weight", "Overweight", "Obese"), a note, and a healthy-weight line such
  as "Lose about X kg to reach a healthy weight (A–B kg for your height)."
  The weight/height fields are pre-filled from the `weight_kg`/`height_cm`
  answer rows. All copy is in `BmiInput`.
- **Options and prompts the API doesn't send.** The API only carries each
  question's static `options`/`prompt`. Web rewrites these in
  `lib/assessments/utils.ts`, and mobile must do the same:
  - `endometriosis` `s2a`/`s3`: the option labels are reworded depending
    on what `s1` (and `s2a`) already established (`getS2aOptions`,
    `getS3Options`). The values never change.
  - Ebola `q6`, `q7`, `q8`, `q9a`: the "within the past 21 days" phrase
    depends on `q5` (`getEbolaExposureWindowPrompt`).
    - `no_symptoms` → "In the 21 days before today (the date of this
      assessment),".
    - Any other answer → "In the 21 days before your symptoms began,".
    - Unanswered → unchanged.
- **Fixed interstitials and banners** (copy in the same file):
  - **Prostate.** On reaching the first "International Prostate Symptom
    Score (IPSS)" question, an IPSS explainer with an answer-meaning table
    and "Continue".
  - **Mental health.** Before the first question of each "Over the last…"
    section: "Answering the next questions" plus an explainer and
    "Continue".
  - **"Sexual Health" section.** At its first question: "A few questions to
    help us understand your situation better" / "Your answers are
    confidential and help us provide more relevant guidance."
  - **Ebola `reason`.** "01 / Reason For Assessment", "Why are you
    checking for Ebola?", "Choose the main reason for starting this
    health check."
  - **Ebola `safety_precheck`.** A red "02 / Safety first", "Check for
    urgent warning signs.", "If there are severe symptoms, seek medical
    help immediately. Do not wait to finish this form." The description
    is hidden here.
  - **Ebola `q3`.** Once any of `bleeding_or_purple_marks`,
    `difficulty_breathing`, `seizures`, `confusion` or `severe_dizziness`
    is ticked, a red banner: "Serious breathing difficulty, seizures,
    major bleeding, confusion or collapse requires immediate medical
    assistance. Do not delay care to finish the questionnaire."
  - **Endometriosis footer.** "One question at a time. Questions not
    relevant to prior answers are skipped."

  The IPSS and Mental health interstitials only show when that question
  has no stored answer yet.

### BMI metrics

A `"bmi"`-type question (key `bmi_calc`) still takes its normal bucketed
answer through `POST .../answers/`. On top of that, send the raw
weight/height here so the PDF report can show the real BMI:

```
POST /api/assessments/<slug>/session/<session_id>/bmi-metrics/
Body: { "weight_kg": 68.5, "height_cm": 170 }
→ { "ok": true }
```

`weight_kg` must be 20–400 and `height_cm` 80–250. The session must be
`in_progress` or `completed`, or you get `400 "Session not active."`. The
values are stored as extra `weight_kg`/`height_cm` answer rows; the bucket
answer itself isn't changed.

## 4. Payment gating and the auto-unlock seeding you must not duplicate

An `awaiting_payment` session unlocks into `in_progress` the moment its
category's `ModuleAccess` grant exists — see
[`payments-and-packages.md`](./payments-and-packages.md) for the actual
M-Pesa flow. The one thing to know here: **the moment unlock happens
(whether at session creation, or later via payment settlement), the
backend auto-fills `gender`/`age`/certain shared variables/prior-chapter
answers from the account's own profile** (`seed_known_session_values`,
also called from `apps.payments.services._settle_successful_payment`).

**Practical implication for mobile: after fetching/resuming a session that
just became `in_progress`, always `GET .../answers/` before rendering the
first question** — don't assume `current_index == 0` means "no answers
exist yet." If gender/age/etc. were already known, they're pre-answered
and `current_index` already reflects that. `sti-uti` doesn't use this loop at all: see
"Sexual & Urinary Health Check V15".

A session counts as already unlocked (no payment step) when any of these
hold (`get_or_create_session`'s `already_unlocked`):

- `is_test_account`.
- It's Ebola ("Public health screening") and `has_ebola_assessment_access`
  holds. Ebola is never sold on its own. It's free for an
  AfyaConnect-verified identity, or for any account that holds at least
  one active package. Without either, the session sits at
  `awaiting_payment` with no package that unlocks it, and `can-start`
  reports `ebola_access_required`. Web's message: "The Ebola health check
  comes free with any other My Wellness Health package, or with a
  verified national ID." Send the user to the packages page, not to an
  Ebola payment.
- The category has a live `ModuleAccess` grant.

`FREE_CATEGORIES` is currently empty.

## 5. Completion and risk scoring

```
GET /api/assessments/<slug>/session/<session_id>/score/
```

Only valid once a `RiskScore` row exists, i.e. the session is
`completed`. Otherwise you get `400 {"detail": "This session has not been
scored yet."}`. Returns (`SessionScoreSerializer`; abridged to the fields
web uses):

```json
{
  "has_active_warning": false,
  "offer_facility_share": false,
  "offer_care_navigation": false,
  "result_display": {
    "kind": "generic",
    "severity": "good",
    "title": "Minimal depression", "body": "...",
    "metric": { "label": "...", "value": "..." },
    "nutrition_recommendation": null,
    "symptom_alerts_section": null,
    "screening_section": null,
    "cta_section": { "heading": "Recommended next steps", "subheading": "No payment now — a navigator will confirm details by phone.", "items": [ { "key": "consultation", "label": "..." } ] },
    "action_summary": null, "critical_notice": null, "important_notice": null,
    "card_color": null, "category_label": null,
    "recommendation_heading": null, "recommendation_body": null, "observations": [],
    "primary_cta_label": null, "secondary_cta_label": null,
    "show_report_card": false, "show_footer_tiles": false
  }
}
```

Field notes:

- `severity` is one of `good` / `attention` / `concern` / `urgent` /
  `neutral`. `neutral` is a plain acknowledgement, not a risk colour, e.g.
  the same-cancer exit (§2.2) or the Metabolic pregnancy exit. Web picks
  all result colours from `severity` itself (§5.1 has the palette).
- `title` can be `null`: `sti_uti` has none.
- `screening_section` (when non-null) is
  `{ heading, intro, message, bullets[], ctas[{key,label}], independence_note, due, status_code, interval, basis, method, description }`.
  On the shared layout, `due` only changes the content (a bookable
  "Book screening" chip and a "Your screening is due" greeting); the card
  looks the same either way. The Cancer and Metabolic pages (below) have
  no booking action on the screening card.
- `symptom_alerts_section` is
  `{ heading, intro, outro, alerts[{title, detail}] }`.
- `nutrition_recommendation` is `{ label, description }`.
- `cta_section.items` are `{key, label}`. Resolve each `key` against the
  config's `ctas` (§1) to book it.
- `has_active_warning`: on a Mental health result, web shows a red
  "Immediate Support Recommended" box with a "Call Befrienders Kenya: +254
  722 178 177" button. Only for Mental health — Ebola also sets this flag,
  and that message would be wrong there.
- `offer_facility_share` (`ebola-screening` only): web shows "Help the
  receiving facility prepare safely" with a "Share with a facility" button
  that opens a navigator booking ("Ebola screening follow-up").
- `offer_care_navigation` (`endometriosis`/`endometriosis-dependent`
  only): web shows "Get help with your next care step", which opens a
  navigator booking ("Endometriosis care navigation"). On a
  `kind: "endometriosis"` result this box is left out, because the "Care &
  support" footer tile does the same job. Both flags are `false` for every
  other assessment.
- `services.get_session_score` also computes the Cancer machine-readable
  output contract (`overall_colour`, `trigger_codes`, `screening_status`,
  `screening_recommendation`, `guideline_version`, …), but
  **`SessionScoreSerializer` deliberately doesn't send them**: data
  minimisation for health data (asserted by `test_views`). Render
  `result_display`; never re-derive from these codes.

**Treat `result_display` as an opaque, pre-rendered content bundle — do
not re-derive any of its fields from raw answers client-side.** This is
explicit, deliberate backend design (`engine/result_display.py`'s own
docstring: *"a second client (the mobile app) must never have to
re-implement this business logic or duplicate the document-mandated
copy"*). `kind` (`"sti_uti"` / `"tiered"` / `"generic"` / `"endometriosis"`)
only tells you which of `result_display`'s optional fields are populated
for this particular result — every field not relevant to this `kind` is
simply `null`. `kind: "tiered"` covers both Cancer (4 tiers) and Metabolic
(hypertension/diabetes) results. Cancer's incomplete and same-cancer
exits, and Metabolic's incomplete and pregnancy exits, fall back to
`"generic"`.

**Which result screen web shows** (`app/(app)/assessments/[slug]/complete/page.tsx`).
The screen loads the config, `POST .../session/` (with the same dependant
id, if any), `.../score/`, `can-start` and
`GET /api/care-navigation/referrals/mine/`. From the referrals it picks
the one whose `session` is this session. It also asks the device for its
location, for the facility finder below. A session still `in_progress`
goes back to `/start`.

- Cancer + `kind: "tiered"` → the Cancer result page (§5.1).
- `hypertension`/`diabetes` + `kind: "tiered"` + non-null `title` → the
  Metabolic result page (§5.2).
- Everything else → the shared layout below. Cancer and Metabolic results
  also fall back to it once a doctor is already handling the referral:
  that referral's booking has `checked_in_at`, is `completed`, or has a
  `follow_up_to`. The colour, symptom and screening cards are then hidden
  and the referral card takes their place.

**Booking from a result** (see
[`bookings-and-consultations.md`](./bookings-and-consultations.md) §2, §3,
§6):

- A **consultation** CTA on a tiered result (the Cancer/Metabolic Orange/Red
  button, or a `consultation` item in a tiered `cta_section`) opens the
  "Find a health facility" modal for this session. Picking a facility
  creates the referral (`POST /api/care-navigation/referrals/from-session/<session_id>/`)
  and its booking. The CTA `label` (with its " - {assessment}" suffix) is
  the fallback `service_label`. Afterwards the referral card
  (`ReferralRecommendationCard`, without its "Recommended care" panel)
  shows on the result screen.
- **Every other CTA** opens the booking dialog prefilled from the resolved
  config CTA: `assessment_slug`, `session_id`, `service_type`, the item's
  `label` as `service_label`, `price_kes` and `description`. For `sti-uti`
  the dialog hides the facility field.

**The shared layout**, top to bottom (each part only when its data is
present). A back link at the top reads "Dashboard".

- **"Thank you!" header** (not for Cancer or Reproductive health): "Your
  {title} questionnaire is complete." and, if set, a "Reference" box with
  `reference_number`.
- **Mental health crisis box** (`has_active_warning`, Mental health only).
  "Immediate Support Recommended" / "Your responses included thoughts that
  you would be better off dead, or of hurting yourself. Please reach out
  for support today — you do not have to manage this alone." It has a
  "Call Befrienders Kenya: +254 722 178 177" button (`tel:+254722178177`)
  and "Or go to your nearest hospital, or contact a healthcare provider
  you trust, right away."
- **Ebola facility-share box** (`ebola-screening` + `offer_facility_share`).
  "Help the receiving facility prepare safely" / "Sharing this screening
  with a facility ahead of your visit lets their team prepare appropriate
  precautions before you arrive. This is optional and confidential -- you
  will be asked to confirm by SMS before anything is shared." The "Share
  with a facility" button opens a `navigator` booking: "Ebola screening
  follow-up", "A navigator will help coordinate safe evaluation at a
  facility near you."
- **Endometriosis care-navigation box** (`offer_care_navigation`, not on
  `kind: "endometriosis"`). "Get help with your next care step" / "You
  told us that something is making care difficult, or asked for support --
  we can help you identify the next step and suitable services." The "Talk
  to a care navigator" button opens a `navigator` booking: "Endometriosis
  care navigation", "A navigator will help you with your next care step."
- **`kind: "endometriosis"` card.** Coloured from `card_color` (`soft`
  background, `border`, `accent` for `category_label`, `button` /
  `button_text` for the primary button). It shows "Your Result", `title`,
  `category_label` and `body`.
  - "Next step":
    - `primary_cta_label` opens a `navigator` booking with that label and
      "A navigator will help you with your next care step."
    - `secondary_cta_label` links to the Endometriosis help screen
      (`learn-more?tab=help`).
  - Then a "Personalised recommendation" card: `recommendation_heading`,
    `recommendation_body`, and `observations` under "What we noticed".
- **`kind: "generic"` / `"sti_uti"` card.** "Your result", `title` (if any)
  with a severity dot, then `body` (keep its line breaks).
  - `metric` as "{label}: **{value}**" (generic only; `sti_uti`'s `body`
    already includes it).
  - `nutrition_recommendation` under "Nutrition Recommendation".
  - Colours by `severity`: green, amber, orange, red. `neutral` uses the
    plain card colours.
- **`symptom_alerts_section`.** `heading` (with a warning icon), `intro`,
  each alert's `title`/`detail`, `outro`.
- **`cta_section`.** `heading`, `subheading`, then one row per item whose
  `key` resolves. Each row has the item `label`, the CTA `description`,
  "Ksh {price_kes}" when set, and a "Book" button.
- **`screening_section`.** "Screening Recommendation", then a greeting
  when the profile has a first name: "Your screening is due, {name}."
  (`due`) or "Your routine screening plan, {name}." (not due). Then
  `message` ?? `intro` ?? "Based on your age and responses, we
  recommend:".
  - **Due:** the `bullets` joined with " and " form one tappable chip.
    It books the first `ctas` entry whose config CTA has
    `service_type: "screening"`, labelled "Book screening". With no
    bullets, a plain "Book screening" button does the same. Any
    non-screening `ctas` get their own button with the item `label`.
  - **Not due:** one non-tappable chip per bullet.
- **Referral card**, if this session has a referral.
- **`cervical-cancer` only** (when not tiered): a static "HPV & the HPV
  vaccine in Kenya" card (`components/hpv-info-card.tsx`).
- **Report card**, only when `show_report_card` is true or the category is
  Cancer. "Keep Your Report" / "Save, email or share your assessment
  report." Three buttons:
  - "Download my report" (§6).
  - "Email the report" (the "Email me this report" dialog, §6).
  - "Share with my doctor" (the "Share with your healthcare provider"
    dialog).

  Under them: "🔒 For your privacy, this PDF is password-protected — the
  password hint appears after downloading." and "You can also share the
  report with your healthcare provider to support further discussion,
  clinical review and appropriate care."
- **`kind: "endometriosis"` with `show_footer_tiles`.** A "Learn about
  endometriosis" tile (→ the Learn More page) and a "Care & support" tile
  (the same navigator booking as the care-navigation box).
- **`sti-uti` sessions finished before V15 only:**
  - "Notify a partner anonymously", when `metric.value` contains "STI"
    (see "Notify a partner" below).
  - "Start the 7–14 day follow-up review", which opens
    `/assessments/sti-uti-followup/start`.
- **"Retake this assessment"**, only when `can-start.allowed` (§2).
- **"Back to Dashboard"** and **"Other Assessments"** (→ `/assessments`).

**Notify a partner** (`sti-uti` sessions finished before V15, `components/partner-notify-dialog.tsx`):

```
POST /api/push/partner-notifications/   { "pathway": "sti" | "both", "message": "<≤500 chars, optional>" }
→ 201 { "id", "token", "pathway", "message", "created_at", "expires_at" }
```

- `pathway` is `"both"` when `metric.value` contains "combined"
  (case-insensitive), otherwise `"sti"`.
- The dialog is titled "Notify a partner anonymously": "Share a
  confidential link with a recent partner so they can also get checked.
  Your identity is not shared."
- It has an "Optional personal note (they will see this — no names
  recommended)" field and "The page they open will not reveal who sent
  the link. Links expire after 60 days.", then "Generate anonymous link".
- The link is the **web** page `https://<web app host>/p/<token>`, shown
  under "Your link".
- Share buttons: "Copy link", "WhatsApp" (`https://wa.me/?text=…`), "SMS"
  and "Email". Each sends "I'd like you to see this confidential health
  notice from My Wellness Health: <link>". The email subject is "A
  confidential health notice".
- Then "You can generate one link per partner. Links expire after 60
  days." and "Create another link".
- Web has no screen that lists or revokes these links.

**Retake.** "Retake this assessment" calls
`POST .../session/ { "retake": true, …same dependant id }`. It opens the
intro if the new session is `awaiting_payment`/`awaiting_call`, otherwise
`/start`. A failure shows the error `detail`.

**2026-10-28/29: Cancer `kind: "tiered"` results got a full on-screen
redesign on web to match a new reference design.** Web renders it with
`components/cancer-result/cancer-result-view.tsx`. This added fields to
both `ResultDisplay` and `ScreeningSection`. Metabolic (`hypertension`,
`diabetes`) got its own redesign on 2026-11-02 using the same fields — see
§5.2.

New top-level `ResultDisplay` fields (Cancer and Metabolic tiered results
only, `null` for every other `kind`/category):
- `action_summary`: `{ "title": string, "items": string[], "intro": string | null }`.
  On Cancer: a fixed, per-tier 3-item checklist ("How to stay on track" /
  "What you can focus on" / "Your recommended next steps" / "What to do
  now"), shown under the result card's body text; `intro` is always
  `null`. On Metabolic: see §5.2.
- `critical_notice`: `{ "heading": string, "body": string } | null` —
  only non-null on a Red/urgent result; a fixed "Do not wait for routine
  screening" alert box.
- `important_notice`: `{ "heading": string, "body": string }` — always
  set on a Cancer or Metabolic tiered result, `null` otherwise. On Cancer it
  branches on tier + the screening recommendation's own `status_code`
  (see below); **web substitutes the user's own first name client-side**
  whenever `heading === "Congratulations!"` (the one combination, out of
  11, that's personalised) — mobile must do the same, not render that
  literal string.

New fields on `screening_section`. They're populated for Cancer and
Metabolic tiered results; generic screening sections leave them `null`.
On a Cancer result the whole section is `null` in these cases (Metabolic:
see §5.2):

- No recommendation for this result.
- A `not_applicable` or `not_routinely_due` status.
- **Any Red/urgent result**, even when the underlying recommendation
  exists. This matches the new design's own "screening hidden entirely on
  red" choice.

The fields:
- `status_code`: `"due" | "upToDate" | "highrisk" | "underage" |
  "unconfirmed" | "neutral" | "carePlan" | null` (`carePlan` is
  Metabolic-only) — drives the screening card's status-pill colour and
  its personalised status sentence on web (e.g. `"due"` → `"Your
  screening is due, {firstName}"`); mobile should build the equivalent
  sentence client-side from this code + the user's own first name, the
  same way web does, rather than expecting a pre-built sentence from the
  backend.
- `interval`: human-readable cadence string (`"Every year"`,
  `"Individualised by a healthcare professional"`, …) or `null`.
- `basis`: the "Based on" fact, e.g. `"Age 42 · No high-risk factors
  reported"` — deliberately never names the *specific* high-risk trigger
  (BRCA/biopsy/family history/etc.) even when `status_code` is
  `"highrisk"`, per the underlying screening engine's own "never states
  why" rule.
- `method`: the test/pathway name alone, with no interval folded in (e.g.
  `"Clinical Breast Examination + Mammogram"`) — distinct from `bullets`,
  which still carries the interval folded into its own prose for the
  shared layout.
- `description`: an optional explanatory sentence. On Cancer it's
  populated only for the `"highrisk"`/`"neutral"` status codes; on
  Metabolic it's always set.
- For an up-to-date screening, the section is `heading: "Well done!"` with
  `status_code` falling back to `"upToDate"`, `due: false`, and no
  bullets/CTAs. Any other state is `heading: "Screening Recommendation"`.
  Tiers 2/3 never carry a `consultation` CTA here, because it's already in
  `cta_section`.

### 5.1 The Cancer result page

**What the web Cancer result page shows** (`cancer-result-view.tsx`; mirror
this):

- **Colours.** The page uses the reference design's own palette per
  `severity`:

  | `severity` | Name | Accent | Fill | Border |
  |---|---|---|---|---|
  | `good` | Green | `#158370` | `#edf8f3` | `#cce9dc` |
  | `attention` | Yellow | `#b47c12` | `#fff8e9` | `#f4dfae` |
  | `concern` | Orange | `#c46e2b` | `#fff5eb` | `#f4dac4` |
  | `urgent` | Red | `#b84140` | `#fff1ef` | `#f3d6d2` |

- **Back link** "Dashboard" at the top.
- **Result card**, in this order:
  - "Your assessment result" label and a "{Green|Yellow|Orange|Red}
    result" pill.
  - `title` as the heading, then `body`.
  - `critical_notice` as a red warning box (`heading` in bold, then
    `body`), if present.
  - `action_summary`: `title`, then `items` as a ticked checklist.
  - One button with fixed UI copy:
    - Green: "Explore my health tips". Yellow: "View my recommendations".
      Both scroll to the checklist.
    - Orange: "Arrange clinical follow-up". Red: "Visit a healthcare
      facility". Both are teal (`#095a5d`) and open the consultation
      booking for `cta_section.items[0]`, resolved by `key` against the
      config's `ctas`. That opens the "Find a health facility" modal (§5,
      "Booking from a result"). The button is left out if there's no such
      CTA.
  - The session's referral card appears under the result card, if one
    exists.
- **"Important to know" card.** Shows `important_notice`. For the
  "Congratulations!" case it adds a tick badge and substitutes the first
  name: "Congratulations, {firstName}!". The name is the first word of the
  profile's `full_name`.
- **Screening card**, only when `screening_section` is non-null:
  - Kicker "{short_title} screening", then the heading "Your screening
    recommendation".
  - A status pill coloured by `status_code`: `due`, `upToDate` and
    `highrisk` get their own colours, everything else is grey. A `null`
    `status_code` is treated as `neutral`.
  - The pill text, where `{organ}` is `short_title` with "cancer" stripped
    and lower-cased. Without a first name, drop the name cleanly and
    capitalise ("Your screening is due", "Well done! Your screening is up
    to date", "You may need enhanced {organ} screening"):

    | `status_code` | Pill text |
    |---|---|
    | `due` | "Your screening is due, {name}" |
    | `upToDate` | "Well done, {name}! Your screening is up to date" |
    | `highrisk` | "{name}, you may need enhanced {organ} screening" |
    | `underage` | "{name}, routine {organ} screening is not yet due for your age" |
    | `unconfirmed` | "{name}, confirm your screening details" |
    | `neutral` | "{name}, discuss whether to continue screening" |

  - `method` as a sub-heading, then `description`.
  - A two-cell fact grid, shown if either value exists: "Recommended
    interval" (`interval`, or "To be confirmed") and "Based on" (`basis`,
    or "Your assessment answers").
- **Report card:** kicker "Keep your report", heading "Your health
  report", text "Save your result or share it with a healthcare
  professional.", and three buttons:
  - "Download" ("Preparing…" while it runs; §6).
  - "Email": the "Email me this report" dialog, prefilled from
    `email-prefill`.
  - "Share": the "Share with your healthcare provider" dialog, the same
    email endpoint with an empty field.
- **Below the cards:**
  - "Retake this assessment", only when `can-start.allowed` (§2).
  - Footer nav: "Back to dashboard" and "Other assessments" →
    `/assessments`.
  - The fixed line "My Wellness Health · This assessment result is not a
    diagnosis or a validated clinical decision. Please discuss your result
    and screening with a qualified healthcare professional."
- **Once a doctor is handling the referral** (§5), Cancer uses the shared
  layout instead. With the colour cards hidden, that leaves the referral
  card, the report card, Retake and the two navigation buttons. Cancer
  never gets the "Thank you!" header.
- **Not shown in this view:**
  - `symptom_alerts_section`, which is non-null on a Red result with
    reported symptoms.
  - `nutrition_recommendation`.
  - The screening section's `heading`/`message`/`bullets`/`ctas`/`independence_note`.
  - `cta_section`'s own labels.

  These are used by the shared layout and the PDF. Hiding the Red symptom
  list is web's current choice; check with product before dropping it on
  mobile too.

### 5.2 The Metabolic result page (`hypertension`, `diabetes`)

Web rebuilt both Metabolic result screens on 2026-11-02 from one shared
reference design
(`MWH_{Hypertension,Diabetes}_Assessment_Results_No_View_Recommendations`).
Web renders `components/metabolic-result/metabolic-result-view.tsx` when
**all** of these hold:

- the slug is `hypertension` or `diabetes`;
- `kind == "tiered"` (i.e. a real colour result — incomplete and the
  pregnancy exit come back `generic` and use the shared layout);
- `title` is non-null (the backend sets it for exactly these two slugs,
  `result_display.METABOLIC_RESULT_PAGE_SLUGS`);
- no doctor is handling the referral yet (same test as Cancer, §5.1).
  Once one is, web shows the shared layout instead, which for Metabolic
  reduces to the "Thank you!" header, the referral visit-status card, Retake
  and the two navigation buttons.

**Render only what's listed here.** Everything this section doesn't
mention is ignored by web on this screen (see "Not shown" at the end). The
page reuses the Cancer page's card styles.

**Colours.** Same per-`severity` palette as the Cancer page (§5.1 table).
Diabetes doesn't return `urgent` today (its engine's Red branch exists but
nothing currently triggers it); render it the same way as hypertension's
if it ever does.

**What the backend sends for these two slugs:**

| Field | Value |
|---|---|
| `title` | Per colour: "Right Track" / "A Few Areas Need Attention" / "Clinical Follow-Up Needed" / "Urgent Evaluation Needed" |
| `body` | Per-colour description; Yellow's varies with whether risk factors were found and whether screening is due |
| `action_summary` | Always set — see the result card below |
| `critical_notice` | Red only |
| `important_notice` | Always set |
| `screening_section.status_code` | `due` / `upToDate` / `carePlan` / `unconfirmed` (both), plus `neutral` (diabetes, not eligible for routine testing) |
| `screening_section.method`, `.interval`, `.basis`, `.description` | Always set when the section exists |

**Page order:** back link "Dashboard" → result card → referral card (if
one exists) → "Important to know" → screening card → report card → Retake →
footer nav → disclaimer.

- **Result card:**
  - "Your assessment result" label and a "{Green|Yellow|Orange|Red}
    result" pill.
  - `title` as the heading, then `body`.
  - `critical_notice`, if present: a red warning box with `heading` in
    bold and `body` on the line below it.
  - `action_summary`: `title` as a small bold heading, then:
    - **If `intro` is non-null** (only ever on Yellow): `intro` ("You
      reported:") in bold, then `items` as a plain bulleted list with amber
      (`#ac7a1c`) bullet markers.
    - **Otherwise:** one row per item, each with a small rounded badge
      showing a per-colour glyph — Green a tick (badge `#eaf4f1`, glyph
      `#087066`), Yellow a clock (`#fff8e9` / `#ac7a1c`), Orange an
      info "i" in a circle (`#fff0e1` / `#b6622a`), Red an exclamation mark
      (`#ffefed` / `#b84140`).
    - Green's `items` is empty: only the title "Continue a healthy
      lifestyle." shows.
  - **One button, Orange and Red only** (teal, `#095a5d`), fixed copy:
    Orange "Clinical follow-up needed", Red "Visit a healthcare facility
    now". Both open the consultation booking for `cta_section.items[0]`,
    resolved by `key` against the config's `ctas` (web opens its own
    facility-choice step, same as Cancer). Leave the button out if there's
    no such CTA. **Green and Yellow have no button at all** — don't
    reintroduce Cancer's "Explore my health tips" / "View my
    recommendations".
- **Referral card:** the existing care-navigation referral for this
  session, if one exists (same as Cancer).
- **"Important to know" card:** "Important to know" tag, then
  `important_notice.heading` and `.body`, as sent. No first-name
  substitution and no tick badge on this page (unlike Cancer's
  "Congratulations!").
- **Screening card** — hidden when `severity == "urgent"` **or**
  `screening_section` is `null`:
  - Kicker "Blood pressure screening" (hypertension) or "Diabetes
    screening" (diabetes), then the heading "Your screening
    recommendation".
  - A status pill. Colour: `due`, `upToDate` and `carePlan` (which uses
    Cancer's `highrisk` orange) get their own; everything else is grey.
    Text, where `{name}` is the first word of the profile's `full_name`;
    without a name, drop it cleanly ("Your screening is due"):

    | `status_code` | Pill text |
    |---|---|
    | `due` | "Your screening is due, {name}" |
    | `upToDate` | "Your screening is up to date, {name}" |
    | `carePlan` | "Continue your clinical care plan, {name}" |
    | `neutral` (or `underage`) | "Routine screening is not currently due, {name}" |
    | `unconfirmed`, `null` or anything else | "{name}, confirm your screening history" |

    Note these differ from the Cancer table in §5.1.
  - `method` as a sub-heading (fallback "Confirm your screening needs"),
    then `description` if present.
  - The two-cell fact grid, **always shown**: "Recommended interval"
    (`interval`, or "To be confirmed") and "Based on" (`basis`, or "Your
    assessment answers").
  - The fixed note "Screening guidance is generated separately from your
    assessment result."
  - No booking action.
- **Report card:** kicker "Keep your report", heading "Your health
  report", text "Save your assessment result or share it with a healthcare
  professional.", and three buttons: "Download PDF" ("Preparing…" while it
  runs; §6), "Email" (prefilled from `email-prefill`) and "Share" (same
  email endpoint, blank field for the provider's address). Web shows this card for these two
  slugs even though `show_report_card` is `false` — don't gate it on that
  flag here.
- **Below the cards:**
  - "Retake this assessment", only when `can-start.allowed` (§2).
  - Footer nav: "Back to dashboard" and "Other assessments" →
    `/assessments`.
  - The fixed two-line disclaimer: "My Wellness Health · This
    self-reported health assessment does not diagnose disease or establish
    control of an existing condition. Screening and referrals must follow
    the approved assessment rules and healthcare-professional guidance."
    then "Standard Wellness and Clinical Advocacy Ltd ·
    info@mywellnesshealth.co.ke · www.mywellnesshealth.co.ke · 0706349849".
- **Not shown on this page** (still in the response — ignore them here):
  - `symptom_alerts_section` (Red's symptoms already appear in
    `action_summary` and `critical_notice`).
  - `nutrition_recommendation`.
  - The screening section's `heading`, `intro`, `message`, `bullets`,
    `ctas`, `due` and `independence_note`.
  - `cta_section`'s own `heading`/`subheading`/`label`s — only its first
    item's `key` is used, to book.
  - `show_report_card`, `show_footer_tiles` and every endometriosis-only
    field.
- **Not on the page at all** (in the reference file, deliberately left
  out on web): the brand header, the "{Condition} health check" title
  block and patient line, the developer "Preview assessment results"
  switcher, and the reference's browser-print report — Download always
  uses the real password-protected PDF (§6).

## 6. PDF report

```
POST /api/assessments/<slug>/session/<session_id>/report/
GET  /api/assessments/<slug>/session/<session_id>/report/email-prefill/
POST /api/assessments/<slug>/session/<session_id>/report/email/     { "email": "..." }
```

Web offers these from two places:

- **The result screens' report card** (§5). It's always on the Cancer and
  Metabolic pages. On the shared layout it shows when `show_report_card`
  is true or the category is Cancer.
- **Each completed health-check card** (§7). This one has download and
  "email me" only, no share.

`POST .../report/` (no body) returns the **raw PDF bytes** directly as the
response body (`Content-Type: application/pdf`), not JSON.

- **Filename.** Read `Content-Disposition`: `attachment;
  filename="<slug>-report-<reference_number or session id>.pdf"`.
- **Password hint.** The custom header `X-Pdf-Password-Hint` carries one
  of three exact strings (`engine/utils.py:derive_pdf_password_hint`):
  - `"last 4 digits of your registered phone number"`
  - `"last 4 characters of your member code"`
  - `"default code provided with your account"`

  Web shows a "PDF downloaded" toast: "This report is password-protected.
  Open it with the <hint>." A failure toasts the error `detail` ("Could
  not download the report" as a fallback).
- **The password itself is never sent in any response.** The PDF is
  encrypted (`PdfWriter.encrypt`) with the last 4 digits of the user's
  own registered phone (digits only). If that isn't usable, it falls back
  to the last 4 alphanumeric characters of their member code, upper-cased.
  If neither is usable, it's a fixed `"0000"`. Mobile must show the same
  hint text and never compute or show the real password proactively. The
  user is expected to already know their own phone number.
- **Errors.** `400` "Please complete the cancer-history screening first."
  / "Please complete payment to generate your report." / "This session has
  not been scored yet." (also for `awaiting_call`).
- **Layout.** The PDF varies by assessment: STI/UTI, STI/UTI follow-up,
  Endometriosis, Cancer, Metabolic and Mental health each have their own,
  and everything else uses a generic one.

`.../report/email/` sends the identical PDF as a real email attachment to
a client-confirmed address. Web has two dialogs on the same endpoint:

- **"Email me this report"** ("We'll send the password-protected PDF to
  this address."). The "Email address" field (placeholder
  `you@example.com`) is pre-filled from `.../report/email-prefill/`. That
  returns `{"email": null}` if the account has no usable email on file;
  then leave the field blank for the user to fill in. A failed prefill
  call also just leaves it blank.
- **"Share with your healthcare provider"** ("We'll send the
  password-protected PDF to your provider's email address."). A blank
  "Your provider's email address" field (placeholder `doctor@clinic.com`).
  Any well-formed address is accepted.

Both dialogs have a "Send report" button ("Sending…" while it runs).

- **Success means queued, not sent.** The server checks the report can be
  built, then queues the build and send on Celery
  (`send_report_email_task`) and returns `200 {"detail": "Report
  emailed."}`. Web's toast: "Report emailed to {address}" / "Check your
  inbox (and spam folder) in a few minutes." Delivery failures are retried
  server-side and never come back to the client.
- **Throttled.** The limit is 10 per hour per user (`report_email` scope),
  and going over it returns `429`.


## 7. Health checks & follow-up (the dashboard's "My Health Checks & Follow-Up")

One card per assessment the user has touched, plus a "not started" card for
each untouched family. Every clinical value on a card (outcome colour/label,
screening card) is read from the same `result_display` the result screen
uses (§5) — render it, never derive it. Web: `components/health-checks/`.

```
GET /api/assessments/health-checks/        → HealthCheckCard[]
PUT /api/assessments/health-checks/<session_id>/visit/   → 204
PUT /api/assessments/health-checks/<session_id>/steps/   → 204
```

```json
// one HealthCheckCard
{
  "id": "<session uuid, or 'assessment:breast-cancer' for a not-started card>",
  "family": "cancer" | "metabolic" | "women" | "mental" | "ebola",
  "name": "Breast cancer",
  "subtitle": "Cancer",
  "assessment_slug": "breast-cancer",
  "session_id": "<uuid>" | null,
  "status": "not_started" | "in_progress" | "awaiting_call" | "completed",
  "progress": 0-100,
  "outcome": { "colour": "green"|"yellow"|"orange"|"red", "label": "...", "description": "..." } | null,
  "screening": { "heading": "...", "summary": "...", "detail": "...", "note": "...", "due": true } | null,
  "facility": { "recommended": true, "priority": "routine"|"urgent", "referral_id": "<uuid>"|null } | null,
  "visit": { "facility": "...", "date": "2026-10-27", "advice": "...", "next_review_date": null } | null,
  "followup_steps": [ { "key": "review_guidance", "label": "Review your personalised recommendations", "done": false } ],
  "report_available": true
}
```

Rules worth knowing:

- **Scope:** the user's own sessions only (no dependant/assisted/child
  sessions), latest session per slug. Only these slugs count:
  - Cancer: the 5 cancers.
  - Metabolic: `hypertension`, `diabetes`.
  - Women: `endometriosis`.
  - Mental: `phq9`, `gad7`, `stress`.
  - Ebola: `ebola-screening`.

  No `-followup`/`-dependent`/`-assisted`/`-child` variant counts. Sexual &
  urinary and Workplace wellbeing never appear. Cards are ordered by
  family as listed; within a family, started assessments come first (newest
  first), then the not-started ones. No not-started card for an assessment
  excluding the user's gender, none in Cancer when
  `profile.cancer_diagnosed` is true, and none for Ebola while it's paused.
- **`name`** is the assessment's own `short_title`: "Breast cancer",
  "Hypertension", "Depression", "General Anxiety Disorder", "Stress" and so on.
- **`subtitle`** is the family: "Cancer", "Metabolic Conditions", "Women’s
  Health" (curly apostrophe), "Mental Wellbeing", "Ebola".
- **`status: "not_started"` can still carry a `session_id`/`assessment_slug`.**
  A session at `needs_pre_screening`/`awaiting_payment` reports as
  `not_started`. An assessment with no session at all gets an
  `id: "assessment:<slug>"` card with a null `session_id`. `progress` is
  `completion_pct`, or 100 once completed.
- **`outcome`** takes its colour from the score's `overall_colour` when
  that's one of the 4 colours. Otherwise it maps `result_display.severity`:
  `good`→green, `attention`→yellow, `concern`→orange, `urgent`→red, and
  `neutral`→none. `label` is `colour_label` or `title`, and `description`
  is `body`.
- **`outcome: null` on a completed card** means there's no colour result
  to show. That's either because the session was never scored, or
  because its result is `neutral` (e.g. the same-cancer exit or the
  Metabolic pregnancy exit). Web shows "Result pending" ("Your health
  check has been completed and its result is still being prepared. Check
  back shortly or open your result page.") and nothing else; never invent
  a colour. Such a card also has `facility: null` and no follow-up steps.
  `report_available` can still be `true`, but web shows no report panel
  on it.
- **`screening`** is built from `result_display.screening_section`:
  - `summary` = `method`, or else `message`. Since 2026-11-02 Metabolic
    sections carry a `method` too, so a hypertension/diabetes card reads
    e.g. "Blood pressure measurement" with `description` as its detail.
  - `detail` = `description`, or else `intro`.
  - `note` = `independence_note`.

  - `heading` = the section's `heading`, or "Screening recommendation".

  It's `null` whenever that section is `null` (e.g. any Red Cancer
  result) or has neither `method` nor `message`.
- **`facility`** is set when there's a non-dismissed assessment referral,
  or when `severity` is `concern`/`urgent`, and only when there's an
  `outcome`. `priority` is `"urgent"` only for `urgent`.
- **Where each card leads (web):** a card with no `assessment_slug` → that
  family's hub (Cancer → `/assessments/cancer`, Metabolic →
  `/assessments?category=Metabolic`, Women → `/assessments/women-health`,
  Mental → `/assessments?category=Mental health`, Ebola →
  `/assessments/ebola`); `in_progress` → `/assessments/<slug>/start`;
  otherwise → `/assessments/<slug>` (intro/paywall). A completed card's
  links open the result screen. "Start/Continue via WhatsApp" opens
  `https://wa.me/254706349849?text=Hello%20My%20Wellness%20Health.%20I%20would%20like%20to%20continue%20a%20health%20assessment.`.
  That's a chat with the team, not a resumed session.
- **Record a visit.** Web only offers this on a card with `facility` set:
  "I have visited a healthcare facility", or "Edit healthcare visit" once
  recorded. `PUT …/visit/` with
  `{ "facility": "≤150 chars", "date": "YYYY-MM-DD", "advice": "≤800 chars", "next_review_date": "YYYY-MM-DD"|null, "confirmed": true }`.
  `confirmed` must be `true` (the "I confirm I attended" tick); the date
  can't be in the future; `next_review_date` can't be before it. Only for
  the user's own **completed** sessions — anything else is `404`/`400`.
  Recording a visit never changes the outcome or the referral.
  - **The form** is "Record healthcare visit" / "Record attendance only
    after you have visited a healthcare facility." Its fields:
    - "Facility visited" (placeholder "Hospital or clinic", required).
    - "Date attended" (required, not after today).
    - "Advice received (optional)".
    - "Next review date (optional)" (not before the visit date).
    - The required tick "I confirm I attended this healthcare visit."

    Then "Cancel" and "Save visit" ("Saving…"). On success it toasts
    "Healthcare visit saved". A failure shows the error `detail` under the
    form. When editing, the fields are pre-filled from `visit`, but the
    tick starts unticked.
- **Follow-up checklist** ("Follow-up plan"): `PUT …/steps/` with
  `{ "step": "<key>", "done": true|false }`.
  Step keys are stable; labels may change. Ticks are the patient's own
  progress notes, not medical clearance. The steps are
  (`health_checks.build_followup_steps`):
  - Always: `review_guidance`.
  - When `screening.due`: `arrange_screening`.
  - When a facility is recommended: `attend_facility`,
    `complete_investigations`, `attend_review`.

  An unknown key returns `400 "Unknown follow-up step."`. Web ticks the box
  straight away, then re-fetches the list. A failure reverts the tick and
  toasts "Couldn't save that step. Please try again."

**What the dashboard section shows** (`components/health-checks/health-checks-followup.tsx`).
Nothing at all when the list is empty.

- **Header.** "My Health Checks & Follow-Up" / "Your progress, results and
  next steps".
- **Unfinished notice**, when any card is `in_progress` or
  `awaiting_call`. "{n} unfinished assessment(s)" / "Pick up where you
  left off, on the web app or through WhatsApp." Its "Continue my
  assessments" button expands and scrolls to the first such card.
- **Visit notice**, when any completed card has an `outcome` and a
  `facility` but no `visit`. "{n} completed health check(s) need(s) visit
  follow-up" / "Follow the urgency and facility guidance from your
  completed assessment. A recorded visit is tracked separately from the
  original assessment result."
- **One collapsible card per entry.** Each shows `name`, `subtitle` and a
  progress ring (`progress`%, or a tick at 100). Expanded, it adds "Your
  assessment progress" with a bar.
  - **Not started / `in_progress` / `awaiting_call`.** The state line reads
    "Not started", "Assessment in progress" or "A care navigator will
    contact you". The expanded text:
    - `awaiting_call`: "Your health check is unlocked. A member of our
      care team will call you to help you complete it."
    - `in_progress`: "Complete your health check to receive guidance
      about symptoms and recommended care."
    - Not started: "Complete your health check to receive personalised
      next-step guidance." (Ebola: "Complete your check to receive
      appropriate exposure and symptom guidance. If you already have
      concerning symptoms or possible exposure, contact the public health
      team promptly.")

    Then "{Start|Continue} on Web App" (where it leads is below) and
    "{Start|Continue} via WhatsApp", with "The web app reopens your saved
    health check. WhatsApp opens a chat with our team, who can help you
    continue." "Continue" is for `in_progress`/`awaiting_call`.
  - **Completed.** It reads "Assessment Completed" and expands to:
    1. "YOUR ORIGINAL ASSESSMENT RESULT": `outcome.label` and
       `outcome.description` (fallback "Review your personalised
       assessment report and next-step guidance."), coloured by
       `outcome.colour`. Or the "Result pending" panel (above).
    2. With `facility`:
       - A "Visit a healthcare facility" button (urgent styling for
         `priority: "urgent"`) that opens the result screen.
       - "Visit Completed" with Facility, Date attended, Advice received
         and Next review, or "Healthcare visit not yet confirmed".
       - The visit button and form (above).
    3. With `screening`: "SCREENING RECOMMENDATION", `heading`, `detail`,
       `summary`, `note` (fallback "Screening eligibility is determined
       independently of result colour."), and "View my screening
       guidance" (→ the result screen).
    4. "Recommended next steps", with fixed text by case:
       - Green: "Continue the guidance supplied with your completed health
         check. A green result is not a diagnosis and does not exclude
         future illness."
       - With `facility`: "Follow the facility and follow-up
         recommendations supplied with your assessment. A completed visit
         does not automatically mean that care is finished."
       - Otherwise: "Review your personalised screening and health
         guidance. Any additional investigations must be determined by the
         appropriate clinical rules."
    5. "Follow-up plan" ("{done} / {total} steps", "Track what has been
       done after the assessment. Checked items do not constitute medical
       clearance."), with one tick box per `followup_steps` entry.
    6. With `report_available`: "Keep your health-check report", with
       "Download report" ("Downloading…") and "Email report". Email opens
       an inline "Email address" form, prefilled from `email-prefill`,
       with "Cancel" / "Send report". These use §6's endpoints with the
       card's `assessment_slug`/`session_id`.
    7. Ebola only: "Public-health follow-up" / "Attendance at a healthcare
       facility is not proof of Ebola clearance or completion of required
       public-health monitoring."
    8. "The assessment outcome, screening eligibility and referral
       attendance are three separate records. No result colour changes
       simply because a visit was recorded."
- **Footer.** "{completed} completed · {in_progress + awaiting_call} in
  progress · {not_started} not started", and "Result colours and
  screening recommendations come from your completed health checks. A
  result is not a diagnosis."

## 8. Cancer journeys (mirror web)

Web rebuilt both Cancer journeys on 2026-10-30. The endpoints are the ones
already documented; this is the order to call them in.

**Diagnosed (free, never paid):** the Cancer hub's "Already diagnosed?
Free Follow-Up" button (or "View My Follow-Up Guidance" once diagnosed),
which opens `/wellness-packages?journey=diagnosed` → "Your Cancer History"
(type from `GET /api/assessments/cancer-pre-screening-content/`'s
`gate.type_choices`, free text when `other`, year 1900–this year) →
`PATCH /api/auth/cancer-diagnosis/` with `cancer_diagnosed: true` → "Your
Follow-Up Guidance" (opt-in: `education_materials: true` on the same
endpoint) → "Other Health Assessments". From then on hide Cancer from
every package list, and the Cancer hub shows only "Your cancer follow-up
guidance".

**Paying:**

1. "Choose This Package" on anything that includes Cancer (Cancer alone, a
   combo containing it, All-in-One, a custom build with it) while
   `profile.cancer_diagnosed_declared_at == null` → "Before you continue":
   "Have you ever been diagnosed with cancer?". "No" →
   `PATCH /api/auth/cancer-diagnosis/ { "cancer_diagnosed": false }`, then
   review/payment. "Yes" → the diagnosed journey above.
2. After payment confirms (see
   [`payments-and-packages.md`](./payments-and-packages.md) §2), open the
   **Cancer hub** ("Cancer Health Checks" → "Choose a Cancer Health
   Check"): the five cancer checks, hiding any whose `excluded_gender`
   matches the user. The hub is paid-access only — if
   `module-access.unlocked["Cancer"]` is missing, send the user to the
   Cancer package instead (unless `cancer_diagnosed`, who gets the free
   guidance link).
   - The hub's back arrow goes to the dashboard. Its hero reads "Choose
     the cancer type you would like to assess. Each health check explains
     risks, warning signs, screening recommendations and appropriate next
     steps."
   - Each card shows "{name} Cancer" and a fixed line:

     | Card | Line |
     |---|---|
     | Breast | "Breast health, warning signs and screening guidance" |
     | Cervical | "Cervical health, HPV and screening guidance" |
     | Oesophageal | "Swallowing symptoms and relevant risk factors" |
     | Colorectal | "Bowel symptoms, family history and screening guidance" |
     | Prostate | "Prostate symptoms and screening discussions" |

   - Under the cards: "If you have already been diagnosed with cancer, use
     our free diagnosed-cancer follow-up guidance instead of repeating this
     cancer risk assessment." and the "Already diagnosed? Free Follow-Up"
     button.
   - A diagnosed user sees only "Your cancer follow-up guidance" ("You told
     us you've been diagnosed with cancer, so the routine cancer risk
     assessments aren't offered. Your follow-up guidance is free.") and
     "View My Follow-Up Guidance".
3. Picking a cancer → its intro, then the Encouraging Fact, then the
   questions. The pre-screening gate comes first for anyone who never
   answered on the packages screen (§2.2). Intro copy comes from the
   backend:
   - `tier_legend` (from `cancer-pre-screening-content`'s
     `before_you_begin`) for the "Know your result" colour list: `label`
     and `meaning`, with dots coloured by index Green/Yellow/Orange/Red.
   - `important_notes[1]` for the "Screening is scored separately." box.
   - The collapsed "IMPORTANT DISCLAIMER" holds, in order: `title`, the
     `intro_paragraphs`, the remaining `important_notes`, then the config's
     `disclaimer`.

   Everything else on the intro is fixed UI copy in
   `components/cancer-intro/cancer-intro.tsx`:
   - The "← Cancer" back link (to the Cancer hub).
   - The hero: "CANCER HEALTH CHECK", "Understand your {breast |
     cervical | oesophageal | colorectal | prostate} health.",
     "Self-paced", "Confidential".
   - "Your path to better {…} health", "What you'll get", "Before you
     continue".
   - The "Prefer WhatsApp?" panel ("Open WhatsApp ↗" →
     `https://wa.me/254706349849?text=Hello%20My%20Wellness%20Health.%20I%20want%20to%20complete%20a%20cancer%20health%20check.`).

   A required tick, "I have read and agree to the Terms and Conditions of
   Use." (linking to the web `/terms` page), enables "Continue to
   assessment".

   The Encouraging Fact screen (`CancerFact`) shows a fixed heart icon, the
   heading "Encouraging Fact" and `encouraging_fact.text`. Web doesn't
   render the `emoji`. It has "Continue", "← Back to instructions" (back
   to the intro) and "← Cancer" (back to the Cancer hub).

---

Last verified against the code on 2026-11-03.

## Anxiety (GAD-7), Depression (PHQ-9) and Stress (PSS-4) results

`result_display.kind` is `"mental_result"` for `gad7`, `phq9` and `stress`: render
`result_display.mental_result`, with a neutral score and never a severity label
or colour. `summary` and `actions` are the next steps in every state. `safety`
comes from `safety_check`: `no` -> `none`, `unsure` -> `follow_up`, `yes` ->
`immediate`, no answer -> `unconfirmed`.

**Anxiety** (`instrument: "gad7"`): the questionnaire ends at an `unsure`/`yes`
safety answer (`can_proceed` is never asked).

| `safety` | Show |
|---|---|
| `none` | `score` / `max_score`, next steps, report; `coping_steps` when not empty (under 15); the consultation box when `consultation_offered` (10 or more) |
| `follow_up` | Safety panel only: no score, report or retake. "Request safety follow-up", 999, 112 |
| `immediate` | Safety panel only: no score, report or retake. 999, 112 |
| `unconfirmed` | No result; retake and navigation only |

**Depression** (`instrument: "phq9"`): same as Anxiety, with these differences. A
positive question 9 is also `follow_up`, whatever the total. `coping_steps` shows
under 20 and its third step depends on question 1. From 20 up, `summary` and
`actions` are the must-do consultation wording.

**Stress** (`instrument: "stress"`): nothing is hidden by a safety answer, and the
questionnaire can continue past it through `can_proceed`.

| `safety` | Show |
|---|---|
| `none` | The full result, with coping strategies at any score; the consultation box when `consultation_offered` (11 or more) |
| `follow_up` / `immediate` | Safety panel above the full result: no coping or consultation |
| `unconfirmed` | The full result with a "safety check was not confirmed" warning: no coping or consultation |

On the health-checks card, these three have `outcome.colour: "neutral"`, with `label`
as the score or safety status: never treat it as a severity.

`score` null on Stress means the questionnaire wasn't finished: show "Assessment
incomplete" and "—". Web: `components/mental-result/`.

## Sexual & Urinary Health Check V15

`sti-uti` and `sti-uti-followup` use their own flow, built from the locked `mwh_su_v15.html`.
Its questions follow the order symptoms were tapped and its safety screens interrupt on the
tap, so it can't be walked by `current_index`. `POST .../answers/` and `.../answers/batch/`
now return 400 for both slugs; **a mobile build that still uses them can't complete this
check**. Web: `components/sexual-health-v15/`, `lib/assessments/sexual-health-v15.ts`. Port the
wording, order and question conditions as they are; `sexual-health-v15-bank.ts` is the question
bank. Screens use the platform's shared assessment design: the usual question layout (top bar,
Exit, section progress, choice cards) and the shared result-page cards, not the source file's look.
Don't show "Why we ask" text.

```
GET  /api/assessments/<slug>/session/<id>/sexual-health/
POST /api/assessments/<slug>/session/<id>/sexual-health/
     { "action": "...", "snapshot": { "pregnant", "symptoms": [...], "answers": {...}, "position": { "stage", "page_index" } } }
```

Create or resume the session with the usual `POST .../session/`. Both calls return the state:
`version` (`"15"`, or `null` for a session finished before V15: use the older result page),
`session_id` (it can change, see `restart`), `status`, `sex`, `profile_diabetes`, `pregnant`,
`symptoms` (in tap order), `answers` (multi-select answers are arrays), `position`, `outcome`
(`care` / `pregnancy` / `safety` / null), `pep` (`return_after`, `ready`, `acknowledged`),
`care` and, on the follow-up slug, `checkin`. `sex: null` means the profile has no gender:
ask the patient to add it.

Each action sends the whole snapshot. The server validates it and recomputes safety and
routing, so never treat the client's routing as final.

| `action` | Effect | Refused with `code` |
|---|---|---|
| `save` | Stores the snapshot, for resuming later | `pep_paused`, `not_in_progress`, `profile_incomplete` |
| `finish` | Completes the check and returns `care` | `safety_active` if a safety screen applies |
| `exit_pregnancy` | Records a pregnant "Yes" or "Not sure" exit | |
| `end_safety` | Records "End assessment" on a safety screen | |
| `pep_pause` | Starts the 24-hour pause from the HIV exposure screen | |
| `pep_resume` | Ends the pause once `pep.ready` is true (immediately for QA accounts in `TEST_USER_EMAILS`) | `pep_paused` |
| `restart` | Clears answers, keeping any PEP pause. From a safety or pregnancy exit it creates a **new session** (no payment, no cooldown), so read `session_id` | `cooldown` after a real result |

After `end_safety`, show the start screen and call `restart` when the patient starts again.
On load, an `outcome` of `safety` also shows the start screen, and `pregnancy` shows the
pregnancy exit.

`care` holds the result copy: `id` (`pyelo`, `combined`, `vvc`, `sti`, `uti`, `unclear`), `title`,
`reason`, `action`, `tag`, `colour`, `priority` (`level`, `label`, `message`), `guidance`,
`summary_pathway`. It is care navigation, never a diagnosis.

**Day-7 check-in.** A patient whose check reached care guidance with symptoms gets one
invitation on day 7 (`data.type: "sexual_health_checkin"`, `data.url`,
`data.assessment_slug: "sti-uti-followup"`). It's free. `checkin` gives `available`,
`available_at`, `symptoms`, `care_id` and `care_title`; `save` and `finish` return
`checkin_not_open` before day 7, and `finish` returns `safety_active` when `fu_danger` is "Yes"
or "Not sure". It's a platform check-in, never a clinician-directed follow-up.

**The result page.** For `outcome: "care"`, show the `care` copy, the conditional notices, the
"View my answers for a clinician consultation" dropdown, a booking button from the config's
`screening` CTA (the dialog hides the facility field) and the shared "Your health report" card
(Download PDF, Email, Share). It has no Back or Print button, unlike the source file. Show
"Restart this assessment" only when `can-start.allowed`: during the 182-day wait it's hidden and
the server refuses it. It's also hidden on the PEP return screen, because it can't skip the pause.

**Finished results are locked.** There's no way to change a finished health check or submitted
check-in: `save`, `finish` and any other change return `not_in_progress`. The check-in summary has
no Back or Print button either, only its booking button and "Return to initial assessment result".
Actions and report exports are audit-logged with no clinical
content.

**Reports.** `POST .../report/` and the email endpoint work as for other assessments once the
session is completed, returning the V15 clinician report (`apps.assessments.sexual_health_report`).
Its content follows `SU_Report_Final.pdf`; its logo, footer and fonts match the Cancer reports. It
never shows an assigned pathway; skipped questions read NOT ANSWERED; a submitted day-7 check-in is
added to its health check's report. A check-in session's report is that same document. The session score's
`result_display.sexual_health` still gives the older fields, mapped from V15.

**WhatsApp.** The bot sends a secure web link for both slugs instead of asking questions.

## Endometriosis Health Check

`endometriosis` and `endometriosis-dependent` follow the 4 November 2026 adult and
dependent source files and the Safety & Care-Routing Engine v2.2. Like Sexual & Urinary
Health, they don't use the question loop in section 3: `POST .../answers/` returns 400 for
them, and WhatsApp links to the website. The session, payment, age, gender and dependant
consent steps are unchanged.

```
GET  /api/assessments/<slug>/session/<id>/endometriosis/
POST /api/assessments/<slug>/session/<id>/endometriosis/   {"action": "...", "snapshot": {...}}
```

Both return the same state: `version`, `population` (`adult` or `dependent`), `status`,
`reference`, `first_name`, `age`, `assent`, `can_restart`, `answers`, `position`, `pause`, `pending_visit`,
`post_done` and `result`. `version: null` means the session finished before this version:
show its result from the older result endpoints.

**Your client holds the questionnaire.** It sends the whole snapshot with every action.
`apps/assessments/engine/endometriosis_v22_bank.py` holds the questions and
`endometriosis_v22.py` the rules; `lib/assessments/endometriosis-v22.ts` on the web is the
reference client port. Adult answers are option indexes and dependent answers are option
text, keyed by the source's ids (`S1`, `Q5a`, `D-S1`). `position` is yours to store and
restore. The server validates each snapshot, removes answers to questions that no longer
apply and returns 400 for anything the questionnaire couldn't have produced.

| Action | When | Effect |
|---|---|---|
| `save` | Any change before finishing | Stores the snapshot |
| `safety_checked` | Adult, after S3 | Starts a pause if the answers need one; read `pause` |
| `safety_pause` | Dependent, on tapping a warning symptom in D-S1 or D-S2 | Starts the pause at once |
| `mental_ack` | Adult, after Q20d when Q20c is Yes | Records that the guidance was read. Send `position.mental_ack: true` |
| `part9_recheck` | Adult, "Recheck immediate safety" at Q18 | Moves safety answers to history |
| `resume` | After the lock | Adult sends `snapshot.visit_status`: `NOT_ASSESSED`, `ASSESSED` or `ATTENDED_NOT_ASSESSED` |
| `finish` | Last main question | Completes and scores |
| `save_post`, `post_visit_recheck`, `post_visit_checked`, `visit_done`, `post_done` | After finishing | Send `snapshot.part`: `visit` or `post`. Only those follow-up answers can change, and each part locks once done |

**Safety pause.** `pause.lock_until` is 24 hours from the original alert, and `pause.ready`
says whether `resume` is allowed. Saves and restarts are refused until then (code
`safety_paused`), so don't offer a way round it. After `resume`, ask the safety questions
again. If they're clear, the check continues. An adult who hasn't reported being assessed
keeps an open referral: `pending_visit` stays set, so show the reminder that it remains open
until a healthcare professional has assessed them. QA accounts in `TEST_USER_EMAILS` can resume straight away.

**Starting again.** `can_restart` says whether to offer "Retake this assessment" on the
result page, and the `restart` action does it, returning the `session_id` to continue with. QA accounts in `TEST_USER_EMAILS` can do
this at any point, including during a pause. Anyone else can only retake a finished check
after the usual waiting period.

**Result.** `result` is present once finished or paused. `result.screen` holds every string
the result page shows. The top border and status pill use one default teal (`#0B7775`) for
every pathway and change only for RED (`#B94337`). `result.safety.red` is true only for a current safety finding,
with `urgency` `now` or `today`. There is no Green, Yellow or Orange. A pregnancy handover
pauses the check but isn't RED.

`result.care_urgency` is `EMERGENCY_NOW`, `URGENT_SAME_DAY`, `CLINICAL_REVIEW`,
`ROUTINE_CONTINUITY` or `SAFETY_REASSESSMENT_REQUIRED`. The last one means the 24 hours are up
or a safety answer is missing, so the next step is "Complete Your Safety Check".
`result.history` holds the clinician-facing answers shown at the end of the PDF. Don't show it
on the patient's result screen.

**Report.** `POST .../report/` works once finished and also during a pause, so the patient
can take it to the facility. The Email and Share actions use the existing report email
endpoints.

**Consent.** For `endometriosis-dependent`, consent is refused when the young person has
declined. A sibling or other caregiver must also send `caregiver_declaration` with
`POST /assessments/manual-dependants/<id>/consent/`, and only when that dependant's
`caregiver_declaration_enabled` is true. It's off until legal sign-off, and consent is refused
while it's off.

```json
{"basis": "guardian_permission", "guardian_name": "...", "guardian_phone": "+2547...", "confirmed": true}
{"basis": "main_caregiver", "reason": "...", "confirmed": true}
```

If the caregiver chooses neither, don't call the endpoint: show the warning signs from `D-S1`
and `D-S2` and stop. The declaration is self-declared and unverified, and the report says so.

## Sexual & Urinary Health result (sessions finished before V15)

For these older sessions, `result_display.sexual_health` drives the page. `pathway` is one of
`STI`, `UTI`, `COMBINED`, `KIDNEY_INFECTION`, `VULVOVAGINAL_CANDIDIASIS`, or `UNREVIEWED`
(no pathway assigned). It is a care pathway, never a diagnosis.

- `safety_urgent`: red-flag symptoms or pregnancy. Show the safety alert and "Visit a
  healthcare facility immediately" instead of the booking step, whatever the pathway.
- `hiv_not_tested`: offer confidential HIV testing (the `hts` CTA) on every pathway.
- `partner_notification_eligible` and `followup_recommended` / `followup_window`: extra
  actions, shown only when there is no safety alert and the pathway isn't kidney infection.

Web: `components/sexual-health-result/`.

## Emergency warnings while answering

Each question in the assessment detail response has `emergency_on` (a list of
answer values, empty for most questions) and `emergency_text`. As soon as any
answered or currently selected question's value is in its `emergency_on`, show
its `emergency_text` in a prominent alert, and keep it up on later questions.
Remove it if that answer changes. The patient can still carry on answering.
Oesophageal Cancer V2.12 is the only assessment using this today.

Changing an answer can delete other answers even when those questions stay
visible (in V2.12, changing the chemical-injury camera test answer clears the
general camera test answers), so re-read answers after any Back navigation.

## Oesophageal Cancer V2.12 score fields

The score response also carries `unresolved_clinical_actions` and
`prevention_factors` (lists of codes), and `navigation_advice` (the advice as given
at the time). These are empty for every other assessment and for oesophageal
results from before V2.12. Show `result_display`, not these fields.