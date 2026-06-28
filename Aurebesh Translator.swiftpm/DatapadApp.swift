import SwiftUI
import WidgetKit
import CoreText
import UIKit


@main
struct DatapadApp: App {
    @ObservedObject private var settings = Settings.shared
    @StateObject private var keyboardObserver = KeyboardObserver()
    
    @State private var isLaunching = true
    @State private var showAlert: Bool = false
    @State private var shouldAnimate: Bool = false
    @State private var rotationAngle: Double = 0
    @State private var viewOrder: [(title: String, view: ActiveView)] = [
        ("Databank", .alphabet), ("System", .settings), ("Transcoder", .translate)
    ]
    
    func registerCustomFonts() {
        let fontNames = [
            "AurebeshBasic",
            "AurebeshBasicDigraph",
            "AurebeshCantina",
            "AurebeshCantinaDigraph",
            "AurebeshCore",
            "AurebeshCoreDigraph",
            "AurebeshDroid",
            "AurebeshDroidDigraph",
            "AurebeshEquinox",
            "AurebeshEquinoxDigraph",
            "AurebeshPixel",
            "AurebeshPixelDigraph",
            "EnglishCanon",
            "EnglishGalactic",
            "EnglishStandard",
            "MandoNew",
            "MandoOld",
            "OuterRimBasic",
            "OuterRimHive",
            "OuterRimProtobesh",
            "OuterRimSith",
            "OuterRimTongue",
            "OuterRimTrade"
        ]

        for fontName in fontNames {
            if let url = Bundle.main.url(forResource: fontName, withExtension: "otf") {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            } else {
                print("❌ Font not found:", fontName)
            }
        }
    }
    
    init() {
        registerCustomFonts()
        
        if let customFont = UIFont(name: settings.systemFont, size: UIFont.preferredFont(forTextStyle: .caption2).pointSize) {
            UISegmentedControl.appearance().setTitleTextAttributes(
                [
                    .font: customFont
                ], for: .normal)
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.black.ignoresSafeArea()
                
                GalacticBackground()
                    .ignoresSafeArea()
                    .opacity(!settings.isMenuOpen ? 1 : 0)
                    .animation(.smooth(duration: 0.2), value: settings.isMenuOpen)
                
                if isLaunching && !settings.skipLaunching {
                    LaunchScreen(isLaunching: $isLaunching)
                } else if settings.firstLaunch {
                    SplashScreen()
                } else {
                    VStack {
                        ZStack {
                            VStack {
                                Image("Title")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .colorMultiply(settings.accentColor.color.opacity(0.9))
                                    .animation(.smooth(duration: 1.0), value: settings.accentColor)
                                
                                switch settings.activeView {
                                case .translate:
                                    TranslateView()
                                case .share:
                                    ShareView()
                                case .crystal:
                                    CrystalView()
                                case .alphabet:
                                    AlphabetView()
                                case .settings:
                                    SettingsView()
                                case .history:
                                    HistoryView()
                                case .quiz:
                                    QuizView()
                                }
                            }
                            
                            Color.black
                                .opacity(settings.isMenuOpen ? 0.75 : 0)
                                .ignoresSafeArea()
                                .disabled(!settings.isMenuOpen)
                                .onTapGesture {
                                    if settings.isMenuOpen {
                                        if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                        
                                        withAnimation(.smooth(duration: 0.4)) {
                                            settings.isMenuOpen = false
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        }
                                    }
                                }
                        }
                        .environmentObject(settings)
                        .environmentObject(keyboardObserver)
                        .accentColor(settings.accentColor.color)
                        .tint(settings.accentColor.color)
                        .animation(.smooth(duration: 0.4), value: settings.activeView)
                        .animation(.smooth(duration: 0.4), value: settings.isMenuOpen)
                        
                        if !keyboardObserver.isKeyboardVisible {
                            Button(action: {
                                if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    settings.isMenuOpen.toggle()
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                            }) {
                                Group {
                                    Image("DatapadIcon")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .colorMultiply(settings.accentColor.color.opacity(0.9))
                                        .frame(width: 60, height: 60)
                                        .animation(.smooth(duration: 1.0), value: settings.accentColor.color)
                                        .overlay(
                                            settings.isMenuOpen ?
                                            Image("DatapadIcon")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .colorMultiply(settings.accentColor.color.opacity(0.9))
                                                .frame(width: 75, height: 75)
                                                .shadow(color: settings.accentColor.color.opacity(0.25), radius: 10, x: 0.0, y: 0.0)
                                                .blur(radius: 5)
                                                .opacity(0.25)
                                                .overlay {
                                                    Image("DatapadIcon")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .colorMultiply(settings.accentColor.color.opacity(0.9))
                                                        .frame(width: 90, height: 90)
                                                        .shadow(color: settings.accentColor.color.opacity(0.25), radius: 10, x: 0.0, y: 0.0)
                                                        .blur(radius: 5)
                                                        .opacity(0.25)
                                                }
                                            : nil
                                        )
                                }
                                .padding(.bottom, UIScreen.main.bounds.width >= 500 ? 8 : 0)
                                .animation(.smooth(duration: 0.4), value: settings.isMenuOpen)
                                .rotationEffect(.degrees(rotationAngle))
                                .animation(.easeInOut(duration: 0.75), value: rotationAngle)
                            }
                            .padding(.top, 12)
                            .overlay(
                                VStack {
                                    Spacer()
                                    
                                    HStack {
                                        Button(action: {
                                            if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                            
                                            withAnimation(.smooth(duration: 0.4)) {
                                                settings.isMenuOpen = false
                                                settings.lastView = settings.activeView
                                                settings.activeView = .history
                                            }
                                        }) {
                                            VStack(spacing: 4) {
                                                Image(systemName: "clock.fill")
                                                    .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .caption1).pointSize))
                                                
                                                Text("Archives")
                                                    .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .caption1).pointSize))
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.5)
                                                    .padding(.top, 4)
                                            }
                                            .padding(1)
                                            .frame(height: 60)
                                            .frame(minWidth: 60)
                                            .frame(maxWidth: .infinity)
                                            .foregroundColor(.primary)
                                            .conditionalGlassEffect(tint: settings.activeView == .history ? settings.accentColor.color.opacity(2) : nil)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.5)
                                        }
                                        .frame(height: 60)
                                        
                                        HolographicButton(currentView: viewOrder[1], image: "gearshape", action: {
                                            if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                            
                                            withAnimation(.smooth(duration: 0.4)) {
                                                settings.isMenuOpen = false
                                                settings.lastView = settings.activeView
                                                settings.activeView = viewOrder[1].view
                                            }
                                        })
                                        
                                        Button(action: {
                                            if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                            
                                            withAnimation(.smooth(duration: 0.4)) {
                                                settings.isMenuOpen = false
                                                settings.lastView = settings.activeView
                                                settings.activeView = .quiz
                                            }
                                        }) {
                                            VStack(spacing: 4) {
                                                Image(systemName: "checklist")
                                                    .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .caption1).pointSize))
                                                
                                                Text("Trials")
                                                    .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .caption1).pointSize))
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.5)
                                                    .padding(.top, 4)
                                            }
                                            .padding(1)
                                            .frame(height: 60)
                                            .frame(minWidth: 60)
                                            .frame(maxWidth: .infinity)
                                            .foregroundColor(.primary)
                                            .conditionalGlassEffect(tint: settings.activeView == .quiz ? settings.accentColor.color.opacity(2) : nil)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.5)
                                        }
                                        .frame(height: 60)
                                    }
                                    
                                    HStack {
                                        HolographicButton(currentView: viewOrder[2], image: "switch.2", action: {
                                            if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                            
                                            withAnimation(.smooth(duration: 0.4)) {
                                                settings.isMenuOpen = false
                                                settings.lastView = settings.activeView
                                                settings.activeView = viewOrder[2].view
                                            }
                                        })
                                        
                                        Button(action: {
                                            if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                            
                                            withAnimation(.smooth(duration: 0.4)) {
                                                settings.isMenuOpen = false
                                                settings.lastView = settings.activeView
                                                settings.activeView = .crystal
                                            }
                                        }) {
                                            ZStack {
                                                BackgroundView(shouldAnimate: $shouldAnimate, stroke: settings.activeView == .crystal, bigCrystal: false)
                                                    .onAppear {
                                                        shouldAnimate = true
                                                    }
                                                    .onDisappear {
                                                        shouldAnimate = false
                                                    }
                                                    .frame(height: 60)
                                                
                                                CrystalImage(width: 38)
                                                    .padding(.top, 14)
                                            }
                                            .frame(height: 60)
                                        }
                                        .conditionalGlassEffect(tint: settings.activeView == .crystal ? settings.accentColor.color.opacity(1.5) : nil)
                                        
                                        HolographicButton(currentView: viewOrder[0], image: "alphabet", action: {
                                            if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                            
                                            withAnimation(.smooth(duration: 0.4)) {
                                                settings.isMenuOpen = false
                                                settings.lastView = settings.activeView
                                                settings.activeView = viewOrder[0].view
                                            }
                                        })
                                    }
                                    .padding(.top, 2)
                                    
                                    AurebeshScriptPicker(showBackground: true)
                                        .padding(.top, 2)
                                    
                                    HStack {
                                        Button(action: {
                                            if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                            
                                            withAnimation(.smooth(duration: 0.4)) {
                                                settings.isMenuOpen = false
                                                let previousView = settings.activeView
                                                settings.activeView = settings.lastView
                                                settings.lastView = previousView
                                            }
                                        }) {
                                            VStack(spacing: 5) {
                                                Image(systemName: "arrowshape.turn.up.backward.fill")
                                                    .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .caption1).pointSize))
                                                
                                                Text("Return")
                                                    .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .caption2).pointSize - 1))
                                                    .padding(.horizontal, 6)
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.25)
                                                    .padding(.top, 4)
                                            }
                                            .padding(1)
                                            .frame(width: 60, height: 60)
                                            .foregroundColor(settings.lastView == settings.activeView ? .secondary : .primary)
                                            .conditionalGlassEffect(
                                                tint: settings.lastView == settings.activeView ?
                                                    .secondary : settings.accentColor.color
                                            )
                                            .disabled(settings.lastView == settings.activeView)
                                        }
                                        .disabled(settings.lastView == settings.activeView)
                                        
                                        RoundedRectangle(cornerRadius: 24)
                                            .foregroundStyle(Color.black.opacity(0.001))
                                            .onTapGesture {
                                                if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                                
                                                withAnimation(.smooth(duration: 0.4)) {
                                                    settings.isMenuOpen = false
                                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                                }
                                            }
                                        
                                        Button(action: {
                                            if settings.inputText.isEmpty {
                                                if settings.hapticOn { UINotificationFeedbackGenerator().notificationOccurred(.error) }
                                                
                                                showAlert = true
                                            } else {
                                                if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                                
                                                withAnimation(.smooth(duration: 0.4)) {
                                                    settings.isMenuOpen = false
                                                    settings.lastView = settings.activeView
                                                    settings.activeView = .share
                                                }
                                            }
                                        }) {
                                            VStack(spacing: 5) {
                                                Image(systemName: settings.inputText.isEmpty ? "square.and.arrow.up.trianglebadge.exclamationmark" : "square.and.arrow.up.fill")
                                                    .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .caption1).pointSize))
                                                
                                                Text("Transmit")
                                                    .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .caption2).pointSize - 1))
                                                    .padding(.horizontal, 6)
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.25)
                                            }
                                        }
                                        .padding(1)
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(settings.inputText.isEmpty ? .secondary : .primary)
                                        .conditionalGlassEffect(
                                            tint: settings.inputText.isEmpty ?
                                                .secondary : settings.activeView == .share ? settings.accentColor.color.opacity(2) : nil
                                        )
                                        .animatedAlert(isPresented: $showAlert, title: "Input Text is Empty", message: "")
                                    }
                                    .padding(.top, 10)
                                }
                                .disabled(!settings.isMenuOpen)
                                .environmentObject(settings)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                                .padding(.bottom, 220)
                                .scaleEffect(settings.isMenuOpen ? 1.0 : 0.1)
                                .opacity(settings.isMenuOpen ? 1 : 0)
                                .animation(.smooth(duration: 0.4), value: settings.isMenuOpen)
                                .transition(.scale)
                            )
                        }
                    }
                    .frame(maxHeight: UIScreen.main.bounds.height)
                }
            }
            .environmentObject(settings)
            .background(.black)
            .preferredColorScheme(.dark)
            .transition(.opacity)
            .accentColor(settings.accentColor.color)
            .tint(settings.accentColor.color)
            .animation(.easeInOut, value: isLaunching)
            .animation(.easeInOut, value: settings.firstLaunch)
        }
        .onChange(of: settings.digraph) { on in
            withAnimation(.smooth) {
                let base = settings.aurebeshFont.replacingOccurrences(of: "Digraph", with: "")
                settings.aurebeshFont = base + (on ? "Digraph" : "")
            }
        }
        .onChange(of: settings.aurebeshFont) { newValue in
            if settings.useAurebesh {
                withAnimation(.smooth) {
                    settings.systemFont = newValue
                }
            }
        }
        .onChange(of: settings.useAurebesh) { newValue in
            withAnimation(.smooth) {
                if newValue {
                    settings.systemFont = settings.aurebeshFont
                } else {
                    settings.systemFont = "EnglishStandard"
                }
            }
        }
        .onChange(of: settings.systemFont) { newFont in
            withAnimation(.smooth) {
                if let customFont = UIFont(name: newFont, size: UIFont.preferredFont(forTextStyle: .caption2).pointSize) {
                    UISegmentedControl.appearance().setTitleTextAttributes([.font: customFont], for: .normal)
                    UISegmentedControl.appearance().setTitleTextAttributes([.font: customFont], for: .selected)
                }
                
                settings.refreshID = UUID()
            }
        }.onChange(of: settings.isMenuOpen) { newValue in
            withAnimation(.easeInOut(duration: 0.75)) {
                if newValue {
                    rotationAngle += 360
                } else {
                    rotationAngle -= 360
                }
            }
        }
        .onChange(of: settings.pickerStyleSelection) { newValue in
            withAnimation(.smooth) {
                if newValue == "Aurebesh" {
                    settings.aurebeshFont = "AurebeshBasic" + (settings.digraph ? "Digraph" : "")
                } else if newValue == "Mando'a" {
                    settings.aurebeshFont = "MandoNew"
                } else if newValue == "Outer Rim" {
                    settings.aurebeshFont = "OuterRimBasic"
                }
            }
        }
    }
}
