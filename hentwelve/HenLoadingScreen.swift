import SwiftUI
import Combine

struct HenLoadingScreen: View {

    @State private var appear: Bool = false
    @State private var spin: Double = 0
    @State private var pulse: Bool = false
    @State private var drift: CGFloat = -0.18
    @State private var twinkle: Double = 0

    var body: some View {
        ZStack {
            HenTheme.background
                .ignoresSafeArea()

            ambient

            VStack(spacing: 16) {
                Spacer()

                HenStarLoader(spin: spin, pulse: pulse, twinkle: twinkle)
                    .frame(width: 210, height: 210)

                Text("Loading")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(HenTheme.textPrimary.opacity(0.9))
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.35), value: appear)

                Spacer()
            }
            .padding(.bottom, 10)
        }
        .onAppear {
            appear = true
            pulse = true

            withAnimation(.linear(duration: 2.2).repeatForever(autoreverses: false)) {
                spin = 360
            }
            withAnimation(.easeInOut(duration: 1.05).repeatForever(autoreverses: true)) {
                twinkle = 1.0
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                drift = 0.22
            }
        }
    }

    private var ambient: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                Color.black.opacity(0.22)

                glowBlob(
                    size: min(w, h) * 0.92,
                    x: w * 0.20,
                    y: h * 0.22,
                    a: HenTheme.accent.opacity(0.30),
                    b: HenTheme.accentSoft.opacity(0.12),
                    drift: drift
                )

                glowBlob(
                    size: min(w, h) * 0.78,
                    x: w * 0.82,
                    y: h * 0.42,
                    a: HenTheme.mist.opacity(0.20),
                    b: HenTheme.accent.opacity(0.10),
                    drift: -drift * 0.85
                )

                glowBlob(
                    size: min(w, h) * 0.64,
                    x: w * 0.48,
                    y: h * 0.78,
                    a: HenTheme.mist.opacity(0.16),
                    b: HenTheme.accentSoft.opacity(0.10),
                    drift: drift * 0.65
                )

                vignette
            }
            .ignoresSafeArea()
        }
        .allowsHitTesting(false)
    }

    private func glowBlob(
        size: CGFloat,
        x: CGFloat,
        y: CGFloat,
        a: Color,
        b: Color,
        drift: CGFloat
    ) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [a, b, Color.clear],
                    center: .center,
                    startRadius: 8,
                    endRadius: size * 0.56
                )
            )
            .frame(width: size, height: size)
            .position(x: x, y: y)
            .offset(x: drift * 140, y: drift * 110)
            .scaleEffect(pulse ? 1.03 : 0.97)
            .blur(radius: 22)
            .blendMode(.screen)
            .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: pulse)
    }

    private var vignette: some View {
        Rectangle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.clear,
                        Color.black.opacity(0.28),
                        Color.black.opacity(0.64)
                    ],
                    center: .center,
                    startRadius: 170,
                    endRadius: 900
                )
            )
            .blendMode(.multiply)
            .allowsHitTesting(false)
    }
}

private struct HenStarLoader: View {

    let spin: Double
    let pulse: Bool
    let twinkle: Double

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let c = CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.5)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                HenTheme.accentSoft.opacity(0.30),
                                HenTheme.mist.opacity(0.12),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: side * 0.52
                        )
                    )
                    .frame(width: side * 0.98, height: side * 0.98)
                    .position(c)
                    .scaleEffect(pulse ? 1.03 : 0.98)
                    .blur(radius: 12)
                    .blendMode(.screen)
                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: pulse)

                ForEach(0..<14, id: \.self) { i in
                    HenOrbitStar(i: i, spin: spin, twinkle: twinkle)
                        .position(c)
                }

                HenCoreStar(t: twinkle)
                    .frame(width: side * 0.26, height: side * 0.26)
                    .position(c)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct HenOrbitStar: View {
    let i: Int
    let spin: Double
    let twinkle: Double

    var body: some View {
        let count = 14.0
        let baseDeg = Double(i) / count * 360.0
        let rad = (baseDeg + spin) * Double.pi / 180.0

        let ringBase = 62.0 + Double(i % 4) * 16.0
        let wobblePhase = (spin * 0.9 + Double(i) * 24.0) * Double.pi / 180.0
        let wobble = sin(wobblePhase) * (2.0 + Double(i % 3) * 1.4)

        let r = ringBase + wobble
        let x = cos(rad) * r
        let y = sin(rad) * r

        let sizeBase = 6.0 + Double((i + 1) % 4)
        let tw = 0.78 + 0.22 * twinkle
        let alpha = 0.55 + 0.40 * twinkle

        return StarShape(points: 5, innerRatio: 0.48)
            .fill(HenTheme.textPrimary.opacity(alpha))
            .frame(width: sizeBase * tw, height: sizeBase * tw)
            .offset(x: x, y: y)
            .rotationEffect(.degrees(baseDeg + spin * 0.25))
            .blur(radius: 0.2)
            .blendMode(.screen)
    }
}

private struct HenCoreStar: View {
    let t: Double

    var body: some View {
        ZStack {
            StarShape(points: 6, innerRatio: 0.46)
                .fill(HenTheme.accent.opacity(0.95))

            StarShape(points: 6, innerRatio: 0.46)
                .stroke(HenTheme.textPrimary.opacity(0.65), lineWidth: 1)

            Circle()
                .fill(HenTheme.mist.opacity(0.25))
                .scaleEffect(0.58 + 0.06 * t)
                .blur(radius: 3)
        }
        .shadow(color: HenTheme.accent.opacity(0.35), radius: 10, x: 0, y: 0)
        .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: t)
    }
}

private struct StarShape: Shape {
    let points: Int
    let innerRatio: CGFloat

    func path(in rect: CGRect) -> Path {
        let p = max(3, points)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) * 0.5
        let inner = outer * innerRatio

        var path = Path()
        let step = Double.pi * 2.0 / Double(p * 2)

        var angle = -Double.pi / 2.0
        var first = true

        for i in 0..<(p * 2) {
            let r = (i % 2 == 0) ? Double(outer) : Double(inner)
            let pt = CGPoint(
                x: center.x + CGFloat(cos(angle) * r),
                y: center.y + CGFloat(sin(angle) * r)
            )
            if first {
                path.move(to: pt)
                first = false
            } else {
                path.addLine(to: pt)
            }
            angle += step
        }

        path.closeSubpath()
        return path
    }
}
