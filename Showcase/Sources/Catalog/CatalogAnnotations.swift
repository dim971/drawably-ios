import Drawably
import SwiftUI

/// The marks you put on other things, and the lean you put them at.
@MainActor let annotationEntries: [CatalogEntry] = [
    CatalogEntry(
        "Underline",
        summary: "A pen line under the words, one per line they wrap onto.",
        demos: [
            Demo(
                "Underline",
                code: #"Text("boils like a doodle").drawablyUnderline()"#
            ) {
                Text("boils like a doodle, and every line it wraps onto gets its own")
                    .drawablyUnderline()
            }
        ]
    ) {
        Text("underline").font(.caption).drawablyUnderline()
    },

    CatalogEntry(
        "Highlight",
        summary: "A marker swipe behind them.",
        demos: [
            Demo(
                "Highlight",
                code: #"Text("real inputs").drawablyHighlight()"#
            ) {
                Text("real inputs, so keyboard and screen readers work as usual")
                    .drawablyHighlight()
            }
        ]
    ) {
        Text("highlight").font(.caption).drawablyHighlight()
    },

    CatalogEntry(
        "Circle",
        summary: "A loop around them, overshooting the way a hand does.",
        demos: [
            Demo(
                "Circle",
                code: #"Text("zero dependencies").drawablyCircle()"#
            ) {
                Text("zero dependencies")
                    .drawablyCircle()
                    .padding(8)
            }
        ]
    ) {
        Text("circle").font(.caption).drawablyCircle()
    },

    CatalogEntry(
        "Tilt",
        summary: "A small hand-placed lean, on any control.",
        demos: [
            Demo(
                "Tilt",
                note: "The lean is picked once and held, so a control does not shift when it re-sketches.",
                code: """
                DrawablyButton("Done", variant: .solid) {}
                    .drawablyTilt()

                DrawablyCard {}
                    .drawablyTilt(degrees: -1.5)
                """
            ) {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 16) {
                        DrawablyButton("Done", variant: .solid) {}.drawablyTilt(seed: 3)
                        DrawablyButton("Save", variant: .scribble) {}.drawablyTilt(seed: 11)
                        DrawablyButton("Cancel") {}.drawablyTilt(seed: 19)
                    }
                    DrawablyCard(seed: 7) {
                        Text("pinned to -1.5°").font(.caption)
                    }
                    .drawablyTilt(degrees: -1.5)
                }
                .padding(.vertical, 8)
            }
        ]
    ) {
        DrawablyBadge("tilt", seed: 5).drawablyTilt(seed: 5, maxDegrees: 4)
    },

    CatalogEntry(
        "Arrow",
        summary: "A sketched arrow between two named anchors.",
        demos: [
            Demo(
                "Arrow",
                code: """
                DrawablyArrowLayer(arrows: [DrawablyArrow(from: "hint", to: "send")]) {
                    Text("start here").drawablyAnchor("hint")
                    DrawablyButton("Send", variant: .solid) {}.drawablyAnchor("send")
                }
                """
            ) {
                ArrowSample()
            }
        ]
    ) {
        ArrowPreview()
    }
]

// Previews are read-only, so they get their own tiny non-interactive views.

struct CheckboxPreview: View {
    @State private var on = true
    var body: some View {
        DrawablyCheckbox(isOn: $on)
    }
}

struct RadioPreview: View {
    @State private var value = "a"
    var body: some View {
        DrawablyRadio(selection: $value, value: "a") { EmptyView() }
    }
}

struct TogglePreview: View {
    @State private var on = true
    var body: some View {
        DrawablyToggle(isOn: $on)
    }
}

struct TextFieldPreview: View {
    @State private var text = ""
    var body: some View {
        DrawablyTextField("text", text: $text)
            .frame(width: 110)
    }
}

struct PickerPreview: View {
    @State private var value = "Medium"
    var body: some View {
        DrawablyPicker(selection: $value, options: ["Medium"]) { $0 }
            .font(.caption)
    }
}

struct ArrowPreview: View {
    var body: some View {
        DrawablyArrowLayer(arrows: [DrawablyArrow(from: "a", to: "b")]) {
            HStack {
                Color.clear.frame(width: 1, height: 20).drawablyAnchor("a")
                Spacer(minLength: 40)
                Color.clear.frame(width: 1, height: 20).drawablyAnchor("b")
            }
        }
        .frame(width: 100, height: 24)
    }
}
