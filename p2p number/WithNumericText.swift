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
    
    // То, что показываем в Text (можно добавить форматирование по желанию)
    private var displayText: String {
        amountString.isEmpty ? "0" : amountString
    }
    
    // MARK: - Ввод
    
    private func appendDigit(_ number: Int) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            amountString.append(contentsOf: String(number))
        }
    }
    
    private func deleteLast() {
        guard !amountString.isEmpty else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            amountString.removeLast()
        }
    }
}


private struct AmountTextView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 64, weight: .bold, design: .rounded))
            .monospacedDigit()
            .contentTransition(.numericText()) // ключевая часть
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: text)
    }
}

private struct CustomKeyboard2: View {
    let onNumber: (Int) -> Void
    let onDelete: () -> Void
    
    private let grid = [
        ["1","2","3"],
        ["4","5","6"],
        ["7","8","9"],
        ["","0","⌫"]
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(grid, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { key in
                        if key == "" {
                            Color.clear.frame(height: 70)
                        } else if key == "⌫" {
                            KeyButton(title: key) { onDelete() }
                        } else {
                            KeyButton(title: key) { onNumber(Int(key)!) }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// Стиль кнопки и сама кнопка (как в исходном файле)
private struct KeyPressStyle2: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 100, style: .continuous)
                    .fill(configuration.isPressed ? Color.gray.opacity(0.1) : Color.clear)
            )
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

private struct KeyButton2: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
            }
            .frame(maxWidth: .infinity, maxHeight: 70)
        }
        .buttonStyle(KeyPressStyle())
    }
}

#Preview {
    WithNumericTextView()
}
