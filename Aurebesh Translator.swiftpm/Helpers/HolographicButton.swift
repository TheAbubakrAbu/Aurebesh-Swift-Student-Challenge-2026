import SwiftUI

struct HolographicButton: View {
    @EnvironmentObject var settings: Settings
    
    var currentView: (title: String, view: ActiveView)
    var image: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .firstTextBaseline) {
                if image == "alphabet" {
                    Text("ab")
                        .font(.custom(settings.aurebeshFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                        .padding([.trailing, .bottom], -1)
                } else {
                    Image(systemName: image)
                        .font(.custom(settings.aurebeshFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                }
                
                Text(currentView.title)
                    .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize - 2))
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .padding(2)
            .padding(.horizontal, 15)
            .frame(height: 60)
            .frame(minWidth: (UIScreen.main.bounds.width)/3)
            .frame(maxWidth: .infinity)
            .foregroundColor(.primary)
            .conditionalGlassEffect(tint: settings.activeView == currentView.view ? settings.accentColor.color.opacity(2) : nil)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
        }
        .frame(width: (UIScreen.main.bounds.width)/3, height: 60)
    }
}

