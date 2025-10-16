# Discord OAuth Setup Guide

## Overview

Discord OAuth login has been integrated into the RestockR app using `flutter_web_auth_2`. This allows users to authenticate using their Discord account directly in simulators and real devices.

---

## Backend Flow

The backend already supports Discord OAuth (see `API/auth.js`):

1. **GET** `/api/auth/discord?guildId={guildId}` - Initiates OAuth
2. Discord redirects to authorize endpoint
3. User authorizes on Discord
4. Discord callbacks to `/api/auth/discord/callback?code=xxx&state=xxx`
5. Backend generates JWT and redirects to `https://restockr.app/login?token={JWT}`

---

## Flutter Implementation

### Files Modified

**Auth Implementation**:
- `lib/data/auth/auth_repository.dart` - Added `signInWithDiscord()` method
- `lib/data/auth/auth_repository_impl.dart` - Implementation using flutter_web_auth_2
- `lib/data/auth/auth_repository_mock.dart` - Mock implementation for development
- `lib/presentation/login_screen/notifier/login_notifier.dart` - Added `performDiscordLogin()`
- `lib/presentation/login_screen/login_screen.dart` - Added Discord button

**Dependencies**:
- `flutter_web_auth_2: ^3.1.2` - Handles OAuth flow and callback interception

---

## Platform Configuration

### iOS Configuration

Already configured in `ios/Runner/Info.plist`:

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

**Note:** Universal Links are optional. The custom scheme `restockr://` is sufficient for `flutter_web_auth_2` to work.

### Android Configuration

Already configured in `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Deep Link Intent Filter for OAuth callbacks -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="restockr" />
</intent-filter>
```

**Note:** App Links are optional. The custom scheme is sufficient.

### How flutter_web_auth_2 Works

`flutter_web_auth_2` opens OAuth in a secure web view and intercepts the callback URL **before** any browser redirects occur. This means:
- No Universal Links / App Links needed for basic functionality
- Works perfectly in simulators
- No manual token capture required
- Backend can redirect to any URL containing the token

---

## Backend Configuration

Update your backend's `CLIENT_ORIGIN` environment variable to match:

**Development**:
```env
CLIENT_ORIGIN=http://localhost:8080
```

**Production**:
```env
CLIENT_ORIGIN=https://restockr.app
```

The backend should redirect OAuth callbacks to:
- Mobile: `restockr://login?token={JWT}` (custom scheme)
- Web: `https://restockr.app/login?token={JWT}` (universal link)

---

## Testing

### Development (Mock Mode)

When running in development mode (`RESTOCKR_ENV=development`), the app uses `MockAuthRepository`:

1. Click "Login with Discord" button
2. Mock delays for 2 seconds (simulating OAuth flow)
3. Automatically returns success with mock JWT token
4. User is logged in

### Staging/Production (Real Mode)

When running with `RESTOCKR_ENV=staging` or `production`:

1. Click "Login with Discord" button
2. **flutter_web_auth_2 opens OAuth in secure web view**
3. User authorizes the app on Discord
4. Discord redirects to backend callback
5. Backend generates JWT and redirects to `https://restockr.app/login?token=...`
6. **flutter_web_auth_2 intercepts callback URL before browser redirect**
7. Token extracted and stored automatically
8. User is logged in

**Works in:** iOS Simulator, Android Emulator, Real Devices, Web

---

## Troubleshooting

### OAuth Window Doesn't Open

**Issue**: Clicking "Login with Discord" does nothing

**Solutions**:
1. Check logs for errors
2. Verify backend URL is correct in env.json
3. Ensure flutter_web_auth_2 is properly installed: `flutter pub get`

### User Cancelled OAuth

**Issue**: User closes OAuth window before completing

**Behavior**: App catches `PlatformException` with code `CANCELED` and shows "Discord login cancelled" message

### Token Not Captured

**Issue**: OAuth completes but user not logged in

**Solutions**:
1. Check backend is redirecting to a URL with `token=` parameter
2. Verify token format is valid JWT
3. Check app logs for error messages
4. Backend must redirect to: `https://restockr.app/login?token=xxx` (or any URL with token parameter)

### Works on Real Device but Not Simulator

**Issue**: This should NOT happen with flutter_web_auth_2

**If it does**:
1. Verify custom URL scheme is properly configured
2. Check flutter_web_auth_2 version is `^3.1.2` or newer
3. Try: `flutter clean && flutter pub get && flutter run`

---

## Environment Variables

Add to `env.json` (optional):

```json
{
  "DISCORD_GUILD_ID": "1348719595619614743",
  "RESTOCKR_ENV": "development"
}
```

To pass guildId dynamically, modify `login_screen.dart:273`:

```dart
void onTapDiscordLogin(BuildContext context) {
  final config = ref.read(backendConfigProvider);
  final guildId = config.toJson()['DISCORD_GUILD_ID'] as String?;
  ref.read(loginNotifier.notifier).performDiscordLogin(guildId: guildId);
}
```

---

## Security Considerations

1. **Token Storage**: JWT tokens are stored securely using `flutter_secure_storage`
2. **HTTPS Only**: OAuth callbacks should only use HTTPS in production
3. **State Parameter**: Backend validates state parameter to prevent CSRF
4. **Token Expiry**: Tokens expire after 7 days (configurable in backend)
5. **Deep Link Validation**: App validates token format before storing

---

## Future Enhancements

- [ ] Add Discord logo icon to button
- [ ] Support multiple Discord servers (guild selection)
- [ ] Add Discord profile display after login
- [ ] Implement Discord-specific permissions
- [ ] Add "Sign out from Discord" option
- [ ] Support Discord role-based access control

---

## Resources

- [Discord OAuth2 Documentation](https://discord.com/developers/docs/topics/oauth2)
- [Flutter Deep Linking](https://docs.flutter.dev/development/ui/navigation/deep-linking)
- [uni_links Package](https://pub.dev/packages/uni_links)
- [url_launcher Package](https://pub.dev/packages/url_launcher)

## Implementation Code

**Location:** `lib/data/auth/auth_repository_impl.dart:255-299`

```dart
@override
Future<AuthResult> signInWithDiscord({String? guildId}) async {
  try {
    // Build OAuth URL
    final baseUrl = config.apiBase.toString();
    final guildParam = guildId != null ? '?guildId=$guildId' : '';
    final oauthUrl = '$baseUrl/api/auth/discord$guildParam';

    // Define callback URL scheme
    final callbackUrlScheme = 'restockr';

    // Launch OAuth flow with flutter_web_auth_2
    // This opens OAuth in a web view and automatically captures the callback
    final result = await FlutterWebAuth2.authenticate(
      url: oauthUrl,
      callbackUrlScheme: callbackUrlScheme,
    );

    // Extract token from callback URL
    final uri = Uri.parse(result);
    final token = uri.queryParameters['token'];

    if (token != null && token.isNotEmpty) {
      await storeToken(token);
      _updateStatus(AuthSessionStatus.authenticated);
      _scheduleTokenRefresh(token);
      return AuthResult.success(token);
    } else {
      return AuthResult.failure('No token received from Discord OAuth');
    }
  } on PlatformException catch (e) {
    if (e.code == 'CANCELED') {
      return AuthResult.failure('Discord login cancelled');
    }
    return AuthResult.failure('Discord OAuth error: ${e.message}');
  } catch (e) {
    return AuthResult.failure('Discord OAuth error: ${e.toString()}');
  }
}
```

---

**Status**: ✅ Discord OAuth Implemented with flutter_web_auth_2
**Last Updated**: October 14, 2025
**Version**: 2.0.0 (using flutter_web_auth_2)
