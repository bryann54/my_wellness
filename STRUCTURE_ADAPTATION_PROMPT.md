# Structure Adaptation Prompt — My Wellness

Use this as the next instruction to the My Wellness implementation agent.

---

You are adapting a copied Flutter foundation from the sibling consumer application into My Wellness. **Keep the architectural patterns; remove and replace the consumer-product assumptions.** This is not a copy-paste port and it is not permission to preserve vehicle, commerce, merchant, inventory, delivery, payment, Firebase, or spare-part behaviour.

## Source of truth

Read `prd.md`, `architecture.md`, `architectural-essentials.md`, `CLAUDE.md`, and `AGENT.md` first. Use the My Wellness staging site only to understand the approved preventive-health journey. The copied consumer code is a structural donor only, never product or API authority.

## Preserve these patterns

1. Keep GetIt + Injectable as the single dependency-injection mechanism: `configureDependencies()`, modules, annotations, and generated registration stay the composition approach.
2. Keep one configured, injected Dio instance, a central API client/provider, central endpoint registry, repository/datasource boundary, typed failure mapping, and BLoC streams/state machines.
3. Keep the navigator-key plus route-generator approach if it is already the selected navigation approach. Rebuild the route table around My Wellness routes and use feature-scoped providers.
4. Keep `common` only for genuinely reusable UI, validators, error handling, design tokens, and domain-neutral utilities.

## Replace these copied assumptions

1. Replace every consumer endpoint, request DTO, response DTO, repository contract, model, route, label, asset, and feature with a My Wellness equivalent or delete it.
2. Refactor `launch` into app lifecycle, connectivity, safe startup, consent/session routing, and My Wellness onboarding entry points. Delete spare-parts, vehicle, merchant, cart, delivery, and coach-mark copy that is not explicitly required.
3. Refactor `auth` for only the verified My Wellness identity/session contract. Remove Firebase login, push-token handling, OTP/token-refresh assumptions, public fallback tokens, and persistent token/cookie behaviour until a My Wellness backend contract approves each one.
4. Refactor `account_setup` into `onboarding_consent` and member profile completion. It must never contain vehicle models, vehicle lookup endpoints, car images, or automotive wording.
5. Refactor `profile` into member profile, privacy, consent, communication preferences, and account support. Remove consumer photo/upload, promotion, notification, and deletion flows unless a My Wellness contract explicitly requires them.

## Non-negotiable senior-engineering controls

- Do not keep the copied Dio client unchanged. Retain its injected-central-client pattern, but remove body/error logging, static/public fallback tokens, automatic refresh/replay logic, and preference-held access tokens. Configure only approved My Wellness base URLs, timeouts, interceptors, and auth behaviour.
- Do not keep a global `BlocsRoot` containing every feature BLoC. Keep only true app-lifetime concerns at the root; create feature BLoCs at the narrowest route/workflow owner and close them with that owner.
- Do not use `shared_preferences` for a session, token, cookie, health data, profile data, assessment answers, or vital readings. Secure storage holds a small secret only after an approved contract. Do not add offline PHI persistence.
- Do not return dynamic raw response objects or `ServerError` objects into BLoC/UI state. Datasources decode DTOs, repositories map them to entities or typed failures, and BLoCs expose safe states.
- Do not infer data streams or APIs from the consumer project. A My Wellness stream, endpoint, mutation, retry, idempotency, or authentication flow is implemented only from an approved/verified My Wellness contract.
- Keep domain pure Dart and data feature-scoped. A copied common model such as User, Car, or PaginatedResponse is retained only if it is generic, safe, and explicitly redefined for My Wellness.

## Execution order

1. Audit every copied file and classify it as retain pattern and rewrite, move into a My Wellness feature, or delete. List that decision before editing.
2. Make the app compile with the retained DI/navigation/network skeleton and no consumer feature imports.
3. Rebuild the initial My Wellness slices in this order: launch/session routing, authentication, onboarding and consent, home, assessment catalogue and questionnaire shell, care plan/results, then bookings, navigator support, vitals, profile and resources as contracts become available.
4. For each slice, add datasource, DTO, mapper, repository implementation/interface, use case, BLoC, page, and tests only when the slice needs that layer.
5. Regenerate Injectable/JSON source only after its inputs change, then run `dart format --set-exit-if-changed .`, `flutter analyze .`, and `flutter test`.

## Hand-off

Report the consumer files removed or rewritten, the retained patterns and why they are safe, the My Wellness contracts used, tests/checks run, and every missing clinical/privacy/backend decision. Do not claim an API contract, logged-in flow, or health-data behaviour that has not been verified.

---
