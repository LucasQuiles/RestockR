# RestockR Developer Handoff

RestockR is a cross–platform Flutter client for monitoring high–demand product restocks, managing personal watchlists, and collaborating on inventory signals. Front‑end implementation is feature complete; the next phase is to connect it to the production backend, harden the deployment pipeline, and ship a 1.0 release. This README captures everything the incoming team needs to continue confidently.

> **Branch notice (`v0.1`)**  
> This branch is a developer-focused staging ground for new navigation work, auth wiring, and tooling tweaks. Expect rapid iteration, force-pushed fixes, and occasional breaking changes while features burn in. Reach for `main` when you need the latest semi-stable build.

---

## Collaboration TL;DR
- **Current status**: Flutter UI complete with real-time WebSocket integration, Discord OAuth, timezone-aware displays, and in-app help system. Backend is live at `emerald-alerts-development.onrender.com` with full API endpoints operational.
- **Primary tools**: `./start.sh` (interactive launcher), `./install.sh`, `./envsetup.sh`, `./emulators.sh`, and `./logs.sh` orchestrate setup, diagnostics, and daily workflows.
- **Secrets**: `env.json` (generated automatically) holds API keys. It is `.gitignore`d and locked to permission `600`.
- **Real-time features**: Native Dart WebSocket client with automatic HTTP fallback for reactions, watchlist sync, and live restock alerts.
- **User experience**: Interactive tutorial system, timezone-aware timestamps, Discord OAuth for mobile, and comprehensive data visualization.
- **Next major deliverables**:
  1. Production deployment and environment configuration.
  2. App store submission (iOS/Android).
  3. Performance optimization and analytics integration.
  4. User acceptance testing and feedback incorporation.

---

## Project Snapshot

| Area | Notes |
| --- | --- |
| **Product Vision** | Give collectors/operators a command center to track restocks across multiple retailers with actionable alerts and historical insights. |
| **Platforms** | iOS, Android, Web (single Flutter codebase). |
| **State Management** | `flutter_riverpod` with `StateNotifier` view models, `equatable` data classes. |
| **Networking** | Full backend integration with `dio` HTTP client + native WebSocket (Socket.IO protocol). Automatic HTTP fallback for reliability. |
| **Real-time** | Native Dart WebSocket client implementing Socket.IO v4 protocol with JWT authentication, ping/pong keep-alive, and event-driven architecture. |
| **Authentication** | Discord OAuth with mobile device detection, JWT token management, secure storage, and automatic refresh. |
| **Data Layer** | Repository pattern with mock/real implementations, watchlist sync, history aggregation, and restock feed management. |
| **User Experience** | Timezone-aware timestamps, interactive tutorial system, heatmap visualizations, and responsive design. |
| **Design System** | Custom widgets under `lib/widgets`, responsive utilities in `lib/core/utils`, centralized date/time formatting. |
| **Logging** | All CLI tooling streams to `.restockr_logs/session_<timestamp>.log[.gz]` for traceability. |

---

## Product Experience Gallery

### Developer Quick Launch Walkthrough
1. **Run the launcher (`RunStartScript.png`)**  
   Execute `./start.sh` from the project root. The script validates the environment (Flutter/Dart/git, CocoaPods on macOS), ensures `env.json` exists, and offers guided fixes. It will not install global dependencies without your confirmation; watch for yellow prompts asking before running Homebrew/apt/snap commands. When the summary banner shows no blocking warnings, you are ready for launch.
   ![Run start script](ScreenShots/RunStartScript.png)
2. **Choose “Quick Launch” (`QuickLaunch.png`)**  
   Option `[1] Quick Launch` performs the fastest path to running RestockR. It checks for connected devices, surfaces recommended targets (iOS/Android/Chrome), and queues the proper `flutter run` command. Selecting other menu items keeps you in the launcher for advanced actions.
   ![Quick launch menu](ScreenShots/QuickLaunch.png)
3. **Select the iOS simulator (`iOSEmu.png`)**  
   When prompted for a platform, pick iOS if you want to boot Apple silicon simulators. The launcher queries available runtimes and uses `simctl` to pick an appropriate device. If none exist, it will offer to create one.
   ![iOS emulator choice](ScreenShots/iOSEmu.png)
4. **Watch the simulator boot (`LaunchiOSSimulation.png`)**  
   The script opens Simulator.app and attaches a spinner while `simctl` boots the selected device. Expect a short delay the first time as Xcode initializes assets.
   ![Launching iOS simulation](ScreenShots/LaunchiOSSimulation.png)
5. **Confirm RestockR is live (`AppLaunchedSuccessfully.png`)**  
   Once the device registers with `flutter devices`, the launcher deploys the app. You should see the Flutter build banner followed by RestockR’s splash screen inside the simulator.
   ![App launched successfully](ScreenShots/AppLaunchedSuccessfully.png)

### Core Application Screens
- **Splash Screen (`SplashScreen.jpg`)**  
  Animated intro that sets the brand tone while Flutter finalizes initialization.
  ![Splash screen](ScreenShots/SplashScreen.jpg)
- **Login Screen (`Login.jpg`)**  
  Credential form with inline validation, password visibility toggle, and quick navigation to recovery actions.
  ![Login screen](ScreenShots/Login.jpg)
- **Monitor Feed (`Monitor.jpg`)**  
  Real-time restock cards exposing retailer, quantity, pricing, and sentiment actions (up/down votes, buy buttons).
  ![Monitor feed](ScreenShots/Monitor.jpg)
- **Watchlist Overview (`Watchlist.jpg`)**  
  Active subscriptions with SKU detail preview and instant unsubscribe control.
  ![Watchlist subscriptions](ScreenShots/Watchlist.jpg)
- **Discovery Watchlist (`Watchlist_2.jpg`)**  
  Explore new products and subscribe with one tap to extend coverage.
  ![Discover products](ScreenShots/Watchlist_2.jpg)
- **Number-Type Filter (`FilterNumberType.jpg`)**  
  Tune thresholds for stock levels or velocity metrics to minimize noise.
  ![Number type filter](ScreenShots/FilterNumberType.jpg)
- **Product-Type Filter (`FilterProductType.jpg`)**  
  Focus on categories (consoles, cards, etc.) aligned with operator responsibilities.
  ![Product type filter](ScreenShots/FilterProductType.jpg)
- **Retailer Filter (`FilterRetailer.jpg`)**  
  Zero in on specific merchants or marketplace groups for targeted monitoring.
  ![Retailer filter](ScreenShots/FilterRetailer.jpg)
- **Retailer Overrides (`RetailerSpecificOverrides.jpg`)**  
  Configure per-retailer delays, cooldowns, and notification rules to respect store quirks.
  ![Retailer-specific overrides](ScreenShots/RetailerSpecificOverrides.jpg)
- **Global Filtering (`GlobalFiltering.jpg`)**  
  Set account-wide minimum quantities and auto-open rules to match restock goals.
  ![Global filtering](ScreenShots/GlobalFiltering.jpg)
- **History Timeline (`History v2.jpg`)**  
  Heatmap of restock activity by hour for postmortems and scheduling.
  ![Recheck history](ScreenShots/History v2.jpg)
- **Notifications & Alerts (`NotificationsAlerts.jpg`)**  
  Toggle restock sounds, push notifications, and escalation preferences.
  ![Notifications & alerts](ScreenShots/NotificationsAlerts.jpg)
- **Profile Hub (`Profile_1.jpg`)**  
  Entry point to alert preferences, account settings, and integrations.
  ![Profile hub](ScreenShots/Profile_1.jpg)
- **Profile Utilities (`Profile_2.jpg`)**  
  Placeholder for upcoming backend-linked features (e.g., organization switching, device management).
  ![Profile utilities](ScreenShots/Profile_2.jpg)

---

## Codebase Tour

```
.
├── android/                     # Standard Flutter Android project
├── ios/                         # iOS/Xcode project + Pod configuration
├── lib/
│   ├── core/                    # App-wide exports, routing, sizing utilities
│   ├── presentation/            # Feature-first screens with models/notifiers/widgets
│   ├── routes/                  # Route generator & navigation configuration
│   ├── theme/                   # ThemeData, color palettes, typography
│   └── widgets/                 # Reusable UI components
├── assets/                      # Images, fonts, mock data
├── scripts (root)               # Executable helpers (start/install/envsetup/etc.)
├── pubspec.yaml                 # Dependencies, fonts, assets
└── env.json                     # Generated secrets (ignored from VCS)
```

Key entry points:
- `lib/presentation/*_screen/` packages UI + `StateNotifier` logic per feature.
- `lib/core/app_export.dart` aggregates shared imports to keep feature files lean.
- `lib/core/utils/size_utils.dart` drives scalable spacing and typography.
- `lib/widgets/` contains custom buttons, text fields, app bars, etc.

---

## Tooling & Scripts

| Script | Purpose |
| --- | --- |
| `start.sh` | Main launcher. Runs diagnostics, guides device/emulator selection, launches the app, and records session logs. |
| `envsetup.sh` | Validates project structure, ensures `env.json`, checks toolchains (Flutter, Dart, git, CocoaPods), and offers guided fixes. |
| `install.sh` | Clean install or reinstall workflow (`flutter pub get`, pod install, workspace cleanup). |
| `emulators.sh` | Interactive manager for iOS simulators & Android emulators, including auto-creation and boot helpers. |
| `uninstall.sh` | Removes generated artifacts, pods, build outputs, and the `.restockr_devkit` marker. |
| `logs.sh` | Inspect, export, or prune `.restockr_logs`. Keeps only the most recent 50 logs (compresses older entries). |
| `test_start.sh` | Smoke test that the launcher boots and logs correctly. Useful in CI once added. |

> All scripts source common helpers from `lib/common.sh` and `lib/visual.sh`, which provide logging, colored output, spinners, timers, and shared environment variables.

---

## Environment Setup

1. **Install prerequisites**
   - Flutter SDK `^3.6.0` (check with `flutter --version`).
   - Dart (bundled with Flutter).
   - Xcode + command-line tools (macOS/iOS) and Android Studio/SDK (Android).
   - Homebrew (macOS) is optional but unlocks automated fixes in the scripts.

2. **Clone the repository**
   ```bash
   git clone https://github.com/LucasQuiles/RestockR.git
   cd RestockR
   ```

3. **Bootstrap tooling**
   ```bash
   chmod +x start.sh install.sh envsetup.sh emulators.sh logs.sh uninstall.sh
   ./start.sh
   ```
   - First run prompts for installation → runs `envsetup.sh` checks → executes `flutter pub get` → optionally installs CocoaPods.
   - Subsequent runs drop you in the developer menu with quick actions (launch app, run tests/analyzer, manage emulators, reinstall kit).

4. **Configure `env.json`**
   - Generated automatically if missing. Update endpoints, auth providers, and telemetry keys before hitting real services:
     ```json
     {
       "RESTOCKR_ENV": "development",
       "RESTOCKR_API_BASE": "https://api.local.restockr.dev",
       "RESTOCKR_WS_URL": "wss://ws.local.restockr.dev/restocks",
       "SUPABASE_URL": "https://your-supabase-project.supabase.co",
       "SUPABASE_ANON_KEY": "replace-me",
       "AUTH_PROVIDER": "supabase",
       "AUTH_STORAGE_DRIVER": "secure_storage",
       "AUTH_REFRESH_INTERVAL_MIN": 45,
       "RESTOCKR_MONITOR_PAGE_SIZE": 25,
       "WATCHLIST_DEFAULT_SORT": "recent_activity",
       "WATCHLIST_MAX_ENTRIES": 100,
       "HISTORY_WINDOW_DAYS": 14,
       "HISTORY_PAGE_SIZE": 50,
       "FILTER_DEFAULTS_PROFILE": "standard",
       "NOTIFICATION_PROVIDER": "fcm",
       "PUSH_PUBLIC_KEY": "",
       "ANALYTICS_WRITE_KEY": "",
       "LOG_LEVEL": "info",
       "TRACE_SAMPLING_RATE": 0.1,
       "OPENAI_API_KEY": "replace-me",
       "GEMINI_API_KEY": "replace-me",
       "ANTHROPIC_API_KEY": "replace-me",
       "PERPLEXITY_API_KEY": "replace-me"
     }
     ```
   - File permissions are locked to `600` by the setup script; avoid loosening them. See `BACKEND_WIRING_HARNESS.md` for guidance on how each field is used.

---

## Running, Building, and Testing

### Day-to-day development
```bash
./start.sh          # recommended workflow (device detection + launch)
flutter run         # manual launch if you already have a device/emulator up
```

### Static analysis & unit tests
```bash
flutter analyze
flutter test
```
> No tests exist yet—plan to introduce unit tests for Riverpod notifiers and widget tests for the critical flows once backend integration lands.

### Release builds
```bash
flutter build apk --release
flutter build ios --release
flutter build web --release
```
Make sure to configure signing, provisioning profiles, and store metadata during the release hardening sprint.

---

## Backend & Integration

### Current Implementation Status ✅

**Backend API**: Fully operational at `https://emerald-alerts-development.onrender.com`

**Completed Integrations**:
1. ✅ **Authentication** - Discord OAuth with JWT tokens, secure storage, automatic refresh
2. ✅ **Product API** - Full CRUD operations, pagination, filtering, search
3. ✅ **Watchlist Management** - Subscribe/unsubscribe to SKUs, sync across devices
4. ✅ **Restock Feed** - Real-time alerts via WebSocket with HTTP fallback
5. ✅ **History & Analytics** - Time-series aggregation, heatmap visualization
6. ✅ **Reactions** - Vote on restocks (yes/no), real-time updates via WebSocket
7. ✅ **User Profile** - Account management, preferences, subscription tracking

### WebSocket Implementation

**Native Dart WebSocket Client** (`lib/data/restocks/native_websocket_client.dart`)

Implements Socket.IO v4 protocol directly using `web_socket_channel`:

**Features**:
- ✅ JWT authentication via `socket.handshake.auth.token`
- ✅ Automatic ping/pong keep-alive mechanism
- ✅ Event emission and listening (react, watchlistUpdate, restock)
- ✅ Connection state management with detailed logging
- ✅ iOS-compatible (resolves socket_io_client timeout issues)

**Protocol Implementation**:
```dart
// Connection URL: wss://host/socket.io/?EIO=4&transport=websocket
// Packet types: 0=open, 2=ping, 3=pong, 4=message
// Message types: 0=connect, 2=event, 4=error
// Event format: 42["event_name",{data}]
// Auth format: 40{"token":"JWT"}
```

**HTTP Fallback**:
Automatic fallback to HTTP endpoints when WebSocket unavailable:
- Reactions: `POST /api/alerts/:alertId/react`
- Ensures 100% reliability regardless of network conditions

**Usage**:
```dart
// Initialize with auth token
final wsClient = NativeWebSocketClient(
  config: backendConfig,
  authToken: jwtToken,
);

// Connect
await wsClient.connect();

// Emit events
wsClient.emit('react', {'alertId': '123', 'type': 'yes'});

// Listen for events
wsClient.on('reactionUpdate', (data) {
  // Handle real-time reaction updates
});

// Stream restock alerts
wsClient.alertStream.listen((alert) {
  // Handle real-time restock notifications
});
```

### Data Layer Architecture

**Repository Pattern** (`lib/data/`)
```
lib/data/
├── auth/                    # Authentication (Discord OAuth, JWT)
├── products/                # Product catalog management
├── watchlist/               # Subscription management
├── restocks/                # Real-time restock feed
│   ├── native_websocket_client.dart    # WebSocket implementation
│   ├── restock_feed_repository.dart    # Abstract interface
│   └── restock_feed_repository_impl.dart # Live + HTTP fallback
└── history/                 # Historical data & analytics
```

Each repository provides:
- Abstract interface for dependency injection
- Mock implementation for development/testing
- Real implementation with error handling
- Automatic caching where appropriate

### Environment Configuration

Production `env.json` template:
```json
{
  "RESTOCKR_ENV": "production",
  "RESTOCKR_API_BASE": "https://emerald-alerts-production.onrender.com",
  "RESTOCKR_WS_URL": "https://emerald-alerts-production.onrender.com",
  "DISCORD_CLIENT_ID": "your-client-id",
  "DISCORD_CLIENT_SECRET": "your-client-secret",
  "DISCORD_REDIRECT_URI": "https://restockr.app/auth/callback"
}
```

**Required Backend Endpoints** (all implemented):
- `POST /api/auth/discord` - OAuth callback
- `GET /api/me` - User profile & watchlist
- `GET /api/products` - Product catalog
- `POST /api/subscribe/:sku` - Add to watchlist
- `DELETE /api/subscribe/:sku` - Remove from watchlist
- `GET /api/alerts/recent` - Restock feed
- `POST /api/alerts/:id/react` - Submit reaction (HTTP fallback)
- `GET /api/history` - Historical aggregations
- **WebSocket** `/socket.io/` - Real-time events (Socket.IO v4)

---

## Development Workflow & Collaboration

- **Branching**: Use feature branches (`feature/backend-auth`, `fix/login-validation`, etc.) off `main`. Keep `main` deployable.
- **Commits**: Conventional style (`feat:`, `fix:`, `chore:`) is preferred to align with existing history.
- **Code Reviews**: Submit PRs against `main`. Include screenshots/GIFs for UI changes and describe testing performed.
- **CI/CD**: Not yet configured. Recommendation: set up GitHub Actions with stages for `flutter analyze`, `flutter test`, and `./test_start.sh`.
- **Release cadence**: Pending. Suggest establishing `staging` and `production` branches once backend integration stabilizes.
- **Documentation**: Additional design docs auto-generated during the refactor were intentionally removed from git. If you regenerate collaboration notes, store them in a shared drive or a new `docs/` folder that remains ignored if the volume is high.

---

## Observability & Troubleshooting

- Session logs live in `.restockr_logs/`. New entries are created every time a script runs.
- `logs.sh` offers `list`, `view`, `export`, and `prune` commands:
  ```bash
  ./logs.sh list
  ./logs.sh view latest
  ./logs.sh export ios-launch > ios_setup.txt
  ```
- iOS specific tips:
  - Ensure Xcode is fully installed (`xcode-select -p` should not error).
  - If simulators are missing, `envsetup.sh` and `emulators.sh` can trigger downloads (`xcodebuild -downloadPlatform iOS`).
- Android specific tips:
  - Install Android Studio Device Manager images.
  - Ensure `$ANDROID_HOME` or `$ANDROID_SDK_ROOT` is set if using CLI tooling.

---

## Known Gaps & TODOs

1. **Backend Integration**
   - Implement authentication (sign-in, token refresh, error modals).
   - Wire real-time restock feed (websocket or polling).
   - Persist user settings/watchlists server-side.

2. **Testing & Quality**
   - Add widget tests for core flows (login, watchlist, monitor, filters).
   - Add integration tests for navigation and API error handling.
   - Include golden tests or visual regression checks for high-value screens.

3. **Performance & Accessibility**
   - Profile start-up time and optimize asset loading.
   - Audit for a11y (contrast, semantics, large text, screen reader labels).
   - Implement skeleton states for long-running operations.

4. **Release Readiness**
   - Configure app icons, splash screens, and store metadata.
   - Set up CI, crash reporting (Sentry/Firebase), and analytics.
   - Draft privacy policy & terms for app stores.

5. **Future Enhancements (Optional)**
   - Multi-tenant/org accounts.
   - Push notification integration (Firebase/APNs).
   - Collaboration features (shared watchlists, comments).

---

## User Experience Enhancements

### In-App Help & Tutorial System ✨

**Interactive Tutorial Modal** (`lib/presentation/help_tutorial_screen/help_tutorial_modal.dart`)

5-slide swipeable tutorial introducing core features:
1. **Welcome** - App overview and purpose
2. **Managing Watchlist** - Star icons, add/remove products, subscription management
3. **Restock History** - Interactive heatmap, hourly breakdowns, activity patterns
4. **Filters & Settings** - Global filters, retailer overrides, notification preferences
5. **Get Started** - Ready to track products

**Features**:
- Swipeable slides with smooth animations
- Progress indicators (dots)
- Quick Tips sections with actionable hints
- Color-coded icons for visual learning
- Back/Next/Get Started navigation
- Accessible from Profile screen help button

### Timezone-Aware Timestamps 🌍

**Centralized DateTime Utility** (`lib/core/utils/date_time_utils.dart`)

All timestamps automatically convert UTC to user's local timezone:

**Available Formatters**:
- `formatFullDate()` - "Monday, Jan 1, 2025"
- `formatShortDate()` - "Mon, 01 Jan"
- `formatTime()` - "3:45 PM"
- `formatTimeWithSeconds()` - "03:45:23 PM"
- `formatMonthYear()` - "January 2025"
- `formatRelativeTime()` - "2 hours ago"

**Benefits**:
- Consistent formatting across all screens
- Automatic timezone conversion
- No manual `.toLocal()` calls needed
- Better user experience for global users

---

## Change Log (Recent Updates)

### v0.1 Branch - Latest Features

**Real-Time Integration** (Oct 16, 2025):
- ✅ Implemented native Dart WebSocket client with Socket.IO v4 protocol
- ✅ Added automatic HTTP fallback for reactions when WebSocket unavailable
- ✅ Fixed iOS connection timeout issues (replaced socket_io_client)
- ✅ JWT authentication via socket.handshake.auth.token
- ✅ Ping/pong keep-alive mechanism for stable connections

**User Experience** (Oct 16, 2025):
- ✅ Added timezone-aware timestamp formatting throughout app
- ✅ Centralized date/time utility for consistent formatting
- ✅ All timestamps now display in user's local timezone
- ✅ In-app help & tutorial system with 5 interactive slides
- ✅ Swipeable tutorial modal with quick tips

**Authentication** (Oct 14, 2025):
- ✅ Discord OAuth implementation with mobile device detection
- ✅ JWT token management with secure storage
- ✅ Automatic token refresh
- ✅ OAuth workaround for iOS simulator limitations

**Data Layer** (Oct 14, 2025):
- ✅ Repository pattern implementation across all features
- ✅ Mock implementations for development
- ✅ Real backend integration with error handling
- ✅ Watchlist sync across WebSocket and HTTP

**Tooling & DevOps**:
- ✅ Modularized CLI scripts (`lib/common.sh` + `lib/visual.sh`)
- ✅ CocoaPods-friendly iOS project
- ✅ Enhanced `start.sh` with guided launch flows
- ✅ Log rotation and export tools (`logs.sh`)
- ✅ Emulator management (`emulators.sh`)
- ✅ Cleaned up temporary documentation and test files

---

## Ownership & Contact

- **Repository Owner**: Lucas Quiles (`@LucasQuiles` on GitHub). Reach out for access, deployment credentials, or historical context.
- **Next Lead**: _TBD_ — please add your contact information here once the backend team takes over.

Keep this README as the single source of truth for onboarding. Update it when you finalize backend endpoints, add CI/CD, or change the release process so future contributors inherit accurate guidance.
