import SwiftUI
import UIKit

struct WithNumericTextView: View {
    @State private var amountString: String = "" // Сырое значение: только цифры
    @State private var isKeyboardOnScreen = true
    @State private var isAmountInsetActive = true
    @State private var keyboardOpacity: Double = 1
    @State private var keyboardSymbolScale: CGFloat = 1
    @State private var keyboardRowsSpacing: CGFloat = 0
    @State private var keyboardHeight: CGFloat = 0
    @State private var amountTapHaptic = AmountTapHaptic()

    // 1) Скорость контейнера суммы.
    private let amountContainerHideAnimation = Animation.easeOut(duration: 0.15)
    private let amountContainerShowAnimation = Animation.easeOut(duration: 0.15)
    // 2) Скорость изменения расстояния между рядами клавиатуры.
    private let keyboardRowsSpacingHideAnimation = Animation.easeOut(duration: 0.15)
    private let keyboardRowsSpacingShowAnimation = Animation.easeOut(duration: 0.15)
    // 2.1) Значения расстояния между рядами (на сколько сжимается/раскрывается).
    private let keyboardRowsSpacingExpanded: CGFloat = 0
    private let keyboardRowsSpacingCollapsed: CGFloat = -12
    // 3) Скорость прозрачности клавиатуры.
    private let keyboardOpacityHideAnimation = Animation.easeOut(duration: 0.15)
    private let keyboardOpacityShowAnimation = Animation.easeOut(duration: 0.15)
    // 4) Скорость масштаба символов клавиатуры.
    private let keyboardSymbolHideAnimation = Animation.easeOut(duration: 0.15)
    private let keyboardSymbolShowAnimation = Animation.easeOut(duration: 0.15)

    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    dismissTapArea

                    FormattedAmountView(rawDigits: amountString)
                        .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
                        .padding(.horizontal)
                        .padding(.leading, 10)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            amountTapHaptic.play()
                            showKeyboard()
                        }

                    dismissTapArea
                }
                .padding(.bottom, amountBottomInset)

                CustomKeyboard(
                    onNumber: appendDigit,
                    onDelete: deleteLast,
                    symbolScale: keyboardSymbolScale,
                    rowSpacing: keyboardRowsSpacing
                )
                .padding(.horizontal)
                .background(
                    GeometryReader { keyboardProxy in
                        Color.clear
                            .preference(
                                key: KeyboardHeightPreferenceKey.self,
                                value: keyboardProxy.size.height
                            )
                    }
                )
                .opacity(keyboardOpacity)
                .allowsHitTesting(isKeyboardOnScreen)
            }
            .onPreferenceChange(KeyboardHeightPreferenceKey.self) { newHeight in
                keyboardHeight = newHeight
            }
        }
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

    private func hideKeyboard() {
        guard isKeyboardOnScreen || isAmountInsetActive || keyboardOpacity > 0 || keyboardSymbolScale > 0 || keyboardRowsSpacing != keyboardRowsSpacingCollapsed else { return }

        withAnimation(amountContainerHideAnimation) {
            isAmountInsetActive = false
        }
        withAnimation(keyboardRowsSpacingHideAnimation) {
            keyboardRowsSpacing = keyboardRowsSpacingCollapsed
        }
        withAnimation(keyboardOpacityHideAnimation) {
            keyboardOpacity = 0
        }
        withAnimation(keyboardSymbolHideAnimation) {
            keyboardSymbolScale = 0.8
        }
        isKeyboardOnScreen = false
    }

    private func showKeyboard() {
        guard !isKeyboardOnScreen || !isAmountInsetActive || keyboardOpacity < 1 || keyboardSymbolScale < 1 || keyboardRowsSpacing != keyboardRowsSpacingExpanded else { return }

        withAnimation(amountContainerShowAnimation) {
            isAmountInsetActive = true
        }
        withAnimation(keyboardRowsSpacingShowAnimation) {
            keyboardRowsSpacing = keyboardRowsSpacingExpanded
        }
        withAnimation(keyboardOpacityShowAnimation) {
            keyboardOpacity = 1
        }
        withAnimation(keyboardSymbolShowAnimation) {
            keyboardSymbolScale = 1
        }
        isKeyboardOnScreen = true
    }

    private var amountBottomInset: CGFloat {
        guard isAmountInsetActive else { return 0 }
        let measuredHeight = keyboardHeight > 0 ? keyboardHeight : 280
        return measuredHeight + 32
    }

    private var dismissTapArea: some View {
        Rectangle()
            .fill(Color.black.opacity(0.0001))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
    }
}

private class AmountTapHaptic {
    private let generator = UIImpactFeedbackGenerator(style: .rigid)

    init() {
        generator.prepare()
    }

    func play() {
        generator.impactOccurred(intensity: 0.6)
        generator.prepare()
    }
}

private struct KeyboardHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview {
    WithNumericTextView()
}
