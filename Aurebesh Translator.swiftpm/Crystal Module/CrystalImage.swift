import SwiftUI

struct CrystalImage: View {
    @EnvironmentObject var settings: Settings
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State var width: CGFloat
    @Binding var shouldAnimateCrystal: Bool
    
    @State private var glowScale: CGFloat = 1.25
    @State private var glowOpacity: Double = 0.25
    @State private var rotationAngle: Double = 0
    
    init(width: CGFloat, shouldAnimateCrystal: Binding<Bool>? = nil) {
        _width = State(initialValue: width)
        if let shouldAnimateCrystal = shouldAnimateCrystal {
            _shouldAnimateCrystal = shouldAnimateCrystal
        } else {
            _shouldAnimateCrystal = .constant(false)
        }
    }
    
    var body: some View {
        Group {
            if settings.crystal == .rgb {
                AnimatedRGBCrystal(showOverlay: true, width: width, glowScale: $glowScale, glowOpacity: $glowOpacity, rotationAngle: $rotationAngle)
                    .animation(.smooth(duration: 2).delay(0.5), value: settings.crystal)
            } else if settings.crystal == .normal {
                settings.accentColor.image
                    .frame(width: width, height: width)
                    .animation(.smooth(duration: 2.0), value: settings.accentColor.color)
                    .rotationEffect(.degrees(rotationAngle))
                    .overlay {
                        settings.accentColor.image
                            .frame(width: glowScale * width, height: glowScale * width)
                            .shadow(color: settings.accentColor.color.opacity(glowOpacity), radius: 10, x: 0.0, y: 0.0)
                            .blur(radius: 7)
                            .opacity(glowOpacity)
                            .animation(.smooth(duration: 1).delay(0.25), value: glowScale)
                            .animation(.smooth(duration: 1).delay(0.25), value: glowOpacity)
                            .animation(.smooth(duration: 1).delay(0.25), value: rotationAngle)
                    }
            } else {
                settings.crystal.image
                    .frame(width: width, height: width)
                    .animation(.smooth(duration: 2.0), value: settings.crystal)
                    .rotationEffect(.degrees(rotationAngle))
                    .overlay {
                        settings.crystal.image
                            .frame(width: glowScale * width, height: glowScale * width)
                            .blur(radius: 7)
                            .opacity(glowOpacity)
                            .animation(.smooth(duration: 2).delay(0.25), value: glowScale)
                            .animation(.smooth(duration: 2).delay(0.25), value: glowOpacity)
                            .animation(.smooth(duration: 2).delay(0.25), value: rotationAngle)
                    }
            }
        }
        .onChange(of: shouldAnimateCrystal) { _ in
            triggerAnimation(rotate: true)
        }
        .onChange(of: settings.accentColor) { _ in
            triggerAnimation()
        }
        .onChange(of: settings.crystal) { _ in
            triggerAnimation()
        }
        .onAppear {
            triggerAnimation()
        }
        .onChange(of: scenePhase) { _ in
            triggerAnimation()
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
    
    private func triggerAnimation(rotate: Bool = false) {
        withAnimation(.easeInOut(duration: 0.5)) {
            glowScale = 1.75
            glowOpacity = 0.5
            if rotate {
                rotationAngle = 15 // Rotate 15 degrees to the right
            }
        }
        
        if rotate {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    rotationAngle = -15 // Rotate 15 degrees to the left
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeInOut(duration: 0.5)) {
                glowScale = 1.25
                glowOpacity = 0.25
                if rotate {
                    rotationAngle = 0 // Reset rotation to the center
                }
                shouldAnimateCrystal = false
            }
        }
    }
}
