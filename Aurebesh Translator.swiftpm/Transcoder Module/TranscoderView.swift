import SwiftUI

let keyboardLetters: [String] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "Delete", "AC"]

let keyboardDigraphLetters: [String] = ["ch", "ae", "eo", "kh", "ng", "oo", "sh", "th", "", " ", "{", "}", "Delete", "AC"]

let specialLetters: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "/", ":", ";", "(", ")", "$", "&", "@", "\"", ".", ",", "?", "!", "'", "*", "Delete", "AC"]

struct TranslateView: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        #if !os(watchOS)
        HoloCard {
            TranslateList()
        }
        #else
        HoloCard {
            NavigationView {
                ScrollView {
                    TranslateList()
                        .navigationTitle("Transcoder")
                }
            }
        }
        #endif
    }
}

struct TranslateList: View {
    @EnvironmentObject var settings: Settings
    #if !os(watchOS)
    @EnvironmentObject var keyboardObserver: KeyboardObserver
    #endif
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State var showEnglish: Bool = false

    @State private var buttonState: ButtonState = .normal
    
    enum ButtonState {
        case normal, digraph, special
    }

    var buttonText: String {
        switch buttonState {
        case .normal:
            return "Normal"
        case .digraph:
            return "Digraph"
        case .special:
            return "Special"
        }
    }
    
    @Namespace private var kbNS
    @State private var lpSelected: LetterData? = nil
    @State private var lpShowDetail = false

    private func letterData(for key: String) -> LetterData? {
        let k = key.lowercased()

        // ignore non-letters / command keys
        if k.isEmpty || k == "delete" || k == "ac" { return nil }

        // Prefer digraphs when enabled and using Aurebesh
        if settings.digraph && settings.aurebeshFont.contains("Aurebesh") && k.count >= 2 {
            if let hit = digraphLetters.first(where: { $0.symbol.lowercased() == k }) {
                return hit
            }
        }

        // Standard letters
        if let hit = aurebeshLetters.first(where: { $0.symbol.lowercased() == k }) {
            return hit
        }

        // Numbers / specials, if you have them as LetterData
        if let hit = numberLetters.first(where: { $0.symbol.lowercased() == k }) {
            return hit
        }
        if let hit = specialAlphabetLetters.first(where: { $0.symbol.lowercased() == k }) {
            return hit
        }

        return nil
    }
    
    var body: some View {
        VStack {
            #if os(watchOS)
            ScrollView {
                HStack {
                    Text(settings.inputText.isEmpty ? settings.pickerStyleSelection : settings.inputText)
                        .font(.custom(settings.aurebeshFont, size: settings.aurebeshFontSize))
                        .foregroundColor(settings.inputText.isEmpty ? .secondary : settings.accentColor.color)
                        .multilineTextAlignment(.leading)
                        .padding()
                    
                    Spacer()
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(settings.accentColor.color.opacity(0.4), lineWidth: 1)
            )
            
            Spacer()
            
            TextField("Type here", text: $settings.inputText)
                .multilineTextAlignment(.leading)
                .font(.custom(settings.englishFont, size: UIFont.preferredFont(forTextStyle: .caption2).pointSize))
                .cornerRadius(20)
                .background(settings.accentColor.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(settings.accentColor.color.opacity(0.4), lineWidth: 1)
                )
            #else
            CustomTextEditor(text: $settings.inputText, aurebeshMode: true)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(settings.accentColor.color.opacity(0.4), lineWidth: 1)
                )
                .animation(.smooth, value: settings.translatingToAurebesh)
                .animation(.smooth, value: settings.inputText)
            
            CustomTextEditor(text: $settings.inputText, aurebeshMode: false)
                .background(settings.accentColor.color.opacity(0.1))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(settings.accentColor.color.opacity(0.4), lineWidth: 1)
                )
                .animation(.smooth, value: settings.translatingToAurebesh)
                .animation(.smooth, value: settings.inputText)
            
            if !settings.translatingToAurebesh && !keyboardObserver.isKeyboardVisible {
                VStack {
                    let spacing: CGFloat = 8
                    let buttonSize = (min(UIScreen.main.bounds.width, 800) - (spacing * 8)) / 7
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: spacing),
                        GridItem(.flexible(), spacing: spacing),
                        GridItem(.flexible(), spacing: spacing),
                        GridItem(.flexible(), spacing: spacing),
                        GridItem(.flexible(), spacing: spacing),
                        GridItem(.flexible(), spacing: spacing),
                        GridItem(.flexible(), spacing: spacing),
                    ], spacing: spacing) {
                        ForEach(buttonState == .special ? specialLetters : buttonState == .digraph ? keyboardDigraphLetters : keyboardLetters, id: \.self) { letter in
                            Button(action: {
                                if !letter.isEmpty {
                                    if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                }
                                
                                withAnimation(.smooth) {
                                    if letter == "Delete" {
                                        if !settings.inputText.isEmpty {
                                            settings.inputText.removeLast()
                                        }
                                    } else if letter == "AC" {
                                        settings.inputText = ""
                                    } else {
                                        if letter != " " { settings.inputText += letter }
                                    }
                                }
                            }) {
                                ZStack {
                                    Color.clear
                                    
                                    Group {
                                        if letter == "Delete" {
                                            Image(systemName: "delete.backward.fill")
                                                .font(.title)
                                                .foregroundColor(settings.accentColor.color)
                                        } else if letter == "AC" {
                                            Image(systemName: "xmark.app.fill")
                                                .font(.title)
                                                .foregroundColor(settings.accentColor.color)
                                        } else {
                                            Text(letter)
                                                .contentShape(Rectangle())
                                                .padding(.top, settings.englishFont == "EnglishCanon" && showEnglish ? 3 : 0)
                                                .padding(.top, settings.englishFont == "EnglishGalactic" && showEnglish ? 3 : 0)
                                            
                                                .padding(.leading, settings.aurebeshFont.contains("AurebeshBasic") && !showEnglish ? 2 : 0)
                                                .padding(.top, settings.aurebeshFont.contains("AurebeshBasic") && !showEnglish ? 2 : 0)
                                            
                                                .padding(.bottom, settings.aurebeshFont.contains("AurebeshCore") && !showEnglish ? 6 : 0)
                                            
                                                .padding(.bottom, settings.aurebeshFont.contains("AurebeshCantina") && !showEnglish ? 1 : 0)
                                            
                                                .padding(.top, settings.aurebeshFont.contains("AurebeshEquinox") && !showEnglish ? 5 : 0)
                                            
                                                .padding(.leading, settings.aurebeshFont.contains("AurebeshPixel") && !showEnglish ? 1 : 0)
                                                .padding(.bottom, settings.aurebeshFont.contains("AurebeshPixel") && !showEnglish ? 7 : 0)
                                            
                                                .padding(.top, settings.aurebeshFont.contains("Mando") && !showEnglish ? 4 : 0)
                                            
                                                .foregroundColor(.primary)
                                                .font(showEnglish
                                                      ? .custom(settings.englishFont, size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)
                                                      : .custom(settings.aurebeshFont, size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)
                                                )
                                        }
                                    }
                                    .padding(10)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.25)
                                }
                            }
                            .frame(width: buttonSize, height: buttonSize)
                            .background(settings.accentColor.color.opacity(0.1))
                            .cornerRadius(11)
                            .overlay(
                                RoundedRectangle(cornerRadius: 11)
                                    .stroke(settings.accentColor.color.opacity(0.4), lineWidth: 1)
                            )
                            .hoverEffect(.highlight)
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.35)
                                    .onEnded { _ in
                                        guard let data = letterData(for: letter) else { return }
                                        if settings.hapticOn { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
                                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                            lpSelected = data
                                            lpShowDetail = true
                                        }
                                    }
                            )
                        }
                    }
                    .padding(.horizontal, 1)
                    
                    HStack {
                        Button(action: {
                            if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                            
                            withAnimation(.smooth) {
                                switch buttonState {
                                case .normal:
                                    if settings.digraph && settings.aurebeshFont.contains("Aurebesh") {
                                        buttonState = .digraph
                                    } else {
                                        buttonState = .special
                                    }
                                case .special:
                                    buttonState = .normal
                                case .digraph:
                                    buttonState = .special
                                }
                            }
                        }) {
                            Text(buttonText)
                                .font(.custom(settings.englishFont, size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                                .foregroundColor(.primary)
                                .padding(.top, settings.englishFont == "EnglishCanon" ? 3 : 0)
                                .padding(16)
                                .lineLimit(1)
                                .minimumScaleFactor(0.25)
                                .frame(width: buttonSize * 2 + spacing, height: buttonSize)
                                .conditionalGlassEffect()
                        }
                        .contextMenu {
                            if buttonState != .normal {
                                Button(action: {
                                    if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                    
                                    buttonState = .normal
                                }) {
                                    if buttonState == .normal {
                                        Image(systemName: "checkmark")
                                        
                                        Spacer()
                                    }
                                    
                                    Text("Normal")
                                }
                            }
                            
                            if buttonState != .digraph && settings.digraph && settings.aurebeshFont.contains("Aurebesh") {
                                Button(action: {
                                    if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                    
                                    buttonState = .digraph
                                }) {
                                    if buttonState == .digraph {
                                        Image(systemName: "checkmark")
                                        
                                        Spacer()
                                    }
                                    
                                    Text("Digraph")
                                }
                            }
                            
                            if buttonState != .special {
                                Button(action: {
                                    if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                    
                                    buttonState = .special
                                }) {
                                    if buttonState == .special {
                                        Image(systemName: "checkmark")
                                        
                                        Spacer()
                                    }
                                    
                                    Text("Special")
                                }
                            }
                        }
                        
                        Button(action: {
                            if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                            
                            withAnimation(.smooth) {
                                settings.inputText += " "
                            }
                        }) {
                            RoundedRectangle(cornerRadius: 24)
                                .foregroundColor(settings.accentColor.color.opacity(0.1))
                                .frame(width: buttonSize * 3, height: buttonSize)
                                .conditionalGlassEffect()
                        }
                        
                        Button(action: {
                            if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                            
                            showEnglish.toggle()
                        }) {
                            Text(settings.pickerStyleSelection)
                                .font(.custom(settings.englishFont, size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                                .foregroundColor(.primary)
                                .padding(.top, settings.englishFont == "EnglishCanon" ? 3 : 0)
                                .padding(16)
                                .lineLimit(1)
                                .minimumScaleFactor(0.25)
                                .frame(width: buttonSize * 2 + spacing, height: buttonSize)
                                .foregroundColor(settings.accentColor.color)
                                .conditionalGlassEffect()
                        }
                    }
                }
                .animation(.smooth, value: settings.translatingToAurebesh)
                .animation(.smooth, value: buttonState)
                .animation(.smooth, value: showEnglish)
            }
            
            if !keyboardObserver.isKeyboardVisible {
                Picker("Keyboard Type", selection: $settings.translatingToAurebesh.animation(.smooth)) {
                    Text("Encoder").tag(true)
                    Text("Decoder").tag(false)
                }
                .pickerStyle(.segmented)
                .conditionalGlassEffect()
                .id(settings.refreshID)
                .padding(.top, 5)
            }
            #endif
        }
        .padding(.horizontal)
        .frame(maxWidth: 800)
        #if !os(watchOS)
        .onDisappear {
            saveHistory()
        }
        .onChange(of: scenePhase) { newValue in
            if newValue == .inactive || newValue == .background {
                saveHistory()
            }
        }
        .onChange(of: settings.digraph) { newValue in
            if !newValue || !settings.aurebeshFont.contains("Aurebesh") {
                if buttonState == .digraph {
                    buttonState = .normal
                }
            }
        }
        .onChange(of: settings.aurebeshFont) { newValue in
            if !settings.digraph || !newValue.contains("Aurebesh") {
                if buttonState == .digraph {
                    buttonState = .normal
                }
            }
        }
        .dismissKeyboardOnScroll()
        .overlay(alignment: .center) {
            if let letter = lpSelected, lpShowDetail {
                ZStack {
                    Color.black.opacity(0.0001)
                        .ignoresSafeArea()
                    
                    LetterDetailView(
                        letter: letter,
                        namespace: kbNS,
                        onClose: {
                            if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                                lpShowDetail = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                lpSelected = nil
                            }
                        }
                    )
                    .transition(.opacity)
                    .zIndex(20)
                }
            }
        }
        #endif
    }
    
    func saveHistory() {
        let trimmedText = settings.inputText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedText.count > 1 else { return }

        let isDuplicate = settings.historyTexts.contains {
            $0.inputText.trimmingCharacters(in: .whitespacesAndNewlines) == trimmedText
        }

        guard !isDuplicate else { return }

        if settings.historyTexts.count >= 50 {
            settings.historyTexts.removeFirst()
        }

        let newHistory = HistoryText(
            inputText: trimmedText,
            aurebeshFont: settings.aurebeshFont,
            englishFont: settings.englishFont,
            digraph: settings.digraph,
            date: Date()
        )

        DispatchQueue.main.async {
            withAnimation(.smooth) {
                settings.historyTexts.append(newHistory)
            }
        }
    }
}

#Preview {
    TranslateList()
        .environmentObject(Settings.shared)
}
