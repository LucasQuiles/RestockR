# WebSocket Cookie Authentication - Limitation Found

## Problem

**Cookies set during external OAuth flow are not accessible to the Flutter app.**

### Evidence
```
flutter: [RestockFeed] Loaded 0 cookies for WebSocket
```

## Root Cause

The Discord OAuth flow uses `url_launcher` / `flutter_web_auth_2` which:
1. Opens external browser (Safari/Chrome)
2. Backend sets session cookies in that browser
3. Redirects back to app with JWT token only
4. **Cookies remain in external browser, NOT transferred to app**

## Why Cookie-Based Auth Won't Work

Flutter app's HTTP client (Dio) and the external OAuth browser are **completely separate cookie stores**. There's no way to extract cookies from the external browser and import them into the app's cookie jar.

### OAuth Flow Diagram
```
User App                External Browser              Backend
  |                             |                         |
  |-- Open OAuth URL ---------->|                         |
  |                             |-- GET /auth/discord --->|
  |                             |<--Set-Cookie: session --|
  |<--Deep Link: ?token=JWT----|                         |
  |                             |                         |
  ✓ Has JWT                     ✓ Has cookies             |
  ✗ No cookies                  ✗ No JWT                  |
```

## Attempted Solutions

### ✅ What We Tried
1. **Added cookie_jar package** - Installed successfully
2. **Added dio_cookie_manager** - Dio now tracks cookies from its own requests
3. **Modified WebSocket client** - Now accepts and sends cookies
4. **Tested cookie extraction** - Found 0 cookies (expected)

### ❌ Why It Doesn't Work
- OAuth cookies are in external browser
- Dio's cookie jar only has cookies from Dio's own requests
- After OAuth, all API calls use Bearer token, so no cookies are set by Dio either

## Solutions

### Option 1: Backend Adds JWT Support for WebSocket (Recommended)
**Backend changes required:**
```javascript
// Socket.IO server middleware
io.use((socket, next) => {
  // Accept JWT token from auth header
  const token = socket.handshake.auth.token ||
                socket.handshake.headers?.authorization?.replace('Bearer ', '');

  if (token) {
    verifyJWT(token, (err, user) => {
      if (err) return next(new Error('Authentication error'));
      socket.user = user;
      next();
    });
  } else {
    next(new Error('Authentication required'));
  }
});
```

**Flutter client:** ✅ Already implemented (passing JWT via Authorization header)

### Option 2: Use WebView Instead of External Browser
**Requires changing OAuth flow:**
1. Replace `url_launcher` with `webview_flutter`
2. Intercept cookies from WebView
3. Extract and store cookies
4. Pass to WebSocket

**Cons:**
- Major refactor of auth flow
- More complex cookie management
- WebView has its own issues on iOS

### Option 3: Accept Limitation (Current State)
**Status quo:**
- ✅ HTTP endpoints work (using JWT)
- ✅ Subscriptions work
- ✅ All core features functional
- ❌ Real-time reactions unavailable
- ❌ WebSocket doesn't connect

**Impact:** Minimal - reactions are a nice-to-have feature

## Recommendation

**Option 1 (Backend JWT support) is the best path forward** because:
1. Flutter app already sends JWT token
2. Backend change is minimal (add JWT verification to Socket.IO)
3. No client-side changes needed beyond what we've already done
4. More secure than cookie-based auth
5. Works across all platforms (iOS, Android, Web)

## Current Implementation Status

### ✅ Completed
- Socket.IO client upgraded to v3.1.2
- Cookie management packages installed
- JWT token passed via Authorization header
- Cookie extraction implemented (works, but finds 0 cookies as expected)

### What's Working
- All HTTP API endpoints
- Discord OAuth login
- Product listing
- Watchlist management (add/remove subscriptions)
- History views
- Profile settings

### What's Not Working
- Real-time WebSocket connection
- Reaction submissions
- Live reaction count updates

## Next Steps

1. **Short term:** Accept current state, deploy app with working features
2. **Long term:** Coordinate with backend team to add JWT support for Socket.IO
3. **Alternative:** Consider if reactions are needed at all

---

**Date:** 2025-10-16
**Issue:** Cookie-based WebSocket auth not possible with external OAuth
**Recommended Solution:** Backend adds JWT token support for Socket.IO
