import Drawably
import SwiftUI

/// Every component, each row showing the real thing rather than a screenshot.
struct CatalogHomeScreen: View {
    @Environment(\.showcaseSettings) private var settings

    var body: some View {
        NavigationStack {
            List {
                Section {
                    PenControls()
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                Section("Components") {
                    ForEach(catalog) { entry in
                        NavigationLink(value: entry.id) {
                            row(entry)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Drawably")
            .navigationDestination(for: String.self) { id in
                if let entry = catalog.first(where: { $0.id == id }) {
                    ComponentScreen(entry: entry)
                }
            }
        }
    }

    private func row(_ entry: CatalogEntry) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.name)
                    .font(.body.weight(.medium))
                Text(entry.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 12)
            entry.preview()
                .drawablyTheme(settings.theme)
                .id(settings.resketchToken)
                .frame(maxWidth: 120, alignment: .trailing)
                .allowsHitTesting(false)
        }
        .padding(.vertical, 6)
    }
}
