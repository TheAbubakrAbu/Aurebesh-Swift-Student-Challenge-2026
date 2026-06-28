import SwiftUI

extension View {
    @ViewBuilder
    func transparentList() -> some View {
        #if os(watchOS)
        self
            .modifier(TransparentListModifier())

        #else
        self
            .listStyle(.plain)
            .modifier(TransparentListModifier())
            .dismissKeyboardOnScroll()

        #endif
    }
}

fileprivate struct TransparentListModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, watchOS 9.0, *) {
            content
                .scrollContentBackground(.hidden)
                .listRowBackground(Color.clear)
                .background(Color.clear)
        } else {
            content.background(Color.clear)
        }
    }
}
