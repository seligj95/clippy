import SwiftUI
import AppKit

@main
struct ClippyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No main window — this is a menu bar app (LSUIElement)
        Settings {
            EmptyView()
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var panel: FloatingPanel?
    private let storageManager = StorageManager()
    private let clipboardMonitor = ClipboardMonitor()
    private var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupClipboardMonitor()
        setupHotkey()

        // Prompt for accessibility on first launch
        AccessibilityService.ensureAccessibility()
    }

    // MARK: - Status Item (Menu Bar)

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clippy")
            button.image?.size = NSSize(width: 16, height: 16)
        }

        let menu = NSMenu()

        let showItem = NSMenuItem(title: "Show Clipboard", action: #selector(togglePanel), keyEquivalent: "")
        showItem.target = self
        menu.addItem(showItem)

        menu.addItem(NSMenuItem.separator())

        let prefsItem = NSMenuItem(title: "Preferences...", action: #selector(openSettings), keyEquivalent: ",")
        prefsItem.target = self
        menu.addItem(prefsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit Clippy", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    // MARK: - Clipboard Monitor

    private func setupClipboardMonitor() {
        // Sync max history size from UserDefaults
        if let stored = UserDefaults.standard.object(forKey: "maxHistorySize") as? Int {
            storageManager.maxHistorySize = stored
        }

        clipboardMonitor.onNewClipboardItem = { [weak self] contents, bundleID, appName in
            DispatchQueue.main.async {
                self?.storageManager.addItem(contents: contents, sourceAppBundleID: bundleID, sourceAppName: appName)
            }
        }
        clipboardMonitor.start()
    }

    // MARK: - Hotkey

    private func setupHotkey() {
        HotkeyService.shared.onHotkeyPressed = { [weak self] in
            self?.togglePanel()
        }
        HotkeyService.shared.register()
    }

    // MARK: - Panel

    @objc private func togglePanel() {
        if let panel, panel.isVisible {
            panel.close()
            self.panel = nil
        } else {
            showPanel()
        }
    }

    private func showPanel() {
        let panelRect = NSRect(x: 0, y: 0, width: 380, height: 500)
        let newPanel = FloatingPanel(contentRect: panelRect)

        let contentView = PanelContentView(
            storageManager: storageManager,
            onPaste: { [weak self] contents in
                self?.panel?.close()
                self?.panel = nil
                // Small delay to let the panel close and return focus to the previous app
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    PasteService.paste(contents: contents)
                }
            },
            onPasteString: { [weak self] string in
                self?.panel?.close()
                self?.panel = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    PasteService.pasteString(string)
                }
            },
            onClose: { [weak self] in
                self?.panel?.close()
                self?.panel = nil
            }
        )

        newPanel.setContent(contentView)
        newPanel.onClose = { [weak self] in
            self?.panel = nil
        }
        newPanel.showCentered()
        panel = newPanel
    }

    // MARK: - Settings

    @objc private func openSettings() {
        if let settingsWindow, settingsWindow.isVisible {
            settingsWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView(onClearHistory: { [weak self] in
            self?.storageManager.clearHistory()
        })

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 280),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Clippy Preferences"
        window.contentView = NSHostingView(rootView: settingsView)
        window.center()
        window.isReleasedWhenClosed = false

        NSApp.setActivationPolicy(.regular)
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow = window

        // Revert to accessory when settings window closes
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.settingsWindow = nil
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }

    // MARK: - Quit

    @objc private func quitApp() {
        clipboardMonitor.stop()
        HotkeyService.shared.unregister()
        NSApp.terminate(nil)
    }
}
