import Foundation

final class ClipboardItem: Identifiable, Codable, Equatable {
    let id: UUID
    var timestamp: Date
    var sourceAppBundleID: String?
    var sourceAppName: String?
    var isPinned: Bool
    var contents: [ClipboardItemContent]

    init(
        id: UUID = UUID(),
        timestamp: Date = .now,
        sourceAppBundleID: String? = nil,
        sourceAppName: String? = nil,
        isPinned: Bool = false,
        contents: [ClipboardItemContent] = []
    ) {
        self.id = id
        self.timestamp = timestamp
        self.sourceAppBundleID = sourceAppBundleID
        self.sourceAppName = sourceAppName
        self.isPinned = isPinned
        self.contents = contents
    }

    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        lhs.id == rhs.id
    }

    /// Returns the best text preview for display purposes.
    var textPreview: String? {
        if let stringContent = contents.first(where: { $0.type == "public.utf8-plain-text" }),
           let data = stringContent.value {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    /// Returns true if this item is primarily an image (has image data but no text).
    var isImage: Bool {
        let hasImage = contents.contains { $0.type == "public.tiff" || $0.type == "public.png" }
        return hasImage && textPreview == nil
    }

    /// Returns true if this item contains a file URL (but no text).
    var isFile: Bool {
        let hasFile = contents.contains { $0.type == "public.file-url" }
        return hasFile && textPreview == nil
    }

    /// Returns the file URL string if this item is a file reference.
    var fileURL: URL? {
        guard let content = contents.first(where: { $0.type == "public.file-url" }),
              let data = content.value,
              let urlString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return URL(string: urlString)
    }

    /// Returns image data (TIFF or PNG) if available.
    var imageData: Data? {
        if let content = contents.first(where: { $0.type == "public.tiff" }),
           let data = content.value {
            return data
        }
        if let content = contents.first(where: { $0.type == "public.png" }),
           let data = content.value {
            return data
        }
        return nil
    }

    /// A fingerprint for deduplication — based on primary content.
    var contentFingerprint: String {
        if let text = textPreview {
            return "text:\(text)"
        }
        if let imgData = imageData {
            let prefix = imgData.prefix(64).base64EncodedString()
            return "image:\(imgData.count):\(prefix)"
        }
        if let url = fileURL {
            return "file:\(url.absoluteString)"
        }
        return "unknown:\(id.uuidString)"
    }
}
