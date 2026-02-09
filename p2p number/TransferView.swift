import SwiftUI

// Модель цифры

struct Digit: Identifiable, Equatable {
    let id = UUID()
    let value: Int
}



// Анимации

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

extension AnyTransition {
    static var digitAppear: AnyTransition {
        AnyTransition.modifier(
            active: DigitAppearModifier(progress: 0),
            identity: DigitAppearModifier(progress: 1)
        )
    }
}



// Цифра

struct DigitView: View {
    let digit: Digit
    
    var body: some View {
        Text("\(digit.value)")
            .font(.system(size: 64, weight: .bold, design: .rounded))
            .transition(.digitAppear)
    }
}




// Инпут

struct BigInputView: View {
    let digits: [Digit]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(digits) { digit in
                DigitView(digit: digit)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 120)
    }
}



// Кнопка клавиатуры

struct KeyPressStyle: ButtonStyle {
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

struct KeyButton: View {
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



// Клавиатура

struct CustomKeyboard: View {
    let onNumber: (Int) -> Void
    let onDelete: () -> Void
    
    let grid = [
        ["1","2","3"],
        ["4","5","6"],
        ["7","8","9"],
        [",","0","⌫"]
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(grid, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { key in
                        if key == "" {
                            Color.clear.frame(height: 70)
                        } else if key == "⌫" {
                            KeyButton(title: key) {
                                onDelete()
                            }
                        } else {
                            KeyButton(title: key) {
                                onNumber(Int(key)!)
                            }
                        }
                    }
                }
            }
        }
    }
}




// Экран

struct ContentView: View {
    
    @State private var digits: [Digit] = []
    
    // Переключатель: true — ваш кастомный переход, false — стандартный (для быстрого отката)
    @State private var useCustomTransition: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            
            Spacer()
            
            BigInputView(digits: digits)
            
            Spacer()
            
            CustomKeyboard(
                onNumber: appendDigit,
                onDelete: deleteDigit
            )
        }
        .padding()
    }
    
    // Действия с суммой
    
    private func appendDigit(_ number: Int) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            digits.append(Digit(value: number))
        }
    }
    
    private func deleteDigit() {
        guard !digits.isEmpty else { return }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            digits.removeLast()
        }
    }
}

#Preview {
    ContentView()
}
