# Setup Guide

## 1. Create a release keystore
```bash
./scripts/generate-keystore.sh release.jks
```
Copy the printed base64 string. Back up `release.jks` somewhere safe and never commit it.

## 2. Create a Firebase service account
1. Firebase Console → Project settings → **Service accounts** (Google Cloud IAM).
2. Create a service account with the **Firebase App Distribution Admin** role.
3. Create a JSON key and keep the file contents for the secret below.
4. In Firebase → App Distribution, create a tester group named `testers` (or change `groups:` in the workflow).
5. Copy your **App ID** (Project settings → General → Your apps, format `1:123:android:abc`).

## 3. Add GitHub repository secrets
Settings → Secrets and variables → Actions → New repository secret:

| Secret | Value |
|---|---|
| `KEYSTORE_BASE64` | base64 of your `.jks` |
| `KEYSTORE_PASSWORD` | keystore password |
| `KEY_ALIAS` | key alias (e.g. `upload`) |
| `KEY_PASSWORD` | key password |
| `FIREBASE_APP_ID` | Firebase Android app ID |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | full contents of the service-account JSON |

## 4. Android: read signing values from the environment
In `app/build.gradle.kts`:

```kotlin
android {
    defaultConfig {
        versionCode = (project.findProperty("versionCode") as String?)?.toInt() ?: 1
        versionName = (project.findProperty("versionName") as String?) ?: "1.0.0"
    }

    signingConfigs {
        create("release") {
            val path = System.getenv("KEYSTORE_PATH")
            if (path != null) {
                storeFile = file(path)
                storePassword = System.getenv("KEYSTORE_PASSWORD")
                keyAlias = System.getenv("KEY_ALIAS")
                keyPassword = System.getenv("KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

## 5. Flutter: read signing values from key.properties
In `android/app/build.gradle.kts` (adjust for Groovy if needed):

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }
    buildTypes {
        release { signingConfig = signingConfigs.getByName("release") }
    }
}
```

## 6. Ship a build
```bash
git tag v1.0.0
git push origin v1.0.0
```
The release workflow builds the signed APK/AAB, sends the APK to Firebase testers, and attaches both files to a GitHub Release.

## Troubleshooting
- **Keystore was tampered with / wrong password**: re-check secrets; no trailing newline in the base64 value.
- **Firebase 403**: the service account needs the App Distribution Admin role.
- **`gradlew: Permission denied`**: workflows run `chmod +x`, but also commit the file as executable (`git update-index --chmod=+x gradlew`).
