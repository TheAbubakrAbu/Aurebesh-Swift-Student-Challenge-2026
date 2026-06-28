import SwiftUI

struct CrystalView: View {
    @EnvironmentObject var settings: Settings
    
    @State private var shouldAnimateBackground = false
    @State private var shouldAnimate = false
    
    var body: some View {
        #if os(watchOS)
        HoloCard {
            NavigationView {
                List {
                    content
                        .listRowBackground(Color.clear)
                }
                .navigationTitle("Crystal")
                .transparentList()
            }
        }
        
        HoloCard {
            NavigationView {
                List {
                    Crystals()
                        .listRowBackground(Color.clear)
                }
                .transparentList()
                .navigationTitle("Crystals")
            }
        }
        #else
        HoloCard {
            FillScroll {
                content
                Crystals()
            }
            .padding(.horizontal)
        }
        #endif
    }
    
    private var content: some View {
        ZStack {
            BackgroundView(shouldAnimate: $shouldAnimateBackground, stroke: false)
            
            VStack {
                CrystalImage(width: 100, shouldAnimateCrystal: $shouldAnimate)
                
                Text(settings.crystal == .normal ? settings.accentColor.crystalName : settings.crystal.crystalName)
                    .foregroundColor(settings.crystal == .black ? .secondary : settings.crystal == .normal ? settings.accentColor.color : .white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity)
                    .font(.custom("EnglishStandard", size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                    .padding(1)
                    .padding(.horizontal, 4)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text(settings.crystal == .normal ? settings.accentColor.crystalName : settings.crystal.crystalName)
                    .foregroundColor(settings.crystal == .black ? .secondary : settings.crystal == .normal ? settings.accentColor.color : .white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity)
                    .font(.custom(settings.aurebeshFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                    .padding(1)
                    .padding(.horizontal, 4)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .padding()
            .padding(.vertical, 10)
        }
        #if os(watchOS)
        .padding(.vertical, 11)
        #endif
        .onTapGesture {
            #if !os(watchOS)
            if settings.hapticOn { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
            #else
            if settings.hapticOn { WKInterfaceDevice.current().play(.click) }
            #endif
            
            shouldAnimate.toggle()
        }
    }
}

private struct FillScroll<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .center, content: content)
                    .frame(maxWidth: .infinity,
                           minHeight: geo.size.height,
                           alignment: .top)
            }
        }
    }
}

#Preview {
    CrystalView()
        .environmentObject(Settings.shared)
}
