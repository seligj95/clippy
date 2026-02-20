# Contributing to Clippy

Thanks for your interest in contributing! Whether it's a bug report, feature request, or a pull request, all contributions are welcome.

## Reporting Issues

If you find a bug or have a feature idea, [open an issue](https://github.com/seligj95/clippy/issues). Please include:

- macOS version
- Steps to reproduce (for bugs)
- Expected vs actual behavior

## Pull Requests

Feel free to submit a PR for bug fixes, improvements, or new features:

1. Fork the repo and create a branch from `main`
2. Make your changes
3. Test locally with `swift build` and verify the app runs
4. Submit a PR with a clear description of the change

## Building from Source

```bash
# Requires Swift 5.9+ / Swift Command Line Tools

# Debug build
swift build

# Release build + .app bundle
./bundle.sh

# Copy to Applications
cp -r Clippy.app /Applications/

# Launch
open /Applications/Clippy.app
```

## Project Structure

```
Clippy/
├── Sources/
│   ├── ClippyApp.swift          # App entry point & AppDelegate
│   ├── Models/
│   │   ├── ClipboardItem.swift       # Clipboard data model
│   │   ├── ClipboardItemContent.swift # Pasteboard type/data pair
│   │   ├── EmojiData.swift           # Emoji catalog & search keywords
│   │   └── AppVersion.swift          # Version constant & comparison
│   ├── Services/
│   │   ├── AccessibilityService.swift # AX permission checks
│   │   ├── ClipboardMonitor.swift     # NSPasteboard polling
│   │   ├── HotkeyService.swift        # Global hotkey (Carbon API)
│   │   ├── PasteService.swift         # Paste simulation (CGEvent)
│   │   ├── StorageManager.swift       # JSON file persistence
│   │   └── UpdateService.swift        # GitHub release update checker
│   └── Views/
│       ├── ClipboardHistoryView.swift # Searchable history list
│       ├── ClipboardItemRow.swift     # Individual item row
│       ├── EmojiPickerView.swift      # Emoji grid with search
│       ├── FloatingPanel.swift        # NSPanel (non-activating)
│       ├── PanelContentView.swift     # Tab container
│       └── SettingsView.swift         # Preferences window
├── Info.plist
└── Clippy.entitlements
```

## Publishing a Release

1. Update the version in `Clippy/Sources/Models/AppVersion.swift` and `Clippy/Info.plist`
2. Run `./bundle.sh` to build and create `Clippy.app.zip`
3. Create a GitHub Release with tag `vX.Y.Z` (e.g., `v1.1.0`)
4. Attach `Clippy.app.zip` to the release
5. Add release notes describing what changed

Users will be notified automatically on launch.

## Data Storage

Clipboard history is stored as JSON at:

```
~/Library/Application Support/Clippy/history.json
```
