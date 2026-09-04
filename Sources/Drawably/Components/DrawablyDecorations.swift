import SwiftUI

/// The three marks you can make over a piece of text.
public enum DrawablyDecoration: Sendable, Hashable {
    /// A pen line just under the text.
    case underline
    /// A translucent marker swipe behind it.
    case highlight
    /// A loop around it, overshooting the way a hand does.
    case circle

    var role: SketchRole {
        switch self {
        case .underline, .circle: .outline
        case .highlight: .wash
        }
    }

    /// Upstream re-sketches an underline and a circle when a pointer arrives,
    /// but leaves a highlight alone.
    var isInteractive: Bool {
        self != .highlight
    }

    func shape(_ size: CGSize, _ options: RoughOptions) -> SketchPath {
        switch self {
        case .underline: DrawablyGeometry.underline(size.width, size.height, options)
        case .highlight: DrawablyGeometry.highlightWash(size.width, size.height, options)
        case .circle: DrawablyGeometry.circleOutline(size.width, size.height, options)
        }
    }
}

/// Text decorations sit on body copy, where the 2pt control stroke reads heavy.
let drawablyDecorationLineWidth: Double = 1.5

public extension View {
    /// Draws a pen line under this view.
    func drawablyUnderline(seed: UInt32? = nil) -> some View {
        drawablyDecorated(.underline, seed: seed)
    }

    /// Washes a marker swipe behind this view.
    func drawablyHighlight(seed: UInt32? = nil) -> some View {
        drawablyDecorated(.highlight, seed: seed)
    }

    /// Loops a pen circle around this view.
    func drawablyCircle(seed: UInt32? = nil) -> some View {
        drawablyDecorated(.circle, seed: seed)
    }

    private func drawablyDecorated(_ decoration: DrawablyDecoration, seed: UInt32?) -> some View {
        modifier(DrawablyDecorationModifier(decoration: decoration, seed: seed))
    }
}

/// Decorates whatever it is applied to as a single box.
///
/// Upstream draws one mark per line an inline element wraps onto; `Text` gets
/// that too, through the renderer below. Everything else is one box.
struct DrawablyDecorationModifier: ViewModifier {
    let decoration: DrawablyDecoration
    let seed: UInt32?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var seedBox: SketchSeed

    init(decoration: DrawablyDecoration, seed: UInt32?) {
        self.decoration = decoration
        self.seed = seed
        _seedBox = State(initialValue: SketchSeed(pinned: seed))
    }

    func body(content: Content) -> some View {
        content
            .drawablySketch(
                decoration,
                layers: [
                    SketchLayer(decoration.role) { size, options in
                        decoration.shape(size, options)
                    }
                ],
                seed: seedBox.value,
                lineWidth: drawablyDecorationLineWidth
            )
            .onHover { hovering in
                guard hovering, decoration.isInteractive else { return }
                seedBox.resketch(reduceMotion: reduceMotion)
            }
    }
}
