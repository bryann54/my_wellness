# My Wellness Mobile App — Product Requirements

## Product

My Wellness is a private preventive-health companion for people in Kenya. It helps members understand health risks, complete approved assessments, receive personal prevention plans, track relevant vitals, book care, and request human care navigation.

The product reference is [My Wellness Health staging](https://staging.mywellnesshealth.co.ke/). Its core journey is **assess risk → build a plan → screen and review → live better**. The mobile app is a secure logged-in companion; it is not a diagnostic, emergency, prescription, or clinician-replacement product.

## Users

| User | Need | Outcome |
| --- | --- | --- |
| Member | Know which preventive action to take | Completes an approved assessment and sees a safe next action |
| Returning member | Keep their journey on track | Sees plan tasks, bookings, reminders and approved vital history |
| Care navigator | Help a consented member move into care | Receives a minimum-necessary support/referral request |
| Clinical/content owner | Keep guidance current and correct | Publishes approved versioned questions, results and plan content through backend services |

## Release-one capabilities

- Authentication, session state, onboarding, and versioned consent.
- Home dashboard with next best action, plan progress, pending assessment, and upcoming booking.
- Guided, resumable approved assessments: cancer, metabolic, mental wellness, sexual/urinary health, and lifestyle/general wellness.
- Safe server-provided results, care-plan tasks, resources, and follow-up actions.
- Approved vital entry/history such as blood pressure and blood glucose.
- Backend-supported appointment/check-up and care-navigation request workflows.
- Profile, communication preferences, privacy, consent, and account support.

## Product controls

Clinical owners approve questionnaire content, eligibility, scoring, result language, escalation instructions, and content versions. The client renders server-approved content only. It must not calculate risk, infer a diagnosis, or make emergency-care claims.

Health collection requires explicit consent. Notifications, deep links, analytics, logs, screenshots, and crash reports must not expose health data, assessment type, result, booking detail, free text, credentials, or direct identifiers.

## Acceptance criteria

1. A member can authenticate, restore approved session state, and log out safely.
2. Consent gates the matching health-data journey and records a policy version/timestamp.
3. A member can complete or resume an approved assessment and receive the exact safe server result state.
4. A member can see care-plan actions, log approved vitals, and complete backend-supported booking/navigation paths.
5. Sign-in, consent, assessment, and booking critical paths have automated coverage.
6. All released clinical content has clinical-owner approval and a versioned backend contract.

## Non-goals

- Client-side clinical scoring, diagnosis, treatment, prescribing, or crisis support.
- Copying the consumer app, Afya Yangu private data, branding, API contracts, or implementation.
- Offline PHI persistence, background sync, durable authentication, or push notifications before their security and backend contracts are approved.
