# Real OAuth Testing Workflow

**The simplest way to test Discord OAuth with real backend authentication in simulators.**

---

## The Problem

Simulators can't directly receive OAuth callbacks from the browser because:
- Browser redirects to `https://restockr.app/login?token=xxx`
- Simulator app doesn't intercept HTTPS URLs (only custom schemes like `restockr://`)
- Browser shows error page or keeps the URL

## The Solution

**Capture the JWT token from your browser and manually inject it into the simulator.**

---

## Step-by-Step Workflow

### 1. Start Your App

```bash
./start.sh
# Choose iOS Simulator or Android Emulator
```

**Wait for app to fully launch** (you should see the login screen)

---

### 2. Run the Capture Tool

```bash
./capture_token.sh
```

The tool will show instructions and wait for your input.

---

### 3. Open Discord OAuth in Browser

**On your Mac** (not in simulator), open:

**Staging Backend**:
```
https://emerald-alerts-development.onrender.com/api/auth/discord
```

**Local Backend** (if running locally):
```
http://localhost:3000/api/auth/discord
```

**With Guild ID** (optional):
```
https://emerald-alerts-development.onrender.com/api/auth/discord?guildId=1348719595619614743
```

---

### 4. Complete Discord Authorization

- Log in to Discord (if not already)
- Click "Authorize" to grant RestockR access
- Wait for redirect...

---

### 5. Capture the Callback URL

After authorization, Discord redirects to:

```
https://restockr.app/login?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4YmI4OD...
```

**The page might show an error** (that's OK! We just need the URL)

**Copy the ENTIRE URL** from your browser's address bar:
- Chrome: Click address bar, Cmd+A, Cmd+C
- Safari: Click address bar, Cmd+A, Cmd+C
- Firefox: Click address bar, Cmd+A, Cmd+C

---

### 6. Paste into the Script

Go back to your terminal where `./capture_token.sh` is running.

**Paste the URL** when prompted:

```
Paste the callback URL (or just the JWT token):
https://restockr.app/login?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Or just paste the token part:
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4YmI4OD...
```

Press Enter.

---

### 7. Select Platform

```
Select platform to inject token:
  [1] iOS Simulator
  [2] Android Emulator
  [3] Both
  [4] Cancel

Select option: 1
```

---

### 8. Watch the Magic ✨

```
✓ Token captured: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
✓ Found booted simulator: iPhone 15 Pro
✓ Injecting token into app...
✓ Token injected successfully!
✓ Check the app - you should be logged in!
```

**Switch to your simulator** - you should be logged in and on the monitor screen! 🎉

---

## Visual Workflow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Start App in Simulator                                   │
│    $ ./start.sh                                             │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Run Capture Tool                                         │
│    $ ./capture_token.sh                                     │
│    [Waiting for input...]                                   │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Open Browser (on your Mac)                               │
│    Visit: https://.../api/auth/discord                      │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Complete Discord OAuth                                   │
│    - Log in to Discord                                      │
│    - Authorize RestockR                                     │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. Browser Redirects                                        │
│    URL: https://restockr.app/login?token=eyJhbGc...        │
│    (Page might show error - that's OK!)                     │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. Copy URL from Browser                                    │
│    Cmd+L, Cmd+A, Cmd+C                                      │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. Paste into Terminal                                      │
│    [Script extracts token automatically]                    │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ 8. Select Platform & Inject                                 │
│    [1] iOS Simulator → xcrun simctl openurl...             │
│    [2] Android Emulator → adb shell am start...             │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ 9. App Opens with Token                                     │
│    ✓ Token captured via deep link                          │
│    ✓ Stored securely                                       │
│    ✓ User logged in                                        │
│    ✓ Navigated to monitor screen                           │
└─────────────────────────────────────────────────────────────┘
```

---

## Why This Works Better

### ❌ Traditional Approach (Doesn't Work in Simulator)
1. App opens browser for OAuth
2. User authorizes on Discord
3. Backend redirects to `https://restockr.app/login?token=xxx`
4. **PROBLEM**: Simulator can't intercept HTTPS URLs
5. Browser shows error page
6. App never receives token

### ✅ Capture & Inject Approach (Works Perfectly)
1. Browser OAuth happens on your Mac
2. You capture the token from the redirect URL
3. Script triggers deep link: `restockr://login?token=xxx`
4. Simulator opens app with deep link
5. App receives token and logs in

---

## Pro Tips

### Tip 1: Keep the Token for Multiple Tests

After capturing a token once, you can reuse it:

```bash
# Save token to file
echo "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." > ~/.restockr_token

# Inject saved token later
./capture_token.sh
# Paste from: cat ~/.restockr_token
```

### Tip 2: Create a Bookmark

Bookmark this URL for quick OAuth:
```
https://emerald-alerts-development.onrender.com/api/auth/discord?guildId=1348719595619614743
```

### Tip 3: Use Both Simulators

Test on both platforms with one OAuth flow:

```bash
./capture_token.sh
# Complete OAuth, paste URL
# Select [3] Both
# Token injected into iOS AND Android simultaneously!
```

### Tip 4: Quick Re-injection

If you already have a token, use the manual method:

```bash
# iOS
xcrun simctl openurl booted "restockr://login?token=YOUR_TOKEN"

# Android
adb shell am start -a android.intent.action.VIEW -d "restockr://login?token=YOUR_TOKEN"
```

---

## Troubleshooting

### "No simulator is currently booted"

**Solution**: Start your simulator first
```bash
./start.sh
# Choose iOS Simulator
```

### "Token doesn't look like a valid JWT"

**Check format**: JWT has 3 parts separated by dots
```
header.payload.signature
```

**If you see HTML instead of JWT**: Your backend might be down or the redirect URL is wrong.

### "App doesn't open after injection"

**Check**:
1. Is the app running in simulator?
2. Is the deep link configured? (It should be after the changes we made)
3. Try rebuilding: `flutter clean && flutter run`

### "Token expired" error in app

**Solution**: JWT tokens expire (usually 7 days). Capture a fresh token:
```bash
./capture_token.sh
# Complete OAuth again to get new token
```

---

## Advanced: Automated Testing Script

For repeated testing, create a helper script:

```bash
#!/bin/bash
# test_real_oauth.sh

# Backend URL
BACKEND="https://emerald-alerts-development.onrender.com"

echo "Opening Discord OAuth..."
open "${BACKEND}/api/auth/discord"

echo ""
echo "After authorizing, paste the callback URL:"
read -r url

# Extract token
token=$(echo "$url" | grep -oP 'token=\K[^&]+')

if [ -n "$token" ]; then
  echo "Injecting token..."
  xcrun simctl openurl booted "restockr://login?token=${token}"
  echo "✓ Done!"
else
  echo "✗ Could not extract token"
fi
```

---

## Summary

**One-time setup**: ✅ Already done (deep links configured)

**Every test**:
1. `./start.sh` → Start app
2. `./capture_token.sh` → Run tool
3. Open browser → Complete OAuth
4. Copy URL → Paste into terminal
5. ✓ Logged in!

**Time per test**: ~30 seconds

**Benefits**:
- Real backend authentication
- Real JWT tokens
- Real user profiles
- No mock data
- No backend configuration changes
- Works with local, staging, or production backends

---

**This is the recommended workflow for Discord OAuth testing in simulators! 🚀**
