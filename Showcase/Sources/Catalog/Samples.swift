import Drawably
import SwiftUI

// Small stateful wrappers so each demo is genuinely interactive rather than a
// picture of a control.

struct CheckboxSample: View {
    @State private var agreed = true
    @State private var subscribed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            DrawablyCheckbox("Ship it", isOn: $agreed)
            DrawablyCheckbox("Subscribe", isOn: $subscribed)
            DrawablyCheckbox(isOn: $agreed)
        }
    }
}

struct RadioSample: View {
    @State private var tool = "Pen"

    var body: some View {
        HStack(spacing: 24) {
            DrawablyRadio("Pen", selection: $tool, value: "Pen")
            DrawablyRadio("Pencil", selection: $tool, value: "Pencil")
            DrawablyRadio("Marker", selection: $tool, value: "Marker")
        }
    }
}

struct ToggleSample: View {
    @State private var boiling = true
    @State private var muted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            DrawablyToggle("Boil", isOn: $boiling)
            DrawablyToggle("Mute", isOn: $muted)
        }
    }
}

struct TextFieldSample: View {
    @State private var name = ""
    @State private var email = "ada@example.com"

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            DrawablyTextField("Your name", text: $name)
            DrawablyTextField("Email", text: $email)
        }
    }
}

struct TextEditorSample: View {
    @State private var notes = "Every render a fresh pen sketch,\nboiling like a doodle."

    var body: some View {
        DrawablyTextEditor(text: $notes, minHeight: 90)
    }
}

struct PickerSample: View {
    @State private var weight = "Medium"

    var body: some View {
        DrawablyPicker(selection: $weight, options: ["Light", "Medium", "Heavy"]) { $0 }
    }
}

struct ArrowSample: View {
    var body: some View {
        DrawablyArrowLayer(arrows: [DrawablyArrow(from: "hint", to: "send")]) {
            HStack {
                Text("start here")
                    .drawablyAnchor("hint")
                Spacer(minLength: 60)
                DrawablyButton("Send", variant: .solid) {}
                    .drawablyAnchor("send")
            }
            .padding(.vertical, 24)
        }
    }
}

struct LoadingButtonSample: View {
    @State private var state: DrawablyButtonState = .idle

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            DrawablyButton("Save", state: state) {
                Task {
                    state = .loading
                    try? await Task.sleep(for: .seconds(1.4))
                    state = .success
                    try? await Task.sleep(for: .seconds(1.4))
                    state = .idle
                }
            }
            Text("Tap it — a loading button boils at 450ms instead of 1200ms.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
