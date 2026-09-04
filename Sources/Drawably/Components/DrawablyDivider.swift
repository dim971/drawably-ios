import SwiftUI

/// A pen line across the available width.
public struct DrawablyDivider: View {
    private let seed: UInt32?

    @State private var freshSeed = drawablyRandomSeed()

    public init(seed: UInt32? = nil) {
        self.seed = seed
    }

    public var body: some View {
        Color.clear
            .frame(height: 10)
            .drawablySketch(
                "divider",
                layers: [
                    SketchLayer(.outline) { size, o in
                        DrawablyGeometry.dividerOutline(size.width, size.height, o)
                    }
                ],
                seed: seed ?? freshSeed
            )
    }
}
