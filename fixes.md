are populating cached assessments? just seen an assessment thats not there anymore.re read the `assessments.md` and refix correctly as expected and match to web with `web.md` provided credentials.

`MEDICAL-PROFILE`
Implement the My Medical History screen redesign for Flutter, guided by
three context files: the health_profile feature (data contract — do not
modify data/domain/bloc), the DHA SHR spec (product law — every label,
cadence, and toast must match verbatim), and the shared design system
(reuse AppSpacing/AppRadius/AppColors/AppPrimaryButton/AppSnackbar/
ShimmerBox/CustomAppBar — invent nothing).

Senior UI principles to apply: clear hierarchy (connection card first,
then four numbered sections), progressive disclosure (collapse long
lists, filter BP), distinct shapes per section (hero tiles for
measurements, compact rows for records, timeline for journey),
first-class empty states (icon + title + spec's exact empty line + pill),
explicit state separation (first-load skeleton vs refresh-with-data vs
hard-error vs stale-error), and calm health-screen tone (semantic colour
only, no decoration).

Preserve verbatim: all API field names, poll cadences (3s fetching/
pending, 15s otherwise), records_fetching true→false refetch rule, 9s
resync backstop, every toast and paragraph from the spec, hero tags.

Deliver three files:
1. pages/my_health_screen.dart — route, jump-link tabs, state router,
   RefreshIndicator, NestedScrollView.
2. widgets/connection_card.dart — owns all DHA polling/POST/consent
   logic; parent passes onHistoryRefresh.
3. widgets/history_sections.dart — MeasurementsSection, ClinicalSection,
   TreatmentSection, JourneySection + shared primitives.

Do not modify entities, usecase, repository, datasource, or bloc. Do not
edit common/. Respect that HealthHistory only carries latest BP/BS
readings — build cards to render latest now and accept full lists later
without touching my_health_screen.dart.

On completion: list every string copied verbatim from the spec and
confirm character-for-character match. Any mismatch is a bug.

`ACCOUNT`
Tighten the Flutter Account feature to match account-and-profile.md
without regressing what already works. Read three files first: the
contract (authoritative — labels, toasts, cooldowns and endpoints are
law and must match web exactly), the existing account feature (extend
it, don't rewrite working parts), and common/ (reuse AppSpacing,
AppRadius, AppColors, AppPrimaryButton, AppSnackbar, ShimmerBox,
AccountSectionCard, MenuItemTile, DropDownWidget, SoftInput,
ProfileSectionCard/Label/ReadOnlyRow — invent nothing).

Scope, in order:

A. General step — add ?raw=1 to the settings-screen profile GET;
   contact-verification note + Email/Phone verification rows with the
   real request/confirm endpoints and OTP sheet; email editable only
   when the account has no email; country picker that hides location
   when not KE; fix the two location hierarchies (county→sub-county
   AND county→constituency→ward, never chained); career dropdown with
   "Other"; SHA coverage block (state from sha_eligibility_checkable,
   National ID save vs Check eligibility) with masked ID; AfyaConnect
   sync row gated by has_national_id with 24h cooldown from
   next_eligible_at; correct verified-identity masking and the real
   two-step update-identity flow (verify-id → update-identity, plus
   the backend-decided manual-entry path). Hide
   email/phone/verification/AfyaConnect rows while acting.

B. Security step — build the real screen behind the current TODO:
   change password (no current-password prompt, sign out on success),
   two-step verification (follow auth-and-signup.md Step 3a),
   Devices & sessions static box + Review sessions → Danger zone.

C. Notifications step — add the push preference rows
   (GET /api/push/preferences/, single PUT of the full list on Save).
   Show Push / Email / SMS only; round-trip whatsapp unchanged; the
   "required" rule counts whatsapp. Keep the existing OS-permission
   sheet separate.

D. Privacy & data step — analytics-opt-out and sha-consent switches
   (each its own PATCH, immediate save, exact toasts) plus
   Download your data (JSON/CSV, Content-Disposition filename, don't
   hardcode).

E. Danger zone step — Sign out everywhere (logout-all, then sign out
   locally); Delete account replaced with the full schedule/cancel
   flow, "DELETE" + password client gate, pending-state with
   scheduled_for as a long local date, verbatim copy incl. the red
   "Take care." banner.

F. Step layout — map the six steps to the app's navigation, General
   entry badge from pending_contact_verifications.length, acting-for
   restriction across all steps.

Hard rules: no regressions to language/theme/logout/delete/export/
profile-save/location-hydration/identity-display/shimmers/error views.
No invented endpoints (flag ambiguity instead — e.g. careers list).
Strings are verbatim from the contract, no paraphrasing or translation.
Extend the existing datasource→repository→usecase→bloc→UI chain;
consider per-step blocs only if the existing pattern supports it.
Read next_eligible_at, never compute cooldowns. Disable buttons from
status. Reuse the app's existing acting-for signal and sign-out path.

Deliver: (1) create/modify file list with one-line reasons; (2)
domain/data additions mapped 1:1 to contract endpoints; (3) bloc/
event/state changes; (4) widgets/screens A–F; (5) a parity checklist
mapping every contract subsection to the implementing file, marked
✅ / 🟡 (with note) / ❌ (with note and what you need). Finish with an
audit: every toast emitted vs the contract's line, every named
endpoint and its query params, every acting-hidden row, every
cooldown/throttle enforced from status, and confirm you did NOT build
anything the contract says doesn't exist (sessions API, etc.). If a
decision can't be made from the contract, stop and ask.