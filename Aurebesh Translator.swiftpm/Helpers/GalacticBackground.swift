//  GalacticBackground_Optimized.swift
//  • No per‑frame state mutation
//  • Continuous drift – starfield never “jumps”
//  • All RNG, paths, shadings cached once

import SwiftUI

// MARK: – Star model
private struct Star {
    let seed:   Int
    let x0:     CGFloat        // initial X  (0 … 10 000)
    let speed:  CGFloat        // pts / s    (left‑ward)
    let yRatio: CGFloat        // vertical position as 0…1 fraction
    let len:    CGFloat        // >0 for streaks, 0 for dots
}

// MARK: – Main view
struct GalacticBackground: View {
    @EnvironmentObject private var settings: Settings

    // per‑device star counts
    #if os(watchOS)
    private static let CNT_FG  =  38
    private static let CNT_MID =  12
    private static let CNT_STR =   4
    #else
    private static let CNT_FG  = 150
    private static let CNT_MID =  50
    private static let CNT_STR =  15
    #endif

    // immutable star arrays
    private static var stars:    [Star] = []   // foreground dots
    private static var midStars: [Star] = []   // mid‑layer dots
    private static var streaks:  [Star] = []   // hyperspace streaks

    // cached geometries
    private static let dot2Path = Path(ellipseIn: CGRect(x: 0, y: 0, width: 2, height: 2))
    private static let dot3Path = Path(ellipseIn: CGRect(x: 0, y: 0, width: 3, height: 3))

    init() {
        if Self.stars.isEmpty { Self.buildStars() }
    }

    private static func buildStars() {
        var rng = RNG(seed: 2024)

        func makeDots(_ count: Int, speed: ClosedRange<CGFloat>) -> [Star] {
            (0..<count).map { idx in
                Star(seed: idx,
                     x0: CGFloat(idx) / CGFloat(count) * 10_000,
                     speed: .random(in: speed),
                     yRatio: rng.next(in: 0...1),
                     len: 0)
            }
        }

        func makeStreaks(_ count: Int) -> [Star] {
            (0..<count).map { idx in
                Star(seed: idx,
                     x0: CGFloat(idx) / CGFloat(count) * 10_000,
                     speed: .random(in: 120...220),
                     yRatio: rng.next(in: 0...1),
                     len: rng.next(in: 12...32))
            }
        }

        stars    = makeDots(CNT_FG,  speed: 20...60)
        midStars = makeDots(CNT_MID, speed:  5...15)
        streaks  = makeStreaks(CNT_STR)
    }

    // MARK: body
    var body: some View {
        switch settings.galaxyMode {
        case .offMode:    EmptyView()

        case .staticMode: frame(at: 0)

        case .dynamicMode:
            TimelineView(.animation) { tl in
                frame(at: tl.date.timeIntervalSinceReferenceDate)
            }
        }
    }

    // MARK: one frame render
    @ViewBuilder private func frame(at time: TimeInterval) -> some View {
        GeometryReader { proxy in
            let size = proxy.size
            Canvas(rendersAsynchronously: true) { ctx, _ in
                // continuous drift
                let maxSpeed: CGFloat = 220
                let offsetX  = CGFloat(time) * maxSpeed

                // shades (re‑computed once per frame)
                let base = settings.useAccentColorGalaxy ? settings.accentColor.color : .white
                let dotShade    = GraphicsContext.Shading.color(base.opacity(0.32))
                let midShade    = GraphicsContext.Shading.color(base.opacity(0.38))
                let streakShade = GraphicsContext.Shading.color(base.opacity(0.18))

                func yPos(_ ratio: CGFloat) -> CGFloat { ratio * size.height }

                // ---------- dots (foreground & mid) ----------
                if settings.starfieldStyle != .streaks {
                    func drawDots(_ stars: [Star], path: Path, shade: GraphicsContext.Shading) {
                        for star in stars {
                            var x = star.x0 - offsetX * (star.speed / maxSpeed)
                            x = fmod(x, size.width); if x < 0 { x += size.width }
                            let y = yPos(star.yRatio)
                            ctx.fill(path.applying(.init(translationX: x, y: y)), with: shade)
                        }
                    }
                    drawDots(Self.stars,    path: Self.dot2Path, shade: dotShade)
                    drawDots(Self.midStars, path: Self.dot3Path, shade: midShade)
                }

                // ---------- streaks --------------------------
                if settings.starfieldStyle != .circles {
                    for st in Self.streaks {
                        var x = st.x0 - offsetX * (st.speed / maxSpeed)
                        x = fmod(x, size.width); if x < 0 { x += size.width }
                        let y = yPos(st.yRatio)
                        ctx.fill(Path(CGRect(x: x, y: y, width: st.len, height: 1)), with: streakShade)
                    }
                }
            }
            .ignoresSafeArea()
            #if !os(watchOS)
            .drawingGroup()            // keep texture only on larger screens
            #endif
        }
    }
}

// MARK: – Tiny PRNG
fileprivate struct RNG {
    private var state: UInt64
    init(seed: Int) { state = UInt64(truncatingIfNeeded: seed) &* 0x7f4a7c15 }
    mutating func next() -> UInt64 {
        state ^= state >> 12; state ^= state << 25; state ^= state >> 27
        return state &* 2685821657736338717
    }
    mutating func next(in r: ClosedRange<Double>) -> Double {
        let u = Double(next()) / Double(UInt64.max)
        return r.lowerBound + u * (r.upperBound - r.lowerBound)
    }
    mutating func next(in r: ClosedRange<CGFloat>) -> CGFloat {
        CGFloat(next(in: r.lowerBound.asDouble ... r.upperBound.asDouble))
    }
}
fileprivate extension CGFloat { var asDouble: Double { Double(self) } }
