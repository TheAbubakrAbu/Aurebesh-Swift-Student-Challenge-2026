import SwiftUI

enum GlassKind { case regular, clear }

struct ConditionalGlassEffect: ViewModifier {
    @EnvironmentObject var settings: Settings
    
    var tint: Color? = nil
    var clear: Bool = false
    var regular: Bool = false

    func body(content: Content) -> some View {
        let effectiveTint: Color = tint ?? settings.accentColor.color

        if #available(iOS 26.0, watchOS 26.0, visionOS 26.0, macOS 26.0, *) {
            if regular {
                if clear {
                    content.glassEffect(.regular.interactive(), in: .rect(cornerRadius: 24))
                } else {
                    content.glassEffect(.regular.tint(effectiveTint.opacity(0.25)).interactive(), in: .rect(cornerRadius: 24))
                }
            } else {
                if clear {
                    content.glassEffect(.regular.interactive(), in: .rect(cornerRadius: 24))
                } else {
                    content.glassEffect(.regular.tint(effectiveTint.opacity(0.25)).interactive(), in: .rect(cornerRadius: 24))
                }
            }
        } else if !clear {
            let isSelected = (tint != nil)
            let color = effectiveTint

            content
                .background(color.opacity(isSelected ? 0.35 : 0.2))
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(color, lineWidth: isSelected ? 10 : 2)
                        .shadow(color: color, radius: 10)
                        .blur(radius: 5)
                        .opacity(0.45)
                )
        }
    }
}

extension View {
    func conditionalGlassEffect(tint: Color? = nil, clear: Bool = false, regular: Bool = false) -> some View {
        modifier(ConditionalGlassEffect(tint: tint, clear: clear, regular: regular))
    }
}
