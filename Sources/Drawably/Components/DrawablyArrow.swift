import SwiftUI

/// Collects the anchors an arrow can be drawn between.
struct DrawablyAnchorKey: PreferenceKey {
    static var defaultValue: [AnyHashable: Anchor<CGRect>] {
        [:]
    }

    static func reduce(
        value: inout [AnyHashable: Anchor<CGRect>],
        nextValue: () -> [AnyHashable: Anchor<CGRect>]
    ) {
        value.merge(nextValue()) { _, new in new }
    }
}

public extension View {
    /// Names this view so an enclosing ``DrawablyArrowLayer`` can point at it.
    func drawablyAnchor(_ id: some Hashable) -> some View {
        anchorPreference(key: DrawablyAnchorKey.self, value: .bounds) { anchor in
            [AnyHashable(id): anchor]
        }
    }
}

/// One arrow, from one named anchor to another.
public struct DrawablyArrow {
    let from: AnyHashable
    let to: AnyHashable
    let seed: UInt32?

    public init(from: some Hashable, to: some Hashable, seed: UInt32? = nil) {
        self.from = AnyHashable(from)
        self.to = AnyHashable(to)
        self.seed = seed
    }
}

/// Draws hand-sketched arrows between anchored views inside it.
///
/// ```swift
/// DrawablyArrowLayer(arrows: [DrawablyArrow(from: "hint", to: "submit")]) {
///     VStack {
///         Text("start here").drawablyAnchor("hint")
///         DrawablyButton("Send") {}.drawablyAnchor("submit")
///     }
/// }
/// ```
///
/// Upstream parks its arrows on `<body>` in document coordinates, which drift
/// when an anchor scrolls. Resolving anchors against this layer instead means
/// they stay put.
public struct DrawablyArrowLayer<Content: View>: View {
    private let arrows: [DrawablyArrow]
    private let content: Content

    public init(arrows: [DrawablyArrow], @ViewBuilder content: () -> Content) {
        self.arrows = arrows
        self.content = content()
    }

    public var body: some View {
        content.overlayPreferenceValue(DrawablyAnchorKey.self) { anchors in
            GeometryReader { proxy in
                ZStack(alignment: .topLeading) {
                    ForEach(Array(arrows.enumerated()), id: \.offset) { index, arrow in
                        if let from = anchors[arrow.from], let to = anchors[arrow.to] {
                            DrawablyArrowShape(
                                from: proxy[from],
                                to: proxy[to],
                                seed: arrow.seed,
                                index: index
                            )
                        }
                    }
                }
            }
            .allowsHitTesting(false)
        }
    }
}

/// The arrow itself: centre to centre, pulled back to each box's edge plus a
/// little clearance so it does not touch what it points at.
private struct DrawablyArrowShape: View {
    let from: CGRect
    let to: CGRect
    let seed: UInt32?
    let index: Int

    @State private var freshSeed = drawablyRandomSeed()

    var body: some View {
        let plan = plan()
        Color.clear
            .frame(width: plan.box.width, height: plan.box.height)
            .drawablySketch(
                "arrow",
                layers: [
                    SketchLayer(.outline) { _, options in
                        Rough.arrow(plan.x1, plan.y1, plan.x2, plan.y2, options)
                    }
                ],
                seed: (seed ?? freshSeed) &+ UInt32(truncatingIfNeeded: index)
            )
            .offset(x: plan.box.minX, y: plan.box.minY)
    }

    private struct Plan {
        var box: CGRect
        var x1: Double
        var y1: Double
        var x2: Double
        var y2: Double
    }

    private func plan() -> Plan {
        let box = from.union(to)
        let start = CGPoint(x: from.midX - box.minX, y: from.midY - box.minY)
        let end = CGPoint(x: to.midX - box.minX, y: to.midY - box.minY)
        let dx = end.x - start.x
        let dy = end.y - start.y
        let length = max(hypot(dx, dy), 1)
        let ux = dx / length
        let uy = dy / length

        /// How far from a box's centre its edge is, along the connecting line.
        /// A zero-size box gives 0/0 and means "no inset".
        func exit(_ rect: CGRect) -> Double {
            let horizontal = rect.width / 2 / abs(ux)
            let vertical = rect.height / 2 / abs(uy)
            let candidates = [horizontal, vertical].filter { !$0.isNaN && $0 != 0 }
            return candidates.min() ?? 0
        }

        let head = min(exit(from) + DrawablyGeometry.arrowGap, length / 2)
        let tail = min(exit(to) + DrawablyGeometry.arrowGap, length / 2)
        return Plan(
            box: box,
            x1: start.x + ux * head,
            y1: start.y + uy * head,
            x2: end.x - ux * tail,
            y2: end.y - uy * tail
        )
    }
}
