# RestockR v0.1 Implementation Plan

This document inventories every user-facing screen in the current Flutter app, highlights the present behaviour of each UI element, and outlines the phased, multi-layered work required to reach a feature-complete v0.1. Phases are organized around the user journey; within each screen, tasks are split across UI/UX, Data & State, and Navigation/Integration layers where applicable.

---

## Phase 0 – Foundation & Navigation

### App Navigation Screen (`AppNavigationScreen`)
| Element | Current State | Status | v0.1 Change |
| --- | --- | --- | --- |
| Debug screen list | Hard-coded list of route names with simple tap-to-navigate. | Prototype utility | Gate behind debug flag and ensure it reflects the authoritative route registry. |
| `NavigatorService.pushNamed` calls | Uses global navigator to open screens. | Works | Confirm integration with future auth guard (prevent navigating into protected routes when signed out). |

#### Progress Notes — 2025-10-13
- [x] Added `AppConfig.showDebugMenu` flag and route registry metadata so the debug navigator pulls
  directly from `AppRoutes` and only builds in debug environments. Touchpoints:
  `lib/core/config/app_config.dart`, `lib/routes/app_routes.dart`,
  `lib/presentation/app_navigation_screen/app_navigation_screen.dart`.
- [ ] Navigation guard infrastructure landed in `NavigatorService` with a Riverpod provider wrapper but
  still needs live auth/session wiring and a redirect strategy before we can block protected routes for
  signed-out users. Touchpoints: `lib/core/utils/navigator_service.dart`,
  `lib/core/navigation/route_guard_provider.dart`, `lib/main.dart`.

---

## Phase 1 – Access & Accounts

### Splash Screen (`SplashScreen`)
| Element | Current State | Status | v0.1 Change |
| --- | --- | --- | --- |
| Animated logo | Scale + fade animation on static asset `imgFrame132`; duration 2s. | Works | Swap in final brand asset, add dark-mode variant if applicable. |
| Delayed navigation | After 2.8s, unconditionally routes to login. | Prototype | Route based on persisted auth/session state; add error handling for failed preload. |
| State management | Reads `splashNotifier` only for image path override. | Incomplete | Extend notifier to fetch remote feature flags / maintenance notices as needed. |

### Login Screen (`LoginScreen`)
| Element | Current State | Status | v0.1 Change |
| --- | --- | --- | --- |
| Logo header | Static `CustomImageView` centered, no responsive constraints. | Works | Confirm adaptive sizing across devices; add margin token usage for design parity. |
| Username field | Required text input with local validation (non-empty). | Prototype | Connect to auth API DTO, surface backend validation errors, support email autofill. |
| Password field | Required, min length 6, obscured text, local validation. | Prototype | Add "show password" toggle, enforce password policy from backend. |
| Forgot Password link | Toast placeholder announcing “coming soon”. | Not implemented | Wire to password-reset flow (modal or deep link) and disable until available. |
| Login button | Red CTA; disabled when `isLoading`; after mock delay, toggles toast + navigation to watchlist. | Prototype | Replace mock delay with real API call, handle failure reasons, persist tokens securely, and show progress indicator inline. |
| Legal copy | Static T&C + Privacy text; no links. | Incomplete | Convert to tappable links opening webviews or external browser. |
| State clean-up | Controllers disposed in notifier dispose. | Works | Ensure state resets on auth errors and support multi-account sign-in flow. |

### Profile Settings Screen (`ProfileSettingsScreen`)
| Element | Current State | Status | v0.1 Change |
| --- | --- | --- | --- |
| App bar back button | Navigates back via `NavigatorService.goBack`. | Works | Add haptic + analytics event; respect notch-safe padding. |
| User info card | Displays placeholder name/email from notifier defaults. | Stub | Populate from authenticated user profile API; support avatar upload or generated initials. |
| Menu items | Navigate to Notifications, Global Filtering, Retailer Overrides. | Works | Add route guards (e.g., hide items without permission), surface confirmation on sign-out (new menu entry). |

---

## Phase 2 – Core Product Surfaces

### Product Watchlist Screen (`ProductWatchlistScreen` + Initial Page)
| Element | Current State | Status | v0.1 Change |
| --- | --- | --- | --- |
| Bottom navigation (`CustomBottomBar`) | 4 tabs (Dashboard, Monitor, History, Watchlist); local index state. | Prototype | Sync with app-wide navigation controller, add badge counts, persist selected tab across sessions. |
| Header title | Static “Watchlist”. | Works | Localize string and confirm dynamic title when switching tabs (Discover vs My Subscriptions). |
| Notification icon | Opens notifications settings screen. | Works | Replace with notifications center when available; add unread badge integration. |
| Profile icon | Routes to profile settings. | Works | Swap icon to user avatar; apply guard for guest users. |
| Search bar | Filters local `watchlistItems` list. | Prototype | Connect to backend search API with debounced query and loading indicator; handle empty/error states gracefully. |
| Tab pills | Two tabs (Discover Products / My Subscriptions) with animated styling. | Works | Ensure TabController stays in sync with data source; add analytics events for tab switching. |
| Discover list | Renders static mock data via `WatchlistItemModel`; subscribe toggles local state. | Prototype | Replace with remote catalog feed, paginate results, display real metadata (price, availability), and disable subscribe on duplicates. |
| Subscriptions list | Filters items where `isSubscribed == true`. | Works (with mock data) | Fetch from user subscriptions endpoint, support reorder/grouping, and allow swipe-to-unsubscribe. |
| Subscribe button | Local toggle function with toast. | Prototype | Make API call, show inline loading, handle quota errors, update counts from server response. |
| Empty states | Basic text messaging. | Works | Align copy with product voice, add CTA to adjust filters when discover empty. |

### Product Monitor Screen (`ProductMonitorScreen`)
| Element | Current State | Status | v0.1 Change |
| --- | --- | --- | --- |
| Header / icons | Same pattern as watchlist. | Works | Share componentized header; consolidate notification/profile actions. |
| Search | Local filter on mock items. | Prototype | Integrate remote search with typeahead; implement clear button. |
| Tab bar | Seven hard-coded retailers; style pill selection. | Prototype | Source tab list from configuration, add “All Retailers” default, support dynamic counts. |
| Monitor list | List items from mock model; up/down vote buttons update local counters; buy button routes to watchlist management. | Prototype | Back hook to monitoring service, enforce vote rate limits, integrate deep link to retailer product page from buy button, and update UI on API response. |
| Loading / empty states | Simple `CircularProgressIndicator` and text. | Works | Enhance with skeleton loaders and actionable empty states (e.g., adjust filters). |

### Recheck History Screen (`RecheckHistoryScreen`)
| Element | Current State | Status | v0.1 Change |
| --- | --- | --- | --- |
| Header / icons | Watchlist-style header. | Works | Unify shared component; add filter badges when global filters active. |
| Search + filter icon | Search field unused; filter icon opens Global Filtering screen. | Stub | Implement query filtering on history dataset and open dedicated filter modal (date/status/type). |
| Month dropdown | Populated with mock options; updates local state only. | Prototype | Load month ranges from API, sync with selected calendar view, persist last selection. |
| Calendar | `CalendarDatePicker` limited to 2020-2030; updates state. | Prototype | Replace with virtualized calendar supporting backend min/max dates and highlight days with activity. |
| Activity table | Renders categorized mock items. | Prototype | Bind to real recheck records, add virtualization for large lists, enable tap to open detail sheet. |
| Global filters link | Navigates to settings screen. | Works | Replace with inline filter summary once global filters accessible from this screen. |

### Watchlist Management Screen (`WatchlistManagementScreen`)
| Element | Current State | Status | v0.1 Change |
| --- | --- | --- | --- |
| Subscription list | Mock data list with unsubscribe button. | Prototype | Fetch authenticated subscriptions, support multi-select bulk actions, and show metadata (retailer, alerts enabled). |
| Unsubscribe dialog | Confirmation modal with hard-coded copy. | Works | Localize text, introduce loading state while API call runs, and update list via notifier response. |
| Success toast | Uses `AppToastVariant.warning` for unsubscribe. | Works (odd variant) | Switch to neutral/success tone per UX guidance; log analytics event. |

---

## Phase 3 – Settings & Controls

### Notifications & Alerts Settings (`NotificationsAlertsSettingsScreen`)
| Element | Current State | Status | v0.1 Change |
| --- | --- | --- | --- |
| App bar back button | Returns to previous screen. | Works | Show screen title centered per design system; add safe area padding. |
| Restock sound toggle | Switch backed by notifier boolean; no persistence beyond session. | Prototype | Persist to user settings API/local storage, add descriptive subtitle, and expose additional notification channels (push/email/sound). |
| Visual feedback | None when toggle changes beyond state update. | Incomplete | Provide snack/toast on save failure and disable while saving. |

### Global Filtering Settings (`GlobalFilteringSettingsScreen`)
| Element | Current State | Status | v0.1 Change |
| --- | --- | --- | --- |
| Minimum target field | Text field with controller; accepts uncontrolled input. | Prototype | Add numeric keyboard, validation, unit label, and auto-save feedback. |
| Categories list | Static mocked categories with switches. | Prototype | Fetch categories from backend, persist toggles, show loading placeholders, and support grouping/search. |
| Save mechanics | No explicit save; switches update notifier only. | Incomplete | Add auto-save debounce or explicit Save CTA with success/error messaging. |

### Retailer-Specific Overrides (`RetailerOverrideSettingsScreen`)
| Element | Current State | Status | v0.1 Change |
| --- | --- | --- | --- |
| App bar | Custom back button with title. | Works | Reuse shared top app bar component. |
| Auto-open toggle | Switch controlling `isAutoOpenEnabled`. | Prototype | Persist to user settings service and display descriptive helper text. |
| Queue delay slider | Range 0–1, representing normalized value. | Prototype | Convert to real unit (seconds) with tick marks, display chosen value label, and enforce min/max constraints from product. |
| Reopen cooldown slider | Same as above. | Prototype | Same improvements as queue delay slider; ensure accessibility (voiceover labels). |
| Save button | Triggers notifier save with toast on success. | Prototype | Disable while saving, handle errors, close screen on success if desired. |

### Retailer Filter (`RetailerFilterScreen`)
| Element | Current State | Status | v0.1 Change |
| --- | --- | --- | --- |
| Filter tabs | Static list with manual navigation to other filter screens. | Prototype | Replace with shared side-nav component; highlight current filter source context. |
| Retailer checklist | Hard-coded retailers toggling local booleans. | Prototype | Populate from backend list (including logos, ordering), allow multi-select, provide `Select All` option, and support search. |
| Clear All | Resets notifier state. | Works | Confirm resets across linked filter screens; add confirmation if selections exist. |
| Apply | Calls notifier `applyFilters()` then closes. | Prototype | Ensure filters apply to calling context (monitor/watchlist); pass result via Navigator response. |
| Close | Simply `goBack()`. | Works | No change beyond analytics event. |

### Product Type Filter (`ProductTypeFilterScreen`)
| Element | Current State | Status | v0.1 Change |
| --- | --- | --- | --- |
| Type list | Hard-coded categories with checkboxes. | Prototype | Fetch product types from backend taxonomy, support hierarchical types, and sync selection with retailer filter summary. |
| All Type toggle | Toggles local boolean. | Prototype | Ensure “All” acts as master toggle (selects/deselects all others) with proper state reconciliation. |
| Apply/Clear/Close | Same behaviour as retailer filter. | Prototype | Maintain parity after wiring to data layer; show unsaved changes indicator. |

### Number Type Filter (`NumberTypeFilterScreen`)
| Element | Current State | Status | v0.1 Change |
| --- | --- | --- | --- |
| Radio options | Two options (Restocks vs Reactions) toggling local state. | Prototype | Replace with configurable list from backend, add context help for each metric, and persist user preference. |
| Layout | Side navigation replicates other filter screens. | Works | Factor into shared widget to reduce duplication. |
| Apply/Clear/Close | Local state only. | Prototype | Wire to upstream filter workflow and broadcast selection to calling screen via Provider or route result. |

---

## Phase 4 – Data & State Enhancements

### Cross-cutting Tasks
| Layer | Current Gap | v0.1 Plan |
| --- | --- | --- |
| Data fetching | Most screens rely on mocked models with local state only. | Implement repository layer backed by real APIs or local database, introduce loading/error states, and standardize caching. |
| State management | Riverpod notifiers exist but hold placeholder logic. | Expand states to include failure reasons, timestamps, pagination cursors; ensure proper disposal and restoration on hot restart. |
| Navigation | Routes are accessible regardless of auth. | Add guarded navigation with deep-link support, define global route constants, and ensure secure transitions post-login. |
| Theming & localization | Strings and colors hard-coded per screen. | Centralize in theme/i18n files, enable dark mode and scaling fonts. |
| Telemetry | No analytics or logging. | Instrument key actions (login, subscribe, apply filters) with analytics hooks and error logging. |

---

## Phase 5 – Quality & Delivery

### Testing & Tooling
- **UI Tests:** Add golden tests for each screen to lock layout while mocked data loads.
- **Integration Tests:** Cover login flow, navigation between bottom tabs, filter application, and settings persistence.
- **Performance:** Audit list screens (monitor, watchlist, history) for virtualization; add frame budget monitoring.
- **Accessibility:** Ensure all tappable elements include semantics labels, focus order, and contrast compliance.
- **Release Readiness:** Document feature toggles, seed data requirements, and fallback behaviours if network requests fail.

---

## Implementation Sequencing Overview
1. **Phase 0:** Harden navigation scaffolding and gating.
2. **Phase 1:** Ship authenticated entry points and profile surfaces with real data.
3. **Phase 2:** Deliver monitoring/watchlist/history experiences backed by production APIs.
4. **Phase 3:** Finalize settings & filter workflows with persistent storage.
5. **Phase 4:** Implement shared data/state improvements and observability.
6. **Phase 5:** Complete testing, accessibility, and release checklist for v0.1.

Each phase can progress in parallel across UI, Data, and Integration layers, but dependencies (e.g., real authentication before protected screens) should guide sprint planning.
