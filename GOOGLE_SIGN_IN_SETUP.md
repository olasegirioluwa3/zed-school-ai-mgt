# Google Sign-In Setup Guide

This guide provides the necessary platform setup instructions for implementing Google Sign-In in your Flutter application.

## Android Setup

### 1. Update `android/app/build.gradle.kts`

Ensure your `android/app/build.gradle.kts` file has the following configuration:

```kotlin
android {
    ...
    defaultConfig {
        ...
        minSdk = flutter.minSdkVersion  // Ensure this is at least 21
        ...
    }
}

dependencies {
    // Google Play Services for Google Sign-In
    implementation("com.google.android.gms:play-services-auth:20.7.0")
}
```

**Note:** This project uses Kotlin DSL (build.gradle.kts) instead of Groovy. The Google Play Services dependency has already been added to your build.gradle.kts file.

### 2. Get SHA-1 and SHA-256 Fingerprints

You need to add your app's SHA fingerprints to the Google Cloud Console. Run the following commands in your project directory:

**For Debug SHA-1 and SHA-256 (Windows):**
```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**For Debug SHA-1 and SHA-256 (Mac/Linux):**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**For Release SHA-1 and SHA-256 (when ready for production):**
```bash
keytool -list -v -keystore <path-to-your-release-keystore> -alias <your-alias>
```

The output will show both SHA-1 and SHA-256 fingerprints. Copy both values.

### 3. Add Fingerprints to Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Navigate to: **APIs & Services** → **Credentials**
4. Find your OAuth 2.0 Client ID for Android
5. Click the edit (pencil) icon
6. Add your package name: `ng.com.zionai.schoolai`
7. Add the SHA-1 fingerprint from step 2
8. Add the SHA-256 fingerprint from step 2
9. Save the changes

### 4. Verify Android Package Name

Check your `android/app/build.gradle.kts` for the correct application ID:
```kotlin
defaultConfig {
    applicationId = "ng.com.zionai.schoolai"  // This must match what you add in Google Cloud Console
    ...
}
```

**Note:** Your current package name is `ng.com.zionai.schoolai`. Use this exact package name in Google Cloud Console.

## iOS Setup

### 1. Add Bundle ID to Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Navigate to: **APIs & Services** → **Credentials**
4. Find your OAuth 2.0 Client ID for iOS
5. Click the edit (pencil) icon
6. Add your iOS Bundle ID: `ng.com.zionai.schoolai`
7. Save the changes

### 2. Update `ios/Runner/Info.plist`

The URL scheme configuration has been added to your `ios/Runner/Info.plist` file. You need to update the REVERSED_CLIENT_ID with your actual value from Google Cloud Console:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- REPLACE THIS with your actual REVERSED_CLIENT_ID from Google Cloud Console -->
            <string>com.googleusercontent.apps.852974895524-mog1f8v0uc01mfe1ovscnmbs076fgh3e</string>
        </array>
    </dict>
</array>
```

**To find your REVERSED_CLIENT_ID:**
1. Go to Google Cloud Console → Credentials
2. Find your iOS OAuth 2.0 Client ID
3. The "iOS URL scheme" is your REVERSED_CLIENT_ID
4. It should look like: `com.googleusercontent.apps.YOUR_CLIENT_ID`
5. Replace the placeholder in Info.plist with your actual REVERSED_CLIENT_ID

### 3. Verify iOS Bundle ID

Check your `ios/Runner.xcodeproj/project.pbxproj` for the correct Bundle ID:
```
PRODUCT_BUNDLE_IDENTIFIER = ng.com.zionai.schoolai;
```

**Note:** Your current iOS Bundle ID is `ng.com.zionai.schoolai`. Use this exact Bundle ID in Google Cloud Console. The Info.plist uses `$(PRODUCT_BUNDLE_IDENTIFIER)` which resolves to this value.

## Important Configuration Notes

### Web Client ID Configuration

The Flutter implementation uses the **Web Client ID** as the `serverClientId` parameter. This is crucial for generating the `idToken` on both Android and iOS:

```dart
GoogleSignIn(
  scopes: ['email', 'profile'],
  serverClientId: '852974895524-mog1f8v0uc01mfe1ovscnmbs076fgh3e.apps.googleusercontent.com',
)
```

This Web Client ID must be configured in your Google Cloud Console and should match the one your backend expects for token validation.

## Testing

### Android Testing
1. Ensure you have Google Play Services installed on your test device/emulator
2. The device/emulator must have a Google account added
3. Run the app and test the "Continue with Google" button

### iOS Testing
1. Ensure you have a valid Apple Developer account (or use the iOS Simulator)
2. The simulator must have Google accounts configured
3. Run the app and test the "Continue with Google" button

## Troubleshooting

### Common Issues

**Issue: "Network error" or "Failed host lookup"**
- Check your internet connection
- Verify the API endpoint URL in `api_config.dart`

**Issue: "Google Sign-In was cancelled"**
- User closed the Google Sign-In dialog (this is normal behavior)
- No action needed

**Issue: "idToken is empty"**
- Ensure `serverClientId` is set to the Web Client ID
- Verify your SHA fingerprints are correctly added to Google Cloud Console
- Check that your package name/bundle ID matches the Google Cloud Console configuration

**Issue: "API key not authorized"**
- Verify your Google Cloud Console project has the correct OAuth consent screen configured
- Ensure the necessary APIs are enabled (Google Sign-In API)

## Backend Integration

The Flutter app sends Google credentials to your backend at:
- **Endpoint**: `POST https://zed.api.zionai.com.ng/api/v2/auth/google`
- **Request Body**:
  ```json
  {
    "idToken": "<GOOGLE_ID_TOKEN>",
    "accessToken": "<GOOGLE_ACCESS_TOKEN>"
  }
  ```

The backend should validate these tokens using the Web Client ID and return your application's JWT token.

## Security Notes

1. **Never commit your keystore files** to version control
2. **Use different signing configurations** for debug and release builds
3. **Keep your Google Cloud Console credentials** secure
4. **Use secure storage** (flutter_secure_storage) for storing authentication tokens
5. **Implement proper token refresh** logic on the backend

## Additional Resources

- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Firebase Authentication](https://firebase.google.com/docs/auth) (alternative approach)
