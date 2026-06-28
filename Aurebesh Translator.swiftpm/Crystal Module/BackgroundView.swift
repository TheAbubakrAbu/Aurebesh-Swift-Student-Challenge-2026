import SwiftUI

struct BackgroundView: View {
    @EnvironmentObject var settings: Settings
    
    @Binding var shouldAnimate: Bool
    let stroke: Bool
    var bigCrystal: Bool = true
    
    var body: some View {
        let radius: CGFloat = 24
        
        if settings.crystal == .normal {
            RoundedRectangle(cornerRadius: radius)
                .stroke(settings.accentColor.color, lineWidth: 5)
                .shadow(color: settings.accentColor.color, radius: 10, x: 0.0, y: 0.0)
                .blur(radius: 5)
                .opacity(0.25)
                .background(settings.accentColor.color.opacity(0.12))
                .cornerRadius(radius)
                .shadow(color: settings.accentColor.color.opacity(0.5), radius: 10, x: 0.0, y: 0.0)
                .animation(.smooth(duration: 1.0), value: settings.accentColor.color)
                .animation(.smooth(duration: 1.0), value: settings.crystal)
        } else {
            RoundedRectangle(cornerRadius: radius)
                .stroke(settings.accentColor.color, lineWidth: stroke ? 1 : 2)
                .shadow(color: settings.accentColor.color, radius: 10, x: 0.0, y: 0.0)
                .blur(radius: 5)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: settings.crystal.gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .opacity(settings.crystal == .rgb ? 0.1 : settings.crystal == .black ? 0.2 : 0.12)
                    #if !os(watchOS)
                    .conditionalPhaseAnimation(shouldAnimate && settings.crystal == .rgb, duration: 1.5)
                    #endif
                    .animation(.smooth(duration: 1.0), value: settings.crystal)
                )
                .cornerRadius(radius)
                .shadow(color: .white.opacity(0.5), radius: 10, x: 0.0, y: 0.0)
                .animation(.smooth(duration: 1.0), value: settings.crystal)
                #if !os(watchOS)
                .onAppear {
                    shouldAnimate = true
                }
                .onDisappear {
                    shouldAnimate = false
                }
                #endif
        }
    }
}

#Preview {
    BackgroundView(shouldAnimate: .constant(false), stroke: false)
        .environmentObject(Settings.shared)
}
