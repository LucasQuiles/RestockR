# Mobile OAuth Setup Guide

## Overview

Discord OAuth for mobile apps requires a redirect flow because the backend redirects to `https://restockr.app/login?token=...` but mobile apps need custom URL schemes like `restockr://callback?token=...`.

## How It Works

```
┌──────────┐         ┌──────────┐         ┌────────────┐         ┌──────────┐
│  Mobile  │────1───▶│ Backend  │────2───▶│  Discord   │────3───▶│ Backend  │
│   App    │         │   API    │         │   OAuth    │         │Callback  │
└──────────┘         └──────────┘         └────────────┘         └──────────┘
     ▲                                                                   │
     │                                                                   │4
     │                                                                   ▼
     │               ┌───────────────┐                          ┌──────────────┐
     └───────7───────│    Mobile     │◀────────6────────────────│   Web Page   │
                     │  Deep Link    │                          │  restockr    │
                     │restockr://... │                          │  .app/login  │
                     └───────────────┘                          └──────────────┘
                                                                        │5
                                                                        ▼
                                                              Redirects to
                                                              restockr://callback?token=...
```

### Step-by-Step Flow:

1. **User taps "Login with Discord"** in mobile app
2. **App opens OAuth URL** using `flutter_web_auth_2` with `callbackUrlScheme: 'restockr'`
3. **Discord OAuth completes** and user authorizes the app
4. **Backend generates JWT** and redirects to `https://restockr.app/login?token=<JWT>`
5. **Web page at restockr.app/login** detects the redirect and immediately redirects to `restockr://callback?token=<JWT>`
6. **iOS/Android intercepts** the `restockr://` custom URL scheme
7. **flutter_web_auth_2 captures** the URL and passes it back to the app
8. **App extracts token** and stores it securely

## Required Files

### 1. Mobile Redirect Page (`web/login.html`)

This file must be deployed to `https://restockr.app/login`:

```html
<!DOCTYPE html>
<html>
<head>
    <title>RestockR - OAuth Redirect</title>
</head>
<body>
    <script>
        // Parse token from URL
        const urlParams = new URLSearchParams(window.location.search);
        const token = urlParams.get('token');
        const error = urlParams.get('error');

        // Redirect to custom scheme
        if (token) {
            window.location.href = `restockr://callback?token=${token}`;
        } else if (error) {
            window.location.href = `restockr://callback?error=${error}`;
        }
    </script>
</body>
</html>
```

**Location in project:** `/Users/lucas/SNEKOPS/RestockR/web/login.html`

### 2. iOS Configuration (`ios/Runner/Info.plist`)

Already configured with custom URL scheme:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>app.restockr</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>restockr</string>
        </array>
    </dict>
</array>
```

### 3. Android Configuration (`android/app/src/main/AndroidManifest.xml`)

Already configured with intent filter:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="restockr" />
</intent-filter>
```

### 4. Flutter OAuth Implementation (`lib/data/auth/auth_repository_impl.dart`)

```dart
@override
Future<AuthResult> signInWithDiscord({String? guildId}) async {
  final oauthUrl = '$baseUrl/api/auth/discord?guildId=$guildId';

  // Use custom scheme to capture redirects
  final result = await FlutterWebAuth2.authenticate(
    url: oauthUrl,
    callbackUrlScheme: 'restockr',
  );

  // Extract token from: restockr://callback?token=...
  final uri = Uri.parse(result);
  final token = uri.queryParameters['token'];

  return token != null
    ? AuthResult.success(token)
    : AuthResult.failure('No token received');
}
```

## Deployment Instructions

### Deploy to Production (restockr.app)

The `web/login.html` file needs to be deployed to `https://restockr.app/login`.

**Option 1: Static Site Hosting (Cloudflare Pages, Netlify, Vercel)**

```bash
# Deploy web directory
cd web
npx wrangler pages deploy . --project-name=restockr-oauth
```

**Option 2: Add to Existing Web App**

Copy `web/login.html` to your existing web app's public directory at the `/login` route.

**Option 3: Backend Redirect (Quick Fix)**

Modify backend to detect mobile user agents and redirect directly to `restockr://callback?token=...` instead of `https://restockr.app/login?token=...`.

## Testing

### Test in iOS Simulator

1. Run the Flutter app: `flutter run -d "iPhone 17 Pro"`
2. Tap "Login with Discord" button
3. Complete Discord OAuth
4. Backend redirects to `https://restockr.app/login?token=...`
5. Web page redirects to `restockr://callback?token=...`
6. App captures token and logs in

### Debug OAuth Flow

Enable debug logging to see the full flow:

```dart
print('🔐 OAuth callback URL: $result');
print('🔐 Parsed URI: scheme=${uri.scheme}, host=${uri.host}');
print('🔐 Query parameters: ${uri.queryParameters}');
```

### Test Redirect Page Locally

```bash
# Start local server
cd web
python3 -m http.server 8080

# Test redirect
open "http://localhost:8080/login.html?token=test123"
```

Should redirect to `restockr://callback?token=test123`

## Common Issues

### Issue: OAuth window doesn't close

**Cause:** Redirect page not deployed or not redirecting properly

**Fix:** Deploy `web/login.html` to `https://restockr.app/login` and verify it's accessible

### Issue: "No token received" error

**Cause:** Backend redirecting to wrong URL or token not in query parameters

**Fix:** Check backend logs to see actual redirect URL. Should be `https://restockr.app/login?token=<JWT>`

### Issue: "CANCELED" error

**Cause:** User closed OAuth window before completing

**Fix:** Normal behavior, user needs to complete OAuth flow

### Issue: Works in web but not mobile

**Cause:** Custom URL scheme not properly configured

**Fix:** Verify `Info.plist` (iOS) and `AndroidManifest.xml` (Android) have `restockr://` scheme

## Environment Variables

In `env.json`:

```json
{
  "DISCORD_GUILD_ID": "1348719595619614743",
  "RESTOCKR_API_BASE": "https://emerald-alerts-development.onrender.com"
}
```

## Backend Configuration

Backend should redirect OAuth callbacks to:

```javascript
// In API/auth.js
router.get('/discord/callback', async (req, res) => {
  const token = generateJWT(user);

  // Redirect to web page that handles mobile deep linking
  res.redirect(`${process.env.CLIENT_ORIGIN}/login?token=${token}`);
});
```

Where `CLIENT_ORIGIN=https://restockr.app`

## Security Considerations

1. **HTTPS Only:** The redirect page must be served over HTTPS
2. **Token in URL:** Tokens are briefly exposed in URL - use short expiry times
3. **Redirect Validation:** Consider adding state parameter validation
4. **Deep Link Hijacking:** Custom URL schemes can be registered by malicious apps

## Alternative: Universal Links (More Secure)

For production, consider implementing Universal Links (iOS) / App Links (Android) instead of custom URL schemes. This requires:

1. Apple App Site Association (AASA) file
2. Domain verification
3. Entitlements configuration

Benefits:
- More secure (verified domain ownership)
- Fallback to web if app not installed
- Cannot be hijacked by other apps

## Status

✅ OAuth redirect page created (`web/login.html`)
✅ iOS custom URL scheme configured
✅ Android intent filter configured
✅ Flutter OAuth implementation updated
⏳ **TODO: Deploy `web/login.html` to `https://restockr.app/login`**
⏳ TODO: Test complete OAuth flow on real device

---

**Last Updated:** October 14, 2025
**Version:** 1.0.0
