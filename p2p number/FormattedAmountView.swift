import SwiftUI

struct FormattedAmountView: View {
    let rawDigits: String

    private let formatter = AmountFormatter()

    private var renderItems: [RenderItem] {
        formatter.renderItems(fromRawDigits: rawDigits)
    }

    var body: some View {
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
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: appeared)
            .transition(.asymmetric(
                insertion: .identity,
                removal: .digitAppear
            ))
            .onAppear {
                appeared = true
            }
    }
}
