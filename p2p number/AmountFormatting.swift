import Foundation

struct AmountFormatter {
    // Узкий неразрывный пробел для разделения тысяч
    private let thinNBSP: Character = Character("\u{202F}")

    func renderItems(fromRawDigits rawDigits: String) -> [RenderItem] {
        let raw = rawDigits.filter { $0.isNumber }

        // Плейсхолдер при пустом вводе
        guard !raw.isEmpty else {
            return [RenderItem(char: "0", id: .placeholder)]
        }

        let trimmed = trimLeadingZeros(in: raw)
        return buildItems(from: trimmed)
    }

    // Удаляет лидирующие нули, но оставляет один "0", если все символы — нули.
    private func trimLeadingZeros(in digits: String) -> String {
        if let nonZero = digits.firstIndex(where: { $0 != "0" }) {
            return String(digits[nonZero...])
        } else {
            return "0"
        }
    }

    // Разбивка на группы по 3 цифры и формирование RenderItem:
    // - Каждая цифра имеет id .digit(index: i) по индексу в "очищенной" строке.
    // - Разделитель (пробел) имеет id .separator(groupIndex: g), где g — порядковый номер группы слева.
    private func buildItems(from trimmed: String) -> [RenderItem] {
        let n = trimmed.count
        let remainder = n % 3 == 0 ? 3 : n % 3

        var items: [RenderItem] = []
        var digitIndex = 0
        var groupIndex = 0

        for (i, ch) in trimmed.enumerated() {
            // Начало очередной группы (кроме первой) — вставляем разделитель
            if i != 0 && (i - remainder) % 3 == 0 {
                groupIndex += 1
                items.append(RenderItem(char: thinNBSP, id: .separator(groupIndex: groupIndex)))
            }
            items.append(RenderItem(char: ch, id: .digit(index: digitIndex)))
            digitIndex += 1
        }

        return items
    }
}

struct RenderItem: Identifiable, Equatable {
    enum ID: Hashable {
        case placeholder
        case digit(index: Int)
        case separator(groupIndex: Int)
    }

    let char: Character
    let id: ID
}
