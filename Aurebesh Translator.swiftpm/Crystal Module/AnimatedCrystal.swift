import SwiftUI

struct AnimatedRGBCrystal: View {
    @State private var shouldAnimateRGB = true
    
    let animationDuration: Double = 1.5
    var showOverlay: Bool
    
    @State var width: CGFloat
    @Binding var glowScale: CGFloat
    @Binding var glowOpacity: Double
    @Binding var rotationAngle: Double
    
    init(showOverlay: Bool, width: CGFloat, glowScale: Binding<CGFloat>? = nil, glowOpacity: Binding<Double>? = nil, rotationAngle: Binding<Double>? = nil) {
        _width = State(initialValue: width)
        
        _glowScale = glowScale ?? .constant(1.25)
        _glowOpacity = glowOpacity ?? .constant(0.25)
        _rotationAngle = rotationAngle ?? .constant(0)

        self.showOverlay = showOverlay
    }
    
    var body: some View {
        if let crystal = crystals.last {
            Group {
                if showOverlay {
                    crystal.image
                        .frame(width: width, height: width)
                        .shadow(color: .white.opacity(glowOpacity), radius: 10, x: 0.0, y: 0.0)
                        .rotationEffect(.degrees(rotationAngle))
                        .conditionalPhaseAnimation(shouldAnimateRGB, duration: animationDuration)
                        .overlay {
                            crystal.image
                                .frame(width: glowScale * width, height: glowScale * width)
                                .blur(radius: 7)
                                .opacity(glowOpacity * 0.5)
                                .animation(.smooth(duration: 2).delay(0.25), value: glowScale)
                                .animation(.smooth(duration: 2).delay(0.25), value: glowOpacity)
                                .animation(.smooth(duration: 2).delay(0.25), value: rotationAngle)
                                .conditionalPhaseAnimation(shouldAnimateRGB, duration: animationDuration)
                        }
                } else {
                    crystal.image
                        .padding(5)
                        .frame(width: width, height: width)
                        .shadow(color: .white.opacity(glowOpacity), radius: 10, x: 0.0, y: 0.0)
                        .conditionalPhaseAnimation(shouldAnimateRGB, duration: animationDuration)
                }
            }
            .onAppear {
                shouldAnimateRGB = true
            }
            .onDisappear {
                shouldAnimateRGB = false
            }
        }
    }
}

extension View {
    @ViewBuilder
    func conditionalPhaseAnimation(_ shouldAnimateRGB: Bool, duration: Double) -> some View {
        if shouldAnimateRGB, #available(iOS 17.0, *) {
            self.phaseAnimator([false, true]) { view, isAnimating in
                view.hueRotation(.degrees(isAnimating ? 420 : 0))
            } animation: { isAnimating in
                .linear(duration: duration)
            }
        } else {
            self
        }
    }
}
