# ADR-10: Separate appointment and medication workflow state

- **Status:** Accepted
- **Date:** 2026-10-23
- **Owner:** My Wellness mobile team
- **Review date:** 2027-01-23

## Context

Appointments and medication list, create, delete, and scan workflows were held by `VitalsBloc`, so opening Vitals also loaded appointment and medication data. These workflows need independent state and feature presentation while preserving their existing API behavior.

## Decision

Appointments and medications own their presentation pages, widgets, events, states, and BLoCs. `AppointmentsBloc` and `MedicationsBloc` are long lived at the app composition boundary and are passed into route subtrees with `BlocProvider.value`, so list and create routes share state. `VitalsBloc` owns only blood pressure and blood sugar readings.

The current approved repository and use cases remain the source of API behavior; no endpoint or mutation semantics changed as part of the state split.

## Alternatives considered

1. Keep all collection state in `VitalsBloc` — rejected because it couples unrelated workflows and makes Vitals load unrelated collections.
2. Duplicate the repository, endpoints, and DTOs for each workflow — rejected because it would duplicate the established API contract and risk behavior drift.

## Privacy and clinical impact

No clinical content, classification, payload, endpoint, or persistence behavior changed. Collection state remains in memory and is not written to ordinary preferences or logs. Medication scan files continue to use the existing protected upload flow.

## Removal plan

Remove this split only if product acceptance again requires appointment and medication workflows to share a single owning feature. Until then, keep their UI and BLoCs out of `features/vitals` and preserve separate tests for each workflow.
