import SwiftUI
import UIKit

let keyAccentColors: [Color] = [.primary, .red, .blue, .green, .yellow, .purple]
let keyAccentColorNames: [String] = ["White", "Red", "Blue", "Green", "Yellow", "Purple"]

struct GlobeButtonRepresentable: UIViewRepresentable {
    unowned var parentVC: UIInputViewController
    let width: CGFloat
    let height: CGFloat

    func makeUIView(context: Context) -> UIButton {
        let globeButton = UIButton(type: .system)

        globeButton.setImage(UIImage(systemName: "globe"), for: .normal)
        
        globeButton.backgroundColor = .clear
        globeButton.tintColor = UIColor(Color.primary)
        
        globeButton.addTarget(
            parentVC,
            action: #selector(parentVC.handleInputModeList(from:with:)),
            for: .allTouchEvents
        )
        
        return globeButton
    }

    func updateUIView(_ uiView: UIButton, context: Context) {
        uiView.frame = CGRect(x: 0, y: 0, width: width, height: height)
    }
}

struct GlobeButton1: View {
    weak var parentVC: UIInputViewController?
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white.opacity(0.001))
                .frame(width: width + 6, height: height + 12)

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.primary.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary.opacity(0.4), lineWidth: 1)
                    )

                GlobeButtonRepresentable(
                    parentVC: parentVC ?? UIInputViewController(),
                    width: width,
                    height: height
                )
            }
            .frame(maxWidth: width, maxHeight: height)
        }
    }
}

struct GlobeButton2: View {
    weak var parentVC: UIInputViewController?
    let width: CGFloat
    let height: CGFloat
    @Binding var accentColorIndex: Int

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(keyAccentColors[accentColorIndex].opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(keyAccentColors[accentColorIndex].opacity(0.4), lineWidth: 1)
            )
            .overlay(
                GlobeButtonRepresentable(
                    parentVC: parentVC ?? UIInputViewController(),
                    width: width,
                    height: height
                )
            )
            .frame(width: width, height: height)
            .buttonStyle(PlainButtonStyle())
    }
}
