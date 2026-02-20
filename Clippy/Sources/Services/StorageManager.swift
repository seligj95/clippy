import Foundation

@Observable
final class StorageManager {
    private var items: [ClipboardItem] = []
    private let storageURL: URL

    var maxHistorySize: Int = 200

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let clippyDir = appSupport.appendingPathComponent("Clippy", isDirectory: true)
        try? FileManager.default.createDirectory(at: clippyDir, withIntermediateDirectories: true)
        storageURL = clippyDir.appendingPathComponent("history.json")
        loadFromDisk()
    }

    /// Add a new clipboard item, deduplicating and pruning as needed.
    func addItem(contents: [ClipboardItemContent], sourceAppBundleID: String?, sourceAppName: String?) {
        let newItem = ClipboardItem(
            sourceAppBundleID: sourceAppBundleID,
            sourceAppName: sourceAppName,
            contents: contents
        )

        // Deduplicate: if the same content exists, remove the old one
        let fingerprint = newItem.contentFingerprint
        items.removeAll { $0.contentFingerprint == fingerprint }

        // Insert at the beginning (most recent first)
        items.insert(newItem, at: 0)

        pruneIfNeeded()
        saveToDisk()
    }

    /// Fetch all items sorted by most recent first.
    func fetchAllItems() -> [ClipboardItem] {
        items
    }

    /// Delete a specific item.
    func deleteItem(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
        saveToDisk()
    }

    /// Clear all non-pinned history.
    func clearHistory() {
        items.removeAll { !$0.isPinned }
        saveToDisk()
    }

    /// Toggle pin state for an item.
    func togglePin(_ item: ClipboardItem) {
        item.isPinned.toggle()
        saveToDisk()
    }

    private func pruneIfNeeded() {
        guard items.count > maxHistorySize else { return }
        // Remove oldest non-pinned items
        let pinned = items.filter(\.isPinned)
        var unpinned = items.filter { !$0.isPinned }
        let maxUnpinned = maxHistorySize - pinned.count
        if unpinned.count > maxUnpinned {
            unpinned = Array(unpinned.prefix(max(0, maxUnpinned)))
        }
        items = pinned + unpinned
        items.sort { $0.timestamp > $1.timestamp }
    }

    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: storageURL, options: .atomic)
        } catch {
            print("Clippy: Failed to save history: \(error)")
        }
    }

    private func loadFromDisk() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return }
        do {
            let data = try Data(contentsOf: storageURL)
            items = try JSONDecoder().decode([ClipboardItem].self, from: data)
        } catch {
            print("Clippy: Failed to load history: \(error)")
            items = []
        }
    }
}
