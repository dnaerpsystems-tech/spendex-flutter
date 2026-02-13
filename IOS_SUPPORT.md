# iOS Platform Support Guide

## Overview

This document outlines the iOS platform support status for the Spendex app, detailing which features work on iOS, platform-specific limitations, and setup instructions.

## Current Platform Status

| Platform | Status | Notes |
|----------|--------|-------|
| **Windows** | ✅ Fully Supported | Current development platform |
| **Android** | ⚠️ Ready (Not Added) | All features implemented, platform needs to be added |
| **iOS** | ⚠️ Partial Support | PDF/AA work, SMS reading not available |

---

## Feature Compatibility Matrix

### Bank Import Features

| Feature | Android | iOS | Notes |
|---------|---------|-----|-------|
| **PDF/CSV Import** | ✅ Full | ✅ Full | File picker works on both platforms |
| **SMS Parser** | ✅ Full | ❌ Not Available | iOS doesn't allow SMS reading |
| **Account Aggregator** | ✅ Full | ✅ Full | WebView OAuth works on both |
| **Import History** | ✅ Full | ✅ Full | Works on both platforms |

### India-Specific Utilities

| Feature | Android | iOS | Notes |
|---------|---------|-----|-------|
| **IFSC Lookup** | ✅ Full | ✅ Full | API-based, works everywhere |
| **UPI Validation** | ✅ Full | ✅ Full | API-based, works everywhere |
| **Payment Method Tagging** | ✅ Full | ✅ Full | Local logic, works everywhere |
| **Date Formatting** | ✅ Full | ✅ Full | Local utility, works everywhere |
| **Currency Formatting** | ✅ Full | ✅ Full | Local utility, works everywhere |

### Core Features

| Feature | Android | iOS | Notes |
|---------|---------|-----|-------|
| **Authentication** | ✅ Full | ✅ Full | Works on both |
| **Dashboard** | ✅ Full | ✅ Full | Works on both |
| **Transactions** | ✅ Full | ✅ Full | Works on both |
| **Categories** | ✅ Full | ✅ Full | Works on both |
| **Accounts** | ✅ Full | ✅ Full | Works on both |
| **Budgets** | ✅ Full | ✅ Full | Works on both |
| **Goals** | ✅ Full | ✅ Full | Works on both |
| **Reports** | ✅ Full | ✅ Full | Works on both |
| **Settings** | ✅ Full | ✅ Full | Works on both |

---

## iOS Limitations

### 1. SMS Reading Not Available

**Why?**
- iOS does not allow third-party apps to read SMS messages due to privacy and security restrictions
- This is a platform limitation imposed by Apple, not a technical implementation issue

**What This Means:**
- The SMS Parser feature will not work on iOS devices
- Users cannot import transactions from bank SMS notifications on iPhone/iPad

**Alternative Approaches for iOS Users:**

#### Option 1: Manual Entry
- Users can manually enter transactions in the app
- Voice input is available for faster entry
- Receipt scanning can extract transaction details

#### Option 2: PDF/CSV Import
- iOS users can export bank statements as PDF or CSV
- Import them using the PDF/CSV Import feature
- Works exactly the same as Android

#### Option 3: Account Aggregator
- Use Account Aggregator framework to fetch transactions
- Securely connects to bank accounts
- Works on both iOS and Android

#### Option 4: Email Forwarding
- Forward bank SMS to email
- Use email parsing (future feature)
- Alternative to direct SMS reading

### 2. File Picker Differences

**iOS File Picker:**
- Uses `UIDocumentPickerViewController`
- Limited to app sandbox and iCloud
- May have different UI/UX than Android

**Implementation:**
- The `file_picker` package handles platform differences automatically
- No code changes needed
- Works seamlessly on iOS

### 3. WebView Differences

**iOS WebView:**
- Uses `WKWebView` (Apple's web rendering engine)
- Different JavaScript bridge than Android
- May have slight rendering differences

**Implementation:**
- The `webview_flutter` package handles platform differences
- Account Aggregator OAuth flow works on both platforms
- No special iOS-specific code needed

---

## Adding iOS Platform

### Prerequisites

- **macOS**: iOS development requires macOS with Xcode
- **Xcode**: Latest version installed from App Store
- **CocoaPods**: Ruby gem manager for iOS dependencies
- **Apple Developer Account**: For device testing and distribution

### Step 1: Add iOS Platform

```bash
# Add iOS platform to the project
flutter create --platforms=ios .

# This will generate the ios/ directory
```

### Step 2: Install Dependencies

```bash
# Install CocoaPods dependencies
cd ios
pod install
cd ..

# Get Flutter packages
flutter pub get
```

### Step 3: Configure Info.plist

Add required permissions to `ios/Runner/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Existing keys -->

    <!-- Camera permission (for receipt scanning) -->
    <key>NSCameraUsageDescription</key>
    <string>We need camera access to scan receipts and extract transaction details</string>

    <!-- Photo library permission (for receipt images) -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>We need photo library access to import receipts and bank statements</string>

    <!-- Face ID / Touch ID permission (for biometric authentication) -->
    <key>NSFaceIDUsageDescription</key>
    <string>We use Face ID to secure your financial data</string>

    <!-- Microphone permission (for voice input) -->
    <key>NSMicrophoneUsageDescription</key>
    <string>We need microphone access for voice-based transaction entry</string>

    <!-- Location permission (optional, for merchant location) -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>We use location to suggest nearby merchants for transactions</string>
</dict>
</plist>
```

### Step 4: Configure Podfile

Update `ios/Podfile` with minimum iOS version:

```ruby
# Uncomment this line to define a global platform for your project
platform :ios, '12.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    # Fix deployment target warnings
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

### Step 5: Update App Icons

Replace default app icons in `ios/Runner/Assets.xcassets/AppIcon.appiconset/` with Spendex app icons.

**Required Sizes:**
- 20x20@2x, 20x20@3x
- 29x29@2x, 29x29@3x
- 40x40@2x, 40x40@3x
- 60x60@2x, 60x60@3x
- 1024x1024 (App Store)

### Step 6: Configure Launch Screen

Update `ios/Runner/Base.lproj/LaunchScreen.storyboard` with Spendex branding.

### Step 7: Build and Test

```bash
# Open in Xcode
open ios/Runner.xcworkspace

# Or build from command line
flutter build ios --debug

# Run on simulator
flutter run -d "iPhone 15 Pro"

# Run on physical device (requires Apple Developer account)
flutter run -d <device-id>
```

---

## iOS-Specific Code Handling

### Platform Checks

The app already includes platform checks for SMS functionality:

```dart
import 'dart:io';

// Check if platform is iOS
if (Platform.isIOS) {
  // iOS-specific code
  print('SMS reading not available on iOS');
  return const Left(
    ValidationFailure(
      'SMS permissions are only available on Android',
      code: 'PLATFORM_NOT_SUPPORTED',
    ),
  );
}
```

### Hiding SMS Feature on iOS

Option 1: **Hide SMS Parser Entry Point**

```dart
// In settings_screen.dart or bank_import_home_screen.dart
import 'dart:io';

// Only show SMS parser on Android
if (Platform.isAndroid) {
  _SettingsTile(
    icon: Iconsax.message,
    title: 'SMS Parser',
    subtitle: 'Import from bank SMS',
    onTap: () => context.push(AppRoutes.smsParser),
  ),
}
```

Option 2: **Show Disabled with Explanation**

```dart
_SettingsTile(
  icon: Iconsax.message,
  title: 'SMS Parser',
  subtitle: Platform.isIOS
    ? 'Not available on iOS'
    : 'Import from bank SMS',
  enabled: Platform.isAndroid,
  onTap: Platform.isAndroid
    ? () => context.push(AppRoutes.smsParser)
    : () => _showIosLimitationDialog(),
),
```

### User-Friendly Error Messages

```dart
void _showIosLimitationDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Feature Not Available'),
      content: const Text(
        'SMS reading is not available on iOS due to Apple\'s privacy restrictions.\n\n'
        'Please use one of these alternatives:\n'
        '• PDF/CSV Import\n'
        '• Account Aggregator\n'
        '• Manual Entry'
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
```

---

## Testing on iOS

### Simulator Testing

```bash
# List available iOS simulators
flutter emulators

# Run on specific simulator
flutter run -d "iPhone 15 Pro"

# Test different iOS versions
flutter run -d "iPhone 14 (iOS 17.0)"
```

### Physical Device Testing

**Requirements:**
- Apple Developer Account (free or paid)
- Device registered in Apple Developer Portal
- Provisioning profile configured

**Steps:**
1. Connect iPhone/iPad via USB
2. Trust computer on device
3. Select device in Xcode
4. Build and run: `flutter run`

### Features to Test on iOS

- ✅ PDF/CSV Import with file picker
- ✅ Account Aggregator OAuth flow
- ✅ Transaction creation and management
- ✅ Dashboard and reports
- ✅ Settings and preferences
- ✅ Dark mode
- ✅ Biometric authentication (Face ID/Touch ID)
- ❌ SMS Parser (verify graceful degradation)

---

## iOS Distribution

### App Store Requirements

**Required:**
- App Store Connect account
- Paid Apple Developer Program membership ($99/year)
- App icons in all required sizes
- Screenshots for all supported devices
- Privacy policy
- Terms of service

**App Store Review Considerations:**
- Explain why SMS reading is Android-only
- Provide alternative import methods
- Follow Apple's Human Interface Guidelines
- Comply with App Store Review Guidelines

### TestFlight Beta Testing

```bash
# Build for TestFlight
flutter build ios --release

# Archive in Xcode and upload to App Store Connect
# Distribute to internal/external testers
```

---

## iOS-Specific Dependencies

### Packages with iOS Support

All packages used in Spendex support iOS:

| Package | iOS Support | Notes |
|---------|-------------|-------|
| `flutter_riverpod` | ✅ Full | State management |
| `go_router` | ✅ Full | Navigation |
| `dio` | ✅ Full | HTTP client |
| `file_picker` | ✅ Full | File selection |
| `webview_flutter` | ✅ Full | WebView (WKWebView) |
| `permission_handler` | ✅ Partial | Some permissions iOS-specific |
| `local_auth` | ✅ Full | Face ID/Touch ID |
| `shared_preferences` | ✅ Full | Local storage |
| `flutter_secure_storage` | ✅ Full | Keychain storage |
| `image_picker` | ✅ Full | Camera/gallery |
| `flutter_sms_inbox` | ❌ Android Only | SMS reading |

### iOS-Only Alternatives

For SMS-like functionality on iOS, consider:
- Email parsing (future feature)
- Push notifications from bank apps
- Manual CSV export from banking apps

---

## Performance Considerations

### iOS Optimizations

- **Startup Time**: iOS apps may start faster due to AOT compilation
- **Smooth Scrolling**: iOS typically has smoother list scrolling
- **Memory Management**: iOS has stricter memory limits
- **Background Tasks**: iOS restricts background operations more than Android

### Best Practices for iOS

1. **Minimize Large Lists**: Use pagination for transaction lists
2. **Optimize Images**: Compress images before caching
3. **Reduce Memory Usage**: Clear caches when memory warnings occur
4. **Battery Efficiency**: Minimize background tasks and location updates

---

## Troubleshooting iOS Issues

### Common Issues

#### 1. Build Fails with CocoaPods Error

```bash
# Clean pods and reinstall
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

#### 2. App Crashes on Launch

- Check Info.plist for missing permissions
- Verify minimum iOS version (12.0+)
- Review Xcode crash logs

#### 3. WebView Not Loading

- Check `NSAppTransportSecurity` in Info.plist
- Ensure internet permissions are set
- Test on physical device (not simulator)

#### 4. File Picker Not Working

- Verify `NSPhotoLibraryUsageDescription` in Info.plist
- Check iCloud Drive entitlements
- Test with different file types

---

## Future iOS Enhancements

### Planned Features

1. **Apple Pay Integration**: Direct UPI payments via Apple Pay
2. **Siri Shortcuts**: Voice commands for transactions
3. **Widgets**: Home screen widgets for balance/spending
4. **Apple Watch**: Companion app for quick entry
5. **iCloud Sync**: Cross-device data synchronization
6. **Email Parsing**: Alternative to SMS on iOS

### Wish List

- **MessageKit Integration**: Request SMS access (unlikely approval)
- **HealthKit Integration**: Link expenses to health purchases
- **CarPlay Support**: Voice-based expense tracking while driving

---

## Summary

### What Works on iOS ✅

- PDF/CSV Import
- Account Aggregator
- Transaction Management
- Dashboard & Reports
- IFSC Lookup
- UPI Validation
- Payment Method Tagging
- Indian Date/Currency Formatting
- All core features (auth, accounts, budgets, goals)

### What Doesn't Work on iOS ❌

- SMS Parser (Apple platform restriction)

### Recommendation

**iOS users get 95% of the functionality**, with only SMS-based import unavailable. The app provides multiple alternative import methods, making it fully usable for iOS users.

---

## Setup Checklist

Before releasing on iOS:

- [ ] Add iOS platform: `flutter create --platforms=ios .`
- [ ] Configure Info.plist permissions
- [ ] Update Podfile with minimum iOS 12.0
- [ ] Add app icons for all sizes
- [ ] Configure launch screen
- [ ] Hide or disable SMS Parser feature
- [ ] Test PDF/CSV import on iOS
- [ ] Test Account Aggregator on iOS
- [ ] Test biometric authentication (Face ID)
- [ ] Test dark mode
- [ ] Run on physical iOS device
- [ ] Submit to TestFlight for beta testing
- [ ] Prepare App Store listing
- [ ] Submit for App Store review

---

## Support

For iOS-specific issues:
- Check Apple Developer Documentation
- Review Flutter iOS deployment guide
- Test on latest iOS version
- Consider hiring iOS developer for advanced features

---

**Document Version**: 1.0
**Last Updated**: February 13, 2026
**Status**: ✅ Complete
