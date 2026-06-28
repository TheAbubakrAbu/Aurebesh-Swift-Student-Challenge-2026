import SwiftUI

struct SplashScreen: View {
    @EnvironmentObject var settings: Settings
    
    @Binding var isLaunching: Bool
    
    @State var continueAnimation = true
    @State private var colorIndex: Int = 0
    @State private var timer: Timer? = nil
    @State private var showCrystal = false
    @State private var showSmallCrystals = false
    @State private var showCrystalName = false
    
    @State private var showRectangle = false
    @State private var rectangleSize = CGSize(width: 200, height: 200)
    @State private var rectangleOpacity = 0.0
    @State private var screenSize = UIScreen.main.bounds.size
    
    @Namespace private var crystalNS
    
    init(isLaunching: Binding<Bool>? = nil) {
        self._isLaunching = isLaunching ?? .constant(true)
    }
    
    var body: some View {
        VStack(alignment: .center) {
            if !continueAnimation {
                Image("Title")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .colorMultiply(settings.accentColor.color.opacity(0.9))
                    .animation(.smooth, value: settings.accentColor)
            }
            
            if !continueAnimation {
                VStack {
                    Text("Hello There!\n\nWelcome to Datapad, the ultimate Aurebesh translator in the galaxy!\n\nBefore we begin, let's select your crystal. Your crystal will become the core of your Datapad, unlocking its full potential.\n\nIt will guide your journey, enhancing your connection to the galaxy's secrets.")
                        .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                        .minimumScaleFactor(0.5)
                }
                .multilineTextAlignment(.leading)
                .transition(.opacity)
                .animation(.smooth(duration: 2.0).delay(0.25), value: continueAnimation)
                .padding(20)
            }
            
            Spacer()
            
            if showCrystal {
                RGBCrystal(continueAnimation: $continueAnimation, showCrystalName: $showCrystalName, rectangleSize: $rectangleSize)
                    .padding(.vertical)
            }
            
            if showSmallCrystals {
                LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 12), count: 6)) {
                    ForEach(accentColors, id: \.self) { accent in
                        CrystalCell(
                            accent: accent,
                            selected: accent == settings.accentColor,
                            namespace: crystalNS
                        ) {
                            guard !continueAnimation else { return }
                            if settings.hapticOn { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }

                            withAnimation(.smooth(duration: 1.0)) {
                                settings.accentColor = accent
                                settings.accentColor = accent
                                colorIndex = accentColors.firstIndex(of: accent) ?? 0
                            }
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: settings.accentColor)
                .padding(.horizontal)
            }
            
            if continueAnimation {
                Spacer()
            }
            
            if !continueAnimation {
                Button(action: {
                    if settings.hapticOn { if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() } }
                    
                    withAnimation(.smooth()) {
                        continueAnimation.toggle()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if settings.hapticOn { UINotificationFeedbackGenerator().notificationOccurred(.success) }
                            
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showSmallCrystals = false
                                showCrystalName = false
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showRectangle = true
                                    rectangleSize = CGSize(width: 200, height: 200)
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    if settings.hapticOn { UINotificationFeedbackGenerator().notificationOccurred(.success) }
                                    
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        rectangleOpacity = 0.25
                                        rectangleSize = screenSize
                                        showCrystal = false
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        if settings.hapticOn { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
                                        
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            rectangleOpacity = 0.0
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                showRectangle = false
                                            }
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                                if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                                
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    settings.firstLaunch = false
                                                    isLaunching = false
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }) {
                    Text("I'm Ready to Translate!")
                        .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.primary)
                        .conditionalGlassEffect()
                        .padding(.top, 25)
                }
                .padding(.horizontal, 26)
            }

        }
        .overlay {
            if showRectangle {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(settings.accentColor.color, lineWidth: 5)
                    .shadow(color: settings.accentColor.color, radius: 10, x: 0.0, y: 0.0)
                    .blur(radius: 5)
                    .opacity(rectangleOpacity)
                    .background(settings.accentColor.color.opacity(0.1))
                    .cornerRadius(24)
                    .shadow(color: settings.accentColor.color.opacity(0.5), radius: 10, x: 0.0, y: 0.0)
                    .frame(width: rectangleSize.width, height: rectangleSize.height)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                
                withAnimation(.smooth(duration: 1.0)) {
                    showCrystal = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if settings.hapticOn { UINotificationFeedbackGenerator().notificationOccurred(.success) }
                    
                    withAnimation(.smooth(duration: 1.0)) {
                        settings.accentColor = Array(accentColors).first ?? .white
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        if settings.hapticOn { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
                        
                        withAnimation(.smooth(duration: 1.0)) {
                            showSmallCrystals = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            startColorCycle()
                        }
                    }
                }
            }
        }
    }
    
    private func startColorCycle() {
        let colors = accentColors
        timer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                colorIndex = (colorIndex + 1) % colors.count
                settings.accentColor = colors[colorIndex]
                if settings.hapticOn { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
                
                if colorIndex == 0 {
                    withAnimation(.smooth(duration: 1)) {
                        stopColorCycle()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            if settings.hapticOn { UINotificationFeedbackGenerator().notificationOccurred(.success) }

                            withAnimation(.smooth(duration: 2.0)) {
                                continueAnimation = false
                                let colors = Array(accentColors)
                                settings.accentColor = colors.first ?? .blue
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func stopColorCycle() {
        timer?.invalidate()
        timer = nil
    }
}

struct RGBCrystal: View {
    @EnvironmentObject var settings: Settings
    
    @Binding var continueAnimation: Bool
    @Binding var showCrystalName: Bool
    @Binding var rectangleSize: CGSize
    
    var body: some View {
        VStack {
            settings.accentColor.image
                .frame(width: 100, height: 100)
                .overlay {
                    settings.accentColor.image
                        .frame(width: 125, height: 125)
                        .blur(radius: 7)
                        .opacity(0.25)
                }
                
            VStack {
                if showCrystalName {
                    Text(settings.accentColor.crystalName)
                        .foregroundColor(settings.accentColor.color)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.opacity)
                        .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .title2).pointSize + 2))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(1)
                    
                    Text(settings.accentColor.crystalName)
                        .foregroundColor(settings.accentColor.color)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.opacity)
                        .font(.custom(settings.aurebeshFont, size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 1)
                        .padding(.bottom, 1)
                }
            }
            .padding()
            .padding(.vertical, 4)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.smooth(duration: 1.0)) {
                    showCrystalName = true
                }
            }
        }
    }
}

struct CrystalCell: View {
    let accent: AccentColor
    let selected: Bool
    let namespace: Namespace.ID
    let tap: () -> Void

    var body: some View {
        accent.image
            .frame(width: 35, height: 35)
            .background {
                if selected {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(accent.color.opacity(0.25))
                        .frame(width: 45, height: 45)
                        .matchedGeometryEffect(id: "highlight", in: namespace)
                        .drawingGroup()
                }
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: tap)
    }
}
