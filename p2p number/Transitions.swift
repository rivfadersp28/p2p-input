import SwiftUI

struct DigitAppearModifier: ViewModifier {
    var progress: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(progress)
            .blur(radius: (1 - progress) * 8)
            .offset(y: (1 - progress) * 24)
            .scaleEffect(0.9 + 0.1 * progress)
    }
}

private struct PlaceholderDisappearModifier: ViewModifier {
    var progress: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(1 - progress)
            .blur(radius: progress * 8)
            .offset(y: -progress * 24)
            .scaleEffect(1.0 - 0.1 * progress)
    }
}

extension AnyTransition {
    static var digitAppear: AnyTransition {
        AnyTransition.modifier(
            active: DigitAppearModifier(progress: 0),
            identity: DigitAppearModifier(progress: 1)
        )
    }

    static var placeholderDisappearUp: AnyTransition {
        AnyTransition.modifier(
            active: PlaceholderDisappearModifier(progress: 1),
            identity: PlaceholderDisappearModifier(progress: 0)
        )
    }
}
