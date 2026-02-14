#!/bin/bash
# Spendex Release Build Script
# Builds Android APK and App Bundle for release

set -e

echo "======================================"
echo "  Spendex Release Builder"
echo "======================================"
echo ""

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

# Navigate to project root
cd "$(dirname "$0")/.."

# Get version from pubspec.yaml
VERSION=$(grep "^version:" pubspec.yaml | cut -d " " -f 2)
echo "Building version: $VERSION"
echo ""

echo -e "${YELLOW}[1/5] Cleaning previous builds...${NC}"
flutter clean

echo ""
echo -e "${YELLOW}[2/5] Getting dependencies...${NC}"
flutter pub get

echo ""
echo -e "${YELLOW}[3/5] Running tests...${NC}"
flutter test

echo ""
echo -e "${YELLOW}[4/5] Building Android APK...${NC}"
flutter build apk --release
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ -f "$APK_PATH" ]; then
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo -e "${GREEN}APK built successfully: $APK_PATH ($APK_SIZE)${NC}"
fi

echo ""
echo -e "${YELLOW}[5/5] Building Android App Bundle...${NC}"
flutter build appbundle --release
AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
if [ -f "$AAB_PATH" ]; then
    AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
    echo -e "${GREEN}AAB built successfully: $AAB_PATH ($AAB_SIZE)${NC}"
fi

echo ""
echo "======================================"
echo -e "${GREEN}  Build Complete!${NC}"
echo "======================================"
echo ""
echo "Output files:"
echo "  - APK: $APK_PATH"
echo "  - AAB: $AAB_PATH"
echo ""
echo "To install APK on device:"
echo "  adb install $APK_PATH"
echo ""
echo "To upload AAB to Play Store:"
echo "  Upload $AAB_PATH to Google Play Console"
