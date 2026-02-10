import SwiftUI

private struct ContentWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct FormattedAmountView: View {
    let rawDigits: String

    private let formatter = AmountFormatter()
    @State private var contentWidth: CGFloat = 0

    private var renderItems: [RenderItem] {
        formatter.renderItems(fromRawDigits: rawDigits)
    }

    var body: some View {
        GeometryReader { geo in
            let scale = contentWidth > 0
                ? min(1.0, geo.size.width / contentWidth)
                : 1.0

            HStack(spacing: 2) {
                ForEach(renderItems) { item in
                    if item.id == .placeholder {
                        Text(String(item.char))
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .transition(.placeholderDisappearUp)
                    } else {
                        AnimatedDigitView(item: item)
                    }
                }

                Text("\u{202F}₽")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
            }
            .fixedSize()
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(key: ContentWidthKey.self, value: proxy.size.width)
                }
            )
            .scaleEffect(scale)
            .frame(width: geo.size.width, height: geo.size.height)
            .onPreferenceChange(ContentWidthKey.self) { width in
                contentWidth = width
            }
        }
        .frame(maxWidth: .infinity, minHeight: 120)
    }
}

private struct AnimatedDigitView: View {
    let item: RenderItem

    @State private var appeared = false

    var body: some View {
        Text(String(item.char))
            .font(.system(size: 64, weight: .bold, design: .rounded))
            .modifier(DigitAppearModifier(progress: appeared ? 1 : 0))
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: appeared)
            .transition(.asymmetric(
                insertion: .identity,
                removal: .digitAppear
            ))
            .onAppear {
                appeared = true
            }
    }
}

#Preview {
    WithNumericTextView()
}
