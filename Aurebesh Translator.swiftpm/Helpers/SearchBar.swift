import SwiftUI

struct SearchBar: UIViewRepresentable {
    @EnvironmentObject var settings: Settings
    
    @Binding var text: String
    
    var onSearchButtonClicked: (() -> Void)?

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        
        var settings: Settings

        init(text: Binding<String>, settings: Settings) {
            _text = text
            self.settings = settings
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }

        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            // removed showsCancelButton line
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.text = ""
            searchBar.resignFirstResponder()
            text = ""
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text, settings: settings)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "Search"
        
        if #available(iOS 26.0, watchOS 26.0, visionOS 26.0, macOS 26.0, *) {
            searchBar.backgroundImage = UIImage()
            searchBar.searchTextField.backgroundColor = .clear
        }

        if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField,
           let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {

            glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = UIColor.gray

            let preferredFont = UIFont.preferredFont(forTextStyle: .subheadline)
            let customFont = UIFont(name: settings.systemFont, size: preferredFont.pointSize)
            textFieldInsideSearchBar.font = customFont
            textFieldInsideSearchBar.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: customFont ?? UIFont.preferredFont(forTextStyle: .subheadline)])
        }

        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        DispatchQueue.main.async {
            self.text = searchBar.text ?? ""
        }
    }
}
