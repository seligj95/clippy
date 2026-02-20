# Clippy

A lightweight clipboard history manager for macOS, inspired by Windows' `Win+V`. Quickly access your clipboard history and emoji picker from a floating panel.

![Clippy UI](assets/app-interface.png)

## Features

- **Clipboard History** — Automatically saves text, images (screenshots, photos), and files you copy
- **Global Hotkey** — Press `⌘⇧V` to open the clipboard panel from any app
- **Emoji Picker** — Browse and search emojis by keyword
- **Search** — Filter clipboard history by content
- **Pin Items** — Pin frequently used clips so they're never pruned
- **Keyboard Navigation** — Arrow keys to browse, Enter to paste, Esc to close
- **Menu Bar App** — Lives in your menu bar, no dock icon
- **Launch at Login** — Optional auto-start via Preferences
- **Persistent History** — Clipboard history saved to disk across app restarts
- **Auto-Update** — Checks GitHub Releases for new versions with one-click install

## Requirements

- macOS 14.0+

## Installation

Download **Clippy.app.zip** from the [latest release](https://github.com/seligj95/clippy/releases/latest), unzip it, and move `Clippy.app` to `/Applications`.

> **Note:** macOS will block unsigned apps the first time — see [Gatekeeper Notice](#gatekeeper-notice) below. You'll also need to grant [Accessibility permission](#permissions).

## Building from Source

If you'd prefer to build locally, see [CONTRIBUTING.md](CONTRIBUTING.md) for instructions. Requires Swift 5.9+ / Command Line Tools.

## Gatekeeper Notice

Since Clippy is ad-hoc signed (not notarized with an Apple Developer ID), macOS may block it the first time you open it. To allow it:

- **Right-click** (or Control-click) `Clippy.app` → select **Open** → click **Open** in the dialog
- Or run: `xattr -cr /Applications/Clippy.app` then open normally

You only need to do this once.

## Permissions

Clippy requires **Accessibility** permission to paste into other apps:

1. Open **System Settings > Privacy & Security > Accessibility**
2. Click **+** and add `/Applications/Clippy.app`
3. Toggle it on
4. Restart Clippy if needed

> **Note:** After an update, you may need to re-grant Accessibility permission since macOS ties it to the specific app binary. To do this, go to Accessibility settings, select Clippy, click **−** to remove it, then click **+** to re-add `Clippy.app`, and restart Clippy.

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

## Contributing

Found a bug or have a feature idea? [Open an issue](https://github.com/seligj95/clippy/issues). Pull requests are welcome too — see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

MIT
