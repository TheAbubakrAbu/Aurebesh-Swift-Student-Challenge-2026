import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {
    private var hostingController: UIHostingController<AnyView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboard()
    }
    
    private func setupKeyboard() {
        /*let keyboardView = DefaultKeyboardView(
            showGlobeButton: needsInputModeSwitchKey,
            onGlobePress: { [weak self] in
                self?.advanceToNextInputMode()
            },
            parentController: self,
            onKeyPress: { [weak self] key in
                self?.textDocumentProxy.insertText(key)
            },
            onDeletePress: { [weak self] in
                self?.textDocumentProxy.deleteBackward()
            },
            onSpacePress: { [weak self] in
                self?.textDocumentProxy.insertText(" ")
            },
            onReturnPress: { [weak self] in
                self?.textDocumentProxy.insertText("\n")
            },
            accentColor: .white,
            aurebeshFont: "AurebeshBasic"
        )*/
        
        let keyboardView = AurebeshKeyboardView(
            onKeyPress: { [weak self] text in
                self?.textDocumentProxy.insertText(text)
            },
            onDeletePress: { [weak self] in
                self?.textDocumentProxy.deleteBackward()
            },
            onSpacePress: { [weak self] in
                self?.textDocumentProxy.insertText(" ")
            },
            onReturnPress: { [weak self] in
                self?.textDocumentProxy.insertText("\n")
            },
            accentColor: .white,
            aurebeshFont: "AurebeshBasic",
            showCrystalScriptButton: true,
            showGlobeButton: needsInputModeSwitchKey,
            parentController: self
        )

        let anyView = AnyView(keyboardView)
        let hc = UIHostingController(rootView: anyView)
        hc.view.translatesAutoresizingMaskIntoConstraints = false
        hc.view.backgroundColor = .clear

        addChild(hc)
        view.addSubview(hc.view)
        hc.didMove(toParent: self)

        NSLayoutConstraint.activate([
            hc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hc.view.topAnchor.constraint(equalTo: view.topAnchor),
            hc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController = hc
    }
}
