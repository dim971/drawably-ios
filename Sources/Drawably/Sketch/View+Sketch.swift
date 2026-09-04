import SwiftUI

extension View {
    /// Draws a sketch behind this view. The shared plumbing for controls that
    /// never re-sketch on their own — cards, dividers, badges, fields.
    func drawablySketch(
        _ configuration: some Hashable,
        layers: [SketchLayer],
        seed: UInt32,
        ink: Color? = nil,
        lineWidth: Double? = nil,
        boilPeriod: Double = 0.4
    ) -> some View {
        background(
            SketchChrome(
                configuration: AnyHashable(configuration),
                layers: layers,
                seed: seed,
                boilPeriod: boilPeriod,
                ink: ink,
                lineWidth: lineWidth
            )
        )
    }
}
