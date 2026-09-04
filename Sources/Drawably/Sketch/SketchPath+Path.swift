import SwiftUI

public extension SketchPath {
    /// Turns the engine's jittered polylines into a drawable `Path`, using the
    /// same midpoint smoothing the SVG output describes: a quadratic through
    /// each interior point, landing on the midpoint of the next segment.
    func path() -> Path {
        var path = Path()
        for subpath in subpaths {
            guard let first = subpath.points.first else { continue }
            path.move(to: CGPoint(x: first.x, y: first.y))
            if subpath.points.count > 2 {
                for i in 1 ..< (subpath.points.count - 1) {
                    let control = subpath.points[i]
                    let next = subpath.points[i + 1]
                    path.addQuadCurve(
                        to: CGPoint(x: (control.x + next.x) / 2, y: (control.y + next.y) / 2),
                        control: CGPoint(x: control.x, y: control.y)
                    )
                }
            }
            let last = subpath.points[subpath.points.count - 1]
            path.addLine(to: CGPoint(x: last.x, y: last.y))
            if subpath.closed { path.closeSubpath() }
        }
        return path
    }
}
