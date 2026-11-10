# Claude Code Instructions — My Wellness

Read `AGENT.md`, `prd.md`, `architecture.md`, and `architectural-essentials.md` before non-trivial work. They are authoritative.

## Mission

Build a private, accessible Flutter preventive-health app for assessments, approved care plans, vital tracking, care booking, and navigation support. Keep consumer architectural patterns only where they are safe and generic; do not copy consumer product logic.

## Required workflow

1. Identify the My Wellness feature, layers, verified contract, privacy impact, and acceptance criterion before editing.
2. Use feature-first Clean Architecture: widgets dispatch BLoC events, BLoCs call use cases, use cases depend on interfaces, repositories use datasources, and DTOs remain in data.
3. Retain GetIt/Injectable composition, one central injected Dio client, endpoint registry, typed failures, and scoped navigation/BLoC ownership.
4. Remove or rewrite copied vehicle, commerce, merchant, cart, delivery, Firebase, public-token, preference-token, and logging behaviour.
5. Add appropriate mapper/repository, BLoC and widget tests with each change.
6. Stop for missing clinical, privacy, legal, consent, authentication, retention, encryption, backend or UX decisions. Never substitute a fixture, guessed endpoint or invented medical content.

## Prohibitions

Never log, commit, analyse, notify, screenshot or fixture health data, credentials, identifiers, free text, tokens, raw request/response bodies, or error bodies. Do not create a global feature-BLoC tree, persistent PHI store, unapproved retry/replay, or durable session mechanism.

## Hand-off

Report files/layers changed, contracts used, tests/checks run, clinical/privacy handling, consumer artefacts removed/rewritten, and decisions still required. Never claim unperformed verification.
