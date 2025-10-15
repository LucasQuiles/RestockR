# Backend Mobile Auth Fix

## Summary

Modified the Discord OAuth callback to detect mobile devices and redirect directly to the custom URL scheme `restockr://callback?token=...` instead of routing through the web app.

## Changes Made

**File:** `API/auth.js` (lines 113-163)

### Added Mobile Detection

```javascript
// Detect mobile and redirect to custom scheme
const userAgent = req.get('user-agent') || '';
const isMobile = /iPhone|iPad|Android/i.test(userAgent);

console.log('📱 User-Agent:', userAgent);
console.log('📱 Is Mobile:', isMobile);

if (isMobile) {
  console.log('📱 Redirecting to mobile app: restockr://callback?token=...');
  return res.redirect(`restockr://callback?token=${token}`);
}

console.log('🌐 Redirecting to web app:', `${process.env.CLIENT_ORIGIN}/login?token=...`);
res.redirect(`${process.env.CLIENT_ORIGIN}/login?token=${token}`);
```

### What This Does

1. **Checks User-Agent** header for mobile devices (iPhone, iPad, Android)
2. **Mobile Flow:** Redirects to `restockr://callback?token=<JWT>`
   - The mobile app's custom URL scheme captures this immediately
   - Token is extracted and user is logged in
3. **Web Flow:** Redirects to `https://restockr.app/login?token=<JWT>`
   - Web app handles the login normally

## Deployment Required

This backend change needs to be deployed to your Render.com instance at:
`https://emerald-alerts-development.onrender.com`

### Option 1: Auto-Deploy (if enabled)

If you have auto-deploy configured from GitHub:

```bash
git add API/auth.js
git commit -m "fix: detect mobile for OAuth redirect to custom URL scheme"
git push origin v0.1
```

Render will automatically deploy the changes.

### Option 2: Manual Deploy

1. Go to https://dashboard.render.com
2. Find your `emerald-alerts-development` service
3. Click "Manual Deploy" → "Deploy latest commit"

### Option 3: Deploy from Render Dashboard

1. Upload the modified `API/auth.js` file
2. Or connect your GitHub repo and trigger a deploy

## Testing After Deployment

1. Run the mobile app: `./start.sh` → Quick Launch [1]
2. Tap "Login with Discord"
3. Complete OAuth in the webview
4. App should automatically return and log you in

### Expected Logs

**Backend logs (Render):**
```
📱 User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)...
📱 Is Mobile: true
📱 Redirecting to mobile app: restockr://callback?token=...
```

**Mobile app logs:**
```
flutter: 🔐 OAuth callback URL: restockr://callback?token=eyJhbGc...
flutter: 🔐 Parsed URI - scheme: restockr, host: callback, path: /callback
flutter: 🔐 Query parameters: {token: eyJhbGc...}
flutter: 🔐 Token received successfully
flutter: 🔐 Login successful!
```

## Rollback Plan

If this causes issues, revert the changes:

```bash
git revert HEAD
git push origin v0.1
```

Or manually restore the original redirect:

```javascript
res.redirect(`${process.env.CLIENT_ORIGIN}/login?token=${token}`);
```

## Alternative Solution (No Backend Deploy)

If you can't deploy backend changes right now, you can deploy the `web/login.html` redirect page to `https://restockr.app/login`. See `OAUTH_MOBILE_SETUP.md` for instructions.

---

**Status:** ⏳ Backend change made locally, needs deployment
**Date:** October 14, 2025
