import Foundation

final class ClipboardItemContent: Identifiable, Codable {
    let id: UUID
    /// The pasteboard type (e.g., "public.utf8-plain-text", "public.tiff", "public.file-url")
    var type: String
    /// The raw data for this content type
    var value: Data?

    init(id: UUID = UUID(), type: String, value: Data? = nil) {
        self.id = id
        self.type = type
        self.value = value
    }
}
