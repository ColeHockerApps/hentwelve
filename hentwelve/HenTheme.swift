import SwiftUI
import Combine

enum HenTheme {

    static var background: Color {
        Color.black
    }

    static var surface: Color {
        Color.white.opacity(0.06)
    }

    static var surfaceStroke: Color {
        Color.white.opacity(0.10)
    }

    static var textPrimary: Color {
        Color.white
    }

    static var textSecondary: Color {
        Color.white.opacity(0.78)
    }

    static var accent: Color {
        Color.white.opacity(0.92)
    }

    static var accentSoft: Color {
        Color.white.opacity(0.36)
    }

    static var mist: Color {
        Color.white.opacity(0.16)
    }

    static var danger: Color {
        Color.red.opacity(0.85)
    }

    static var ok: Color {
        Color.green.opacity(0.75)
    }

    static func screenBackground() -> some View {
        background.ignoresSafeArea()
    }

    static func cardBackground(corner: CGFloat = 22) -> some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .fill(surface)
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(surfaceStroke, lineWidth: 1)
            )
    }
}
