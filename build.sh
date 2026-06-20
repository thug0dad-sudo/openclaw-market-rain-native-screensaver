#!/bin/bash
set -euo pipefail

APP_NAME="OpenClawMarketRainNative"
BUILD_DIR="build"
BUNDLE="$BUILD_DIR/$APP_NAME.saver"
CONTENTS="$BUNDLE/Contents"
MACOS_DIR="$CONTENTS/MacOS"

rm -rf "$BUILD_DIR"
mkdir -p "$MACOS_DIR"

swiftc \
  -emit-library \
  -module-name "$APP_NAME" \
  -o "$MACOS_DIR/$APP_NAME" \
  Sources/OpenClawMarketRainView.swift \
  -framework ScreenSaver \
  -framework AppKit

cp Info.plist "$CONTENTS/Info.plist"

echo "Built: $BUNDLE"
