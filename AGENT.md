# My Wellness Delivery Agent Guide

## Read first

Read `prd.md`, `architecture.md`, `architectural-essentials.md`, `CLAUDE.md`, and `STRUCTURE_ADAPTATION_PROMPT.md`. These override copied consumer implementation details.

## Execution rules

1. Preserve safe structure, not copied behaviour: GetIt/Injectable, central injected Dio/API provider, endpoint registry, repository boundaries, BLoC state machines, and navigator-key routing.
2. Audit copied files before using them. Classify each as rewrite for My Wellness, retain only as generic infrastructure, or delete.
3. Replace consumer features with My Wellness features: launch/session routing, auth, onboarding_consent, home, assessments, results/care_plan, appointments, care_navigation, vitals, resources and profile.
4. Keep domain pure Dart; keep DTOs/mappers/datasources in data; keep UI effects out of widget build methods.
5. Use approved My Wellness API and clinical contracts only. Do not infer tokens, streams, retries, scoring, results, recommendations or health-record behaviour.
6. Keep sensitive information out of logs, analytics, crash reports, notifications, fixtures, preferences, commits and screenshots.

## Done criteria

- The requested product acceptance criterion is met.
- Relevant mapper/repository, BLoC, widget and integration tests pass.
- `dart format --set-exit-if-changed .`, `flutter analyze .`, and `flutter test` pass.
- Generated DI/JSON output is current and never hand-edited.
- No consumer-domain artefact or unsafe copied mechanism remains on the changed path.
- An ADR/document update exists for every architecture or data-handling decision.

## Escalate immediately

- Any request needs clinical scoring, diagnosis, treatment/emergency wording, or unapproved assessment content.
- Consent, storage, retention, deletion, encryption, session persistence, API mutation, retry or stream semantics are missing.
- A copied API client or feature would require retaining public tokens, token preferences, raw logging, Firebase, vehicle/e-commerce code, or PHI persistence.
