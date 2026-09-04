import Drawably
import SwiftUI

/// Every component in the library, in the order the docs introduce them.
///
/// One entry per component drives the home list, the detail screen and the
/// previews — adding a component is adding an entry, not writing a screen.
///
/// It builds SwiftUI views, so it is main-actor bound like everything else here.
@MainActor let catalog: [CatalogEntry] = controlEntries + annotationEntries

/// The controls proper.
@MainActor private let controlEntries: [CatalogEntry] = [
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
    }
]
