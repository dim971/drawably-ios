import SwiftUI

/// How far a tilt leans, and where the angle comes from.
public enum DrawablyTilt {
    /// A couple of degrees: enough to read as placed by hand, not enough to
    /// look broken.
    public static let defaultMaxDegrees: Double = 2

    /// The angle a seed produces, drawn from the same PRNG the sketches use so
    /// a pinned seed gives a pinned lean.
    public static func angle(seed: UInt32, maxDegrees: Double = defaultMaxDegrees) -> Double {
        var rand = Mulberry32(seed: seed)
        return (rand.next() * 2 - 1) * maxDegrees
    }
}

public extension View {
    /// Leans this view by a small random angle, so a group of controls looks
    /// laid out by hand rather than by a layout engine.
    ///
    /// ```swift
    /// DrawablyButton("Done", variant: .solid) {}
    ///     .drawablyTilt()
    /// ```
    ///
    /// The lean is picked once and held: it is a placement, not part of the
    /// sketch, so it does not change when the control re-sketches under a
    /// finger. Pass a `seed` to pin it.
    func drawablyTilt(
        seed: UInt32? = nil,
        maxDegrees: Double = DrawablyTilt.defaultMaxDegrees
    ) -> some View {
        modifier(DrawablyTiltModifier(seed: seed, maxDegrees: maxDegrees))
    }

    /// Leans this view by an exact angle.
    func drawablyTilt(degrees: Double) -> some View {
        rotationEffect(.degrees(degrees))
    }
}

/// Holds the lean so it survives re-renders without being re-rolled.
private struct DrawablyTiltModifier: ViewModifier {
    let seed: UInt32?
    let maxDegrees: Double

    @State private var freshSeed = drawablyRandomSeed()

    func body(content: Content) -> some View {
        content.rotationEffect(
            .degrees(DrawablyTilt.angle(seed: seed ?? freshSeed, maxDegrees: maxDegrees))
        )
    }
}
