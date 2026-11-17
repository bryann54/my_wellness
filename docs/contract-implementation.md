# Contract implementation tracker

This file maps the mobile contract guide set to Flutter implementation files,
tests, and commits. Update the relevant row in the same commit as every
contract-driven feature change.

Guide set: `2026-11-16.b9b79a`

Status meanings:

- `Implemented`: the documented mobile flow is present and covered by tests.
- `Partial`: some documented behavior exists, but the row lists open work.
- `Missing`: no production implementation exists yet.
- `Removed`: an obsolete implementation was deleted because the contract no
  longer describes it.

| Contract | Status | Flutter entry points | Contract tests | Remaining work |
| --- | --- | --- | --- | --- |
| `README.md` shared UI rules | Partial | `lib/common/res/app_typography.dart`, `lib/common/widgets/` | Flutter analyzer and widget suite | Finish replacing feature-level direct font declarations and add a localization leak test. Native stacked-route back buttons are intentionally retained for platform behavior. |
| `auth-and-signup.md` | Partial | `lib/features/auth/`, `lib/features/geography/` | `test/features/auth/` | Align signup steps and copy, international identity, reset delivery selection, verification destinations, and SHR status handling. |
| `account-and-profile.md` | Partial | `lib/features/account/` | `test/features/account/` | Add verified contacts, raw profile loading, Security, Privacy, sessions/devices, data export, and billing entry points. |
| `annual-wellness-plan.md` | Missing | — | — | Add API models, state, plan screen, actions, and tests. |
| `assessments.md` | Partial | `lib/features/assessments/`, `lib/features/home/presentation/widgets/assessment_progress_card.dart` | `test/features/assessments/`, `test/features/home/` | Add catalogue filtering and ordering, category module access, hubs, dependent/assisted entry, workplace chapters, and complete health-check follow-up cards. |
| `reference-sexual-health-v15.md` | Missing | Generic assessment renderer only | — | Add the V15 state machine, result behavior, follow-up, and anonymous partner notification. |
| `vitals-medications-appointments.md` | Partial | `lib/features/vitals/`, `lib/features/medications/`, `lib/features/appointments/` | `test/features/vitals/`, `test/features/appointments/` | Replace legacy BP states, complete the blood-sugar decision flow, add insulin/supply/refill/injection features, and finish appointment edit/reminder behavior. |
| `bookings-and-consultations.md` | Partial | `lib/features/bookings/`, `lib/features/appointments/` | `test/features/appointments/` | Add the four-step facility flow, booking detail/timeline, consent, summaries, downloads, email, and post-visit follow-up. |
| `payments-and-packages.md` | Partial | `lib/features/pricing/` | — | Add module-specific access, card/bank/manual payments, status polling, proof submission, donations/subsidies, and Billing pages. |
| `health-records-and-shr.md` | Partial | `lib/features/health_profile/`, `lib/features/auth/presentation/pages/shr_consent_screen.dart` | `test/features/health_profile/health_history_contract_test.dart` | Structured three-tab medical history and empty rows are implemented; complete the remaining SHR states, visit follow-up, and visit checklist flows. |
| `next-of-kin.md` | Missing | — | — | Add settings, invitation acceptance, acting context, banner, routing, and tests. |
| `push-notifications.md` | Partial | `lib/features/notifications/` | — | Route `data.url` to equivalent screens and default all other pushes to Dashboard after Billing, Booking Detail, and Visit Follow-Up routes exist. |

## Change log

| Commit | Contract work |
| --- | --- |
| `95f47f7` | Saved guide set and the dashboard health-check parsing/profile-filter baseline. |
| `08b0373` | Began shared Poppins and flat-focus alignment. |
| `47bea8b` | Restores native platform back navigation, removes unused placeholder features, introduces this tracker, and replaces the Health Profile web-style rendering with structured localized tabs. |

## Pull-request checklist

- Link every changed contract row.
- Add or update the corresponding contract test.
- Add every new user-facing message to all supported locale files.
- Do not introduce literal user-facing text in Dart widgets, dialogs, snackbars,
  semantics, tooltips, or validation messages.
- Regenerate routes and serialization code when annotated sources change.
