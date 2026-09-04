import SwiftUI

/// One drawn layer of a control: what shape to generate, and the presentation
/// state that animates it.
public struct SketchLayer {
    let role: SketchRole
    let generate: @Sendable (CGSize, RoughOptions) -> SketchPath
    /// Hidden layers stay in the stack so their geometry is not regenerated
    /// when they appear — a focus ring should not re-sketch on focus.
    var isVisible: Bool = true
    /// How much of the stroke is drawn, for the checkbox's tick.
    var trim: Double = 1
    /// Horizontal travel, for the toggle's knob.
    var offsetX: Double = 0
    /// Scale about the centre, for the radio's dot.
    var scale: Double = 1
    /// Paints the inside of a normally unfilled layer — the wash a button's
    /// outline picks up on hover.
    var fill: Color?

    public init(
        _ role: SketchRole,
        isVisible: Bool = true,
        trim: Double = 1,
        offsetX: Double = 0,
        scale: Double = 1,
        fill: Color? = nil,
        generate: @escaping @Sendable (CGSize, RoughOptions) -> SketchPath
    ) {
        self.role = role
        self.generate = generate
        self.isVisible = isVisible
        self.trim = trim
        self.offsetX = offsetX
        self.scale = scale
        self.fill = fill
    }
}

/// A `Path` that has already been generated — `Shape` conformance only so the
/// animatable modifiers (`trim`, `offset`, `scaleEffect`) can be used on it.
private struct PrebuiltShape: Shape {
    let prebuilt: Path

    func path(in _: CGRect) -> Path {
        prebuilt
    }
}

/// The sketch drawn behind a control.
///
/// Generates the boil frames once per box size, seed and options — never inside
/// a draw pass — then cycles which one is shown. Upstream does the same thing
/// with three stacked SVG paths and a stepped CSS custom property; there is no
/// equivalent here, so a timeline drives the index instead.
struct SketchChrome: View {
    /// Distinguishes one layer set from another, so switching a button from
    /// `outline` to `solid` regenerates rather than reusing stale frames.
    var configuration: AnyHashable
    var layers: [SketchLayer]
    var seed: UInt32
    /// Upstream boils at 1200ms across three frames, and at 450ms while a
    /// button is loading.
    var boilPeriod: Double = 0.4
    /// Overrides both ink colours, the way `--drawably-ink` does for a button's
    /// error and success states.
    var ink: Color?
    /// Text decorations sit on body copy, where the 2pt control stroke reads
    /// heavy, so they override the width down to 1.5.
    var lineWidth: Double?

    @Environment(\.drawablyTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var frames: [[Path]] = []

    private struct CacheKey: Hashable {
        var width: Double
        var height: Double
        var seed: UInt32
        var roughness: Double
        var boil: Double
        var configuration: AnyHashable
    }

    var body: some View {
        GeometryReader { proxy in
            let key = CacheKey(
                width: proxy.size.width,
                height: proxy.size.height,
                seed: seed,
                roughness: theme.roughness,
                boil: theme.boil,
                configuration: configuration
            )
            content
                .onChange(of: key, initial: true) { _, _ in
                    frames = generateFrames(in: proxy.size)
                }
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder private var content: some View {
        if frames.isEmpty {
            Color.clear
        } else if reduceMotion || theme.boil == 0 {
            stack(frame: 0)
        } else {
            TimelineView(.periodic(from: .now, by: boilPeriod)) { context in
                stack(frame: frameIndex(at: context.date))
            }
        }
    }

    private func stack(frame: Int) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(layers.enumerated()), id: \.offset) { index, layer in
                let variants = frames[index]
                let shape = PrebuiltShape(prebuilt: variants[frame % variants.count])
                ZStack {
                    if layer.role.isFilled {
                        shape.fill(paint(for: layer.role))
                    } else if let fill = layer.fill {
                        shape.fill(fill)
                    }
                    shape
                        .trim(from: 0, to: layer.trim)
                        .stroke(paint(for: layer.role), style: strokeStyle(for: layer.role))
                }
                .scaleEffect(layer.scale)
                .offset(x: layer.offsetX)
                .opacity(layer.isVisible ? layer.role.opacity : 0)
                .blendMode(layer.role.blendMode)
            }
        }
    }

    private func frameIndex(at date: Date) -> Int {
        let step = Int((date.timeIntervalSinceReferenceDate / boilPeriod).rounded(.down))
        return ((step % 3) + 3) % 3
    }

    private func generateFrames(in size: CGSize) -> [[Path]] {
        guard size.width > 0, size.height > 0 else { return [] }
        let options = RoughOptions(seed: seed, roughness: theme.roughness, boil: theme.boil)
        let count = theme.boil == 0 ? 1 : 3
        return layers.map { layer in
            Rough.variants({ layer.generate(size, $0) }, options, count: count)
                .map { $0.path() }
        }
    }

    private func paint(for role: SketchRole) -> Color {
        if let ink { return ink }
        return role.usesFillColor ? theme.fill : theme.stroke
    }

    private func strokeStyle(for role: SketchRole) -> StrokeStyle {
        StrokeStyle(
            lineWidth: role.fixedLineWidth ?? lineWidth ?? theme.width,
            lineCap: .round,
            lineJoin: .round
        )
    }
}

public extension Animation {
    /// Upstream's `--drawably-ease`, `cubic-bezier(0.2, 0, 0, 1)`.
    static func drawablyEase(duration: Double = 0.16) -> Animation {
        .timingCurve(0.2, 0, 0, 1, duration: duration)
    }
}
