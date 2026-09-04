import Drawably
import SwiftUI

@main
struct DrawablyShowcaseApp: App {
    var body: some Scene {
        WindowGroup {
            ScratchScreen()
        }
    }
}

/// A temporary page for eyeballing components as they land.
struct ScratchScreen: View {
    @State private var agreed = true
    @State private var subscribed = false
    @State private var boiling = true
    @State private var tool = "Pen"
    @State private var name = ""
    @State private var notes = "Boils like a doodle."
    @State private var weight = "Medium"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Text("Buttons")
                    .font(.headline)
                HStack(spacing: 12) {
                    DrawablyButton("Done", variant: .solid) {}
                    DrawablyButton("Save", variant: .scribble) {}
                    DrawablyButton("Cancel", tone: .neutral) {}
                }
                HStack(spacing: 12) {
                    DrawablyButton("Delete", tone: .danger) {}
                    DrawablyButton("Retry", state: .error) {}
                    DrawablyButton("Saved", state: .success) {}
                }
                HStack(spacing: 12) {
                    DrawablyButton("Wait", state: .loading) {}
                    DrawablyButton("Off") {}.disabled(true)
                }

                Text("Choice")
                    .font(.headline)
                VStack(alignment: .leading, spacing: 14) {
                    DrawablyCheckbox("Ship it", isOn: $agreed)
                    DrawablyCheckbox("Subscribe", isOn: $subscribed)
                    DrawablyToggle("Boil", isOn: $boiling)
                    HStack(spacing: 20) {
                        DrawablyRadio("Pen", selection: $tool, value: "Pen")
                        DrawablyRadio("Pencil", selection: $tool, value: "Pencil")
                    }
                }

                Text("Fields")
                    .font(.headline)
                VStack(alignment: .leading, spacing: 14) {
                    DrawablyTextField("Your name", text: $name)
                    DrawablyTextEditor(text: $notes, minHeight: 72)
                    DrawablyPicker(selection: $weight, options: ["Light", "Medium", "Heavy"]) { $0 }
                }

                Text("List")
                    .font(.headline)
                DrawablyList(["Sketch it", "Boil it", "Ship it"], id: \.self, marker: .check) {
                    Text($0)
                }

                Text("Decorations")
                    .font(.headline)
                VStack(alignment: .leading, spacing: 16) {
                    Text("boils like a doodle").drawablyUnderline()
                    Text("real inputs").drawablyHighlight()
                    Text("zero dependencies").drawablyCircle()
                }
                .padding(.vertical, 8)

                Text("Arrow")
                    .font(.headline)
                DrawablyArrowLayer(arrows: [DrawablyArrow(from: "hint", to: "send")]) {
                    HStack {
                        Text("start here")
                            .drawablyAnchor("hint")
                        Spacer()
                        DrawablyButton("Send", variant: .solid) {}
                            .drawablyAnchor("send")
                    }
                    .padding(.vertical, 20)
                }

                Text("Badges")
                    .font(.headline)
                HStack(spacing: 12) {
                    DrawablyBadge("v0.1.0")
                    DrawablyBadge("MIT", variant: .scribble)
                }

                Text("Divider")
                    .font(.headline)
                DrawablyDivider()

                Text("Card")
                    .font(.headline)
                DrawablyCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("npm i drawably")
                            .font(.system(.body, design: .monospaced))
                        Text("Every render a fresh pen sketch.")
                            .font(.caption)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .background(Color.white)
    }
}
