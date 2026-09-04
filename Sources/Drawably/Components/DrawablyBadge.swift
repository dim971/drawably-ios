import SwiftUI

/// How a badge's box is filled in.
public enum DrawablyBadgeVariant: Sendable, Hashable {
    case outline
    case scribble
}

/// A small sharp-cornered tag, drawn round a monospaced label.
///
/// ```swift
/// DrawablyBadge("v0.3.10")
/// ```
public struct DrawablyBadge<Label: View>: View {
    private let variant: DrawablyBadgeVariant
    private let seed: UInt32?
    private let label: Label

    @Environment(\.drawablyTheme) private var theme
    @State private var freshSeed = drawablyRandomSeed()

    public init(
        variant: DrawablyBadgeVariant = .outline,
        seed: UInt32? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self.variant = variant
        self.seed = seed
        self.label = label()
    }

    public var body: some View {
        label
            .font(.system(size: 12, weight: .medium, design: .monospaced))
            .foregroundStyle(theme.stroke)
            .padding(.vertical, 1)
            .padding(.horizontal, 7)
            .drawablySketch(variant, layers: layers, seed: seed ?? freshSeed)
    }

    private var layers: [SketchLayer] {
        var layers: [SketchLayer] = []
        if variant == .scribble {
            layers.append(SketchLayer(.scribble) { size, o in
                DrawablyGeometry.badgeScribble(size.width, size.height, o)
            })
        }
        layers.append(SketchLayer(.outline) { size, o in
            DrawablyGeometry.badgeOutline(size.width, size.height, o)
        })
        return layers
    }
}

public extension DrawablyBadge where Label == Text {
    init(
        _ title: LocalizedStringKey,
        variant: DrawablyBadgeVariant = .outline,
        seed: UInt32? = nil
    ) {
        self.init(variant: variant, seed: seed) { Text(title) }
    }
}
