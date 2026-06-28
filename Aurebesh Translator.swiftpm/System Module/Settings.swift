import SwiftUI
import os

let logger = Logger(subsystem: "com.Quran.Elmallah.Datapad", category: "Datapad")

final class Settings: ObservableObject {
    private let userDefaults: UserDefaults
    static let shared = Settings()
    
    @Published var refreshID = UUID()
    
    @Published var activeView: ActiveView = .translate
    @Published var lastView: ActiveView = .translate
    
    @Published var accentColor: AccentColor {
        didSet {
            userDefaults.setValue(accentColor.rawValue, forKey: "accentColor")
        }
    }
    
    @Published var crystal: Crystal {
        didSet { userDefaults.setValue(crystal.rawValue, forKey: "crystal") }
    }
    
    @Published var digraph: Bool {
        didSet { userDefaults.setValue(digraph, forKey: "digraph") }
    }
    
    @Published var aurebeshFont: String {
        didSet {
            userDefaults.setValue(aurebeshFont, forKey: "aurebeshGalacticFont")
        }
    }
    
    @Published var englishFont: String {
        didSet { userDefaults.setValue(englishFont, forKey: "englishGalacticFont") }
    }
    
    @Published var historyTexts: [HistoryText] {
        didSet {
            if let encoded = try? JSONEncoder().encode(historyTexts) {
                userDefaults.set(encoded, forKey: "historyTexts")
            }
        }
    }
    
    @AppStorage("galaxyBackgroundMode") var galaxyBackgroundMode: String = GalaxyBackgroundMode.dynamicMode.rawValue
    var galaxyMode: GalaxyBackgroundMode {
        get { GalaxyBackgroundMode(rawValue: galaxyBackgroundMode) ?? .offMode }
        set { galaxyBackgroundMode = newValue.rawValue }
    }
    
    @AppStorage("starfieldStyle") private var starfieldStyleRaw: String = StarfieldStyle.both.rawValue
    var starfieldStyle: StarfieldStyle {
        get { StarfieldStyle(rawValue: starfieldStyleRaw) ?? .both }
        set { starfieldStyleRaw = newValue.rawValue }
    }
    
    @AppStorage("useAccentColorGalaxy") var useAccentColorGalaxy: Bool = true
    
    @AppStorage("useAurebesh") var useAurebesh: Bool = false
    
    @AppStorage("systemFont") var systemFont: String = "EnglishStandard"
    
    @AppStorage("hapticOn") var hapticOn: Bool = true
    
    @AppStorage("skipLaunching") var skipLaunching: Bool = false
    
    @AppStorage("translatingToAurebesh") var translatingToAurebesh: Bool = false
        
    @AppStorage("aurebeshFontSize") var aurebeshFontSize: Double = UIFont.preferredFont(forTextStyle: .body).pointSize * 1.6
    
    @AppStorage("useSystemFontSize") var useSystemFontSize: Bool = true
    
    @AppStorage("firstLaunch") var firstLaunch: Bool = true
        
    @AppStorage("pickerStyleSelection") var pickerStyleSelection: String = "Aurebesh"
    
    @Published var inputText: String = ""
    
    @Published var isMenuOpen = false
        
    private init() {
        guard let defaults = UserDefaults(suiteName: "group.com.Datapad.AppGroup") else {
            fatalError("Unable to access App Group UserDefaults")
        }
        self.userDefaults = defaults

        let defaultsDict: [String: Any] = [
            "accentColor": "white",
            "crystal": "normal",
            "digraph": true,
            "aurebeshGalacticFont": "AurebeshBasicDigraph",
            "englishGalacticFont": "EnglishStandard",
        ]
        userDefaults.register(defaults: defaultsDict)

        self.accentColor = AccentColor(rawValue: userDefaults.string(forKey: "accentColor") ?? "white") ?? .white
        self.crystal = Crystal(rawValue: userDefaults.string(forKey: "crystal") ?? "normal") ?? .normal
        self.digraph = userDefaults.bool(forKey: "digraph")
        self.aurebeshFont = userDefaults.string(forKey: "aurebeshGalacticFont") ?? "AurebeshBasicDigraph"
        self.englishFont = userDefaults.string(forKey: "englishGalacticFont") ?? "EnglishStandard"
        
        if let data = userDefaults.data(forKey: "historyTexts"),
           let decoded = try? JSONDecoder().decode([HistoryText].self, from: data) {
            self.historyTexts = decoded
        } else {
            self.historyTexts = []
        }
    }
}

let aurebeshFonts: [String] = [
    "AurebeshBasic",
    "AurebeshCore",
    "AurebeshDroid",
    "AurebeshEquinox",
    "AurebeshCantina",
    "AurebeshPixel",
    
    "MandoNew",
    "MandoOld",
    
    "OuterRimBasic",
    "OuterRimTongue",
    "OuterRimSith",
    "OuterRimHive",
    "OuterRimTrade",
    "OuterRimProtobesh",
]

let aurebeshFontNames: [String] = [
    "Aurebesh Basic",
    "Aurebesh Core",
    "Aurebesh Droid",
    "Aurebesh Equinox",
    "Aurebesh Cantina",
    "Aurebesh Pixel",
    
    "New Mando’a",
    "Old Mando’a",
    
    "Outer Rim Basic",
    "Outer Rim Old Tongue",
    "Outer Rim Sith",
    "Outer Rim Hive",
    "Outer Rim Trade",
    "Outer Rim Protobesh",
]

enum AccentColor: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }

    case blue, green, yellow, purple, white, red
    case cyan, mint, orange, indigo, brown, pink
    case equator, jade, electrum, amethyst, graphite, fuchsia

    enum Category {
        case standard
        case premium1
        case premium2
    }

    var category: Category {
        switch self {
        case .blue, .green, .yellow, .purple, .white, .red:
            return .standard
        case .cyan, .mint, .orange, .indigo, .brown, .pink:
            return .premium1
        default:
            return .premium2
        }
    }

    var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        case .purple: return .purple
        case .white: return .white
        case .red: return .red
        
        case .cyan: return .cyan
        case .mint: return .mint
        case .orange: return .orange
        case .indigo: return .indigo
        case .brown: return .brown
        case .pink: return .pink

        case .equator: return Color(red: 0.4, green: 0.5, blue: 0.9)
        case .jade: return Color(red: 0.3, green: 0.9, blue: 0.5)
        case .electrum: return Color(red: 188/255, green: 157/255, blue: 57/255)
        case .amethyst: return Color(red: 0.6, green: 0.4, blue: 0.8)
        case .graphite: return .gray
        case .fuchsia: return Color(red: 0.8, green: 0.3, blue: 0.7)
        }
    }
    
    var crystalName: String {
        return "\(self.rawValue.capitalized) Crystal"
    }
    
    var image: some View {
        return AnyView(
            Image("Crystal")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .overlay {
                    LinearGradient(
                        gradient: Gradient(colors: [self.color]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .mask(
                        Image("Crystal")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    )
                    .opacity(0.55)
                }
        )
    }
    
    var widgetImageSmall: some View {
        return AnyView(
            Image("WidgetCrystalSmall")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .overlay {
                    LinearGradient(
                        gradient: Gradient(colors: [self.color]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .mask(
                        Image("WidgetCrystalSmall")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    )
                    .opacity(0.55)
                }
        )
    }
    
    var widgetImageWatch: some View {
        return AnyView(
            Image("WidgetCrystalWatch")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .overlay {
                    LinearGradient(
                        gradient: Gradient(colors: [self.color]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .mask(
                        Image("WidgetCrystalWatch")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    )
                    .opacity(0.55)
                }
        )
    }
}

enum Crystal: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    case normal, dawn, dusk, twilight, tempest, midnight
    case starlight, eclipse, aurora, nebula, solstice, balance
    case ember, forge, horizon, genesis, black, rgb

    var crystalName: String {
        return "\(self.rawValue.capitalized) Crystal"
    }

    var gradientColors: [Color] {
        switch self {
        case .balance: return [.blue, .red]
        case .solstice: return [.green, .orange]
        case .ember: return [.red, .yellow]
        case .dawn: return [.purple, .pink]
        case .nebula: return [.green, .teal]
        case .aurora: return [.blue, .purple]
        case .twilight: return [.orange, .purple]
        case .dusk: return [.yellow, .indigo]
        case .midnight: return [.black, .blue]
        case .eclipse: return [.black, .gray, .indigo]
        case .tempest: return [.indigo, .mint]
        case .horizon: return [.orange, .yellow, .pink, .purple]
        case .genesis: return [.green, .mint, .blue]
        case .forge: return [.purple, .red, .orange]
        case .starlight: return [.white, .cyan, .purple]
        case .black: return [.white, .white, .white, .gray]
        case .rgb: return [.red, .orange, .yellow, .green, .blue, .purple]
        default: return [.white, .white, .white, .black]
        }
    }

    var image: some View {
        if self == .black {
            return AnyView(
                Image("Crystal")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay {
                        LinearGradient(
                            gradient: Gradient(colors: [.white]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .mask(
                            Image("Crystal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        )
                        .opacity(0.75)
                    }
                    .colorInvert()
            )
        } else {
            return AnyView(
                Image("Crystal")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay {
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .mask(
                            Image("Crystal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        )
                        .opacity(self == .rgb ? 0.5 : 0.55)
                    }
            )
        }
    }
    
    var widgetImageSmall: some View {
        if self == .black {
            return AnyView(
                Image("WidgetCrystalSmall")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay {
                        LinearGradient(
                            gradient: Gradient(colors: [.white]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .mask(
                            Image("WidgetCrystalSmall")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        )
                        .opacity(0.75)
                    }
                    .colorInvert()
            )
        } else {
            return AnyView(
                Image("WidgetCrystalSmall")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay {
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .mask(
                            Image("WidgetCrystalSmall")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        )
                        .opacity(self == .rgb ? 0.5 : 0.55)
                    }
            )
        }
    }
    
    var widgetImageWatch: some View {
        if self == .black {
            return AnyView(
                Image("WidgetCrystalWatch")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay {
                        LinearGradient(
                            gradient: Gradient(colors: [.white]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .mask(
                            Image("WidgetCrystalWatch")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        )
                        .opacity(0.75)
                    }
                    .colorInvert()
            )
        } else {
            return AnyView(
                Image("WidgetCrystalWatch")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay {
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .mask(
                            Image("WidgetCrystalWatch")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        )
                        .opacity(self == .rgb ? 0.5 : 0.55)
                    }
            )
        }
    }
}

let accentColors: [AccentColor] = AccentColor.allCases.filter { $0.category == .standard }
let premiumAccentColors1: [AccentColor] = AccentColor.allCases.filter { $0.category == .premium1 }
let premiumAccentColors2: [AccentColor] = AccentColor.allCases.filter { $0.category == .premium2 }
let allAccentColors: [AccentColor] = AccentColor.allCases

let crystals: [Crystal] = Crystal.allCases

struct HistoryText: Identifiable, Codable, Equatable {
    let id: UUID
    var inputText: String
    var aurebeshFont: String
    var digraph: Bool
    var date: Date

    init(inputText: String, aurebeshFont: String, englishFont: String, digraph: Bool, date: Date) {
        self.id = UUID()
        self.inputText = inputText
        self.aurebeshFont = aurebeshFont
        self.digraph = digraph
        self.date = date
    }
    
    static func == (lhs: HistoryText, rhs: HistoryText) -> Bool {
        lhs.id == rhs.id
    }
}

enum ActiveView {
    case translate, alphabet, settings, share, crystal, history, quiz
}

enum GalaxyBackgroundMode: String, CaseIterable, Identifiable {
    case offMode = "Off"
    case staticMode = "Static"
    case dynamicMode = "Dynamic"
    
    var id: String { self.rawValue }
}

enum StarfieldStyle: String, CaseIterable, Identifiable {
    case streaks = "Streaks"
    case circles = "Stars"
    case both = "Both"
    
    var id: String { rawValue }
}
