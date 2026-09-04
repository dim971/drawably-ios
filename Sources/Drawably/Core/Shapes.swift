import Foundation

public extension Rough {
    /// A straight pen stroke between two points.
    static func line(
        _ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double, _ o: RoughOptions
    ) -> SketchPath {
        doubleStroke(sampleLine(x1, y1, x2, y2), o, false)
    }

    /// A pen circle.
    static func circle(_ cx: Double, _ cy: Double, _ r: Double, _ o: RoughOptions) -> SketchPath {
        ellipse(cx, cy, r, r, o)
    }

    /// Ramanujan's perimeter approximation, sampled every 8 points like the
    /// lines are, so a big ellipse doesn't come out smoother than a short edge.
    static func ellipse(
        _ cx: Double, _ cy: Double, _ rx: Double, _ ry: Double, _ o: RoughOptions
    ) -> SketchPath {
        let h = pow((rx - ry) / (rx + ry), 2)
        let perimeter = Double.pi * (rx + ry) * (1 + (3 * h) / (10 + (4 - 3 * h).squareRoot()))
        let n = max(8, Int(ceil(perimeter / 8)))
        let points = ellipsePoints(cx, cy, rx, ry, 0, .pi * 2, n).dropLast()
        return doubleStroke(Array(points), o, true)
    }

    /// A pen rectangle with rounded corners.
    static func roundedRect(
        _ x: Double, _ y: Double, _ w: Double, _ h: Double, _ r: Double, _ o: RoughOptions
    ) -> SketchPath {
        doubleStroke(roundedRectPoints(x, y, w, h, r), o, true)
    }

    /// How long each of the arrow head's wings is, and how far it opens.
    static let arrowHead: Double = 12
    /// How far each wing opens from the shaft.
    static let arrowHeadAngle: Double = .pi / 6

    /// A pen arrow: a shaft and two wings meeting at its point.
    static func arrow(
        _ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double, _ o: RoughOptions
    ) -> SketchPath {
        let a = atan2(y2 - y1, x2 - x1)
        func wing(_ da: Double) -> Pt {
            Pt(x2 - arrowHead * cos(a + da), y2 - arrowHead * sin(a + da))
        }
        let left = wing(arrowHeadAngle)
        let right = wing(-arrowHeadAngle)

        // The shaft runs its own stream off the same seed; both wings then
        // share a second stream, in that order.
        let shaft = line(x1, y1, x2, y2, o)
        var rand = Mulberry32(seed: o.seed)
        let amp = 1.2 * o.roughness
        func head(_ p: Pt) -> Subpath {
            let pts = boilPass(jitter(sampleLine(x2, y2, p.x, p.y, step: 4), &rand, amp), o)
            return Subpath(points: pts, closed: false)
        }
        return shaft + SketchPath([head(left), head(right)])
    }

    /// A pen tick, drawn down then up.
    static func checkmark(
        _ x: Double, _ y: Double, _ w: Double, _ h: Double, _ o: RoughOptions
    ) -> SketchPath {
        var rand = Mulberry32(seed: o.seed)
        // The shared vertex is deliberately duplicated: midpoint smoothing
        // would otherwise round the corner off.
        let pts = sampleLine(x, y + h * 0.6, x + w * 0.35, y + h, step: 4)
            + sampleLine(x + w * 0.35, y + h, x + w, y, step: 4)
        let jittered = boilPass(jitter(pts, &rand, 1.2 * o.roughness), o)
        return SketchPath([Subpath(points: jittered, closed: false)])
    }

    /// A single back-and-forth 45° hatch, drawn as one continuous stroke.
    static func scribbleFill(
        _ x: Double, _ y: Double, _ w: Double, _ h: Double, _ o: RoughOptions
    ) -> SketchPath {
        var rand = Mulberry32(seed: o.seed)
        let gap: Double = 6
        var pts: [Pt] = []
        var flip = false
        var t = gap
        while t < w + h {
            let a = Pt(x + max(0, t - h), y + min(t, h))
            let b = Pt(x + min(t, w), y + max(0, t - w))
            pts.append(contentsOf: flip ? [b, a] : [a, b])
            flip.toggle()
            t += gap
        }
        guard pts.count >= 2 else { return SketchPath() }
        let jittered = boilPass(jitter(pts, &rand, 1.2 * o.roughness), o)
        return SketchPath([Subpath(points: jittered, closed: false)])
    }
}
