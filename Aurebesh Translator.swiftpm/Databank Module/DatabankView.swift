import SwiftUI

struct AlphabetView: View {
    @EnvironmentObject var settings: Settings

    var body: some View {
        #if !os(watchOS)
        HoloCard {
            AlphabetList()
        }
        #else
        HoloCard {
            NavigationView {
                List {
                    HoloCard(showBorder: true) {
                        AlphabetImage()
                            .padding()
                    }
                    .padding(.vertical, 11)
                    .listRowBackground(Color.clear)
                }
                .navigationTitle("Databank")
                .transparentList()
            }
        }
        
        HoloCard {
            NavigationView {
                AlphabetList()
                    .navigationTitle("Letters")
            }
        }
        #endif
    }
}

struct AlphabetList: View {
    @EnvironmentObject var settings: Settings
    
    @Namespace private var letterNS
    @State private var selectedLetter: LetterData? = nil
    @State private var showDetail = false
    @State private var searchText: String = ""
    
    private func columnWidth(for textStyle: UIFont.TextStyle, extra: CGFloat = 4, sample: String? = nil, fontName: String? = nil) -> CGFloat {
        let sampleString = (sample ?? "M") as NSString
        let font: UIFont

        if let fontName = fontName, let customFont = UIFont(name: fontName, size: UIFont.preferredFont(forTextStyle: textStyle).pointSize) {
            font = customFont
        } else {
            font = UIFont.preferredFont(forTextStyle: textStyle)
        }

        return ceil(sampleString.size(withAttributes: [.font: font]).width) + extra
    }

    private var glyphWidth: CGFloat {
        columnWidth(for: .title3, extra: 0, sample: "WI", fontName: settings.aurebeshFont)
    }
    
    private var dashWidth: CGFloat {
        columnWidth(for: .headline, extra: 0, sample: "-")
    }
    
    private var digraphPrefixWidth: CGFloat {
        columnWidth(for: .title3, extra: 4, sample: "(WW )", fontName: settings.aurebeshFont)
    }
    
    private var digraphLatinWidth: CGFloat {
        columnWidth(for: .title3, extra: 4, sample: "WW", fontName: "EnglishStandard")
    }
    
    @ViewBuilder
    private func alphabetRows(_ data: [LetterData]) -> some View {
        ForEach(data) { letter in
            HoloCard(showBorder: true) {
                Group {
                    #if !os(watchOS)
                    HStack(alignment: .center) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(letter.symbol)
                                .font(.custom(settings.aurebeshFont, size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                                .foregroundColor(settings.accentColor.color)
                                .frame(width: glyphWidth, alignment: .center)
                            
                            Text("-")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .frame(width: dashWidth)
                            
                            Text(letter.symbol)
                                .font(.custom("EnglishStandard", size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                                .foregroundColor(.primary)
                                .frame(width: glyphWidth, alignment: .center)
                        }
                        
                        Spacer()
                        
                        if !settings.aurebeshFont.contains("Mand") && !settings.aurebeshFont.contains("OuterRim")  {
                            Text(letter.name)
                                .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                                .foregroundColor(.secondary)
                        }
                    }
                    #else
                    HStack(alignment: .firstTextBaseline) {
                        Text(letter.symbol)
                            .font(.custom(settings.aurebeshFont, size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                            .foregroundColor(settings.accentColor.color)
                            .frame(width: glyphWidth, alignment: .center)
                        
                        Spacer()
                        
                        Text(letter.symbol)
                            .font(.custom("EnglishStandard", size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                            .foregroundColor(.primary)
                            .padding(.top, 1)
                            .frame(width: glyphWidth, alignment: .center)
                    }
                    #endif
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                #if !os(watchOS)
                .contextMenu {
                    Button {
                        if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                        UIPasteboard.general.string = letter.name
                    } label: {
                        Label("Copy Aurebesh Name", systemImage: "doc.on.doc")
                    }
                }
                #endif
            }
            .onTapGesture {
                #if !os(watchOS)
                if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                #else
                if settings.hapticOn { WKInterfaceDevice.current().play(.click) }
                #endif
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    selectedLetter = letter
                    showDetail = true
                }
            }
            #if !os(watchOS)
            .listRowSeparator(.hidden, edges: .all)
            .padding(.vertical, {
                let verticalPadding: CGFloat
                if #available(iOS 26.0, watchOS 26.0, visionOS 26.0, macOS 26.0, *) {
                    verticalPadding = -10
                } else {
                    verticalPadding = 0
                }
                return verticalPadding
            }())
            #endif

            .padding(.horizontal, -4)
        }
    }
    
    @ViewBuilder
    private func alphabetRows(_ data: [LetterData], digraph: Bool) -> some View {
        ForEach(data) { letter in
            HoloCard(showBorder: true) {
                Group {
                    #if !os(watchOS)
                    HStack(alignment: .center) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(letter.symbol)
                                .font(.custom(
                                    settings.aurebeshFont.replacingOccurrences(of: "Digraph", with: "") + "Digraph",
                                    size: UIFont.preferredFont(forTextStyle: .title3).pointSize)
                                )
                                .foregroundColor(settings.accentColor.color)
                                .frame(width: glyphWidth, alignment: .center)
                            
                            HStack(spacing: 0) {
                                Text("( ")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                let characters = Array(letter.symbol)
                                
                                if characters.count >= 2 {
                                    Text(String(characters[0]))
                                        .font(.custom(settings.aurebeshFont, size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                                        .foregroundColor(settings.accentColor.color)
                                    
                                    Text(String(characters[1]))
                                        .font(.custom(settings.aurebeshFont, size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                                        .foregroundColor(settings.accentColor.color)
                                }
                                
                                Text(" )")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: digraphPrefixWidth, alignment: .center)
                        }
                        
                        Text("-")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .frame(width: dashWidth)
                        
                        Text(letter.symbol)
                            .font(.custom("EnglishStandard", size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                            .foregroundColor(.primary)
                            .frame(width: digraphLatinWidth, alignment: .center)
                        
                        Spacer()
                        
                        Text(letter.name)
                            .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                            .foregroundColor(.secondary)
                    }
                    #else
                    HStack(alignment: .firstTextBaseline) {
                        Text(letter.symbol)
                            .font(.custom(
                                settings.aurebeshFont.replacingOccurrences(of: "Digraph", with: "") + "Digraph",
                                size: UIFont.preferredFont(forTextStyle: .title3).pointSize)
                            )
                            .foregroundColor(settings.accentColor.color)
                            .frame(width: glyphWidth, alignment: .center)
                        
                        Spacer()
                        
                        Text(letter.symbol)
                            .font(.custom("EnglishStandard", size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                            .foregroundColor(.primary)
                            .padding(.top, 1)
                            .frame(width: digraphLatinWidth, alignment: .center)
                    }
                    #endif
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                #if !os(watchOS)
                .listRowSeparator(.hidden, edges: .all)
                .contextMenu {
                    Button {
                        if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                        UIPasteboard.general.string = letter.name
                    } label: {
                        Label("Copy Aurebesh Name", systemImage: "doc.on.doc")
                    }
                }
                #endif
            }
            .onTapGesture {
                #if !os(watchOS)
                if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                #else
                if settings.hapticOn { WKInterfaceDevice.current().play(.click) }
                #endif
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    selectedLetter = letter
                    showDetail = true
                }
            }
            #if !os(watchOS)
            .listRowSeparator(.hidden, edges: .all)
            .padding(.vertical, {
                let verticalPadding: CGFloat
                if #available(iOS 26.0, watchOS 26.0, visionOS 26.0, macOS 26.0, *) {
                    verticalPadding = -10
                } else {
                    verticalPadding = 0
                }
                return verticalPadding
            }())
            #endif
            .padding(.horizontal, -4)
        }
    }
    
    var body: some View {
        List {
            Group {
                #if os(watchOS)
                TextField("    🔎 Search", text: $searchText)
                    .multilineTextAlignment(.leading)
                    .font(.custom("EnglishStandard", size: UIFont.preferredFont(forTextStyle: .caption2).pointSize))
                    .cornerRadius(24)
                    .background(settings.accentColor.color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(settings.accentColor.color.opacity(0.4), lineWidth: 1)
                    )
                    .frame(height: 10)
                #endif
                
                #if !os(watchOS)
                HoloCard(showBorder: true) {
                    VStack {
                        VStack(spacing: 4) {
                            Text(settings.pickerStyleSelection + " Alphabet")
                                .font(.custom("EnglishStandard", size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                                .foregroundColor(settings.accentColor.color)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            
                            Text(settings.pickerStyleSelection + " Alphabet")
                                .font(.custom(settings.aurebeshFont, size: UIFont.preferredFont(forTextStyle: .body).pointSize))
                                .foregroundColor(settings.accentColor.color)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .padding(.bottom)
                        }
                        .padding(.top, -2)
                        
                        AlphabetImage { letter in
                            if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                selectedLetter = letter
                                showDetail = true
                            }
                        }
                        
                        AurebeshScriptPicker()
                            .padding(.top)
                    }
                    .padding()
                }
                .listRowSeparator(.hidden)
                #endif
                
                let filteredAurebeshLetters = aurebeshLetters.filter {
                    searchText.isEmpty ? true :
                    $0.name.lowercased().contains(searchText.lowercased()) ||
                    $0.symbol.lowercased().contains(searchText.lowercased()) ||
                    $0.symbol.lowercased().first == searchText.lowercased().first
                }
                
                if !filteredAurebeshLetters.isEmpty {
                    Section(header: Text("STANDARD LETTERS").font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .body).pointSize))) {
                        alphabetRows(filteredAurebeshLetters)
                    }
                }
                
                let filteredDigraphLetters = digraphLetters.filter {
                    searchText.isEmpty ? true :
                    $0.name.lowercased().contains(searchText.lowercased()) ||
                    $0.symbol.lowercased().contains(searchText.lowercased()) ||
                    $0.symbol.lowercased().first == searchText.lowercased().first ||
                    $0.symbol.lowercased().first == searchText.lowercased().first ||
                    $0.name.lowercased().first == searchText.lowercased().first
                }
                
                if settings.aurebeshFont.contains("Aurebesh") && !filteredDigraphLetters.isEmpty {
                    Section(header: Text("DIGRAPH LETTERS").font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .body).pointSize))) {
                        alphabetRows(filteredDigraphLetters, digraph: true)
                    }
                }
                
                let filteredNumberLetters = numberLetters.filter {
                    searchText.isEmpty ? true :
                    $0.name.lowercased().contains(searchText.lowercased())
                }
                
                if !filteredNumberLetters.isEmpty {
                    Section(header: Text("NUMBERS").font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .body).pointSize))) {
                        alphabetRows(filteredNumberLetters)
                    }
                }
                
                let filteredSpecialLetters = specialAlphabetLetters.filter {
                    searchText.isEmpty ? true :
                    $0.name.lowercased().contains(searchText.lowercased())
                }
                
                if !filteredSpecialLetters.isEmpty {
                    Section(header: Text("SPECIAL CHARACTERS").font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .body).pointSize))) {
                        alphabetRows(filteredSpecialLetters)
                    }
                }
                
                if settings.aurebeshFont.contains("Mand") {
                    Section(header: Text("MANDO'A EXPLANATION").font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .body).pointSize))) {
                        Group {
                            Text("Mando'a is a phonetic script with a warrior-like history, written left to right. The term itself means \"Mando language,\" and each symbol represents a distinct sound.")
                            
                            Text("Over time, Mando'a evolved into two forms: Old (Classic) and New Mando'a. The classic form preserves older styles, while the new version reflects modern usage and is more commonly used today.")
                            
                            Link("Learn More about Mando'a", destination: URL(string: "https://project-shereshoy.tumblr.com/post/668753830966657024/development-history-the-mandalorian-alphabet")!)
                                .foregroundColor(settings.accentColor.color == .white ? .blue : settings.accentColor.color)
                        }
                        .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                    }
                } else if settings.aurebeshFont.contains("OuterRim") {
                    if settings.aurebeshFont.contains("OuterRimBasic") {
                        Section(header: Text("OUTER RIM BASIC EXPLANATION").font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .body).pointSize))) {
                            Group {
                                Text("Outer Rim Basic is a script designed for practicality and fast recognition across the galaxy's frontier. It’s widely used in starports, trade posts, and colony settlements where clear, functional signage is critical.")
                                
                                Text("Unlike ornate scripts like Aurebesh, Outer Rim Basic strips symbols down to their most essential forms. It's the working class of galactic scripts. It is efficient, utilitarian, and ubiquitous in the Outer Rim Territories.")
                                
                                Link("Learn More about Outer Rim Basic", destination: URL(string: "https://starwars.fandom.com/wiki/Outer_Rim_Basic")!)
                                    .foregroundColor(settings.accentColor.color == .white ? .blue : settings.accentColor.color)
                            }
                            .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                        }
                    } else if settings.aurebeshFont.contains("OuterRimTongue") {
                        Section(header: Text("OLD TONGUE EXPLANATION").font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .body).pointSize))) {
                            Group {
                                Text("Also called ur-Kittât, the Old Tongue is the forbidden runic language of the Sith. It appears across temples and artifacts on worlds like Malachor and Exegol, and was used in rites, oaths, and prophecies.")
                                
                                Text("Its meaning can shift with line breaks and inflection, and some inscriptions were even transcribed as mirrored Aurebesh to be read backwards—deliberately obscuring their intent.")
                                
                                Text("During the late Republic, droids were barred from translating it, yet the tongue endured within secret orders and among Sith adepts.")
                                
                                Link("Learn more about the Old Tongue", destination: URL(string: "https://starwars.fandom.com/wiki/Ur-Kittât")!)
                                    .foregroundColor(settings.accentColor.color == .white ? .blue : settings.accentColor.color)
                            }
                            .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                        }
                    } else if settings.aurebeshFont.contains("OuterRimSith") {
                        Section(header: Text("SITH SCRIPT EXPLANATION").font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .body).pointSize))) {
                            Group {
                                Text("In Legends, Sith is the language of the original Sith species and later the Sith Order. It’s an agglutinative tongue (long words built from stacked morphemes) and often uses a verb-subject-object word order.")
                                
                                Text("Across eras it was preserved in holocrons, tomes, and temple walls, and spoken by groups like the Lost Tribe of the Sith.")
                                
                                Text("Multiple writing systems existed: early hieroglyphs; Common and High Sith for daily and ceremonial use; and Kittât runes commonly used for incantations.")
                                
                                Link("Learn more about Sith Script", destination: URL(string: "https://starwars.fandom.com/wiki/Sith_(language)")!)
                                    .foregroundColor(settings.accentColor.color == .white ? .blue : settings.accentColor.color)
                            }
                            .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                        }
                    } else if settings.aurebeshFont.contains("OuterRimHive") {
                        Section(header: Text("HIVE SCRIPT EXPLANATION").font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .body).pointSize))) {
                            Group {
                                Text("Hive Script is an organic and spindly writing system used by insectoid civilizations. With looping curves and clustered strokes, its form reflects the hive-minded societies it originates from.")
                                
                                Text("Often etched into stone or metal, Hive Script appears in subterranean structures and ancient blueprints. Its aesthetic is both alien and ancient, designed for caste-based efficiency.")
                                
                                Link("Learn More about Hive Script", destination: URL(string: "https://starwars.fandom.com/wiki/Geonosian_language")!)
                                    .foregroundColor(settings.accentColor.color == .white ? .blue : settings.accentColor.color)
                            }
                            .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                        }
                    } else if settings.aurebeshFont.contains("OuterRimTrade") {
                        Section(header: Text("TRADE SCRIPT EXPLANATION").font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .body).pointSize))) {
                            Group {
                                Text("Trade Script is a formal writing system used by powerful corporate networks in the Outer Rim. Its design prioritizes clarity, authority, and legibility in bureaucratic and economic records.")
                                
                                Text("You’ll see it on cargo manifests, trading consoles, and automated systems. It’s the language of commerce. It is mechanical, assertive, and unmistakably institutional.")
                                
                                Link("Learn More about Trade Script", destination: URL(string: "https://aurekfonts.tumblr.com/post/613875294601371648/tf-gunray")!)
                                    .foregroundColor(settings.accentColor.color == .white ? .blue : settings.accentColor.color)
                            }
                            .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                        }
                    } else if settings.aurebeshFont.contains("OuterRimProtobesh") {
                        Section(header: Text("PROTOBESH EXPLANATION").font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .body).pointSize))) {
                            Group {
                                Text("Protobesh is the earliest known precursor to Aurebesh. Discovered in ancient navigation systems and primordial star charts, it is a raw, angular script that predates modern galactic writing.")
                                
                                Text("Often found in forgotten observatories and deep-space vaults, Protobesh served as the foundation for interstellar language, linking the earliest records of starfaring civilizations.")
                                
                                Link("Learn More about Protobesh", destination: URL(string: "https://starwars.fandom.com/wiki/Aurebesh")!)
                                    .foregroundColor(settings.accentColor.color == .white ? .blue : settings.accentColor.color)
                            }
                            .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                        }
                    }
                } else {
                    Section(header: Text("AUREBESH EXPLANATION").font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .body).pointSize))) {
                        Group {
                            Text("Aurebesh is the standard script for Galactic Basic (English), the most common language in the galaxy. Named after its first two letters, \"Aurek\" and \"Besh,\" it's usually written left to right but can also appear top to bottom.")
                            
                            Text("Each symbol matches a letter in English, making it easy to transcribe. Aurebesh also supports digraphs like \"ch,\" \"ae,\" and \"th,\" though these are rare. Digraph support can be customized in the System Module.")
                            
                            Text("Variants like Cantina Aurebesh are decorative and popular in urban hubs, while Droid Aurebesh features a mechanical design used in technical systems and droid facilities.")
                            
                            Text("From control panels to signage, Aurebesh is everywhere, uniting communication across countless interstellar worlds.")
                            
                            Link("Learn More about Aurebesh on Wookieepedia", destination: URL(string: "https://starwars.fandom.com/wiki/Aurebesh")!)
                                .foregroundColor(settings.accentColor.color == .white ? .blue : settings.accentColor.color)
                        }
                        .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                    }
                }
            }
            .listRowBackground(Color.clear)
        }
        .transparentList()
        #if os(watchOS)
        .listStyle(.carousel)
        #else
        .overlay(alignment: .bottom) {
            SearchBar(text: $searchText.animation(.easeInOut))
                .listRowSeparator(.hidden)
                .padding(.horizontal, 8)
                .padding(.bottom, -8)
        }
        #endif
        .overlay(alignment: .center) {
            if let letter = selectedLetter, showDetail {
                ZStack {
                    Color.black.opacity(0.0001)
                        .ignoresSafeArea()
                    
                    LetterDetailView(
                        letter: letter,
                        namespace: letterNS,
                        onClose: {
                            #if !os(watchOS)
                            if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                            #else
                            if settings.hapticOn { WKInterfaceDevice.current().play(.click) }
                            #endif
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                                showDetail = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                selectedLetter = nil
                            }
                        }
                    )
                    .transition(.opacity)
                    .zIndex(10)
                }
            }
        }
    }
}

struct AlphabetImage: View {
    @EnvironmentObject var settings: Settings

    var onSelect: ((LetterData) -> Void)? = nil

    #if os(watchOS)
    var columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]
    #else
    var columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]
    #endif

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(aurebeshLetters) { letter in
                VStack(spacing: 4) {
                    Text(letter.symbol)
                        .font(.custom(settings.aurebeshFont,
                                      size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                        .foregroundColor(settings.accentColor.color)

                    Text(letter.symbol)
                        .font(.custom("EnglishStandard",
                                      size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture { onSelect?(letter) }
            }

            if settings.aurebeshFont.contains("Aurebesh") {
                ForEach(digraphLetters) { letter in
                    VStack(spacing: 4) {
                        Text(letter.symbol)
                            .font(.custom(
                                settings.aurebeshFont.replacingOccurrences(of: "Digraph", with: "") + "Digraph",
                                size: UIFont.preferredFont(forTextStyle: .title3).pointSize
                            ))
                            .foregroundColor(settings.accentColor.color)

                        Text(letter.symbol)
                            .font(.custom("EnglishStandard",
                                          size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { onSelect?(letter) } // NEW
                }
            }
        }
        #if os(watchOS)
        .padding(.vertical, 8)
        #endif
    }
}

struct LetterDetailView: View {
    @EnvironmentObject var settings: Settings
    
    let letter: LetterData
    let namespace: Namespace.ID
    var onClose: () -> Void

    /// Treat as digraph when the current family is Aurebesh and the symbol has 2+ characters
    private var isDigraphLetter: Bool {
        settings.aurebeshFont.contains("Aurebesh") && letter.symbol.count >= 2
    }

    /// Current family without "Digraph" suffix (so we can exclude it from "other scripts")
    private var currentFamilyBase: String {
        settings.aurebeshFont.replacingOccurrences(of: "Digraph", with: "")
    }

    // compact tiles: squeeze more per row
    // MARK: - Family scoping

    private enum FamilyGroup { case aurebesh, mando, outerRim, unknown }

    private var familyGroup: FamilyGroup {
        let base = currentFamilyBase
        if base.hasPrefix("Aurebesh") { return .aurebesh }
        if base.hasPrefix("Mando")    { return .mando }
        if base.hasPrefix("OuterRim") { return .outerRim }
        return .unknown
    }

    // compact tiles: squeeze more per row
    private var grid: [GridItem] {
        [GridItem(.adaptive(minimum: 110), spacing: 8)]
    }

    /// Fonts to preview ONLY within the same family/section
    private var sectionFonts: [String] {
        switch familyGroup {
        case .aurebesh:
            // all Aurebesh families; always show Digraph variants per your requirement
            return [
                "AurebeshBasic", "AurebeshCore", "AurebeshCantina",
                "AurebeshEquinox", "AurebeshDroid", "AurebeshPixel"
            ].map { $0 + "Digraph" }

        case .mando:
            // just the Mando’a pair
            return ["MandoNew", "MandoOld"]

        case .outerRim:
            // all Outer Rim families
            return [
                "OuterRimBasic", "OuterRimTongue", "OuterRimSith",
                "OuterRimHive", "OuterRimTrade", "OuterRimProtobesh"
            ]

        case .unknown:
            return []
        }
    }

    private var sectionTitle: String {
        switch familyGroup {
        case .aurebesh: return "In Aurebesh styles"
        case .mando:    return "In Mando’a styles"
        case .outerRim: return "In Outer Rim styles"
        case .unknown:  return "In other styles"
        }
    }

    private func displayName(for font: String) -> String {
        // Nice labels for the caption; strips "Digraph" suffix if present
        let base = font.replacingOccurrences(of: "Digraph", with: "")
        switch base {
        case "AurebeshBasic":    return "Aurebesh · Basic"
        case "AurebeshCore":     return "Aurebesh · Core"
        case "AurebeshCantina":  return "Aurebesh · Cantina"
        case "AurebeshEquinox":  return "Aurebesh · Nexus"
        case "AurebeshDroid":    return "Aurebesh · Droid"
        case "AurebeshPixel":    return "Aurebesh · Pixel"
        case "MandoNew":         return "Mando’a · New"
        case "MandoOld":         return "Mando’a · Old"
        case "OuterRimBasic":    return "Outer Rim · Basic"
        case "OuterRimTongue":   return "Outer Rim · Old Tongue"
        case "OuterRimSith":     return "Outer Rim · Sith"
        case "OuterRimHive":     return "Outer Rim · Hive"
        case "OuterRimTrade":    return "Outer Rim · Trade"
        case "OuterRimProtobesh":return "Outer Rim · Protobesh"
        default:                 return base
        }
    }

    var body: some View {
        HoloCard {
            VStack(spacing: 5) {
                Text(letter.symbol)
                    #if !os(watchOS)
                    .font(.custom(settings.aurebeshFont, size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize * 8))
                    #else
                    .font(.custom(settings.aurebeshFont, size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize))
                    #endif
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Text(letter.symbol)
                    #if !os(watchOS)
                    .font(.custom("EnglishStandard", size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize * 2))
                    #else
                    .font(.custom("EnglishStandard", size: UIFont.preferredFont(forTextStyle: .title2).pointSize))
                    #endif
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                #if !os(watchOS)
                if settings.aurebeshFont.contains("Aurebesh") {
                    Text(letter.name)
                        .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .title2).pointSize))
                        .foregroundColor(.secondary)
                }

                if !sectionFonts.isEmpty {
                    Divider().padding(.vertical)

                    LazyVGrid(columns: grid, spacing: 8) {
                        ForEach(sectionFonts, id: \.self) { fontName in
                            HoloCard(showBorder: true) {
                                VStack(spacing: 4) {
                                    Text(letter.symbol)
                                        .font(.custom(
                                            fontName,
                                            size: UIFont.preferredFont(forTextStyle: .title3).pointSize
                                        ))
                                        .foregroundColor(settings.accentColor.color)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)

                                    Text(displayName(for: fontName))
                                        .font(.custom(
                                            settings.systemFont,
                                            size: UIFont.preferredFont(forTextStyle: .caption2).pointSize
                                        ))
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 6)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                #endif

                Button {
                    onClose()
                } label: {
                    HStack {
                        Text("Close")
                            #if !os(watchOS)
                            .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                            #else
                            .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                            #endif
                        
                        Image(systemName: "xmark.circle.fill")
                            #if !os(watchOS)
                            .font(.title2)
                            #else
                            .font(.subheadline)
                            #endif
                    }
                }
                .foregroundColor(.secondary)
                .padding(.top)
            }
            .padding()
            .conditionalGlassEffect(regular: true)
        }
        .padding(.horizontal)
        .animation(.spring(response: 0.45, dampingFraction: 0.9), value: letter.id)
    }
}

#Preview {
    Group {
        #if !os(watchOS)
        AlphabetView()
        #else
        AlphabetList()
            .environmentObject(Settings.shared)
        #endif
    }
    .environmentObject(Settings.shared)
}
