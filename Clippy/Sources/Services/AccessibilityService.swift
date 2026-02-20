import AppKit

struct AccessibilityService {
    /// Check if the app is trusted for Accessibility access.
    static var isTrusted: Bool {
        AXIsProcessTrusted()
    }

    /// Prompt the user to grant Accessibility permission.
    static func requestPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    /// Check and prompt if not yet trusted. Returns true if trusted.
    @discardableResult
    static func ensureAccessibility() -> Bool {
        if isTrusted { return true }
        requestPermission()
        return false
    }
}
