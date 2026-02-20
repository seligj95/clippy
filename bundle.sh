#!/bin/bash
set -e

APP_NAME="Clippy"
BUILD_DIR=".build/release"
BUNDLE_DIR="$APP_NAME.app"

echo "Building release..."
swift build -c release

echo "Creating app bundle..."
rm -rf "$BUNDLE_DIR"
mkdir -p "$BUNDLE_DIR/Contents/MacOS"
mkdir -p "$BUNDLE_DIR/Contents/Resources"

# Copy executable
cp "$BUILD_DIR/$APP_NAME" "$BUNDLE_DIR/Contents/MacOS/$APP_NAME"

# Copy Info.plist
cp Clippy/Info.plist "$BUNDLE_DIR/Contents/Info.plist"

# Copy icon
cp Clippy/AppIcon.icns "$BUNDLE_DIR/Contents/Resources/AppIcon.icns"

# Create PkgInfo
echo -n "APPL????" > "$BUNDLE_DIR/Contents/PkgInfo"

echo ""
echo "✅ Created $BUNDLE_DIR"
echo ""
echo "To install, run:"
echo "  cp -r $BUNDLE_DIR /Applications/"
echo ""
echo "Then open from /Applications or Spotlight."
