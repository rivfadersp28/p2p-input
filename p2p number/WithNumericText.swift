import SwiftUI

struct WithNumericTextView: View {
    @State private var amountString: String = "" // Сырое значение: только цифры

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            FormattedAmountView(rawDigits: amountString)
                .frame(maxWidth: .infinity, minHeight: 120)
                .padding(.leading, 10)
            
            Spacer()

            CustomKeyboard(
                onNumber: appendDigit,
                onDelete: deleteLast
            )
        }
        .padding()
    }

    private func appendDigit(_ number: Int) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7), {
            amountString.append(contentsOf: String(number))
        })
    }

    private func deleteLast() {
        guard !amountString.isEmpty else { return } 
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7), {
            amountString.removeLast()
        })
    }
}

#Preview {
    WithNumericTextView()
}
