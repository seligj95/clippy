import SwiftUI

struct EmojiPickerView: View {
    let onSelect: (String) -> Void
    let onClose: () -> Void

    @State private var searchText = ""
    @State private var selectedCategory: String = "smileys"
    @State private var recentEmojis: [String] = {
        UserDefaults.standard.stringArray(forKey: "recentEmojis") ?? []
    }()

    private var displayCategories: [EmojiCategory] {
        var cats = emojiCategories
        // Populate the "recent" category with stored recents
        if let idx = cats.firstIndex(where: { $0.id == "recent" }) {
            cats[idx] = EmojiCategory(id: "recent", name: "Recently Used", icon: "clock", emojis: recentEmojis)
        }
        // If no recents, remove the category
        if recentEmojis.isEmpty {
            cats.removeAll { $0.id == "recent" }
        }
        return cats
    }

    private var searchResults: [String] {
        guard !searchText.isEmpty else { return [] }
        let query = searchText.lowercased()
        let all = emojiCategories.flatMap(\.emojis)
        return all.filter { emoji in
            // Check keyword map first
            if let keywords = emojiKeywords[emoji] {
                if keywords.contains(where: { $0.contains(query) }) { return true }
            }
            // Fall back to Unicode character names
            let name = emoji.unicodeScalars.compactMap {
                Unicode.Scalar($0.value)?.properties.name?.lowercased()
            }.joined(separator: " ")
            return name.contains(query)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search emojis...", text: $searchText)
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

            if searchText.isEmpty {
                // Category tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 2) {
                        ForEach(displayCategories) { category in
                            Button {
                                selectedCategory = category.id
                            } label: {
                                Image(systemName: category.icon)
                                    .font(.system(size: 14))
                                    .frame(width: 30, height: 26)
                                    .background(selectedCategory == category.id ? Color.accentColor.opacity(0.15) : Color.clear)
                                    .cornerRadius(4)
                                    .foregroundStyle(selectedCategory == category.id ? Color.accentColor : .secondary)
                            }
                            .buttonStyle(.plain)
                            .help(category.name)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }

                Divider()

                // Emoji grid for selected category
                if let category = displayCategories.first(where: { $0.id == selectedCategory }) {
                    emojiGrid(emojis: category.emojis, title: category.name)
                }
            } else {
                // Show all emojis when searching (basic)
                emojiGrid(emojis: searchResults, title: "Search Results")
            }
        }
        .onKeyPress(.escape) {
            onClose()
            return .handled
        }
    }

    @ViewBuilder
    private func emojiGrid(emojis: [String], title: String) -> some View {
        if emojis.isEmpty {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "face.dashed")
                    .font(.system(size: 32))
                    .foregroundStyle(.tertiary)
                Text("No emojis")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        } else {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(36), spacing: 4), count: 8), spacing: 4) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button {
                            selectEmoji(emoji)
                        } label: {
                            Text(emoji)
                                .font(.system(size: 24))
                                .frame(width: 36, height: 36)
                                .background(Color.primary.opacity(0.001)) // Ensure hit area
                                .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                        .help(emoji)
                    }
                }
                .padding(8)
            }
        }
    }

    private func selectEmoji(_ emoji: String) {
        // Add to recents
        var recents = recentEmojis
        recents.removeAll { $0 == emoji }
        recents.insert(emoji, at: 0)
        if recents.count > 32 {
            recents = Array(recents.prefix(32))
        }
        recentEmojis = recents
        UserDefaults.standard.set(recents, forKey: "recentEmojis")

        onSelect(emoji)
        onClose()
    }
}
