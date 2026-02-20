import SwiftUI
import LaunchAtLogin

struct SettingsView: View {
    @AppStorage("maxHistorySize") private var maxHistorySize: Int = 200
    @AppStorage("pollingInterval") private var pollingInterval: Double = 0.5

    let onClearHistory: () -> Void

    @State private var showClearConfirmation = false

    var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            shortcutsTab
                .tabItem {
                    Label("Shortcuts", systemImage: "command")
                }

            aboutTab
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 420, height: 280)
    }

    @ViewBuilder
    private var generalTab: some View {
        Form {
            LaunchAtLogin.Toggle("Launch at login")

            Picker("History size:", selection: $maxHistorySize) {
                Text("50").tag(50)
                Text("100").tag(100)
                Text("200").tag(200)
                Text("500").tag(500)
                Text("999").tag(999)
            }
            .pickerStyle(.segmented)

            Picker("Polling interval:", selection: $pollingInterval) {
                Text("0.25s").tag(0.25)
                Text("0.5s").tag(0.5)
                Text("1.0s").tag(1.0)
                Text("2.0s").tag(2.0)
            }
            .pickerStyle(.segmented)

            Section {
                Button("Clear Clipboard History", role: .destructive) {
                    showClearConfirmation = true
                }
                .confirmationDialog(
                    "Clear all clipboard history?",
                    isPresented: $showClearConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Clear All", role: .destructive) {
                        onClearHistory()
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }

            Section {
                HStack {
                    Text("Accessibility:")
                    if AccessibilityService.isTrusted {
                        Label("Granted", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Label("Not Granted", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Button("Grant Access") {
                            AccessibilityService.requestPermission()
                        }
                    }
                }
            }
        }
        .padding()
    }

    @ViewBuilder
    private var shortcutsTab: some View {
        Form {
            HStack {
                Text("Toggle clipboard panel:")
                Spacer()
                Text(HotkeyService.shared.shortcutDescription)
                    .font(.system(size: 13, design: .monospaced))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.15))
                    .cornerRadius(6)
            }
            Text("Default: ⌘⇧V")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    @ViewBuilder
    private var aboutTab: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "doc.on.clipboard.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.accentColor)
            Text("Clippy")
                .font(.title)
                .fontWeight(.bold)
            Text("Version 1.0.0")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("A clipboard history manager for macOS")
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
