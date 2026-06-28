import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var settings: Settings
    @State private var searchText: String = ""
    
    var filteredHistory: [HistoryText] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return settings.historyTexts.sorted { $0.date > $1.date }
        } else {
            let term = searchText.lowercased()
            return settings.historyTexts.filter {
                $0.inputText.lowercased().contains(term)
            }.sorted { $0.date > $1.date }
        }
    }

    var body: some View {
        HoloCard {
            if filteredHistory.isEmpty {
                VStack {
                    Spacer()
                    
                    Text("No entries recorded in these archives.")
                        .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                    
                    Spacer()
                }
            } else {
                List {
                    Group {
                        Section(header: Text("TRANSLATION ARCHIVES").font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .body).pointSize))) {
                            ForEach(filteredHistory) { text in
                                VStack(alignment: .leading) {
                                    Text(text.inputText)
                                        .font(.custom(text.aurebeshFont, size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                                        .foregroundColor(settings.accentColor.color)
                                    
                                    Text(text.inputText)
                                        .font(.custom("EnglishStandard", size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                                        .foregroundColor(.primary)
                                    
                                    Text(text.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                                .onTapGesture {
                                    if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                    
                                    withAnimation(.smooth(duration: 0.4)) {
                                        settings.isMenuOpen = false
                                        settings.aurebeshFont = text.aurebeshFont
                                        
                                        if settings.aurebeshFont.contains("Aurebesh") {
                                            settings.pickerStyleSelection = "Aurebesh"
                                        } else if settings.aurebeshFont.contains("Mando") {
                                            settings.pickerStyleSelection = "Mando'a"
                                        } else if settings.aurebeshFont.contains("OuterRim") {
                                            settings.pickerStyleSelection = "Outer Rim"
                                        }
                                        
                                        settings.inputText = text.inputText
                                        settings.lastView = .history
                                        settings.activeView = .translate
                                    }
                                }
                                .contextMenu {
                                    Button {
                                        if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                        
                                        UIPasteboard.general.string = text.inputText
                                    } label: {
                                        Label("Copy Text", systemImage: "doc.on.doc")
                                    }
                                    
                                    Button(role: .destructive) {
                                        if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                        
                                        if let index = settings.historyTexts.firstIndex(where: { $0.id == text.id }) {
                                            settings.historyTexts.remove(at: index)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .transparentList()
                .animation(.smooth, value: settings.historyTexts)
                .overlay(alignment: .bottom) {
                    VStack(spacing: 1) {
                        if !settings.historyTexts.isEmpty {
                            Button {
                                if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                
                                withAnimation(.smooth) {
                                    settings.historyTexts.removeAll()
                                }
                            } label: {
                                Text("Clear All")
                                    .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                                    .fontWeight(.semibold)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 12)
                                    .foregroundColor(.primary)
                                    .conditionalGlassEffect()
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            .animation(.easeInOut(duration: 0.4), value: settings.historyTexts.count)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal, 8)
                        }
                        
                        SearchBar(text: $searchText.animation(.easeInOut))
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, -8)
                }
            }
        }
    }
}
