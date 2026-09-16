# My Wellness Mobile App — Architecture

## Stack

| Area | Standard |
| --- | --- |
| Client | Flutter and Dart stable for iOS and Android |
| State | flutter_bloc; Bloc for workflows and Cubit only for small eventless state |
| Dependency injection | GetIt and Injectable through `configureDependencies()` |
| Networking | One injected Dio client, central endpoint registry and feature datasources |
| Serialization | json_annotation/json_serializable DTOs in data only |
| Routing | Navigator key and route generator, with feature-scoped providers |
| Storage | Secure storage for a small approved session secret only; preferences for non-sensitive UI flags only |
| Testing | flutter_test, bloc_test, mocktail/fakes, integration_test |
| Delivery | GitHub Actions CI, dependency review, protected staging and production environments |

## Structure

```text
lib/
├── main.dart and bootstrap/app composition
├── common/                          # shared UI, validators, safe errors, design tokens
├── core/
│   ├── api_client/                  # configured Dio, interceptors, endpoint registry
│   ├── injector/                    # GetIt/Injectable modules and generated config
│   ├── storage/
│   └── config/
└── features/
    └── <feature>/
        ├── data/{datasources,models,mappers,repositories}/
        ├── domain/{entities,repositories,usecases}/
        └── presentation/{bloc,pages,widgets}/
```

Initial My Wellness features are launch, auth, onboarding_consent, home, assessments, care_plan, results, appointments, care_navigation, vitals, resources, notifications, and profile.

## Dependency flow

```text
Widget → Bloc event → Use case → Repository interface
                                  ↑
Datasource → DTO/mapper → Repository implementation
```

- Domain is pure Dart: no Flutter, Dio, storage, DTO, or plugin imports.
- Widgets never call repositories, datasources, HTTP clients, or mappers.
- DTOs remain in data; repositories map DTOs to entities or typed failures.
- Features never import another feature's data or presentation internals.
- Preserve GetIt/Injectable, central Dio, endpoint registry, and navigator-key patterns; replace every consumer-specific endpoint, model, route, API assumption and feature.

## BLoC and API rules

- BLoC events/states are immutable, explicit and equatable. Do not use ambiguous boolean state bags.
- BLoCs call use cases. BlocListener owns one-time effects; BlocBuilder/selectors render state.
- Use a single configured Dio instance, safe interceptors, bounded timeouts, and typed failure mapping.
- Do not retain request/response/body/error logging, public fallback tokens, automatic refresh/replay, Firebase auth/push assumptions, or preference-held access tokens from copied code.
- Implement an endpoint, stream, mutation, retry, idempotency scheme, or session policy only from an approved My Wellness contract.

## Core entities

| Entity | Required fields |
| --- | --- |
| Member | opaque id, display name, preferences, onboarding status |
| ConsentRecord | purpose, status, policy version, captured/withdrawn timestamps |
| AssessmentDefinition | id, category, version, approved questions, eligibility |
| AssessmentSubmission | assessment/version, typed question-ID answers, lifecycle timestamps |
| AssessmentResult | server result ID, approved risk label/summary/actions, source version |
| CarePlan and Task | id, status, action target, due date, source version |
| VitalReading | id, type, typed values/unit, recorded time/source |
| Appointment | id, service, status, schedule/mode as returned by server |
| NavigatorRequest | id, requested service/reason category, safe status |

IDs are opaque strings and timestamps are UTC at rest. Health, identity, session, and free-text fields are sensitive: never log, analyse, notify, screenshot, cache unencrypted, or commit them.

## Verification

Add mapper/repository tests, BLoC state-transition tests, widget validation tests, and integration tests for approved critical flows. Run:

```bash
dart format --set-exit-if-changed .
flutter analyze .
flutter test
dart run build_runner build --delete-conflicting-outputs # after codegen inputs change
```
