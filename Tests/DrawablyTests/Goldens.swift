@testable import Drawably
import Foundation

/// Fixtures generated from the published `drawably` npm package by
/// `Tools/gen-goldens.mjs`. Regenerate them when tracking a new upstream
/// version; never hand-edit them.
struct Goldens: Decodable {
    struct Options: Decodable {
        let seed: UInt32
        let roughness: Double
        let boil: Double?

        var rough: RoughOptions {
            RoughOptions(seed: seed, roughness: roughness, boil: boil ?? 0)
        }
    }

    struct PRNGCase: Decodable {
        let seed: UInt32
        let values: [Double]
    }

    struct ShapeCase: Decodable {
        let fn: String
        let args: [Double]
        let opts: Options
        let d: String
    }

    struct VariantCase: Decodable {
        let fn: String
        let args: [Double]
        let opts: Options
        let n: Int
        let ds: [String]
    }

    struct ControlCase: Decodable {
        let layer: String
        let w: Double
        let h: Double
        let opts: Options
        let ds: [String]
    }

    struct ArrowCase: Decodable {
        let layer: String
        let args: [Double]
        let opts: Options
        let ds: [String]
    }

    let upstream: String
    let prng: [PRNGCase]
    let shapes: [ShapeCase]
    let variants: [VariantCase]
    let controls: [ControlCase]
    let arrows: [ArrowCase]

    static let shared: Goldens = {
        guard let url = Bundle.module.url(
            forResource: "goldens", withExtension: "json", subdirectory: "Fixtures"
        ) else {
            fatalError("goldens.json is missing from the test bundle")
        }
        do {
            return try JSONDecoder().decode(Goldens.self, from: Data(contentsOf: url))
        } catch {
            fatalError("goldens.json could not be decoded: \(error)")
        }
    }()
}

/// Rebuilds a primitive from the name and argument list the fixture records.
func generate(_ fn: String, _ a: [Double], _ o: RoughOptions) -> SketchPath {
    switch fn {
    case "roughLine": Rough.line(a[0], a[1], a[2], a[3], o)
    case "roughRoundedRect": Rough.roundedRect(a[0], a[1], a[2], a[3], a[4], o)
    case "roughCircle": Rough.circle(a[0], a[1], a[2], o)
    case "roughEllipse": Rough.ellipse(a[0], a[1], a[2], a[3], o)
    case "roughArrow": Rough.arrow(a[0], a[1], a[2], a[3], o)
    case "roughCheckmark": Rough.checkmark(a[0], a[1], a[2], a[3], o)
    case "scribbleFill": Rough.scribbleFill(a[0], a[1], a[2], a[3], o)
    default: fatalError("unknown primitive in fixtures: \(fn)")
    }
}

/// A lookup table rather than a switch: the fixture's layer names map
/// one-to-one onto `DrawablyGeometry`, and a table keeps that obvious.
let layerGenerators: [String: @Sendable (Double, Double, RoughOptions) -> SketchPath] = [
    "button.outline": DrawablyGeometry.buttonOutline,
    "button.blob": DrawablyGeometry.buttonBlob,
    "button.scribble": DrawablyGeometry.buttonScribble,
    "button.focus": DrawablyGeometry.buttonFocus,
    "card.outline": DrawablyGeometry.cardOutline,
    "checkbox.outline": DrawablyGeometry.checkboxOutline,
    "checkbox.check": DrawablyGeometry.checkboxCheck,
    "checkbox.focus": DrawablyGeometry.checkboxFocus,
    "radio.outline": DrawablyGeometry.radioOutline,
    "radio.dot": DrawablyGeometry.radioDot,
    "radio.focus": DrawablyGeometry.radioFocus,
    "toggle.outline": DrawablyGeometry.toggleOutline,
    "toggle.knob": DrawablyGeometry.toggleKnob,
    "toggle.focus": DrawablyGeometry.toggleFocus,
    "divider.outline": DrawablyGeometry.dividerOutline,
    "field.outline": DrawablyGeometry.fieldOutline,
    "field.focus": DrawablyGeometry.fieldFocus,
    "select.chevron": DrawablyGeometry.selectChevron,
    "select.checkMask": DrawablyGeometry.selectCheckMask,
    "badge.outline": DrawablyGeometry.badgeOutline,
    "badge.scribble": DrawablyGeometry.badgeScribble,
    "list.dash": { DrawablyGeometry.listDash($0, $1, $2) },
    "list.check": { DrawablyGeometry.listCheck($0, $1, $2) },
    "underline.outline": DrawablyGeometry.underline,
    "highlight.wash": DrawablyGeometry.highlightWash,
    "circle.outline": DrawablyGeometry.circleOutline
]

func generateLayer(_ name: String, _ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
    guard let gen = layerGenerators[name] else {
        fatalError("unknown layer in fixtures: \(name)")
    }
    return gen(w, h, o)
}

/// One case where this port and upstream disagree.
struct Mismatch {
    let label: String
    let expected: String
    let actual: String
}

/// Formats the first few mismatches so a failure says which case broke and
/// where the two strings diverge, rather than dumping thousands of characters.
func report(_ mismatches: [Mismatch]) -> String {
    guard !mismatches.isEmpty else { return "" }
    let head = mismatches.prefix(3).map { m -> String in
        let common = zip(m.expected, m.actual).prefix { $0 == $1 }.count
        let from = max(0, common - 20)
        func window(_ s: String) -> String {
            let chars = Array(s)
            return String(chars[from ..< min(chars.count, from + 60)])
        }
        return """
        \(m.label)
          diverges at character \(common)
          expected …\(window(m.expected))…
          actual   …\(window(m.actual))…
        """
    }
    return "\(mismatches.count) mismatch(es):\n" + head.joined(separator: "\n")
}
