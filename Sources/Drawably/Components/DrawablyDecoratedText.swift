import SwiftUI

public extension Text {
    /// Draws a pen line under this text, one per line it wraps onto.
    func drawablyUnderline(seed: UInt32? = nil) -> some View {
        DrawablyDecoratedText(text: self, decoration: .underline, seed: seed)
    }

    /// Washes a marker swipe behind this text, one per line it wraps onto.
    func drawablyHighlight(seed: UInt32? = nil) -> some View {
        DrawablyDecoratedText(text: self, decoration: .highlight, seed: seed)
    }

    /// Loops a pen circle around this text, one per line it wraps onto.
    func drawablyCircle(seed: UInt32? = nil) -> some View {
        DrawablyDecoratedText(text: self, decoration: .circle, seed: seed)
    }
}

/// Text with a mark drawn on every line it occupies.
///
/// Upstream reads `getClientRects()` to get one box per wrapped line. The
/// equivalent here is `TextRenderer`, which arrived in iOS 18 — below that the
/// whole run is decorated as a single box, which is the same thing whenever the
/// text fits on one line.
struct DrawablyDecoratedText: View {
    let text: Text
    let decoration: DrawablyDecoration
    let seed: UInt32?

    @Environment(\.drawablyTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var seedBox: SketchSeed

    init(text: Text, decoration: DrawablyDecoration, seed: UInt32?) {
        self.text = text
        self.decoration = decoration
        self.seed = seed
        _seedBox = State(initialValue: SketchSeed(pinned: seed))
    }

    var body: some View {
        Group {
            if #available(iOS 18.0, macOS 15.0, *) {
                perLine
            } else {
                text.modifier(DrawablyDecorationModifier(decoration: decoration, seed: seed))
            }
        }
        .onHover { hovering in
            guard hovering, decoration.isInteractive else { return }
            seedBox.resketch(reduceMotion: reduceMotion)
        }
    }

    private var frameCount: Int {
        theme.boil == 0 ? 1 : 3
    }

    @available(iOS 18.0, macOS 15.0, *)
    @ViewBuilder private var perLine: some View {
        if reduceMotion || theme.boil == 0 {
            marked(frame: 0)
        } else {
            TimelineView(.periodic(from: .now, by: 0.4)) { context in
                let step = Int((context.date.timeIntervalSinceReferenceDate / 0.4).rounded(.down))
                marked(frame: ((step % 3) + 3) % 3)
            }
        }
    }

    @available(iOS 18.0, macOS 15.0, *)
    private func marked(frame: Int) -> some View {
        text.textRenderer(
            DrawablyDecorationRenderer(
                decoration: decoration,
                seed: seedBox.value,
                frame: frame,
                frameCount: frameCount,
                color: decoration.role.usesFillColor ? theme.fill : theme.stroke,
                roughness: theme.roughness,
                boil: theme.boil
            )
        )
    }
}

/// Draws the text, plus one sketched mark per line.
///
/// The geometry is generated inside the draw pass because the line boxes are
/// only known here — but the seed is fixed, so the same frame always produces
/// the same marks, and there are as many shapes as there are lines.
@available(iOS 18.0, macOS 15.0, *)
private struct DrawablyDecorationRenderer: TextRenderer {
    let decoration: DrawablyDecoration
    let seed: UInt32
    let frame: Int
    let frameCount: Int
    let color: Color
    let roughness: Double
    let boil: Double

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        // a highlight goes behind the words; a line or a loop goes over them
        if decoration == .highlight { marks(layout, in: &context) }
        for line in layout {
            context.draw(line)
        }
        if decoration != .highlight { marks(layout, in: &context) }
    }

    private func marks(_ layout: Text.Layout, in context: inout GraphicsContext) {
        for (index, line) in layout.enumerated() {
            let rect = line.typographicBounds.rect
            let options = RoughOptions(
                seed: seed &+ UInt32(truncatingIfNeeded: index),
                roughness: roughness,
                boil: boil
            )
            let variants = Rough.variants(
                { decoration.shape(rect.size, $0) },
                options,
                count: frameCount
            )
            var line = context
            line.translateBy(x: rect.minX, y: rect.minY)
            line.opacity = decoration.role.opacity
            if decoration.role.blendMode == .multiply { line.blendMode = .multiply }
            line.stroke(
                variants[frame % variants.count].path(),
                with: .color(color),
                style: StrokeStyle(
                    lineWidth: decoration.role.fixedLineWidth ?? drawablyDecorationLineWidth,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        }
    }
}
