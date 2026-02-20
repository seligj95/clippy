import SwiftUI
import AppKit

struct ClipboardItemRow: View {
    let item: ClipboardItem
    let isSelected: Bool
    let onPaste: () -> Void
    let onDelete: () -> Void
    let onTogglePin: () -> Void

    @State private var isHoveringImage = false

    var body: some View {
        Button(action: onPaste) {
            HStack(spacing: 10) {
                // Content preview
                contentPreview
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Metadata & actions
                VStack(alignment: .trailing, spacing: 2) {
                    Text(relativeTime(item.timestamp))
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)

                    HStack(spacing: 4) {
                        if item.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Paste") { onPaste() }
            Button(item.isPinned ? "Unpin" : "Pin") { onTogglePin() }
            Divider()
            Button("Delete", role: .destructive) { onDelete() }
        }
    }

    @ViewBuilder
    private var contentPreview: some View {
        if let text = item.textPreview {
            Text(text.prefix(200))
                .font(.system(size: 12))
                .lineLimit(3)
                .foregroundStyle(.primary)
        } else if item.isImage, let imgData = item.imageData, let nsImage = NSImage(data: imgData) {
            Image(nsImage: nsImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 60)
                .cornerRadius(4)
                .onHover { hovering in
                    isHoveringImage = hovering
                }
                .popover(isPresented: $isHoveringImage, arrowEdge: .trailing) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 400, maxHeight: 400)
                        .padding(8)
                }
        } else if item.isFile, let url = item.fileURL {
            HStack(spacing: 6) {
                Image(systemName: "doc")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 1) {
                    Text(url.lastPathComponent)
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                    Text(url.deletingLastPathComponent().path)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        } else {
            Text("Unknown content")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
    }

    private func relativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: .now)
    }
}
