import Foundation

/// The per-control layer geometry, ported from upstream `src/controls.ts`.
///
/// Each function is one drawn layer of one control, taking the control's box
/// and returning the shape for it. Components compose these; the golden tests
/// pin every one of them against the JS library's output.
public enum DrawablyGeometry {
    /// How far a control's outline sits inside its box, leaving room for the
    /// stroke and its jitter.
    public static let inset: Double = 3

    // MARK: - Shared rectangles

    public static func outlineRect(
        _ radius: Double, _ w: Double, _ h: Double, _ o: RoughOptions
    ) -> SketchPath {
        Rough.roundedRect(inset, inset, w - 2 * inset, h - 2 * inset, radius, o)
    }

    /// The focus ring sits just *outside* the box, unlike every other layer.
    public static func focusRect(
        _ radius: Double, _ w: Double, _ h: Double, _ o: RoughOptions
    ) -> SketchPath {
        Rough.roundedRect(-1, -1, w + 2, h + 2, radius, o)
    }

    // MARK: - Button

    public static func buttonOutline(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        outlineRect(8, w, h, o)
    }

    /// The `solid` variant's ink blob uses the same shape as the outline; only
    /// its paint differs.
    public static func buttonBlob(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        outlineRect(8, w, h, o)
    }

    public static func buttonScribble(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        Rough.scribbleFill(inset + 2, inset + 2, w - 2 * inset - 4, h - 2 * inset - 4, o)
    }

    public static func buttonFocus(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        focusRect(10, w, h, o)
    }

    // MARK: - Card

    public static func cardOutline(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        outlineRect(10, w, h, o)
    }

    // MARK: - Checkbox

    public static func checkboxOutline(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        outlineRect(5, w, h, o)
    }

    public static func checkboxCheck(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        Rough.checkmark(w * 0.24, h * 0.2, w * 0.52, h * 0.5, o)
    }

    public static func checkboxFocus(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        focusRect(7, w, h, o)
    }

    // MARK: - Radio

    public static func radioOutline(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        Rough.circle(w / 2, h / 2, min(w, h) / 2 - inset, o)
    }

    public static func radioDot(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        Rough.circle(w / 2, h / 2, min(w, h) * 0.18, o)
    }

    public static func radioFocus(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        Rough.circle(w / 2, h / 2, min(w, h) / 2 + 1, o)
    }

    // MARK: - Toggle

    /// A pill: the corner radius is whatever makes the ends semicircular.
    public static func toggleOutline(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        outlineRect((h - 2 * inset) / 2, w, h, o)
    }

    public static func toggleKnob(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        _ = w
        return Rough.circle(h / 2, h / 2, h / 2 - inset - 3, o)
    }

    public static func toggleFocus(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        focusRect(12, w, h, o)
    }

    /// How far the knob slides, for the default 44×24 pill.
    public static func toggleKnobTravel(_ w: Double, _ h: Double) -> Double {
        w - h
    }

    // MARK: - Divider

    public static func dividerOutline(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        Rough.line(inset, h / 2, w - inset, h / 2, o)
    }

    // MARK: - Text fields, text areas and selects

    public static func fieldOutline(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        outlineRect(6, w, h, o)
    }

    public static func fieldFocus(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        focusRect(8, w, h, o)
    }

    public static let chevronWidth: Double = 12
    public static let chevronHeight: Double = 6
    public static let chevronRight: Double = 12
    /// At chevron scale, full roughness turns the V into noise.
    public static let chevronRoughness: Double = 0.4

    public static func selectChevron(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        let x = w - chevronRight - chevronWidth
        let y = h / 2 - chevronHeight / 2
        var co = o
        co.roughness = o.roughness * chevronRoughness
        var second = co
        second.seed = o.seed &+ 1
        return Rough.line(x, y, x + chevronWidth / 2, y + chevronHeight, co)
            + Rough.line(x + chevronWidth / 2, y + chevronHeight, x + chevronWidth, y, second)
    }

    public static let checkBox: Double = 14
    public static let checkInset: Double = 2

    /// The tick drawn next to the chosen option in a picker.
    public static func selectCheckMask(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        _ = (w, h)
        let side = checkBox - checkInset * 2
        return Rough.checkmark(checkInset, checkInset, side, side, o)
    }

    /// How tall the tail is. The popup reserves this much at its top, so the
    /// tail is drawn inside the box rather than hanging outside it.
    public static let popupTailHeight: Double = 10
    public static let popupTailWidth: Double = 18

    /// The popup's frame, which starts below the space the tail occupies.
    public static func popupFrame(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        Rough.roundedRect(
            inset,
            inset + popupTailHeight,
            w - 2 * inset,
            h - 2 * inset - popupTailHeight,
            6,
            o
        )
    }

    /// A pen tail on the popup's top edge, pointing back at the control it
    /// belongs to. Two strokes meeting at a point, drawn the way an arrow head
    /// is — without it the popup floats unattached, since it carries none of
    /// the platform's own bubble.
    public static func popupTail(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        _ = h
        // centred, because the popup is centred under the control it belongs to
        let left = (w - popupTailWidth) / 2
        let apexX = left + popupTailWidth / 2
        let baseY = inset + popupTailHeight
        var second = o
        second.seed = o.seed &+ 1
        return Rough.line(left, baseY, apexX, inset, o)
            + Rough.line(apexX, inset, left + popupTailWidth, baseY, second)
    }

    // MARK: - Badge

    public static func badgeOutline(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        outlineRect(2, w, h, o)
    }

    public static func badgeScribble(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        Rough.scribbleFill(inset + 1, inset + 1, w - 2 * inset - 2, h - 2 * inset - 2, o)
    }

    // MARK: - List markers

    /// Markers are drawn in the gutter to the left of the row, so their x is
    /// negative relative to the row's box.
    public static let markerLeft: Double = -18
    public static let markerWidth: Double = 10
    public static let markerLine: Double = 22

    public static func listDash(
        _ w: Double, _ h: Double, _ o: RoughOptions, lineHeight: Double = markerLine
    ) -> SketchPath {
        _ = (w, h)
        return Rough.line(markerLeft, lineHeight / 2, markerLeft + markerWidth, lineHeight / 2, o)
    }

    public static func listCheck(
        _ w: Double, _ h: Double, _ o: RoughOptions, lineHeight: Double = markerLine
    ) -> SketchPath {
        _ = (w, h)
        return Rough.checkmark(
            markerLeft, lineHeight / 2 - markerWidth / 2, markerWidth, markerWidth, o
        )
    }

    // MARK: - Text decorations

    public static let underlineGap: Double = 2
    /// The loop overshoots the text box the way a hand circles a word rather
    /// than tracing it.
    public static let circlePadX: Double = 1.15
    public static let circlePadY: Double = 1.4
    public static let circlePad: Double = 4

    public static func underline(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        Rough.line(0, h + underlineGap, w, h + underlineGap, o)
    }

    public static func highlightWash(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        Rough.scribbleFill(0, 0, w, h, o)
    }

    public static func circleOutline(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        Rough.ellipse(
            w / 2, h / 2,
            (w / 2) * circlePadX + circlePad,
            (h / 2) * circlePadY + circlePad,
            o
        )
    }

    // MARK: - Arrow

    /// Breathing room between an anchor's edge and the arrow's end.
    public static let arrowGap: Double = 6
}
