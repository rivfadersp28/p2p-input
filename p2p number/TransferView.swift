import SwiftUI

// MARK: - Model

struct Digit: Identifiable, Equatable {
    let id = UUID()
    let value: Int
}

// MARK: - Custom Transition

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
        .modifier(
            active: DigitAppearModifier(progress: 0),
            identity: DigitAppearModifier(progress: 1)
        )
    }
}

// MARK: - Digit View

struct DigitView: View {
    let digit: Digit
    
    var body: some View {
        Text("\(digit.value)")
            .font(.system(size: 64, weight: .bold, design: .rounded))
            .monospacedDigit()
            .transition(.digitAppear)
    }
}

// MARK: - Big Input Display

struct BigInputView: View {
    let digits: [Digit]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(digits) { digit in
                DigitView(digit: digit)
            }
        }
        .animation(
            .spring(response: 0.35, dampingFraction: 0.7),
            value: digits
        )
        .frame(maxWidth: .infinity, minHeight: 120)
    }
}

// MARK: - Keyboard Button

struct KeyButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.gray.opacity(0.15))
                
                Text(title)
                    .font(.title.bold())
            }
            .frame(height: 70)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Keyboard

struct CustomKeyboard: View {
    let onNumber: (Int) -> Void
    let onDelete: () -> Void
    
    let grid = [
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

// MARK: - Main Screen

struct ContentView: View {
    
    @State private var digits: [Digit] = []
    
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
    
    // MARK: - Actions
    
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

