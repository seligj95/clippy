import Foundation
import AppKit

/// Checks GitHub Releases for new versions and can download + install updates.
@MainActor
final class UpdateService: ObservableObject {
    static let shared = UpdateService()

    private let repo = "seligj95/clippy"

    @Published var latestVersion: String?
    @Published var releaseURL: URL?       // GitHub release page
    @Published var downloadURL: URL?      // Direct .zip download
    @Published var releaseNotes: String?
    @Published var isChecking = false
    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0
    @Published var error: String?

    var updateAvailable: Bool {
        guard let latest = latestVersion else { return false }
        return AppVersion.compare(AppVersion.current, latest) == .orderedAscending
    }

    /// Check GitHub for the latest release.
    func checkForUpdates() async {
        isChecking = true
        error = nil
        defer { isChecking = false }

        let urlString = "https://api.github.com/repos/\(repo)/releases/latest"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                error = "Invalid response"
                return
            }

            if httpResponse.statusCode == 404 {
                // No releases yet
                latestVersion = nil
                return
            }

            guard httpResponse.statusCode == 200 else {
                error = "GitHub returned status \(httpResponse.statusCode)"
                return
            }

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                error = "Invalid JSON"
                return
            }

            // Parse tag name (strip leading "v" if present)
            if let tagName = json["tag_name"] as? String {
                let version = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName
                latestVersion = version
            }

            if let htmlURL = json["html_url"] as? String {
                releaseURL = URL(string: htmlURL)
            }

            releaseNotes = json["body"] as? String

            // Look for Clippy.app.zip in assets
            if let assets = json["assets"] as? [[String: Any]] {
                for asset in assets {
                    if let name = asset["name"] as? String,
                       name.hasSuffix(".zip") && name.contains("Clippy"),
                       let downloadURLString = asset["browser_download_url"] as? String {
                        downloadURL = URL(string: downloadURLString)
                        break
                    }
                }
            }
        } catch {
            self.error = "Network error: \(error.localizedDescription)"
        }
    }

    /// Download the latest release and install it.
    func downloadAndInstall() async {
        guard let downloadURL else {
            // Fall back to opening the release page
            if let releaseURL {
                NSWorkspace.shared.open(releaseURL)
            }
            return
        }

        isDownloading = true
        downloadProgress = 0
        error = nil
        defer { isDownloading = false }

        do {
            let (tempURL, response) = try await URLSession.shared.download(from: downloadURL)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                error = "Download failed"
                return
            }

            // Unzip to a temporary directory
            let tempDir = FileManager.default.temporaryDirectory
                .appendingPathComponent("ClippyUpdate-\(UUID().uuidString)")
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

            let zipPath = tempDir.appendingPathComponent("Clippy.app.zip")
            try FileManager.default.moveItem(at: tempURL, to: zipPath)

            // Unzip using ditto (macOS built-in, handles .app bundles correctly)
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
            process.arguments = ["-xk", zipPath.path, tempDir.path]
            try process.run()
            process.waitUntilExit()

            guard process.terminationStatus == 0 else {
                error = "Failed to unzip update"
                return
            }

            // Find the .app in the extracted contents
            let extractedApp = tempDir.appendingPathComponent("Clippy.app")
            guard FileManager.default.fileExists(atPath: extractedApp.path) else {
                error = "Clippy.app not found in download"
                return
            }

            // Determine the current app's location
            let currentAppPath = Bundle.main.bundlePath
            let appURL = URL(fileURLWithPath: currentAppPath)

            // If running from /Applications, replace in-place
            if currentAppPath.hasPrefix("/Applications") {
                // Move old app to trash
                try FileManager.default.trashItem(at: appURL, resultingItemURL: nil)
                // Copy new app
                try FileManager.default.copyItem(at: extractedApp, to: appURL)
            } else {
                // Running from build directory — install to /Applications
                let destURL = URL(fileURLWithPath: "/Applications/Clippy.app")
                if FileManager.default.fileExists(atPath: destURL.path) {
                    try FileManager.default.trashItem(at: destURL, resultingItemURL: nil)
                }
                try FileManager.default.copyItem(at: extractedApp, to: destURL)
            }

            // Clean up temp files
            try? FileManager.default.removeItem(at: tempDir)

            // Relaunch the app
            relaunch()
        } catch {
            self.error = "Update failed: \(error.localizedDescription)"
        }
    }

    /// Relaunch the app after update.
    private func relaunch() {
        let appPath: String
        if Bundle.main.bundlePath.hasPrefix("/Applications") {
            appPath = Bundle.main.bundlePath
        } else {
            appPath = "/Applications/Clippy.app"
        }

        // Use /usr/bin/open to relaunch after a short delay
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", "sleep 1 && open \"\(appPath)\""]
        try? process.run()

        NSApp.terminate(nil)
    }
}
