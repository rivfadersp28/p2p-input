import SwiftUI

extension Color {
    // Удобный не-опциональный инициализатор с запасным цветом
    init(hex: String, default defaultColor: Color = .clear) {
        if let color = Color._parseHex(hex) {
            self = color
        } else {
            self = defaultColor
        }
    }

    // Если хотите оставить и опциональный — можно, но не обязательно.
    init?(hex: String) {
        guard let color = Color._parseHex(hex) else { return nil }
        self = color
    }

    // Общий парсер
    private static func _parseHex(_ hex: String) -> Color? {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        let scanner = Scanner(string: hexString)
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else { return nil }

        let r, g, b, a: CGFloat

        switch hexString.count {
        case 3:
            // #RGB
            let r4 = (hexNumber & 0xF00) >> 8
            let g4 = (hexNumber & 0x0F0) >> 4
            let b4 = (hexNumber & 0x00F)
            r = CGFloat((r4 << 4) | r4) / 255.0
            g = CGFloat((g4 << 4) | g4) / 255.0
            b = CGFloat((b4 << 4) | b4) / 255.0
            a = 1.0
        case 6:
            // #RRGGBB
            r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255.0
            g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255.0
            b = CGFloat(hexNumber & 0x0000FF) / 255.0
            a = 1.0
        case 8:
            // #RRGGBBAA
            r = CGFloat((hexNumber & 0xFF000000) >> 24) / 255.0
            g = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(hexNumber & 0x000000FF) / 255.0
        default:
            return nil
        }

        return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
