import SwiftUI

struct ImageSettings: Equatable {
    var showEnglish: Bool
    var aurebeshFontSize: Double
    var englishFont: String
    var englishFontSize: Double
    var showDigraphs: Bool
}

struct ShareView: View {
    @EnvironmentObject var settings: Settings
    
    @State private var showingActivityView = false
    @State private var activityItems: [Any] = []
    @State private var generatedImage: UIImage?
    @State private var showAlert = false
    @State var imageSettings = ImageSettings(showEnglish: false, aurebeshFontSize: 0, englishFont: "", englishFontSize: 0, showDigraphs: false)
    
    func generateImage() -> UIImage {
        let maxWidth: CGFloat = 800
        let padding: CGFloat = 20

        let textColor = UIColor(settings.accentColor.color)
        let backgroundColor: UIColor = .black

        let aurebeshFont = UIFont(name: settings.aurebeshFont, size: imageSettings.aurebeshFontSize) ?? UIFont.preferredFont(forTextStyle: .body)
        let aurebeshAttributes: [NSAttributedString.Key: Any] = [.font: aurebeshFont, .foregroundColor: textColor]
        let attributedAurebeshText = NSAttributedString(string: settings.inputText, attributes: aurebeshAttributes)
        
        let constraintBox = CGSize(width: maxWidth - 2 * padding, height: .greatestFiniteMagnitude)
        let aurebeshRect = attributedAurebeshText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)

        var widerWidth = min(maxWidth, aurebeshRect.size.width + 2 * padding)
        var totalHeight = aurebeshRect.size.height.rounded(.up) + 2 * padding

        var attributedEnglishText: NSAttributedString? = nil
        var englishRect: CGRect = .zero
        
        if imageSettings.showEnglish {
            let englishFont = UIFont(name: imageSettings.englishFont, size: imageSettings.englishFontSize) ?? UIFont.preferredFont(forTextStyle: .body)
            let englishAttributes: [NSAttributedString.Key: Any] = [.font: englishFont, .foregroundColor: textColor]
            attributedEnglishText = NSAttributedString(string: settings.inputText, attributes: englishAttributes)

            englishRect = attributedEnglishText!.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)

            totalHeight += padding + englishRect.size.height.rounded(.up)
            widerWidth = max(aurebeshRect.size.width, englishRect.size.width) + 2 * padding
        }
        
        let imageSize = CGSize(width: widerWidth, height: totalHeight)
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: imageSize, format: format)

        let image = renderer.image { context in
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: imageSize))

            let aurebeshRectWithPadding = CGRect(x: padding, y: padding, width: aurebeshRect.size.width, height: aurebeshRect.size.height)
            attributedAurebeshText.draw(with: aurebeshRectWithPadding, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)

            if let englishText = attributedEnglishText {
                let englishRectWithPadding = CGRect(x: padding, y: aurebeshRectWithPadding.maxY + padding, width: englishRect.size.width, height: englishRect.size.height)
                englishText.draw(with: englishRectWithPadding, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
            }
        }

        return image
    }

    func generateImageAsync() {
        DispatchQueue.global(qos: .userInitiated).async {
            let image = self.generateImage()
            DispatchQueue.main.async {
                withAnimation(.smooth) {
                    self.generatedImage = image
                    self.activityItems = [image]
                }
            }
        }
    }

    var body: some View {
        HoloCard {
            VStack {
                if generatedImage != nil {
                    Image(uiImage: generatedImage!)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(24)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 3.75)
                        .background(settings.accentColor.color.opacity(0.2))
                        .foregroundColor(settings.accentColor.color)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(settings.accentColor.color, lineWidth: 5)
                                .blur(radius: 5)
                                .opacity(0.5)
                        )
                }
                
                Spacer()
                
                HStack {
                    Text("\(settings.pickerStyleSelection) Text Size:")
                        .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                    
                    Text("\(Int(imageSettings.aurebeshFontSize))")
                        .foregroundColor(settings.accentColor.color)
                        .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                        .padding(.trailing, -6)
                    
                    Spacer()
                    
                    Stepper(value: $imageSettings.aurebeshFontSize.animation(.smooth), in: 35...100, step: 5) {}
                        .fixedSize()
                        .conditionalGlassEffect()
                }
                .padding(.top)
                .padding(.vertical, 2)
                
                if settings.aurebeshFont.contains("Aurebesh") {
                    Toggle(isOn: $settings.digraph.animation(.smooth)) {
                        Text("Use Aurebesh Digraphs")
                    }
                    .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                    .tint(settings.accentColor.color.opacity(0.5))
                    .padding(.vertical, 4)
                }
                
                Toggle(isOn: $imageSettings.showEnglish.animation(.smooth)) {
                    Text("Show English")
                }
                .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                .tint(settings.accentColor.color.opacity(0.5))
                .padding(.vertical, 2)
                
                if imageSettings.showEnglish {
                    Picker("English Font", selection: $imageSettings.englishFont.animation(.smooth)) {
                        Text("Standard").tag("EnglishStandard")
                        Text("Galactic").tag("EnglishGalactic")
                        Text("Canon").tag("EnglishCanon")
                    }
                    .pickerStyle(.segmented)
                    .conditionalGlassEffect()
                    .id(settings.refreshID)
                    
                    HStack {
                        Text("English Text Size:")
                            .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                        
                        Text("\(Int(imageSettings.englishFontSize))")
                            .foregroundColor(settings.accentColor.color)
                            .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                            .padding(.trailing, -6)
                        
                        Spacer()
                        
                        Stepper(value: $imageSettings.englishFontSize.animation(.smooth), in: 35...100, step: 5) {}
                            .fixedSize()
                            .conditionalGlassEffect()
                    }
                    .padding(.vertical, 2)
                }
                
                HStack {
                    Button(action: {
                        if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                        
                        if generatedImage == nil {
                            generateImageAsync()
                        } else {
                            UIPasteboard.general.image = generatedImage
                            showAlert = true
                        }
                    }) {
                        Text("Copy Image")
                            .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                            .frame(maxWidth: (UIScreen.main.bounds.width - 110) / 2)
                            .padding()
                            .foregroundColor(.primary)
                            .conditionalGlassEffect()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                        
                        if generatedImage == nil {
                            generateImageAsync()
                        } else {
                            activityItems = [generatedImage!]
                            showingActivityView = true
                        }
                    }) {
                        Text("Share Image")
                            .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                            .frame(maxWidth: (UIScreen.main.bounds.width - 110) / 2)
                            .padding()
                            .foregroundColor(.primary)
                            .conditionalGlassEffect()
                    }
                }
                .padding(.top, 20)
                .sheet(isPresented: $showingActivityView) {
                    if #available(iOS 16.0, *) {
                        ActivityView(activityItems: activityItems)
                            .presentationDetents([.medium])
                    } else {
                        ActivityView(activityItems: activityItems)
                    }
                }
                .animatedAlert(isPresented: $showAlert, title: "Copied", message: "Image copied to clipboard.")
            }
            .padding(.horizontal)
        }
        .onAppear {
            imageSettings = ImageSettings(showEnglish: true, aurebeshFontSize: settings.aurebeshFontSize + 35, englishFont: settings.englishFont, englishFontSize: 35, showDigraphs: settings.digraph)
            generateImageAsync()
        }
        .onChange(of: imageSettings) { newValue in
            generateImageAsync()
        }
        .onChange(of: settings.aurebeshFont) { newValue in
            generateImageAsync()
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        vc.modalPresentationStyle = .formSheet
        return vc
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct AnimatedAlertView: UIViewRepresentable {
    var title: String
    var message: String
    @Binding var isPresented: Bool

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            showAlert(in: view)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    private func showAlert(in view: UIView) {
        guard let parentView = view.superview else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // Present the alert with animation
        UIView.transition(with: parentView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            let viewController = UIViewController()
            viewController.view.backgroundColor = .clear
            parentView.addSubview(viewController.view)
            parentView.window?.rootViewController?.present(alert, animated: true)
        })

        // Dismiss the alert with animation after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIView.transition(with: parentView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                alert.dismiss(animated: true) {
                    self.isPresented = false
                }
            })
        }
    }
}

struct AnimatedAlertHelper: ViewModifier {
    @Binding var isPresented: Bool
    var title: String
    var message: String

    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                AnimatedAlertView(title: title, message: message, isPresented: $isPresented)
                    .frame(width: 0, height: 0)
            }
        }
    }
}

extension View {
    func animatedAlert(isPresented: Binding<Bool>, title: String, message: String) -> some View {
        self.modifier(AnimatedAlertHelper(isPresented: isPresented, title: title, message: message))
    }
}
