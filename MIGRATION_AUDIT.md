# Copied foundation audit

This audit was completed before the rewrite. All copied source files and
consumer visual assets were removed with explicit approval because the source
tree was untracked and structurally inconsistent with the declared product.

| Copied area | Decision | Reason |
| --- | --- | --- |
| `core/injector` | Rewrite | Retains Injectable/GetIt composition without Firebase or preferences. |
| `core/api_client` | Rewrite | Retains one injected Dio/provider boundary; removes logging, public tokens, refresh/replay and endpoints. |
| `common/handlers`, validators, UI | Rewrite selectively | Only domain-neutral failures, use-case base, theme, and unavailable UI remain. |
| `common/models`, user repository, storage, notification service | Delete | Consumer identity/profile, preference persistence, image, push and raw-response assumptions. |
| `features/launch` | Rewrite | Safe in-memory session routing only; no coach marks or spare-parts UI. |
| `features/auth` | Rewrite | Contract-pending sign-in shell; no Firebase, OTP, token or push behaviour. |
| `features/account_setup` | Delete | Vehicle lookup, car images and automotive copy have no My Wellness equivalent. |
| `features/profile` | Rewrite | Safe profile/support placeholder; no upload, promotion, notification or deletion mutation. |
| Commerce, merchant, inventory, cart, delivery, payment, vehicle, maps and service features | Delete | Out of product scope. |
| `assets/` | Delete | Every supplied asset was consumer-product branding or automotive/commerce imagery. |
| Firebase, OneSignal, storage, maps, camera and commerce dependencies | Delete | Unapproved sensitive-data, notification, location or consumer functionality. |

## Retained safe patterns

`configureDependencies()`, generated Injectable registrations, injected Dio,
central endpoint registry, typed failures, navigator key/route generator and
feature-scoped BLoCs remain. There are no registered global feature BLoCs.

## Contract status

No approved My Wellness API, identity/session, consent, clinical-content,
booking, care-navigation, vital, retention, or privacy contract was available
in the repository. Accordingly this foundation sends no API request, stores no
session or health information, and renders no clinical content.
