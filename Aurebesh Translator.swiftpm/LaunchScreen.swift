import SwiftUI

struct LaunchScreen: View {
    @EnvironmentObject var settings: Settings
    
    @Binding var isLaunching: Bool
    
    @State private var size = 0.8
    @State private var opacity = 0.1
    @State private var rotation: Double = 0
    @State private var rectangleSize = CGSize(width: 200, height: 200)
    @State private var rectangleOpacity = 0.0
    @State private var showRectangle = false
    @State private var showOverlay = false
    @State private var screenSize = CGSize.zero
    
    var body: some View {
        HoloCard {
            VStack(alignment: .center) {
                Spacer()
                
                Image("DatapadIcon")
                    .resizable()
                    .scaledToFit()
                    .colorMultiply(settings.accentColor.color.opacity(0.9))
                    .frame(maxWidth: 200, maxHeight: 200)
                    .padding()
                    .rotationEffect(.degrees(rotation))
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        animateLaunch()
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
                        }
                        
                        if showOverlay {
                            Image("DatapadIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .colorMultiply(settings.accentColor.color.opacity(0.9))
                                .frame(width: 215, height: 215)
                                .shadow(color: settings.accentColor.color.opacity(0.25), radius: 10, x: 0.0, y: 0.0)
                                .rotationEffect(.degrees(rotation))
                                .blur(radius: 5)
                                .opacity(0.15)
                                .overlay {
                                    Image("DatapadIcon")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .colorMultiply(settings.accentColor.color.opacity(0.9))
                                        .frame(width: 230, height: 230)
                                        .shadow(color: settings.accentColor.color.opacity(0.5), radius: 10, x: 0.0, y: 0.0)
                                        .rotationEffect(.degrees(rotation))
                                        .blur(radius: 5)
                                        .opacity(0.25)
                                }
                        }
                    }
                
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            withAnimation(.easeInOut) {
                screenSize = UIScreen.main.bounds.size
            }
        }
    }
    
    private func animateLaunch() {
        withAnimation(.easeInOut(duration: 0.35)) {
            self.size = 1.0
            self.opacity = 0.5
            triggerHapticFeedback(.light)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.easeInOut(duration: 0.7)) {
                self.rotation = 360
                self.opacity = 1.0
                triggerHapticFeedback(.light)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.showOverlay = true
                    triggerHapticFeedback(.light)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        self.showRectangle = true
                        self.rectangleSize = CGSize(width: 200, height: 200)
                    }
                    
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.showOverlay = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.rectangleOpacity = 0.25
                            self.rectangleSize = screenSize
                            triggerHapticFeedback(.light)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                self.rectangleOpacity = 0.0
                                triggerHapticFeedback(.soft)
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + (settings.firstLaunch ? 1 : 0.68)) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    self.isLaunching = false
                                    triggerHapticFeedback(.light)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func triggerHapticFeedback(_ feedbackType: HapticFeedbackType) {
        if settings.hapticOn {
            switch feedbackType {
            case .soft:
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            case .light:
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case .medium:
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case .heavy:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
    }

    enum HapticFeedbackType {
        case soft, light, medium, heavy
    }
}
