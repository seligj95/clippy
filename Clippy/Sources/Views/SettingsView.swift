import SwiftUI
import AppKit
import LaunchAtLogin

struct SettingsView: View {
    @AppStorage("maxHistorySize") private var maxHistorySize: Int = 200
    @AppStorage("pollingInterval") private var pollingInterval: Double = 0.5

    let onClearHistory: () -> Void

    @State private var showClearConfirmation = false
    @ObservedObject private var updateService = UpdateService.shared

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
        .frame(width: 420, height: 340)
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
            Text("Version \(AppVersion.current)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("A clipboard history manager for macOS")
                .font(.body)
                .foregroundStyle(.secondary)

            Divider()
                .padding(.horizontal, 40)

            // Update section
            updateSection

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .task {
            await updateService.checkForUpdates()
        }
    }

    @ViewBuilder
    private var updateSection: some View {
        if updateService.isChecking {
            HStack(spacing: 6) {
                ProgressView()
                    .controlSize(.small)
                Text("Checking for updates...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else if updateService.updateAvailable, let latest = updateService.latestVersion {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundStyle(.blue)
                    Text("Version \(latest) available!")
                        .font(.caption)
                        .fontWeight(.medium)
                }

                if let notes = updateService.releaseNotes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .frame(maxWidth: 280)
                }

                if updateService.isDownloading {
                    ProgressView("Downloading update...")
                        .controlSize(.small)
                } else {
                    HStack(spacing: 12) {
                        if updateService.downloadURL != nil {
                            Button("Install Update") {
                                Task { await updateService.downloadAndInstall() }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }

                        if let releaseURL = updateService.releaseURL {
                            Button("View Release") {
                                NSWorkspace.shared.open(releaseURL)
                            }
                            .controlSize(.small)
                        }
                    }
                }
            }
        } else if let error = updateService.error {
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
                Text(error)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Button("Retry") {
                Task { await updateService.checkForUpdates() }
            }
            .controlSize(.small)
        } else {
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(.green)
                Text("You're up to date")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Button("Check for Updates") {
                Task { await updateService.checkForUpdates() }
            }
            .controlSize(.small)
        }
    }
}
