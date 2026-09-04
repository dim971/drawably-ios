import SwiftUI

/// What a drawn layer *is*, which decides how it is painted.
///
/// One case per path class in upstream's stylesheet, so the paint rules below
/// can be read against it directly.
public enum SketchRole: Sendable, Hashable {
    /// The control's border.
    case outline
    /// A solid ink fill, as under a `solid` button.
    case blob
    /// Hatched fill.
    case scribble
    /// The ring shown while the control has keyboard focus.
    case focus
    /// A radio's centre dot.
    case dot
    /// A toggle's sliding knob.
    case knob
    /// A checkbox's tick.
    case check
    /// A select's V.
    case chevron
    /// A list row's bullet.
    case marker
    /// A highlighter's translucent swipe.
    case wash

    /// Whether the shape is filled as well as stroked.
    var isFilled: Bool {
        switch self {
        case .blob, .dot, .knob: true
        default: false
        }
    }

    /// Which of the theme's two ink colours the layer takes.
    var usesFillColor: Bool {
        switch self {
        case .blob, .dot, .knob, .wash: true
        default: false
        }
    }

    /// `nil` means "whatever the theme's stroke width is".
    var fixedLineWidth: Double? {
        switch self {
        case .blob, .knob: 4
        case .scribble, .focus: 1.5
        case .wash: 6
        default: nil
        }
    }

    var opacity: Double {
        self == .wash ? 0.3 : 1
    }

    var blendMode: BlendMode {
        self == .wash ? .multiply : .normal
    }
}
