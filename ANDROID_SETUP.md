# Android Platform Setup Guide

This document provides instructions for adding Android platform support and implementing native SMS reading functionality for the Bank Import feature.

## Prerequisites

- Flutter SDK installed
- Android Studio or Android SDK installed
- Java/Kotlin development environment set up

## Step 1: Add Android Platform

Run the following command in the project root:

```bash
flutter create --platforms=android .
```

This will generate the `android/` directory with all necessary Android project files.

## Step 2: Configure Android Permissions

Add SMS permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Existing permissions -->

    <!-- SMS Permissions for Bank Import Feature -->
    <uses-permission android:name="android.permission.READ_SMS" />
    <uses-permission android:name="android.permission.RECEIVE_SMS" />

    <application>
        <!-- Your existing application configuration -->
    </application>
</manifest>
```

## Step 3: Implement SMS Platform Channel (Optional)

The app uses `flutter_sms_inbox` package for SMS reading, which works out of the box. However, for enhanced performance and custom functionality, you can implement a native platform channel.

### Create SMS Reader Helper (Optional Enhancement)

Create `android/app/src/main/kotlin/com/spendex/app/SmsReader.kt`:

```kotlin
package com.spendex.app

import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.provider.Telephony

class SmsReader(private val context: Context) {

    fun readMessages(startDate: Long, endDate: Long, addresses: List<String>?): List<Map<String, Any>> {
        val messages = mutableListOf<Map<String, Any>>()
        val uri = Telephony.Sms.CONTENT_URI

        // Build selection query
        var selection = "${Telephony.Sms.DATE} >= ? AND ${Telephony.Sms.DATE} <= ?"
        val selectionArgs = mutableListOf(startDate.toString(), endDate.toString())

        if (!addresses.isNullOrEmpty()) {
            val addressPlaceholders = addresses.joinToString(",") { "?" }
            selection += " AND ${Telephony.Sms.ADDRESS} IN ($addressPlaceholders)"
            selectionArgs.addAll(addresses)
        }

        val cursor: Cursor? = context.contentResolver.query(
            uri,
            arrayOf(
                Telephony.Sms._ID,
                Telephony.Sms.ADDRESS,
                Telephony.Sms.BODY,
                Telephony.Sms.DATE,
                Telephony.Sms.READ
            ),
            selection,
            selectionArgs.toTypedArray(),
            "${Telephony.Sms.DATE} DESC"
        )

        cursor?.use {
            val idIndex = it.getColumnIndex(Telephony.Sms._ID)
            val addressIndex = it.getColumnIndex(Telephony.Sms.ADDRESS)
            val bodyIndex = it.getColumnIndex(Telephony.Sms.BODY)
            val dateIndex = it.getColumnIndex(Telephony.Sms.DATE)
            val readIndex = it.getColumnIndex(Telephony.Sms.READ)

            while (it.moveToNext()) {
                val message = mapOf(
                    "id" to it.getString(idIndex),
                    "address" to it.getString(addressIndex),
                    "body" to it.getString(bodyIndex),
                    "date" to it.getLong(dateIndex),
                    "read" to (it.getInt(readIndex) == 1)
                )
                messages.add(message)
            }
        }

        return messages
    }
}
```

### Update MainActivity (Optional Enhancement)

Modify `android/app/src/main/kotlin/com/spendex/app/MainActivity.kt`:

```kotlin
package com.spendex.app

import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.spendex/sms"
    private val SMS_PERMISSION_REQUEST_CODE = 100
    private lateinit var smsReader: SmsReader
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        smsReader = SmsReader(applicationContext)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isSupported" -> {
                    result.success(true)
                }
                "hasPermission" -> {
                    val hasPermission = ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.READ_SMS
                    ) == PackageManager.PERMISSION_GRANTED
                    result.success(hasPermission)
                }
                "requestPermission" -> {
                    pendingResult = result
                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(Manifest.permission.READ_SMS),
                        SMS_PERMISSION_REQUEST_CODE
                    )
                }
                "readSmsMessages" -> {
                    if (ContextCompat.checkSelfPermission(
                            this,
                            Manifest.permission.READ_SMS
                        ) != PackageManager.PERMISSION_GRANTED
                    ) {
                        result.error("PERMISSION_DENIED", "SMS read permission not granted", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val startDate = call.argument<Long>("startDate") ?: 0L
                        val endDate = call.argument<Long>("endDate") ?: System.currentTimeMillis()
                        val addresses = call.argument<List<String>>("addresses")

                        val messages = smsReader.readMessages(startDate, endDate, addresses)
                        result.success(messages)
                    } catch (e: Exception) {
                        result.error("SMS_READ_ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == SMS_PERMISSION_REQUEST_CODE) {
            val granted = grantResults.isNotEmpty() &&
                         grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingResult?.success(granted)
            pendingResult = null
        }
    }
}
```

## Step 4: Update Gradle Configuration

Ensure `android/app/build.gradle` has the correct configuration:

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.spendex.app"
        minSdkVersion 23  // Minimum for SMS reading
        targetSdkVersion 34
        // ... other configurations
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }
}
```

## Step 5: Test on Android Device

1. Build the app:
   ```bash
   flutter build apk --debug
   ```

2. Install on Android device:
   ```bash
   flutter install
   ```

3. Test SMS import feature:
   - Navigate to Settings → Bank Import → SMS Parser
   - Grant SMS permission when prompted
   - Select date range and banks to filter
   - Verify SMS messages are read and parsed correctly

## Important Notes

- **Privacy**: SMS reading requires sensitive permissions. Handle user data responsibly.
- **Runtime Permissions**: Android 6.0+ requires runtime permission requests.
- **Background Access**: Android 10+ restricts background SMS access.
- **Play Store**: Apps reading SMS require additional verification for Play Store submission.

## Fallback: Using flutter_sms_inbox Package

The app currently uses `flutter_sms_inbox` package which handles SMS reading without custom platform channels. This is the recommended approach for most use cases as it:

- Works out of the box without native code
- Handles permissions automatically
- Supports both Android and iOS (where applicable)
- Maintains compatibility across Android versions

The native platform channel implementation above is **optional** and only needed for:
- Custom SMS filtering logic
- Performance optimization for large SMS databases
- Advanced SMS operations beyond reading

## Current Status

✅ **Windows Platform**: Fully functional
⚠️ **Android Platform**: Not yet added to project
📱 **SMS Feature**: Ready to use once Android platform is added

To add Android support, run:
```bash
flutter create --platforms=android .
flutter pub get
```

After adding Android platform, the SMS parser feature will work automatically using the `flutter_sms_inbox` package.
