# Clippy

A lightweight clipboard history manager for macOS, inspired by Windows' `Win+V`. Quickly access your clipboard history and emoji picker from a floating panel.

## Features

- **Clipboard History** — Automatically saves text, images, and files you copy
- **Global Hotkey** — Press `⌘⇧V` to open the clipboard panel from any app
- **Emoji Picker** — Browse and search emojis by keyword
- **Search** — Filter clipboard history by content
- **Pin Items** — Pin frequently used clips so they're never pruned
- **Keyboard Navigation** — Arrow keys to browse, Enter to paste, Esc to close
- **Menu Bar App** — Lives in your menu bar, no dock icon
- **Launch at Login** — Optional auto-start via Preferences
- **Persistent History** — Clipboard history saved to disk across app restarts

## Requirements

- macOS 14.0+
- Swift 5.9+ / Swift Command Line Tools

## Building

```bash
# Debug build
swift build

# Release build + .app bundle
./bundle.sh
```

## Installation

```bash
# Build and bundle
./bundle.sh

# Copy to Applications
cp -r Clippy.app /Applications/

# Launch
open /Applications/Clippy.app
```

## Permissions

Clippy requires **Accessibility** permission to paste into other apps:

1. Open **System Settings > Privacy & Security > Accessibility**
2. Click **+** and add `/Applications/Clippy.app`
3. Toggle it on
4. Restart Clippy if needed

> **Note:** If you rebuild and reinstall, you may need to remove and re-add Clippy in the Accessibility list since macOS ties permissions to the specific binary.

## Usage

| Action | Shortcut |
|---|---|
| Open/close clipboard panel | `⌘⇧V` |
| Navigate items | `↑` / `↓` |
| Paste selected item | `Enter` or click |
| Close panel | `Esc` |
| Search | Start typing in the search field |
| Pin/Delete items | Right-click for context menu |

Access **Preferences** and **Quit** from the menu bar icon.

## Project Structure

```
Clippy/
├── Sources/
│   ├── ClippyApp.swift          # App entry point & AppDelegate
│   ├── Models/
│   │   ├── ClipboardItem.swift       # Clipboard data model
│   │   ├── ClipboardItemContent.swift # Pasteboard type/data pair
│   │   └── EmojiData.swift           # Emoji catalog & search keywords
│   ├── Services/
│   │   ├── AccessibilityService.swift # AX permission checks
│   │   ├── ClipboardMonitor.swift     # NSPasteboard polling
│   │   ├── HotkeyService.swift        # Global hotkey (Carbon API)
│   │   ├── PasteService.swift         # Paste simulation (CGEvent)
│   │   └── StorageManager.swift       # JSON file persistence
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

## Data Storage

Clipboard history is stored as JSON at:

```
~/Library/Application Support/Clippy/history.json
```

## License

MIT
