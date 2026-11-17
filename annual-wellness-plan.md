# My Annual Checkup (annual wellness plan)

<!-- guide-header:start -->
> **Guide set `2026-11-16.b9b79a`.** Every file in this guide carries this same line.
>
> **Related files you need open with this one:** `README.md` (shared conventions)
>
> **AI agents, before building anything from this file:** check that you have each related
> file and that its guide-set line reads exactly `2026-11-16.b9b79a`. If a file is missing or its line
> differs, stop and ask the developer for the current copy, naming the files you need (or
> fetch them: `GET /api/mobile-guide/<filename>/`, README "Fetching this guide itself, over
> HTTP"). Never fill a gap from memory or an older copy. Anything the app already shows that
> this guide doesn't describe is out of date: the app must match the website and WhatsApp.
<!-- guide-header:end -->

The plan lists suggested tests for the user's annual check-up. The API builds
it from the user's age and sex, their own completed assessments, their blood
pressure and blood sugar monitoring, and two opt-ins. The app shows what comes
back and makes no decisions of its own. It is free for every signed-in adult. See it on staging at
https://staging.mywellnesshealth.co.ke/checkup ("My Annual Checkup" in the sidebar).

All calls need the user's normal token. Errors use the standard envelope:
`{"error": {"detail": ..., "status_code": ...}}`, except the report's `409`
(see below).

| Call | Body | Success |
|---|---|---|
| `GET /api/wellness-plan/` | | `200`, Plan |
| `PATCH /api/wellness-plan/preferences/` | `{mental_health_opt_in?, sexual_health_opt_in?}` | `200`, Plan (rebuilt) |
| `POST /api/wellness-plan/report/` | | `200`, PDF |

## Plan not available

When the profile has no age or no sex (male or female), or the user is under
18, the plan comes back as:

```json
{
  "eligible": false,
  "ineligible_reason": "missing_age",
  "preferences": {"mental_health_opt_in": false, "sexual_health_opt_in": false}
}
```

`ineligible_reason` is `missing_age`, `missing_sex` or `under_18`. Ask the user
to complete their profile for the first two. `POST .../report/` returns `409`
in these cases, with an **unwrapped** body (not the envelope):
`{"detail": "Your plan is not available yet.", "ineligible_reason": "missing_age"}`.

## Plan

```json
{
  "eligible": true,
  "ineligible_reason": null,
  "preferences": {"mental_health_opt_in": false, "sexual_health_opt_in": true},
  "profile": {"age": 42, "sex": "female"},
  "reports_count": 2,
  "findings": [
    {"id": "bp", "label": "High BP or hypertension", "detail": "Relevant BP assessment or monitoring result"}
  ],
  "family_history": {"count": 1, "colorectal_earlier": true, "hereditary_review": false},
  "cvd_risk": null,
  "previous_tests_count": 0,
  "urgent_alerts": [{"urgency": "urgent", "reason": "Urgent clinical assessment required"}],
  "assessments": [
    {
      "id": "cancer",
      "name": "Cancer Health Checks",
      "description": "Complete the relevant cancer assessments to strengthen screening and family-history guidance.",
      "priority": "recommended",
      "status": "In progress",
      "completed": false,
      "short_name": "Cancer",
      "link": "/assessments/cancer"
    }
  ],
  "improvement_pending": [{"id": "cancer", "name": "Cancer Health Checks", "short_name": "Cancer"}],
  "key_tests": [{"id": "bp", "name": "Blood pressure measurement"}],
  "recommended_count": 12,
  "categories": ["Core wellness", "Metabolic & heart", "Cancer screening", "Women’s health", "Sexual health", "Clinical follow-up"],
  "tests": [
    {
      "id": "mammogram",
      "name": "Mammography",
      "category": "Women’s health",
      "tier": "recommended",
      "tag": "Recommended",
      "reason": "Age-based breast screening is appropriate; breast risk profile may change interval.",
      "timing": "40–55: often yearly; 56–74: often every 2 years",
      "source": "Kenya NCI screening 2024"
    }
  ],
  "calendar": [
    {
      "id": "bp",
      "name": "Blood pressure measurement",
      "last": "Not recorded",
      "next": "Review at your check-up",
      "status": "History unavailable",
      "due_at": null,
      "needs_review": true
    }
  ],
  "care_stages": [
    {"title": "Get your initial wellness package", "status": "Available", "text": "Your current age, history and available reports generate a usable plan immediately."}
  ]
}
```

Notes for showing it:

- `tests` holds every catalogued test. `tier` is `recommended`, `consider` or
  `not`; show `tag` as the label. The recommended list is the `recommended`
  tests, "Tests to discuss" is the `consider` tests, and "Tests not added" is
  the `not` tests. Group each list by `category`, in the order of `categories`.
- `key_tests` is the short list for the top card (at most 6).
  `recommended_count` is the total number of recommended tests.
- `urgent_alerts` is empty unless an assessment completed in the last 90 days
  reported urgent symptoms. When it isn't empty, show the urgent banner first.
- `assessments[].id` is `cancer`, `metabolic`, `women`, `mental` or `sexual`.
  `mental` and `sexual` appear only when opted in; `women` only for women.
  `status` is shown as given. For `cancer` it is `Follow-up guidance` when the
  user reported a cancer diagnosis. `completed` is true when `status` is
  `Completed`.
- `assessments[].short_name` is the short form used in sentences: `Cancer`,
  `Metabolic`, `Women’s Health`, `Mental Health` or `Sexual & Urinary`.
- `assessments[].link` is where the row's link goes. Once `completed`, it's
  the dashboard's health checks section (`/dashboard#health-checks-title`).
  Otherwise it's the place to take the check, e.g. `/assessments/cancer` or
  `/assessments?category=Metabolic`. Open it as given.
- `assessments[].priority` is `recommended` (`cancer`, `metabolic`),
  `separate` (`women`) or `optional` (`mental`, `sexual`). Web groups the
  Health Checks tab by it (see "Screens").
- `improvement_pending` lists the `recommended`-priority checks that aren't
  `Completed` or `Follow-up guidance` yet, each with `id`, `name` and
  `short_name`.
- `cvd_risk` is always `null` for now, and `previous_tests_count` is always 0.
  Previous test dates aren't stored yet, so every `calendar` entry reads
  "History unavailable" and `care_stages` after the first read "Not arranged".

## Opt-ins

`PATCH /api/wellness-plan/preferences/` with either or both booleans. Mental
health and sexual health results are left out of the plan unless the matching
opt-in is `true`. A next of kin can't change these; they get
`403 next_of_kin_not_allowed`. Web sends one field per tick, shows the new tick
straight away, and replaces the whole plan with the response. On failure it toasts
*"Could not save your choice. Please try again."* and shows the saved choice again.
Both boxes are disabled while a save is in flight.

## PDF

`POST /api/wellness-plan/report/` returns `application/pdf` as an attachment
(filename in `Content-Disposition`). The PDF is password-protected like every
other health report: the `X-Pdf-Password-Hint` header says which password to
use. Web shows the hint in its success toast: **"PDF downloaded"**, *"This
report is password-protected. Open it with the {hint}."* (without the second
line when there's no hint). On failure it toasts the error, or *"Could not
generate the PDF"*.

## Screens

Web's page (https://staging.mywellnesshealth.co.ke/checkup), word for word, top to
bottom.

**Always shown**
- Header: eyebrow "My Wellness Health", title **"Building My Annual Wellness
  Check-Up"**.
- Intro panel: eyebrow "Your personalised wellness plan", **"Your annual wellness
  package, built for you."**, *"See the tests recommended from your age and available
  health reports. Your plan improves as you complete more assessments."*
- A spinner while loading. On error: *"We couldn't load your plan. Please refresh the
  page to try again."*
- At the bottom: a red box **"Not every test is for everyone"**, *"Some investigations
  are unnecessary, already up to date or need a clinician's assessment. New warning
  signs require prompt clinical care rather than an annual visit."*, then the footer
  "MY WELLNESS HEALTH", "Know Your Risk. Take Action Early. Live Better."

**Plan not available** (`eligible: false`): one card.

| `ineligible_reason` | Title | Body | Button |
|---|---|---|---|
| `missing_age` | Add your date of birth | Your plan is built from your age. Add your date of birth to your profile to see it. | **Update my profile** → Account settings |
| `missing_sex` | Add your sex | Your plan is built from your age and sex. Add your sex to your profile to see it. | **Update my profile** → Account settings |
| `under_18` | For adults aged 18 and over | My Annual Checkup is available to adults aged 18 and over. | none |

**Plan available**, in this order:

1. **Urgent banner**, only when `urgent_alerts` isn't empty:
   - Heading **"Urgent clinical follow-up required"**, then *"{urgent_alerts[0].reason}.
     Do not wait for all assessments or for the annual plan."*
   - Then, in bold: *"Visit a healthcare facility immediately. Seek emergency care now;
     do not wait for this annual plan or further online steps."*
2. **"Your recommended tests"** card with the pill "Available now":
   - Intro: *"Personalised using the age and health information already in your My
     Wellness Health account."*
   - One ticked line per `key_tests` name, or *"Your current reports suggest a clinical
     wellness review. Your detailed package is available below."* when it's empty.
   - When `recommended_count` is larger than the number of `key_tests`: *"And more
     personalised checks and clinical reviews in your full package."*
   - The **"Download my recommended tests (PDF)"** button, then a **"See all tests and
     explanations"** link to the My Plan tab.
   - Closing line: *"This is a draft for clinician review, not a prescription or a
     confirmed diagnosis. Your package remains available as additional assessments are
     completed."*
3. One of two cards, depending on `improvement_pending`:
   - **Not empty:** **"Make your package more complete"**, *"For a fuller
     understanding of your health, we recommend completing {names}. You can still use
     your current plan now."*, and the link **"Explore recommended assessments"** to the
     Health Checks tab. `{names}` is the `improvement_pending` `short_name`s joined by
     " and " (e.g. "Cancer and Metabolic").
   - **Empty:** **"Health-check reports connected"** with the pill "Updated", *"Cancer
     and Metabolic Health assessment findings are contributing to your package.
     Continue to review the next steps in each report."*
4. **"Optional additions to your wellness package"**, *"Only include these areas if you
   choose to. Your existing private assessment findings are not added to this plan
   without your permission."*
   - Two checkboxes (see "Opt-ins"):
     - **Include Mental Health**, "Mental wellbeing review and follow-up, if indicated"
       (`mental_health_opt_in`).
     - **Include Sexual Health**, "Confidential sexual-health screening and relevant
       tests" (`sexual_health_opt_in`).
   - Then: *"Both are optional and may be changed any time. HIV testing remains
     voluntary and confidential."*
5. **"Explore my wellness plan"** and four tabs: **My Plan**, **Health Checks**, **My
   Records**, **All Tests** (My Plan first). Each tab starts with a heading and a line:

   | Tab | Heading | Line |
   |---|---|---|
   | My Plan | My full recommended package | Your recommended tests, including when to discuss or repeat them. |
   | Health Checks | How to improve my package | Your package is available now. These health checks can make it more complete. |
   | My Records | My assessment information | Your saved reports and clinical history are already connected. |
   | All Tests | Understand the tests | The full list, filtered according to your needs. |

A test list shows the tests grouped under each `categories` heading, in that order,
skipping empty categories. Each test shows `name`, its `tag` pill, `reason`, and
"Timing: `timing`" when `timing` isn't empty. Pill colour by `tier`: `recommended`
primary, `consider` orange, `not` grey.

**My Plan tab**
- **"My recommended annual wellness tests"** with the pill "Ready to use".
  - Intro: *"Based on the information currently available. Your clinician can confirm
    which investigations are appropriate and when they are due."*
  - Then the `recommended` tests.
- When there are `consider` tests, a collapsed **"Tests to discuss with a clinician
  ({n})"** holding them.
- For `profile.sex` `female`, **"Women's Health has its own pathway"** with the pill
  "Separate":
  - Body: *"Cervical and breast screening recommendations are considered using your
    age, risk and previous tests. Endometriosis and other Women's Health care continue
    through their dedicated assessments and follow-up—not a requirement for this
    package."*
  - A **"View Women's Health pathway"** link to the Health Checks tab.
- Collapsed **"My prevention calendar"**: the title again with the pill "Auto-updating".
  - Intro: *"Previous test dates and clinician-approved intervals determine what is
    due. Missing test history is not treated as an overdue result."*
  - One entry per `calendar` item: `name`, a `status` pill, "Last: `last`" and "Next:
    `next`". With none: *"No recommended investigations currently need calendar
    tracking."*
  - Closing line: *"Your care team may change dates after abnormal results, treatment
    changes, or risk review. Reminders can only be sent after backend scheduling and
    notification consent are connected."*
- Collapsed **"My care pathway and next steps"**: **"From your assessments to follow-up
  care"**.
  - Intro: *"Your care steps reflect your saved assessment and appointment records. No
    extra patient checklist is required."*
  - One numbered row per `care_stages` item: "{n}. {title}", `text`, and a `status`
    pill.
  - No button under it: the "Arrange clinical review" button was removed with the old
    check-up booking (2026-11-14).

**Health Checks tab**
- A card with the eyebrow "Your annual package is already available" and **"Make your
  plan more complete"**.
  - Body: *"You can view and download the package now. We recommend completing Cancer
    and Metabolic Health assessments so your plan reflects more of your risk factors and
    screening needs."*
  - Then the `priority: "recommended"` rows.
- When there are `separate` rows: **"Women's Health — separate pathway"**.
  - Body: *"Women's Health is managed through its own clinical pathway and does not
    delay your general check-up plan. Age- and risk-appropriate breast and cervical
    screening remain visible in your recommended tests."*
  - Then those rows.
- When there are `optional` rows: **"Health checks you chose to include"** and those rows.
- A closing box: **"No completion percentage is required."**
  - Body: *"Each newly completed assessment improves personalisation; your downloadable
    wellness package remains available in the meantime."*
  - A **"Return to my wellness package"** button to the My Plan tab.

Each row shows a tick (when `completed`) or a clipboard icon, then `name`, `description`
and a link, with the `status` pill on the right. The pill is green when `completed`,
orange otherwise. The link reads **"View available reports"** when `completed` and
**"Explore health checks"** otherwise, and opens the row's `link` (the dashboard's
"My Health Checks & Follow-Up" section once completed, otherwise the place to take
the check).

**My Records tab**
- Opening line: *"Your saved account details and completed assessment reports are used
  automatically. You do not need to answer again."*
- **"Your existing information builds this plan"**:
  - Body: *"Your age, screening history and existing health checks are used to suggest
    appropriate tests. New assessments will refine the package automatically."*
  - "Relevant reports available" with the pill "{reports_count} report(s)".
  - A box **"Findings informing the plan"**: the `findings` labels joined by " · ", or
    *"No additional structured risk findings have been supplied."* Under it: *"Clinical
    follow-up advice in your assessment reports remains applicable. This page is not a
    diagnosis."*
- **"What else the system checks"**:
  - **Family history:** "{family_history.count} structured relative record(s)", or "No
    structured family-history record supplied". Adds " · Colorectal screening may start
    earlier" when `colorectal_earlier`, and " · Consider hereditary cancer review" when
    `hereditary_review`.
  - **Cardiovascular risk:** "Awaiting validated clinical risk calculation, when
    indicated."
  - **Previous tests:** "{previous_tests_count} test result record(s) available for
    next-due calculations."
- A **"See my recommended tests"** button to the My Plan tab.

**All Tests tab**
- **"What can be included?"**:
  - Body: *"This is a review of tests seen in Kenyan wellness packages. You will not
    need all of them. The plan removes low-value tests and flags conditional tests."*
  - Two counts: the non-`not` tests, "Potentially relevant", and the `not` tests, "Not
    routinely selected".
- **"Current recommended / conditional tests"**: the `recommended` and `consider` tests.
- Collapsed **"View tests not added to this package"**: the `not` tests.
- **"Why this is not a fixed executive package"**:
  - Body: *"Hospital wellness bundles frequently include ECG, echocardiography,
    ultrasound, tumour markers, chest X-ray or extensive vitamin testing. These are not
    automatically necessary. Your plan prioritises tests supported by risk, symptoms and
    clinical guidelines."*
  - Then: *"Screening is separate from the colour of your Cancer Health Check outcome.
    An urgent symptom is not something to wait to investigate during an annual visit."*
- **"Clinical sources and package examples"**: a list of links that open in the
  browser. The list is fixed web content:
  - "Kenya Cancer Screening and Early Diagnosis Guidelines, 2nd edition (2024)"
  - "Kenya NCD Primary Care Protocols (2025)"
  - "KUTRRH wellness centre packages"
  - "Aga Khan University Hospital Nairobi wellness packages"
  - "AAR Healthcare wellness programme"

  Copy the link targets from the staging page.

---

Last verified against the code on 2026-11-09.
