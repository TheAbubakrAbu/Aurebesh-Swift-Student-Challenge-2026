import SwiftUI

struct Crystals: View {
    @EnvironmentObject var settings: Settings
    
    @State private var shouldAnimate = false
    
    func hapticFeedback() {
        #if !os(watchOS)
        if settings.hapticOn { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
        #else
        if settings.hapticOn { WKInterfaceDevice.current().play(.click) }
        #endif
    }
    
    func gridItems() -> [GridItem] {
        #if os(watchOS)
        return [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ]
        #else
        return [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ]
        #endif
    }
        
    var body: some View {
        Group {
            #if !os(watchOS)
            Divider()
                .background(settings.accentColor.color)
                .padding(.top, 6)
            #endif
            
            HStack {
                Spacer()
                
                Text("Selected Color:")
                    .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.vertical, 10)
                
                Spacer()
            }
            
            LazyVGrid(columns: gridItems()) {
                ForEach(allAccentColors) { accentColor in
                    if settings.accentColor == accentColor {
                        accentColor.image
                            .padding(5)
                            .frame(width: 37, height: 37)
                            .background(settings.accentColor.color.opacity(0.25))
                            .foregroundColor(.primary)
                            .cornerRadius(24)
                            .shadow(color: settings.accentColor.color.opacity(0.5), radius: 10, x: 0.0, y: 0.0)
                            .overlay(
                                Circle()
                                    .stroke(settings.accentColor.color, lineWidth: 5)
                                    .shadow(color: settings.accentColor.color, radius: 10, x: 0.0, y: 0.0)
                                    .blur(radius: 5)
                                    .opacity(0.5)
                            )
                            .onTapGesture {
                                hapticFeedback()
                                
                                withAnimation(.smooth(duration: 1.0)) {
                                    settings.accentColor = accentColor
                                }
                            }
                    } else {
                        accentColor.image
                            .padding(5)
                            .frame(width: 37, height: 37)
                            .background(settings.accentColor.color.opacity(0.001))
                            .onTapGesture {
                                hapticFeedback()
                                
                                withAnimation(.smooth(duration: 1.0)) {
                                    settings.accentColor = accentColor
                                }
                            }
                    }
                }
            }
            #if os(watchOS)
            .padding(.vertical, 6)
            #endif
            
            #if !os(watchOS)
            Divider()
                .background(settings.accentColor.color)
                .padding(.top, 6)
            #endif
                
            HStack {
                Spacer()
                
                Text("Selected Crystal:")
                    .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.vertical, 10)
                
                Spacer()
            }
            
            LazyVGrid(columns: gridItems(), spacing: 12) {
                ForEach(crystals) { crystal in
                    if settings.crystal == crystal {
                        if crystal == .normal {
                            settings.accentColor.image
                                .padding(5)
                                .frame(width: 37, height: 37)
                                .background(settings.accentColor.color.opacity(0.25))
                                .foregroundColor(.primary)
                                .cornerRadius(24)
                                .shadow(color: settings.accentColor.color.opacity(0.5), radius: 10, x: 0.0, y: 0.0)
                                .overlay(
                                    Circle()
                                        .stroke(settings.accentColor.color, lineWidth: 5)
                                        .shadow(color: settings.accentColor.color, radius: 10, x: 0.0, y: 0.0)
                                        .blur(radius: 5)
                                        .opacity(0.5)
                                )
                                .onTapGesture {
                                    hapticFeedback()
                                    
                                    withAnimation(.smooth(duration: 1.0)) {
                                        settings.crystal = crystal
                                    }
                                }
                        } else if crystal == .rgb {
                            AnimatedRGBCrystal(showOverlay: false, width: 37)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: settings.crystal.gradientColors),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .opacity(0.25)
                                    #if !os(watchOS)
                                    .conditionalPhaseAnimation(shouldAnimate, duration: 1.5)
                                    #endif
                                )
                                .cornerRadius(24)
                                .shadow(color: .white.opacity(0.5), radius: 10, x: 0.0, y: 0.0)
                                .overlay(
                                    Circle()
                                        .stroke(.white, lineWidth: 5)
                                        .shadow(color: .white, radius: 10, x: 0.0, y: 0.0)
                                        .blur(radius: 5)
                                        .opacity(0.5)
                                )
                                .onAppear {
                                    shouldAnimate = true
                                }
                                .onDisappear {
                                    shouldAnimate = false
                                }
                                .onTapGesture {
                                    hapticFeedback()
                                    
                                    withAnimation(.smooth(duration: 1.0)) {
                                        settings.crystal = .rgb
                                    }
                                }
                        } else {
                            crystal.image
                                .padding(5)
                                .frame(width: 37, height: 37)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: settings.crystal.gradientColors),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .opacity(0.25)
                                )
                                .cornerRadius(24)
                                .shadow(color: .white.opacity(0.5), radius: 10, x: 0.0, y: 0.0)
                                .overlay(
                                    Circle()
                                        .stroke(settings.crystal == .black ? .gray : .white, lineWidth: 5)
                                        .shadow(color: settings.crystal == .black ? .gray : .white, radius: 10, x: 0.0, y: 0.0)
                                        .blur(radius: 5)
                                        .opacity(0.5)
                                )
                                .onTapGesture {
                                    hapticFeedback()
                                    
                                    withAnimation(.smooth(duration: 1.0)) {
                                        settings.crystal = crystal
                                    }
                                }
                        }
                    } else {
                        if crystal == .normal {
                            settings.accentColor.image
                                .padding(5)
                                .frame(width: 37, height: 37)
                                .background(settings.accentColor.color.opacity(0.001))
                                .cornerRadius(24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(settings.accentColor.color, lineWidth: 2)
                                )
                                .onTapGesture {
                                    hapticFeedback()
                                    
                                    withAnimation(.smooth(duration: 1.0)) {
                                        settings.crystal = crystal
                                    }
                                }
                        } else if crystal == .rgb {
                            AnimatedRGBCrystal(showOverlay: false, width: 37)
                                .background(settings.accentColor.color.opacity(0.001))
                                .onTapGesture {
                                    hapticFeedback()
                                        
                                    withAnimation(.smooth(duration: 1.0)) {
                                        settings.crystal = .rgb
                                    }
                                }
                        } else if crystal == .black {                        
                            ZStack {
                                crystal.image
                                    .padding(5)
                                    .frame(width: 37, height: 37)
                                    .colorInvert()
                                    
                                crystal.image
                                    .padding(5)
                                    .frame(width: 32, height: 32)
                            }
                            .background(settings.accentColor.color.opacity(0.001))
                            .onTapGesture {
                                hapticFeedback()
                                    
                                withAnimation(.smooth(duration: 1.0)) {
                                    settings.crystal = crystal
                                }
                            }
                        } else {
                            crystal.image
                                .padding(5)
                                .frame(width: 37, height: 37)
                                .background(settings.accentColor.color.opacity(0.001))
                                .onTapGesture {
                                    hapticFeedback()
                                    
                                    withAnimation(.smooth(duration: 1.0)) {
                                        settings.crystal = crystal
                                    }
                                }
                        }
                    }
                }
            }
            #if os(watchOS)
            .padding(.vertical, 6)
            #endif

            #if !os(watchOS)
            Divider()
                .background(settings.accentColor.color)
                .padding(.top, 14)
            #endif
        }
    }
}
