import SwiftUI

// Экран с одним Text и .contentTransition(.numericText())



struct WithNumericTextView: View {
    @State private var amountString: String = "" // Хранит ввод как строку, чтобы корректно работать с запятой
    
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            AmountTextView(text: displayText)
                .frame(maxWidth: .infinity, minHeight: 120)
                .padding(.horizontal)
            
            Spacer()
            
            CustomKeyboard(
                onNumber: appendDigit,
                onDelete: deleteLast
            )
        }
        .padding()
    }
    
    private var displayText: String {
        amountString.isEmpty ? "0" : amountString
    }
    
    // Ввод
    
    private func appendDigit(_ number: Int) {
        amountString.append(contentsOf: String(number))
    }
    
    private func deleteLast() {
        guard !amountString.isEmpty else { return }
            amountString.removeLast()
    }
}

private struct AmountTextView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 64, weight: .bold, design: .rounded))
            .monospacedDigit()
            .contentTransition(.numericText())
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: text)
    }
}


#Preview {
    WithNumericTextView()
}
