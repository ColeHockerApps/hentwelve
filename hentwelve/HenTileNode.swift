import SwiftUI
import Combine

struct HenTileNode: View {

    let value: Int
    let size: CGFloat
    let isNew: Bool
    let didMerge: Bool

    @State private var pop: CGFloat = 0.98
    @State private var glow: Double = 0.0

    init(value: Int, size: CGFloat, isNew: Bool = false, didMerge: Bool = false) {
        self.value = value
        self.size = size
        self.isNew = isNew
        self.didMerge = didMerge
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: max(10, size * 0.16), style: .continuous)
                .fill(fillColor)
                .overlay(
                    RoundedRectangle(cornerRadius: max(10, size * 0.16), style: .continuous)
                        .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                )

            if value > 0 {
                Text("\(value)")
                    .font(.system(size: fontSize, weight: .heavy, design: .rounded))
                    .foregroundColor(textColor)
                    .minimumScaleFactor(0.35)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
            }
        }
        .frame(width: size, height: size)
        .scaleEffect(pop)
        .shadow(color: Color.black.opacity(0.22), radius: 10, x: 0, y: 8)
        .overlay(glowOverlay)
        .onAppear {
            let shouldPop = isNew || didMerge
            if shouldPop {
                pop = 0.90
                withAnimation(.spring(response: 0.26, dampingFraction: 0.62)) {
                    pop = 1.03
                }
                withAnimation(.easeOut(duration: 0.16).delay(0.18)) {
                    pop = 1.0
                }
            } else {
                pop = 1.0
            }

            if value >= 64 {
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                    glow = 1.0
                }
            } else {
                glow = 0.0
            }
        }
        .accessibilityLabel(Text(value > 0 ? "\(value)" : "Empty"))
    }

    private var glowOverlay: some View {
        RoundedRectangle(cornerRadius: max(10, size * 0.16), style: .continuous)
            .stroke(Color.white.opacity(0.12 + glow * 0.16), lineWidth: 2)
            .blur(radius: 2 + glow * 2)
            .opacity(value >= 64 ? 1 : 0)
            .allowsHitTesting(false)
    }

    private var fontSize: CGFloat {
        if value < 100 { return size * 0.44 }
        if value < 1000 { return size * 0.38 }
        return size * 0.32
    }

    private var fillColor: Color {
        switch value {
      //  case 0: return HenTheme.surfaceStrong.opacity(0.45)
        case 2: return HenTheme.accentSoft.opacity(0.28)
        case 4: return HenTheme.accentSoft.opacity(0.38)
        case 8: return HenTheme.accent.opacity(0.26)
        case 16: return HenTheme.accent.opacity(0.34)
        case 32: return HenTheme.accent.opacity(0.44)
        case 64: return HenTheme.mist.opacity(0.28)
        case 128: return HenTheme.mist.opacity(0.34)
        case 256: return HenTheme.mist.opacity(0.40)
        case 512: return HenTheme.mist.opacity(0.50)
        case 1024: return HenTheme.mist.opacity(0.62)
        case 2048: return HenTheme.mist.opacity(0.78)
        default: return HenTheme.mist.opacity(0.78)
        }
    }

    private var textColor: Color {
        if value <= 4 { return HenTheme.textPrimary.opacity(0.92) }
        return HenTheme.textPrimary.opacity(0.98)
    }
}
