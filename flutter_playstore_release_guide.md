# Flutter Android App Professional Play Store Release Guide

A step-by-step production workflow for publishing a Flutter Android application professionally on Google Play Store.

---

# 1. Verify Flutter Environment

Check Flutter installation:

```bash
flutter doctor -v
```

Check Flutter version:

```bash
flutter --version
```

Use the stable channel:

```bash
flutter channel stable
flutter upgrade
```

Ensure:

* Flutter stable version
* Java 17 installed
* Android SDK updated
* Android Studio configured

---

# 2. Update Application Version

Open:

```
pubspec.yaml
```

Update:

```yaml
version: 1.0.0+1
```

Format:

```
versionName+versionCode
```

Example:

```
1.0.0+1
1.0.1+2
1.1.0+3
2.0.0+10
```

Rules:

* Version name is visible to users.
* Version code must always increase.
* Never reuse an uploaded version code.

Example:

```yaml
version: 1.2.0+15
```

---

# 3. Configure Android Package Name

Open:

```
android/app/build.gradle
```

Update:

```gradle
defaultConfig {
    applicationId "com.company.product"
}
```

Example:

```gradle
defaultConfig {
    applicationId "ng.com.zionai.schoolai"
    minSdkVersion 23
    targetSdkVersion 35
}
```

Important:

The package name is permanent after publishing.

Recommended format:

```
com.company.appname
```

---

# 4. Update Application Name

Open:

```
android/app/src/main/AndroidManifest.xml
```

Update:

```xml
<application
    android:label="Your App Name">
```

Example:

```xml
<application
    android:label="ZED School AI">
```

---

# 5. Configure App Icon

Install:

```bash
flutter pub add flutter_launcher_icons
```

Add to:

```
pubspec.yaml
```

```yaml
flutter_launcher_icons:
  android: true
  image_path: "assets/icon/icon.png"
```

Generate icons:

```bash
dart run flutter_launcher_icons
```

Requirements:

* PNG format
* 1024x1024 source image
* High quality

---

# 6. Create Android Release Keystore

Generate signing key:

```bash
keytool -genkey \
-v \
-keystore ~/release-key.jks \
-keyalg RSA \
-keysize 2048 \
-validity 10000 \
-alias release
```

Move the file:

```
android/app/release-key.jks
```

Keep this file secure.

Do not lose it.

---

# 7. Create key.properties

Create:

```
android/key.properties
```

Add:

```properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=release
storeFile=release-key.jks
```
e.g "D:/Program Files/Java/jdk-17/bin/keytool.exe" -genkey -v -keystore android\app\schoolai-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias schoolai

---

# 8. Configure Gradle Signing

Open:

```
android/app/build.gradle
```

Add:

```gradle
def keystoreProperties = new Properties()

def keystorePropertiesFile =
rootProject.file('key.properties')

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(
        new FileInputStream(keystorePropertiesFile)
    )
}
```

Inside android:

```gradle
signingConfigs {

    release {

        keyAlias keystoreProperties['keyAlias']

        keyPassword keystoreProperties['keyPassword']

        storeFile keystoreProperties['storeFile']
            ? file(keystoreProperties['storeFile'])
            : null

        storePassword keystoreProperties['storePassword']
    }
}
```

Configure release:

```gradle
buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

---
# 9. Protect Signing Files

Add to:

```
.gitignore
```

```text
*.jks
*.keystore
key.properties
```

Never upload:

```
release-key.jks
```

---

# 10. Review Android Permissions

Open:

```
android/app/src/main/AndroidManifest.xml
```

Remove unnecessary permissions.

Example:

Do not keep:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
```

unless your app uses camera features.

---

# 11. Create Privacy Policy

Create a public page:

Example:

```
https://yourdomain.com/privacy-policy
```
Include:

* Data collected
* Why data is collected
* Third-party services
* User rights
* Contact information
* Account deletion process

Required for:

* User accounts
* Analytics
* Ads
* AI services

---
# 12. Implement Account Deletion
If users can create accounts, provide:

Inside app:
```
Settings
    |
Delete Account
```

Also provide:
```
https://yourdomain.com/delete-account
```

---
# 13. Complete Google Play Data Safety

Google Play Console:

```
App Content
    |
Data Safety
```

Declare:

* Personal data
* Device information
* Analytics
* Advertising ID
* User generated content

Information must match your actual app behavior.

---

# 14. Enable Play App Signing

Google Play Console:

```
Setup
 |
App Integrity
 |
Play App Signing
```

Recommended:

```
Use Google-managed signing key
```

---

# 15. Clean Flutter Project

Run:

```bash
flutter clean
```

Get dependencies:

```bash
flutter pub get
```

Analyze:

```bash
flutter analyze
```

Test:

```bash
flutter test
```

---

# 16. Build Release Bundle

Google Play requires:

```
.aab
```

Build:

```bash
flutter build appbundle --release
```

Generated file:

```
build/app/outputs/bundle/release/app-release.aab
```

---

# 17. Test Release Build

Create APK:

```bash
flutter build apk --release
```

Install:

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

Test:

* Login
* Registration
* API calls
* Notifications
* Payments
* Ads
* Offline mode
* AI features

---

# 18. Create Google Play Console Application

Open:

https://play.google.com/console

Create:

```
Create App
```

Provide:

* App name
* Default language
* App category
* Free/Paid selection

---

# 19. Prepare Store Listing

Required:

## App Icon

```
512x512 PNG
```

## Feature Graphic

```
1024x500
```

## Screenshots

Minimum:

```
2 screenshots
```

Recommended:

```
5-8 screenshots
```

Prepare:

* Short description
* Full description
* App category
* Contact details

---

# 20. Configure Testing Tracks

Do not publish directly.

Use:

## Internal Testing

For:

* Developers
* QA team

Upload:

```
app-release.aab
```

Then:

## Closed Testing

For:

* Beta users
* Customers
* Schools

Then:

## Production Release

After testing.

---

# 21. Release Commands Cheat Sheet

## Run App

```bash
flutter run
```

## Analyze Code

```bash
flutter analyze
```

## Run Tests

```bash
flutter test
```

## Clean Build

```bash
flutter clean
flutter pub get
```

## Build APK

```bash
flutter build apk --release
```

## Build Play Store Bundle

```bash
flutter build appbundle --release
```

---

# 22. Professional Release Workflow

Recommended:

```
Developer
    |
    |
Git Commit
    |
    |
Release Tag
    |
    |
CI/CD Build
    |
    |
Generate AAB
    |
    |
Internal Testing
    |
    |
Closed Testing
    |
    |
Production Release
```

Create release tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

---

# 23. Final Google Play Compliance Checklist

Before publishing:

* [ ] Flutter build successful
* [ ] App signed correctly
* [ ] Version increased
* [ ] Target SDK updated
* [ ] Privacy policy available
* [ ] Data Safety completed
* [ ] Content rating completed
* [ ] Ads declaration completed
* [ ] Account deletion implemented
* [ ] Screenshots uploaded
* [ ] Store description completed
* [ ] Internal testing completed
* [ ] AAB uploaded

---

# 24. Special Compliance for Education/AI Apps

For student applications:

Pay attention to:

* Google Play Families Policy
* Child-directed ads settings
* AI-generated content disclosure
* User privacy
* Student data protection
* Account deletion
* Parental controls where applicable

---

# Production Stack Recommendation

```
Flutter App

        |
        |

Google Play App Signing

        |
        |

Firebase Crashlytics

        |
        |

Firebase Analytics

        |
        |

CI/CD Pipeline

        |
        |

Google Play Console Release
```

---

End of Document
