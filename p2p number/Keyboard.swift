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

        // Собственные состояния для анимации
        @State private var scale: CGFloat = 1.0
        @State private var highlightOpacity: CGFloat = 0.0

        // Флаги управления последовательностью
        @State private var isAnimatingDown = false   // идет фаза "вниз"
        @State private var isAnimatingUp = false     // идет фаза "вверх"
        @State private var needsRelease = false      // палец уже оторван, но ждём завершения "вниз"

        // Параметры анимации
        private let downDuration: TimeInterval = 0.15
        private let upDuration: TimeInterval = 0.15
        private let pressedScale: CGFloat = 1.2
        private let releasedScale: CGFloat = 1.0
        private let pressedOpacity: CGFloat = 0.1
        private let releasedOpacity: CGFloat = 0.0

        var body: some View {
            configuration.label
                .background(
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        .fill(Color.gray.opacity(highlightOpacity))
                        .frame(maxWidth: 80, maxHeight: 70)
                )
                .scaleEffect(scale)
                .onChange(of: configuration.isPressed) { _, isPressed in
                    if isPressed {
                        handlePressDown()
                        if !didTriggerPress {
                            didTriggerPress = true
                            onPress?()
                        }
                    } else {
                        // Только отмечаем, что нужен релиз. Реальная анимация "вверх" пойдет
                        // либо сразу (если вниз уже завершилась), либо после её завершения.
                        didTriggerPress = false
                        needsRelease = true
                        tryStartReleaseIfPossible()
                    }
                }
        }

        private func handlePressDown() {
            // Если уже идёт "вниз" — игнорируем повтор
            guard !isAnimatingDown else { return }

            // Сбрасываем состояние релиза
            needsRelease = false
            isAnimatingUp = false

            isAnimatingDown = true

            // Запускаем последовательную анимацию "вниз" фиксированной длительности
            Task { @MainActor in
                withAnimation(.easeOut(duration: downDuration)) {
                    scale = pressedScale
                    highlightOpacity = pressedOpacity
                }
                // Ждём длительность "вниз"
                try? await Task.sleep(nanoseconds: UInt64(downDuration * 1_000_000_000))

                isAnimatingDown = false

                // Если к этому моменту палец уже отпущен — запускаем релиз
                tryStartReleaseIfPossible()
            }
        }

        private func tryStartReleaseIfPossible() {
            // Релиз можно начать, если:
            // - палец уже оторван (needsRelease == true)
            // - не идёт фаза "вниз"
            // - не идёт уже фаза "вверх"
            guard needsRelease, !isAnimatingDown, !isAnimatingUp else { return }

            isAnimatingUp = true
            needsRelease = false

            Task { @MainActor in
                withAnimation(.easeOut(duration: upDuration)) {
                    scale = releasedScale
                    highlightOpacity = releasedOpacity
                }
                try? await Task.sleep(nanoseconds: UInt64(upDuration * 1_000_000_000))
                isAnimatingUp = false
            }
        }
    }
}

struct KeyButton: View {
    let title: String
    var symbolScale: CGFloat = 1
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
                    .scaleEffect(symbolScale)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(KeyPressStyle(onPress: onPress))
    }
}

private class KeyboardHaptic {
    private let generator = UIImpactFeedbackGenerator(style: .rigid)

    init() {
        generator.prepare()
    }

    func play() {
        generator.impactOccurred(intensity: 0.6)
        generator.prepare()
    }
}

struct CustomKeyboard: View {
    let onNumber: (Int) -> Void
    let onDelete: () -> Void
    var symbolScale: CGFloat = 1
    var rowSpacing: CGFloat = 0

    @State private var haptic = KeyboardHaptic()
    private let rowHeight: CGFloat = 70

    let grid = [
        ["1","2","3"],
        ["4","5","6"],
        ["7","8","9"],
        [",","0","⌫"]
    ]

    var body: some View {
        VStack(spacing: rowSpacing) {
            ForEach(grid, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(row, id: \.self) { key in
                        if key == "" {
                            Color.clear.frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if key == "⌫" {
                            KeyButton(
                                title: key,
                                symbolScale: symbolScale,
                                onPress: { haptic.play() },
                                onTap: { onDelete() }
                            )
                        } else if Int(key) != nil {
                            KeyButton(
                                title: key,
                                symbolScale: symbolScale,
                                onPress: { haptic.play() },
                                onTap: { onNumber(Int(key)!) }
                            )
                        } else {
                            // Например, запятая — просто haptic (или можно ничего)
                            KeyButton(
                                title: key,
                                symbolScale: symbolScale,
                                onPress: { haptic.play() },
                                onTap: { /* ничего */ }
                            )
                        }
                    }
                }
                .frame(height: rowHeight)
            }
        }
    }
}

#Preview {
    CustomKeyboard(
        onNumber: { _ in },
        onDelete: { }
    )
}
