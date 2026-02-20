import AppKit

struct PasteService {
    /// Write clipboard item data back to the general pasteboard and simulate Cmd+V.
    static func paste(contents: [ClipboardItemContent]) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        // If the item has text content, skip image types (TIFF/PNG) that are just
        // rich-text renderings — otherwise the receiving app may paste them as images.
        let hasText = contents.contains { $0.type == "public.utf8-plain-text" }
        let imageTypes: Set<String> = ["public.tiff", "public.png"]

        for content in contents {
            if hasText && imageTypes.contains(content.type) { continue }
            let type = NSPasteboard.PasteboardType(content.type)
            if let data = content.value {
                pasteboard.setData(data, forType: type)
            }
        }

        simulatePaste()
    }

    /// Paste a plain string.
    static func pasteString(_ string: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
        simulatePaste()
    }

    /// Simulate Cmd+V via CGEvent to paste into the active app.
    private static func simulatePaste() {
        guard AccessibilityService.isTrusted else {
            AccessibilityService.requestPermission()
            return
        }

        let vKeyCode: CGKeyCode = 0x09 // 'v' key

        guard let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: vKeyCode, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: vKeyCode, keyDown: false) else {
            return
        }

        // Set Cmd modifier + physical key flag (0x000008)
        let cmdFlag = CGEventFlags(rawValue: UInt64(CGEventFlags.maskCommand.rawValue) | 0x000008)
        keyDown.flags = cmdFlag
        keyUp.flags = cmdFlag

        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }
}
