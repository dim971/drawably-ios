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

    /// A control's border: a rounded rectangle inset from its box.
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

    /// A button's border.
    public static func buttonOutline(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        outlineRect(8, w, h, o)
    }

    /// The `solid` variant's ink blob uses the same shape as the outline; only
    /// its paint differs.
    public static func buttonBlob(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        outlineRect(8, w, h, o)
    }

    /// The hatching under a `scribble` button, inside the border.
    public static func buttonScribble(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        Rough.scribbleFill(inset + 2, inset + 2, w - 2 * inset - 4, h - 2 * inset - 4, o)
    }

    /// A button's focus ring.
    public static func buttonFocus(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        focusRect(10, w, h, o)
    }

    // MARK: - Card

    /// A card's border, rounded a little more than a button's.
    public static func cardOutline(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        outlineRect(10, w, h, o)
    }

    // MARK: - Checkbox

    /// A checkbox's border.
    public static func checkboxOutline(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        outlineRect(5, w, h, o)
    }

    /// A checkbox's tick, sized to about half the box.
    public static func checkboxCheck(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        Rough.checkmark(w * 0.24, h * 0.2, w * 0.52, h * 0.5, o)
    }

    /// A checkbox's focus ring.
    public static func checkboxFocus(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        focusRect(7, w, h, o)
    }

    // MARK: - Radio

    /// A radio's ring.
    public static func radioOutline(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        Rough.circle(w / 2, h / 2, min(w, h) / 2 - inset, o)
    }

    /// A radio's centre dot, drawn filled.
    public static func radioDot(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        Rough.circle(w / 2, h / 2, min(w, h) * 0.18, o)
    }

    /// A radio's focus ring.
    public static func radioFocus(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        Rough.circle(w / 2, h / 2, min(w, h) / 2 + 1, o)
    }

    // MARK: - Toggle

    /// A pill: the corner radius is whatever makes the ends semicircular.
    public static func toggleOutline(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        outlineRect((h - 2 * inset) / 2, w, h, o)
    }

    /// A toggle's knob, drawn at the left end and slid across.
    public static func toggleKnob(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        _ = w
        return Rough.circle(h / 2, h / 2, h / 2 - inset - 3, o)
    }

    /// A toggle's focus ring.
    public static func toggleFocus(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        focusRect(12, w, h, o)
    }

    /// How far the knob slides, for the default 44×24 pill.
    public static func toggleKnobTravel(_ w: Double, _ h: Double) -> Double {
        w - h
    }

    // MARK: - Divider

    /// A divider: one line across the middle of its box.
    public static func dividerOutline(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        Rough.line(inset, h / 2, w - inset, h / 2, o)
    }

    // MARK: - Text fields, text areas and selects

    /// The border a text field, text editor and picker share.
    public static func fieldOutline(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        outlineRect(6, w, h, o)
    }

    /// The focus ring those three share.
    public static func fieldFocus(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        focusRect(8, w, h, o)
    }

    /// The chevron's width, height, and distance from the trailing edge.
    public static let chevronWidth: Double = 12
    /// How tall the chevron is.
    public static let chevronHeight: Double = 6
    /// How far the chevron sits from the trailing edge.
    public static let chevronRight: Double = 12
    /// At chevron scale, full roughness turns the V into noise.
    public static let chevronRoughness: Double = 0.4

    /// A picker's V, drawn in the gutter its trailing padding reserves.
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

    /// The box a picker's tick is drawn in, and its inset within it.
    public static let checkBox: Double = 14
    /// How far the tick is inset in that box.
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
    /// How wide the tail is at its base.
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

    /// How far an outline's stroke can reach inside its box: the inset it is
    /// drawn at, half its own width, and the jitter of the second, wider pass.
    ///
    /// Anything that has to stay clear of the stroke — a label inside a tight
    /// box, say — has to allow for all three, and both of the last two come
    /// from the theme.
    public static func outlineReach(width: Double, roughness: Double) -> Double {
        inset + width / 2 + 1.5 * roughness * 1.4
    }

    // MARK: - Badge

    /// Upstream sets 1pt above and below, which leaves the label inside the
    /// stroke's own reach — at the default width it lands on the text, and a
    /// thicker pen or a rougher hand makes it worse.
    public static func badgePadding(
        width: Double,
        roughness: Double
    ) -> (vertical: Double, horizontal: Double) {
        let reach = outlineReach(width: width, roughness: roughness)
        return (vertical: reach + 2, horizontal: reach + 5)
    }

    /// A badge's border: a tight, near-square tag.
    public static func badgeOutline(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        outlineRect(2, w, h, o)
    }

    /// The hatching under a `scribble` badge.
    public static func badgeScribble(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        Rough.scribbleFill(inset + 1, inset + 1, w - 2 * inset - 2, h - 2 * inset - 2, o)
    }

    // MARK: - List markers

    /// Markers are drawn in the gutter to the left of the row, so their x is
    /// negative relative to the row's box.
    public static let markerLeft: Double = -18
    /// A marker's length, and the line height it is centred on.
    public static let markerWidth: Double = 10
    /// The line height a marker is centred on when the row does not say.
    public static let markerLine: Double = 22

    /// A list row's dash, drawn in the gutter to its left.
    public static func listDash(
        _ w: Double, _ h: Double, _ o: RoughOptions, lineHeight: Double = markerLine
    ) -> SketchPath {
        _ = (w, h)
        return Rough.line(markerLeft, lineHeight / 2, markerLeft + markerWidth, lineHeight / 2, o)
    }

    /// A list row's tick, drawn in the gutter to its left.
    public static func listCheck(
        _ w: Double, _ h: Double, _ o: RoughOptions, lineHeight: Double = markerLine
    ) -> SketchPath {
        _ = (w, h)
        return Rough.checkmark(
            markerLeft, lineHeight / 2 - markerWidth / 2, markerWidth, markerWidth, o
        )
    }

    // MARK: - Text decorations

    /// How far below the text box an underline sits.
    public static let underlineGap: Double = 2
    /// The loop overshoots the text box the way a hand circles a word rather
    /// than tracing it.
    public static let circlePadX: Double = 1.15
    /// How far the loop overshoots vertically.
    public static let circlePadY: Double = 1.4
    /// A few points more on top of that, in both directions.
    public static let circlePad: Double = 4

    /// A line under a run of text.
    public static func underline(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        Rough.line(0, h + underlineGap, w, h + underlineGap, o)
    }

    /// A marker swipe filling a run of text's box.
    public static func highlightWash(_ w: Double, _ h: Double, _ o: RoughOptions) -> SketchPath {
        Rough.scribbleFill(0, 0, w, h, o)
    }

    /// A loop around a run of text, overshooting its box.
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
