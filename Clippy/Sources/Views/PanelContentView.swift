import SwiftUI

enum PanelTab: String, CaseIterable {
    case clipboard = "Clipboard"
    case emoji = "Emoji"

    var icon: String {
        switch self {
        case .clipboard: return "doc.on.clipboard"
        case .emoji: return "face.smiling"
        }
    }
}

struct PanelContentView: View {
    @State private var selectedTab: PanelTab = .clipboard
    let storageManager: StorageManager
    let onPaste: ([ClipboardItemContent]) -> Void
    let onPasteString: (String) -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            HStack(spacing: 0) {
                ForEach(PanelTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 12))
                            Text(tab.rawValue)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedTab == tab ? Color.accentColor.opacity(0.15) : Color.clear)
                        .foregroundStyle(selectedTab == tab ? Color.accentColor : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(.ultraThinMaterial)

            Divider()

            // Tab content
            switch selectedTab {
            case .clipboard:
                ClipboardHistoryView(
                    storageManager: storageManager,
                    onPaste: onPaste,
                    onClose: onClose
                )
            case .emoji:
                EmojiPickerView(
                    onSelect: onPasteString,
                    onClose: onClose
                )
            }
        }
        .frame(minWidth: 340, minHeight: 400)
    }
}
