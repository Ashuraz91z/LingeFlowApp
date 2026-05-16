import SwiftUI

extension Color {
    static let lingeInk = adaptive(light: Color(red: 0.02, green: 0.06, blue: 0.19), dark: Color(red: 0.95, green: 0.96, blue: 1.00))
    static let lingeMuted = adaptive(light: Color(red: 0.52, green: 0.56, blue: 0.70), dark: Color(red: 0.66, green: 0.69, blue: 0.80))
    static let lingePlaceholder = adaptive(light: Color(red: 0.38, green: 0.42, blue: 0.58), dark: Color(red: 0.58, green: 0.62, blue: 0.75))
    static let lingeTabMuted = adaptive(light: Color(red: 0.56, green: 0.59, blue: 0.73), dark: Color(red: 0.58, green: 0.62, blue: 0.75))
    static let lingeBackground = adaptive(light: Color(red: 0.985, green: 0.98, blue: 1.00), dark: Color(red: 0.05, green: 0.06, blue: 0.11))
    static let lingeSurface = adaptive(light: .white, dark: Color(red: 0.11, green: 0.12, blue: 0.18))
    static let lingeSearchBackground = adaptive(light: Color(red: 0.95, green: 0.95, blue: 0.98), dark: Color(red: 0.16, green: 0.17, blue: 0.24))
    static let lingeControlBackground = adaptive(light: Color(red: 0.95, green: 0.95, blue: 0.98), dark: Color(red: 0.16, green: 0.17, blue: 0.24))
    static let lingeBorder = adaptive(light: Color(red: 0.86, green: 0.88, blue: 0.94), dark: Color.white.opacity(0.10))
    static let lingeCompleted = adaptive(light: Color(red: 0.18, green: 0.20, blue: 0.30), dark: Color(red: 0.88, green: 0.89, blue: 0.95))
    static let lingeDisabledFill = adaptive(light: Color(red: 0.90, green: 0.91, blue: 0.95), dark: Color(red: 0.20, green: 0.21, blue: 0.28))
    static let lingeDisabledText = adaptive(light: Color(red: 0.70, green: 0.72, blue: 0.80), dark: Color(red: 0.48, green: 0.51, blue: 0.61))
    static let lingeDoneStart = Color(red: 0.22, green: 0.20, blue: 0.42)
    static let lingeDoneEnd = Color(red: 0.30, green: 0.25, blue: 1.00)
    static let lingeUndoText = Color(red: 0.88, green: 0.86, blue: 1.00)
    static let lingePurple = Color(red: 0.30, green: 0.25, blue: 1.00)
    static let lingeGreen = Color(red: 0.12, green: 0.74, blue: 0.37)
    static let lingeBlue = Color(red: 0.05, green: 0.50, blue: 1.00)
    static let lingeOrange = Color(red: 1.00, green: 0.49, blue: 0.12)
    static let lingeDestructive = Color(red: 0.82, green: 0.08, blue: 0.16)
    static let lingeDestructiveDark = Color(red: 0.62, green: 0.03, blue: 0.10)

    private static func adaptive(light: Color, dark: Color) -> Color {
        Color(
            UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
            }
        )
    }
}
