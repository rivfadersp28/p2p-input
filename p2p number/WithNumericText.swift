import SwiftUI

// Экран с посимвольным рендером и кастомным переходом появления символов.
// Цель: при вводе анимируется только новый правый символ (и, при необходимости, пробел между тысячами),
// уже введённые символы остаются без повторной анимации.

struct WithNumericTextView: View {
    @State private var amountString: String = "" // Хранит ввод как строку (только цифры)
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            BigFormattedInputView(
                rawDigits: amountString
            )
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
    
    // Ввод
    
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

// Посимвольное форматированное отображение
private struct BigFormattedInputView: View {
    let rawDigits: String // только цифры
    
    // Узкий неразрывный пробел для разделения тысяч
    private let thinNBSP = "\u{202F}"
    
    // Строим массив «рендер-символов» с идентификаторами,
    // чтобы при вставке пробела сохранялась идентичность уже существующих цифр.
    private var renderItems: [RenderItem] {
        let raw = rawDigits.filter { $0.isNumber }
        
        // Плейсхолдер: если пусто — показываем один "0"
        guard !raw.isEmpty else {
            return [RenderItem(char: "0", id: .placeholder)]
        }
        
        // Убираем лидирующие нули (кроме случая, когда все нули)
        let trimmed = trimLeadingZeros(in: raw)
        
        // Разбиваем на группы по 3 цифры слева направо и вставляем разделители
        return buildItems(from: trimmed)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(renderItems) { item in
                Text(String(item.char))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .transition(transition(for: item.id))
            }
        }
        .frame(maxWidth: .infinity, minHeight: 120)
    }
    
    // MARK: - Вспомогательные
    
    private func transition(for id: RenderItem.ID) -> AnyTransition {
        switch id {
        case .placeholder:
            // Для плейсхолдера используем специальный переход исчезновения вверх
            return .placeholderDisappearUp
        default:
            // Для остальных — стандартный переход появления цифр
            return .digitAppear
        }
    }
    
    private func trimLeadingZeros(in digits: String) -> String {
        let nonZeroIndex = digits.firstIndex(where: { $0 != "0" })
        if let idx = nonZeroIndex {
            return String(digits[idx...])
        } else {
            return "0"
        }
    }
    
    // Построение элементов с идентификаторами:
    // - Каждая цифра получает id .digit(index: i), где i — её индекс в "очищенной" строке trimmed.
    // - Разделитель (пробел) получает id .separator(groupIndex: g), где g — индекс группы слева (1, 2, ...)
    //   Привязка к группе делает идентичность пробелов стабильной при вводе/удалении справа.
    private func buildItems(from trimmed: String) -> [RenderItem] {
        let n = trimmed.count
        let remainder = n % 3 == 0 ? 3 : n % 3
        var items: [RenderItem] = []
        
        // Пройдём по цифрам, вставляя пробелы перед каждой группой из 3 цифр, кроме первой группы
        var digitIndex = 0 // индекс цифры в trimmed
        var groupIndex = 0 // порядковый номер группы (начиная с 1) для пробелов
        
        for (i, ch) in trimmed.enumerated() {
            // Если это начало группы (кроме самой первой), вставляем разделитель
            if i != 0 && (i - remainder) % 3 == 0 {
                groupIndex += 1
                items.append(RenderItem(char: Character(thinNBSP), id: .separator(groupIndex: groupIndex)))
            }
            items.append(RenderItem(char: ch, id: .digit(index: digitIndex)))
            digitIndex += 1
        }
        
        return items
    }
}

// Модель рендер-элемента с устойчивым идентификатором
private struct RenderItem: Identifiable, Equatable {
    enum ID: Hashable {
        case placeholder               // плейсхолдер "0" на пустом вводе
        case digit(index: Int)         // индекс цифры в trimmed
        case separator(groupIndex: Int)// номер группы слева направо
    }
    let char: Character
    let id: ID
}

// Специальный переход для исчезновения плейсхолдера вверх
private struct PlaceholderDisappearModifier: ViewModifier {
    var progress: CGFloat // 0..1
    func body(content: Content) -> some View {
        content
            .opacity(1 - progress)
            .blur(radius: progress * 8)
            .offset(y: -progress * 24) // вверх
            .scaleEffect(1.0 - 0.1 * progress)
    }
}

private extension AnyTransition {
    // Исчезновение вверх для плейсхолдера, появление — как обычно (идентичное состояние)
    static var placeholderDisappearUp: AnyTransition {
        AnyTransition.modifier(
            active: PlaceholderDisappearModifier(progress: 1),
            identity: PlaceholderDisappearModifier(progress: 0)
        )
    }
}

// Превью
#Preview {
    WithNumericTextView()
}
