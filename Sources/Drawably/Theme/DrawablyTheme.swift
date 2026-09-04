import SwiftUI

/// The ink, paper and pen settings a sketch is drawn with.
///
/// Mirrors upstream's CSS custom properties one for one, defaults included, and
/// travels down the view tree the way they cascade.
public struct DrawablyTheme: Sendable, Equatable {
    /// Line colour. Upstream's pen blue.
    public var stroke: Color
    /// Colour for filled layers: a solid button's blob, a radio's dot, a
    /// highlight's wash.
    public var fill: Color
    /// Background the ink sits on; a solid button's label is drawn in it.
    public var paper: Color
    /// Stroke width for ordinary layers.
    public var width: Double
    /// Ink for the `danger` tone and the `error` state.
    public var error: Color
    /// Ink for the `success` state.
    public var success: Color
    /// Jitter amplitude of the base sketch.
    public var roughness: Double
    /// Per-frame flicker amplitude. `0` renders a still sketch.
    public var boil: Double

    public init(
        stroke: Color = .drawablyPenBlue,
        fill: Color = .drawablyPenBlue,
        paper: Color = .white,
        width: Double = 2,
        error: Color = .drawablyError,
        success: Color = .drawablySuccess,
        roughness: Double = 1,
        boil: Double = 0.3
    ) {
        self.stroke = stroke
        self.fill = fill
        self.paper = paper
        self.width = width
        self.error = error
        self.success = success
        self.roughness = roughness
        self.boil = boil
    }

    public static let `default` = DrawablyTheme()
}

public extension Color {
    /// `#2724d1` — upstream's default ink.
    static let drawablyPenBlue = Color(red: 0x27 / 255, green: 0x24 / 255, blue: 0xD1 / 255)
    /// `#d12724`
    static let drawablyError = Color(red: 0xD1 / 255, green: 0x27 / 255, blue: 0x24 / 255)
    /// `#188a42`
    static let drawablySuccess = Color(red: 0x18 / 255, green: 0x8A / 255, blue: 0x42 / 255)
    /// `#6e675f` — the warm grey of the `neutral` tone.
    static let drawablyNeutral = Color(red: 0x6E / 255, green: 0x67 / 255, blue: 0x5F / 255)
}

public extension EnvironmentValues {
    @Entry var drawablyTheme = DrawablyTheme.default
}

public extension View {
    /// Applies a theme to every Drawably control below this view.
    func drawablyTheme(_ theme: DrawablyTheme) -> some View {
        environment(\.drawablyTheme, theme)
    }

    /// Adjusts the inherited theme in place.
    func drawablyTheme(_ transform: @escaping (inout DrawablyTheme) -> Void) -> some View {
        transformEnvironment(\.drawablyTheme, transform: transform)
    }
}
