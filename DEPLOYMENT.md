# Deployment Guide

## iOS Deployment

### Prerequisites
- macOS computer
- Xcode installed
- iOS device
- Apple Developer account
- Flutter SDK installed

### Development Setup
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Open iOS folder in Xcode: `open ios/Runner.xcworkspace`
4. In Xcode:
   - Select the "Runner" project in the navigator
   - Select the "Runner" target
   - In "Signing & Capabilities":
     - Select your team
     - Update bundle identifier if needed

### Deploy to Physical Device (Release Mode)

To deploy a release version that runs independently on your device (without debug banner or debugger):

```bash
# 1. Clean the project and reinstall dependencies
flutter clean
flutter pub get
cd ios
pod install
cd ..

# 2. Build and install release version
flutter build ios --release
flutter install --release
```

When prompted, select your physical device from the list.

### Troubleshooting

1. If you see "untrusted developer" on your iPhone:
   - Go to Settings > General > VPN & Device Management
   - Find your developer certificate
   - Tap "Trust [your developer name]"

2. If the app crashes on launch:
   - Make sure you're building in release mode
   - Check that all dependencies are properly installed
   - Verify signing certificate is valid

3. If pod install fails:
   - Try removing Pods directory: `rm -rf ios/Pods ios/Podfile.lock`
   - Run `flutter clean`
   - Run `flutter pub get`
   - Run `cd ios && pod install`

### Notes

- Debug mode will show a debug banner and try to connect to the Flutter tools
- Release mode is what you should use for testing on physical devices
- The app will remain installed on your device until you delete it
- You can launch it any time without being connected to your computer

### Common Commands

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Update iOS pods
cd ios && pod install && cd ..

# Build release version
flutter build ios --release

# Install to connected device
flutter install --release
``` 