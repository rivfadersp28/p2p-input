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
                Text(String(item.char))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .transition(transition(for: item.id))
            }
        }
        .frame(maxWidth: .infinity, minHeight: 120)
    }

    private func transition(for id: RenderItem.ID) -> AnyTransition {
        switch id {
        case .placeholder:
            return .placeholderDisappearUp
        default:
            return .digitAppear
        }
    }
}
