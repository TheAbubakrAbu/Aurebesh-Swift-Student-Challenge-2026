import SwiftUI

struct HoloCard<Content: View>: View {
    @EnvironmentObject var settings: Settings
    
    @State private var visible = false
    
    let content: Content
    let showBorder: Bool

    init(showBorder: Bool = false, @ViewBuilder _ content: () -> Content) {
        self.showBorder = showBorder
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            if showBorder {   
                RoundedRectangle(cornerRadius: 24)
                    .stroke(settings.accentColor.color, lineWidth: 5)
                    .shadow(color: settings.accentColor.color, radius: 10)
                    .blur(radius: 5)
                    .opacity(0.25)
                    .background(settings.accentColor.color.opacity(0.1))
                    .cornerRadius(24)
                    .shadow(color: settings.accentColor.color.opacity(0.5), radius: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(settings.accentColor.color.opacity(0.4), lineWidth: 1)
                    )
            }
            
            content
        }
        .scaleEffect(visible ? 1 : 1.3)
        .opacity(visible ? 1 : 0)
        .onAppear {
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.6)) {
                    visible = true
                }
            }
        }
        .onDisappear {
            visible = false
        }
    }
}
