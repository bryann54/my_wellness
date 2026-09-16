# My Wellness — Architectural Essentials

These are binding decisions. Change one only through a reviewed ADR in `docs/adr/` with context, alternatives, owner, privacy/clinical impact, review date, and removal plan.

| ID | Decision | Consequence |
| --- | --- | --- |
| ADR-01 | Feature-first layered boundaries | Every feature owns data, domain and presentation; domain stays pure Dart and DTOs never leave data |
| ADR-02 | Server-owned clinical logic | The client submits answers and renders approved, versioned results/actions; it never scores or derives clinical meaning |
| ADR-03 | Contract-first integration | Endpoints, streams, mutations, errors, auth and retries are implemented only from a reviewed My Wellness contract |
| ADR-04 | Injectable/GetIt composition | Keep `configureDependencies()`, modules, annotations, and generated registration as the single DI mechanism |
| ADR-05 | One safe API client | Retain one injected Dio client and endpoint registry; no request/error logging, public fallback tokens, unapproved refresh or automatic mutation replay |
| ADR-06 | Sensitive data minimisation | PHI, PII, secrets, free text, raw responses and error bodies never enter logs, analytics, crash tools, notifications, fixtures or ordinary preferences |
| ADR-07 | Offline PHI is not approved | No assessment/vital cache or sync queue until encryption, key lifecycle, consent, retention, deletion, idempotency and conflict design are approved |
| ADR-08 | Feature-scoped BLoCs | Do not keep a global registry of feature BLoCs; route/workflow owners create and dispose their BLoC |
| ADR-09 | Privacy-safe delivery | Flavours, CI, protected staging/production environments, least-privilege secrets and reproducible release artifacts are required |

## Required controls

1. Secure storage is for a small approved secret only; shared preferences are for non-sensitive UI flags only.
2. Logout, account switch and token invalidation clear authenticated in-memory and approved local state.
3. Notifications/deep links use generic text and opaque route IDs only; no health category, result, vital, appointment, free text or direct identifier.
4. Mental and sexual/urinary health experiences use approved wording and never imply emergency monitoring or emergency response.
5. A new analytics, crash, notification, database, Firebase, background-worker or identity SDK requires a data inventory, consent/security review, and ADR when it changes these decisions.

## Required merge gates

- Format, analyse, test, and debug-build every pull request.
- Block vulnerable/disallowed dependency changes.
- Use protected staging for distribution; CI and forked PRs never access signing/distribution secrets.
- Use protected tagged production releases with approval, signing, release notes and rollback procedure.
