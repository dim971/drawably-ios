import Drawably
import SwiftUI

/// Every component in the library, in the order the docs introduce them.
///
/// One entry per component drives the home list, the detail screen and the
/// previews — adding a component is adding an entry, not writing a screen.
///
/// It builds SwiftUI views, so it is main-actor bound like everything else here.
@MainActor let catalog: [CatalogEntry] = [
    CatalogEntry(
        "Button",
        summary: "Three variants, three tones, four states. Re-sketches when pressed.",
        demos: [
            Demo(
                "Variants",
                code: """
                DrawablyButton("Done", variant: .solid) { submit() }
                DrawablyButton("Save", variant: .scribble) { save() }
                DrawablyButton("Cancel") { dismiss() }
                """
            ) {
                HStack(spacing: 12) {
                    DrawablyButton("Done", variant: .solid) {}
                    DrawablyButton("Save", variant: .scribble) {}
                    DrawablyButton("Cancel") {}
                }
            },
            Demo(
                "Tones",
                code: """
                DrawablyButton("Keep", tone: .standard) {}
                DrawablyButton("Later", tone: .neutral) {}
                DrawablyButton("Delete", tone: .danger) {}
                """
            ) {
                HStack(spacing: 12) {
                    DrawablyButton("Keep") {}
                    DrawablyButton("Later", tone: .neutral) {}
                    DrawablyButton("Delete", tone: .danger) {}
                }
            },
            Demo(
                "States",
                note: "A state recolours the ink without touching the theme.",
                code: """
                DrawablyButton("Wait", state: .loading) {}
                DrawablyButton("Retry", state: .error) {}
                DrawablyButton("Saved", state: .success) {}
                """
            ) {
                HStack(spacing: 12) {
                    DrawablyButton("Wait", state: .loading) {}
                    DrawablyButton("Retry", state: .error) {}
                    DrawablyButton("Saved", state: .success) {}
                }
            },
            Demo(
                "Live",
                code: """
                @State private var state: DrawablyButtonState = .idle

                DrawablyButton("Save", state: state) { save() }
                """
            ) {
                LoadingButtonSample()
            }
        ]
    ) {
        DrawablyButton("Done", variant: .solid) {}
    },

    CatalogEntry(
        "Card",
        summary: "A sketched box to group content in.",
        demos: [
            Demo(
                "Card",
                code: """
                DrawablyCard {
                    Text("npm i drawably")
                }
                """
            ) {
                DrawablyCard {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("npm i drawably")
                            .font(.system(.body, design: .monospaced))
                        Text("Every render a fresh pen sketch.")
                            .font(.caption)
                    }
                }
            }
        ]
    ) {
        DrawablyCard { Text("Card").font(.caption) }
    },

    CatalogEntry(
        "Checkbox",
        summary: "The tick is drawn on stroke by stroke, not faded in.",
        demos: [
            Demo(
                "Checkbox",
                code: """
                @State private var agreed = true

                DrawablyCheckbox("Ship it", isOn: $agreed)
                DrawablyCheckbox(isOn: $agreed)
                """
            ) {
                CheckboxSample()
            }
        ]
    ) {
        CheckboxPreview()
    },

    CatalogEntry(
        "Radio",
        summary: "A ring that gains a dot when picked.",
        demos: [
            Demo(
                "Radio group",
                code: """
                @State private var tool = "Pen"

                DrawablyRadio("Pen", selection: $tool, value: "Pen")
                DrawablyRadio("Pencil", selection: $tool, value: "Pencil")
                """
            ) {
                RadioSample()
            }
        ]
    ) {
        RadioPreview()
    },

    CatalogEntry(
        "Toggle",
        summary: "A pill with an ink blob that slides across it.",
        demos: [
            Demo(
                "Toggle",
                code: """
                @State private var boiling = true

                DrawablyToggle("Boil", isOn: $boiling)
                """
            ) {
                ToggleSample()
            }
        ]
    ) {
        TogglePreview()
    },

    CatalogEntry(
        "Text field",
        summary: "One line of text in a sketched box.",
        demos: [
            Demo(
                "Text field",
                code: """
                @State private var name = ""

                DrawablyTextField("Your name", text: $name)
                """
            ) {
                TextFieldSample()
            }
        ]
    ) {
        TextFieldPreview()
    },

    CatalogEntry(
        "Text editor",
        summary: "Several lines of it, in the same box.",
        demos: [
            Demo(
                "Text editor",
                code: """
                @State private var notes = ""

                DrawablyTextEditor(text: $notes, minHeight: 90)
                """
            ) {
                TextEditorSample()
            }
        ]
    ) {
        TextFieldPreview()
    },

    CatalogEntry(
        "Picker",
        summary: "A pen chevron, opening a sketched list tailed back to the field.",
        demos: [
            Demo(
                "Picker",
                note: "The box is already as wide as the widest option, so picking never shifts the layout.",
                code: """
                @State private var weight = "Medium"

                DrawablyPicker(selection: $weight, options: ["Light", "Medium", "Heavy"]) { $0 }
                """
            ) {
                PickerSample()
            }
        ]
    ) {
        PickerPreview()
    },

    CatalogEntry(
        "Divider",
        summary: "A pen line across the available width.",
        demos: [
            Demo("Divider", code: "DrawablyDivider()") {
                DrawablyDivider()
            }
        ]
    ) {
        DrawablyDivider()
    },

    CatalogEntry(
        "Badge",
        summary: "A small sharp-cornered tag round a monospaced label.",
        demos: [
            Demo(
                "Variants",
                code: """
                DrawablyBadge("v0.1.0")
                DrawablyBadge("MIT", variant: .scribble)
                """
            ) {
                HStack(spacing: 12) {
                    DrawablyBadge("v0.1.0")
                    DrawablyBadge("MIT", variant: .scribble)
                }
            }
        ]
    ) {
        DrawablyBadge("v0.1.0")
    },

    CatalogEntry(
        "List",
        summary: "Bullets drawn by hand in the gutter.",
        demos: [
            Demo(
                "Markers",
                code: """
                DrawablyList(steps, id: \\.self, marker: .check) { step in
                    Text(step)
                }
                """
            ) {
                VStack(alignment: .leading, spacing: 18) {
                    DrawablyList(["zero deps", "real inputs", "boils in CSS"], id: \.self) {
                        Text($0)
                    }
                    DrawablyList(["Sketch it", "Boil it", "Ship it"], id: \.self, marker: .check) {
                        Text($0)
                    }
                }
            }
        ]
    ) {
        DrawablyList(["one", "two"], id: \.self, marker: .check) {
            Text($0).font(.caption)
        }
    },

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

private struct CheckboxPreview: View {
    @State private var on = true
    var body: some View {
        DrawablyCheckbox(isOn: $on)
    }
}

private struct RadioPreview: View {
    @State private var value = "a"
    var body: some View {
        DrawablyRadio(selection: $value, value: "a") { EmptyView() }
    }
}

private struct TogglePreview: View {
    @State private var on = true
    var body: some View {
        DrawablyToggle(isOn: $on)
    }
}

private struct TextFieldPreview: View {
    @State private var text = ""
    var body: some View {
        DrawablyTextField("text", text: $text)
            .frame(width: 110)
    }
}

private struct PickerPreview: View {
    @State private var value = "Medium"
    var body: some View {
        DrawablyPicker(selection: $value, options: ["Medium"]) { $0 }
            .font(.caption)
    }
}

private struct ArrowPreview: View {
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
