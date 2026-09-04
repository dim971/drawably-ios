import SwiftUI

/// What a list draws in its gutter.
public enum DrawablyListMarker: Sendable, Hashable {
    /// A short pen dash.
    case dash
    /// A pen tick.
    case check
}

/// A list whose bullets are drawn by hand in the gutter.
///
/// ```swift
/// DrawablyList(steps, id: \.self, marker: .check) { step in
///     Text(step)
/// }
/// ```
public struct DrawablyList<Data: RandomAccessCollection, ID: Hashable, Content: View>: View {
    /// The gutter the markers are drawn into.
    public static var gutter: Double {
        24
    }

    private let data: Data
    private let id: KeyPath<Data.Element, ID>
    private let marker: DrawablyListMarker
    private let seed: UInt32?
    private let spacing: Double
    private let content: (Data.Element) -> Content

    @State private var freshSeed = drawablyRandomSeed()

    public init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        marker: DrawablyListMarker = .dash,
        spacing: Double = 6,
        seed: UInt32? = nil,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.id = id
        self.marker = marker
        self.spacing = spacing
        self.seed = seed
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(rows) { row in
                content(row.element)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    // the marker is drawn to the left of the row's own box, so
                    // it lands in the list's leading padding
                    .drawablySketch(
                        marker,
                        layers: [markerLayer(marker)],
                        seed: (seed ?? freshSeed) &+ UInt32(truncatingIfNeeded: row.index)
                    )
            }
        }
        .padding(.leading, Self.gutter)
    }

    /// Each row keeps both its caller-supplied identity and its position, since
    /// the position is what seeds its marker.
    private struct Row: Identifiable {
        let id: ID
        let index: Int
        let element: Data.Element
    }

    private var rows: [Row] {
        data.enumerated().map { Row(id: $0.element[keyPath: id], index: $0.offset, element: $0.element) }
    }
}

/// Built outside the generic view on purpose: a sendable closure declared in
/// there captures `Data`, `ID` and `Content`'s metatypes, and it only ever
/// needed the marker.
private func markerLayer(_ marker: DrawablyListMarker) -> SketchLayer {
    SketchLayer(.marker) { size, options in
        switch marker {
        case .dash:
            DrawablyGeometry.listDash(size.width, size.height, options, lineHeight: size.height)
        case .check:
            DrawablyGeometry.listCheck(size.width, size.height, options, lineHeight: size.height)
        }
    }
}

public extension DrawablyList where Data.Element: Identifiable, ID == Data.Element.ID {
    init(
        _ data: Data,
        marker: DrawablyListMarker = .dash,
        spacing: Double = 6,
        seed: UInt32? = nil,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.init(data, id: \.id, marker: marker, spacing: spacing, seed: seed, content: content)
    }
}
