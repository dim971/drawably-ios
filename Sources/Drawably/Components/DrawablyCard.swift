import SwiftUI

/// A sketched box to group content in.
///
/// ```swift
/// DrawablyCard {
///     Text("npm i drawably")
/// }
/// ```
public struct DrawablyCard<Content: View>: View {
    private let seed: UInt32?
    private let content: Content

    @State private var freshSeed = drawablyRandomSeed()

    public init(seed: UInt32? = nil, @ViewBuilder content: () -> Content) {
        self.seed = seed
        self.content = content()
    }

    public var body: some View {
        content
            .padding(16)
            .drawablySketch(
                "card",
                layers: [
                    SketchLayer(.outline) { size, o in
                        DrawablyGeometry.cardOutline(size.width, size.height, o)
                    }
                ],
                seed: seed ?? freshSeed
            )
    }
}
