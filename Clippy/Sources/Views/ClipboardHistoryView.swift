import SwiftUI
import AppKit

struct ClipboardHistoryView: View {
    let storageManager: StorageManager
    let onPaste: ([ClipboardItemContent]) -> Void
    let onClose: () -> Void

    @State private var searchText = ""
    @State private var items: [ClipboardItem] = []
    @State private var selectedIndex: Int? = nil

    private var filteredItems: [ClipboardItem] {
        if searchText.isEmpty { return items }
        return items.filter { item in
            if let text = item.textPreview {
                return text.localizedCaseInsensitiveContains(searchText)
            }
            if let url = item.fileURL {
                return url.lastPathComponent.localizedCaseInsensitiveContains(searchText)
            }
            return false
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search clipboard history...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(10)
            .background(.ultraThinMaterial)

            Divider()

            if filteredItems.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: searchText.isEmpty ? "doc.on.clipboard" : "magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundStyle(.tertiary)
                    Text(searchText.isEmpty ? "Clipboard history is empty" : "No results found")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    if searchText.isEmpty {
                        Text("Copy something to get started")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                    }
                }
                Spacer()
            } else {
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVStack(spacing: 1) {
                            ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                                ClipboardItemRow(
                                    item: item,
                                    isSelected: selectedIndex == index,
                                    onPaste: {
                                        onPaste(item.contents)
                                        onClose()
                                    },
                                    onDelete: {
                                        storageManager.deleteItem(item)
                                        refreshItems()
                                    },
                                    onTogglePin: {
                                        storageManager.togglePin(item)
                                        refreshItems()
                                    }
                                )
                                .id(index)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onChange(of: selectedIndex) { _, newValue in
                        if let idx = newValue {
                            withAnimation {
                                scrollProxy.scrollTo(idx, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
        .onAppear { refreshItems() }
        .onKeyPress(.upArrow) {
            moveSelection(by: -1)
            return .handled
        }
        .onKeyPress(.downArrow) {
            moveSelection(by: 1)
            return .handled
        }
        .onKeyPress(.return) {
            pasteSelected()
            return .handled
        }
        .onKeyPress(.escape) {
            onClose()
            return .handled
        }
    }

    private func refreshItems() {
        items = storageManager.fetchAllItems()
    }

    private func moveSelection(by offset: Int) {
        let count = filteredItems.count
        guard count > 0 else { return }

        if let current = selectedIndex {
            let next = current + offset
            selectedIndex = max(0, min(count - 1, next))
        } else {
            selectedIndex = offset > 0 ? 0 : count - 1
        }
    }

    private func pasteSelected() {
        guard let idx = selectedIndex, idx < filteredItems.count else { return }
        let item = filteredItems[idx]
        onPaste(item.contents)
        onClose()
    }
}
