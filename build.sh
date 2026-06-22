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

### OpenClaw: package web resources into saver bundle ###
SAVER_BUNDLE="build/OpenClawMarketRainNative.saver"
RESOURCE_DEST="$SAVER_BUNDLE/Contents/Resources"

if [ -d "Resources" ] && [ -d "$SAVER_BUNDLE/Contents" ]; then
  mkdir -p "$RESOURCE_DEST"
  cp -R Resources/. "$RESOURCE_DEST/"
  echo "Packaged web resources into: $RESOURCE_DEST"
else
  echo "Warning: Resources folder or saver bundle missing; web resources not packaged."
fi

