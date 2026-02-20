import AppKit
import Carbon

/// Manages global hotkey registration using Carbon APIs.
/// Default: Cmd+Shift+V to toggle the clipboard panel.
@MainActor
final class HotkeyService {
    static let shared = HotkeyService()

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    var onHotkeyPressed: (() -> Void)?

    /// The current hotkey key code (default: 0x09 = 'v')
    var keyCode: UInt32 {
        get { UInt32(UserDefaults.standard.integer(forKey: "hotkeyKeyCode")).nonZero ?? 0x09 }
        set {
            UserDefaults.standard.set(Int(newValue), forKey: "hotkeyKeyCode")
            reregister()
        }
    }

    /// The current hotkey modifiers (default: Cmd+Shift)
    var modifiers: UInt32 {
        get { UInt32(UserDefaults.standard.integer(forKey: "hotkeyModifiers")).nonZero ?? (UInt32(cmdKey) | UInt32(shiftKey)) }
        set {
            UserDefaults.standard.set(Int(newValue), forKey: "hotkeyModifiers")
            reregister()
        }
    }

    private init() {}

    func register() {
        unregister()

        // Install event handler for hotkey events
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let handler: EventHandlerUPP = { _, event, _ -> OSStatus in
            DispatchQueue.main.async {
                HotkeyService.shared.onHotkeyPressed?()
            }
            return noErr
        }

        InstallEventHandler(
            GetApplicationEventTarget(),
            handler,
            1,
            &eventType,
            nil,
            &eventHandler
        )

        // Register the hotkey
        let hotKeyID = EventHotKeyID(
            signature: OSType(0x434C4950), // "CLIP"
            id: 1
        )

        RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
        if let handler = eventHandler {
            RemoveEventHandler(handler)
            eventHandler = nil
        }
    }

    private func reregister() {
        if hotKeyRef != nil {
            register()
        }
    }

    /// Human-readable description of the current shortcut.
    var shortcutDescription: String {
        var parts: [String] = []
        let mods = modifiers
        if mods & UInt32(cmdKey) != 0 { parts.append("⌘") }
        if mods & UInt32(shiftKey) != 0 { parts.append("⇧") }
        if mods & UInt32(optionKey) != 0 { parts.append("⌥") }
        if mods & UInt32(controlKey) != 0 { parts.append("⌃") }
        parts.append(keyCodeToString(keyCode))
        return parts.joined()
    }

    private func keyCodeToString(_ code: UInt32) -> String {
        let keyMap: [UInt32: String] = [
            0x00: "A", 0x01: "S", 0x02: "D", 0x03: "F", 0x04: "H",
            0x05: "G", 0x06: "Z", 0x07: "X", 0x08: "C", 0x09: "V",
            0x0B: "B", 0x0C: "Q", 0x0D: "W", 0x0E: "E", 0x0F: "R",
            0x10: "Y", 0x11: "T", 0x12: "1", 0x13: "2", 0x14: "3",
            0x15: "4", 0x16: "6", 0x17: "5", 0x18: "=", 0x19: "9",
            0x1A: "7", 0x1B: "-", 0x1C: "8", 0x1D: "0", 0x1E: "]",
            0x1F: "O", 0x20: "U", 0x21: "[", 0x22: "I", 0x23: "P",
            0x25: "L", 0x26: "J", 0x28: "K", 0x2C: "/", 0x2D: "N",
            0x2E: "M", 0x2F: ".", 0x31: " ", 0x24: "↩", 0x30: "⇥",
            0x33: "⌫", 0x35: "⎋", 0x7A: "F1", 0x78: "F2", 0x63: "F3",
            0x76: "F4", 0x60: "F5", 0x61: "F6", 0x62: "F7", 0x64: "F8",
            0x65: "F9", 0x6D: "F10", 0x67: "F11", 0x6F: "F12",
        ]
        return keyMap[code] ?? "?"
    }
}

private extension UInt32 {
    var nonZero: UInt32? { self == 0 ? nil : self }
}
