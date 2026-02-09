import SwiftUI
import UIKit

struct KeyPressStyle: ButtonStyle {
    // Замыкание, вызываемое при касании (touch down)
    var onPress: (() -> Void)? = nil

    func makeBody(configuration: Configuration) -> some View {
        KeyPressBody(
            configuration: configuration,
            onPress: onPress
        )
    }

    // Вынесено во внутренний View, чтобы иметь @State
    private struct KeyPressBody: View {
        let configuration: Configuration
        var onPress: (() -> Void)?
        @State private var didTriggerPress = false

        var body: some View {
            configuration.label
                .background(
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        .fill(configuration.isPressed ? Color.gray.opacity(0.1) : Color.clear)
                )
                .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
                .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
                .onChange(of: configuration.isPressed) { _, isPressed in
                    if isPressed {
                        if !didTriggerPress {
                            didTriggerPress = true
                            onPress?()
                        }
                    } else {
                        // Сбрасываем флаг, чтобы следующая итерация снова могла вызвать onPress
                        didTriggerPress = false
                    }
                }
        }
    }
}

struct KeyButton: View {
    let title: String
    // onPress — при касании (touch down)
    var onPress: (() -> Void)? = nil
    // onTap — при отпускании (touch up inside), стандартное действие
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: {
            onTap?()
        }) {
            ZStack {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color(hex: "#333333"))
            }
            .frame(maxWidth: .infinity, maxHeight: 80)
            .contentShape(Rectangle())
        }
        .buttonStyle(KeyPressStyle(onPress: onPress))
    }
}

struct CustomKeyboard: View {
    let onNumber: (Int) -> Void
    let onDelete: () -> Void

    let grid = [
        ["1","2","3"],
        ["4","5","6"],
        ["7","8","9"],
        [",","0","⌫"]
    ]

    // Легкий haptic-генератор
    private func hapticLight() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(grid, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(row, id: \.self) { key in
                        if key == "" {
                            Color.clear.frame(height: 70)
                        } else if key == "⌫" {
                            KeyButton(
                                title: key,
                                onPress: { hapticLight() },
                                onTap: { onDelete() }
                            )
                        } else if Int(key) != nil {
                            KeyButton(
                                title: key,
                                onPress: { hapticLight() },
                                onTap: { onNumber(Int(key)!) }
                            )
                        } else {
                            // Например, запятая — просто haptic (или можно ничего)
                            KeyButton(
                                title: key,
                                onPress: { hapticLight() },
                                onTap: { /* ничего */ }
                            )
                        }
                    }
                }
            }
        }
    }
}
