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

# Ad-hoc code sign
echo "Code signing..."
codesign --force --deep --sign - "$BUNDLE_DIR"

echo ""
echo "✅ Created $BUNDLE_DIR"

# Create a zip for GitHub Releases
echo "Creating release zip..."
ditto -c -k --sequesterRsrc --keepParent "$BUNDLE_DIR" "Clippy.app.zip"
echo "✅ Created Clippy.app.zip (upload this to GitHub Releases)"

echo ""
echo "To install locally, run:"
echo "  cp -r $BUNDLE_DIR /Applications/"
echo ""
echo "To publish a release:"
echo "  1. Update AppVersion.current in Clippy/Sources/Models/AppVersion.swift"
echo "  2. Update CFBundleShortVersionString in Clippy/Info.plist"
echo "  3. Run: ./bundle.sh"
echo "  4. Create a GitHub Release with tag vX.Y.Z"
echo "  5. Attach Clippy.app.zip to the release"
echo ""
echo "Then open from /Applications or Spotlight."
