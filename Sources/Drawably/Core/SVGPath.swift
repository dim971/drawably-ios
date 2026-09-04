import Foundation

/// `Number.prototype.toFixed(2)`, reproduced.
///
/// C's `%.2f` rounds halves to even, JavaScript rounds them away from zero, so
/// a value like `0.125` formats as `0.12` in one and `0.13` in the other. Those
/// exact halves are common in this library's geometry, and the golden fixtures
/// are upstream's strings — hence the explicit tie branch.
func jsToFixed2(_ value: Double) -> String {
    if value.isNaN { return "NaN" }
    let negative = value < 0
    let magnitude = abs(value)
    if magnitude.isInfinite { return negative ? "-Infinity" : "Infinity" }

    let n: Double
    let halves = magnitude * 200
    if halves == halves.rounded(), halves.truncatingRemainder(dividingBy: 2) == 1 {
        // exactly .xx5: ECMAScript takes the larger candidate
        n = (halves + 1) / 2
    } else {
        n = (magnitude * 100).rounded(.toNearestOrAwayFromZero)
    }

    var digits = String(format: "%.0f", n)
    while digits.count < 3 {
        digits = "0" + digits
    }
    let split = digits.index(digits.endIndex, offsetBy: -2)
    let text = String(digits[..<split]) + "." + String(digits[split...])
    return negative ? "-" + text : text
}

public extension Subpath {
    /// The SVG `d` string upstream would emit for this stroke: a move, then a
    /// quadratic through each interior point to the midpoint of the next
    /// segment, then a line to the last point.
    ///
    /// Only the tests need this — rendering builds a `Path` from the same
    /// traversal instead — but it is what makes "faithful port" checkable.
    /// Every stroke's `d` string, concatenated the way upstream builds them.
    var svgString: String {
        guard let first = points.first else { return "" }
        var d = "M\(jsToFixed2(first.x)) \(jsToFixed2(first.y))"
        if points.count > 2 {
            for i in 1 ..< (points.count - 1) {
                let c = points[i]
                let mx = (c.x + points[i + 1].x) / 2
                let my = (c.y + points[i + 1].y) / 2
                d += "Q\(jsToFixed2(c.x)) \(jsToFixed2(c.y)) \(jsToFixed2(mx)) \(jsToFixed2(my))"
            }
        }
        let last = points[points.count - 1]
        d += "L\(jsToFixed2(last.x)) \(jsToFixed2(last.y))"
        return closed ? d + "Z" : d
    }
}

public extension SketchPath {
    /// Every stroke's `d` string, concatenated the way upstream builds them.
    var svgString: String {
        subpaths.map(\.svgString).joined()
    }
}
