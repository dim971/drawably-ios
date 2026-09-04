import Drawably
import SwiftUI

/// The pen settings, on every screen.
///
/// Parametric jitter is the whole point of this library, so the controls that
/// drive it are always to hand rather than buried in a settings screen.
struct PenControls: View {
    @Environment(\.showcaseSettings) private var settings

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Pen")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button("Re-sketch", systemImage: "arrow.trianglehead.2.clockwise") {
                    settings.resketch()
                }
                .font(.caption)
                .labelStyle(.titleAndIcon)
            }

            slider("Roughness", value: settingsBinding(\.roughness), range: 0 ... 3)
            slider("Boil", value: settingsBinding(\.boil), range: 0 ... 2)
            slider("Width", value: settingsBinding(\.width), range: 0.5 ... 6)

            HStack(spacing: 10) {
                Text("Ink")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(Array(inks.enumerated()), id: \.offset) { _, ink in
                    Button {
                        settings.theme.stroke = ink
                        settings.theme.fill = ink
                    } label: {
                        Circle()
                            .fill(ink)
                            .frame(width: 20, height: 20)
                            .overlay(Circle().stroke(.primary.opacity(0.2)))
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                Button("Reset") { settings.reset() }
                    .font(.caption)
            }
        }
        .padding(14)
        .background(.quaternary.opacity(0.4), in: .rect(cornerRadius: 12))
    }

    private var inks: [Color] {
        [.drawablyPenBlue, .black, .drawablyError, .drawablySuccess, .drawablyNeutral]
    }

    private func settingsBinding(_ keyPath: WritableKeyPath<DrawablyTheme, Double>) -> Binding<Double> {
        Binding(
            get: { settings.theme[keyPath: keyPath] },
            set: { settings.theme[keyPath: keyPath] = $0 }
        )
    }

    private func slider(
        _ title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>
    ) -> some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 68, alignment: .leading)
            Slider(value: value, in: range)
            Text(String(format: "%.2f", value.wrappedValue))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
    }
}
