import CoreGraphics
import Foundation

/// A point in the sketch's own coordinate space.
public struct Pt: Sendable, Equatable {
    public var x: Double
    public var y: Double

    public init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }
}

/// One continuous pen stroke: a jittered polyline that gets smoothed through
/// the midpoints between its points when it is turned into a path.
public struct Subpath: Sendable, Equatable {
    public var points: [Pt]
    public var closed: Bool

    public init(points: [Pt], closed: Bool) {
        self.points = points
        self.closed = closed
    }
}

/// A whole sketched shape. Upstream concatenates SVG `d` strings; the same
/// concatenation here is a list of strokes, so nothing is lost and the
/// geometry stays inspectable.
public struct SketchPath: Sendable, Equatable {
    public var subpaths: [Subpath]

    public init(_ subpaths: [Subpath] = []) {
        self.subpaths = subpaths
    }

    public static func + (lhs: SketchPath, rhs: SketchPath) -> SketchPath {
        SketchPath(lhs.subpaths + rhs.subpaths)
    }

    public var isEmpty: Bool {
        subpaths.isEmpty
    }
}

/// The stroke engine. A direct port of upstream `src/rough.ts`.
public enum Rough {
    // MARK: - Sampling

    /// Walks a straight edge in `step`-point increments.
    public static func sampleLine(
        _ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double, step: Double = 8
    ) -> [Pt] {
        let n = max(2, Int(ceil(hypot(x2 - x1, y2 - y1) / step)))
        return (0 ... n).map { i in
            let t = Double(i) / Double(n)
            return Pt(x1 + (x2 - x1) * t, y1 + (y2 - y1) * t)
        }
    }

    public static func ellipsePoints(
        _ cx: Double, _ cy: Double, _ rx: Double, _ ry: Double,
        _ a0: Double, _ a1: Double, _ n: Int
    ) -> [Pt] {
        (0 ... n).map { i in
            let a = a0 + (a1 - a0) * Double(i) / Double(n)
            return Pt(cx + rx * cos(a), cy + ry * sin(a))
        }
    }

    static func arcPoints(
        _ cx: Double, _ cy: Double, _ r: Double, _ a0: Double, _ a1: Double, _ n: Int = 4
    ) -> [Pt] {
        ellipsePoints(cx, cy, r, r, a0, a1, n)
    }

    static func roundedRectPoints(
        _ x: Double, _ y: Double, _ w: Double, _ h: Double, _ radius: Double
    ) -> [Pt] {
        let r = min(radius, w / 2, h / 2)
        return sampleLine(x + r, y, x + w - r, y)
            + arcPoints(x + w - r, y + r, r, -.pi / 2, 0)
            + sampleLine(x + w, y + r, x + w, y + h - r)
            + arcPoints(x + w - r, y + h - r, r, 0, .pi / 2)
            + sampleLine(x + w - r, y + h, x + r, y + h)
            + arcPoints(x + r, y + h - r, r, .pi / 2, .pi)
            + sampleLine(x, y + h - r, x, y + r)
            + arcPoints(x + r, y + r, r, .pi, .pi * 1.5)
    }

    // MARK: - Jitter

    /// Nudges every point by up to `amp` in each axis. The x draw always
    /// precedes the y draw — reordering them would desynchronise the whole
    /// PRNG stream and change every sketch downstream.
    public static func jitter(_ points: [Pt], _ rand: inout Mulberry32, _ amp: Double) -> [Pt] {
        points.map { p in
            let dx = (rand.next() * 2 - 1) * amp
            let dy = (rand.next() * 2 - 1) * amp
            return Pt(p.x + dx, p.y + dy)
        }
    }

    static func boilPass(_ points: [Pt], _ o: RoughOptions) -> [Pt] {
        guard o.boil != 0, let boilSeed = o.boilSeed else { return points }
        var rand = Mulberry32(seed: boilSeed)
        return jitter(points, &rand, o.boil)
    }

    /// Draws the shape twice from one PRNG stream, the second pass 1.4× wider
    /// than the first — the overlap is what reads as a pen going over a line.
    static func doubleStroke(_ points: [Pt], _ o: RoughOptions, _ close: Bool) -> SketchPath {
        var rand = Mulberry32(seed: o.seed)
        let amp = 1.5 * o.roughness
        let first = boilPass(jitter(points, &rand, amp), o)
        let second = boilPass(jitter(points, &rand, amp * 1.4), o)
        return SketchPath([
            Subpath(points: first, closed: close),
            Subpath(points: second, closed: close)
        ])
    }

    // MARK: - Boil frames

    /// The `n` pre-computed frames the boil animation cycles through, each
    /// re-jittered off a prime-spaced offset of the base seed.
    public static func variants(
        _ generate: (RoughOptions) -> SketchPath,
        _ o: RoughOptions,
        count: Int = 3
    ) -> [SketchPath] {
        (0 ..< count).map { i in
            var framed = o
            framed.boilSeed = o.seed &+ UInt32(truncatingIfNeeded: (i + 1) * 7919)
            return generate(framed)
        }
    }
}
