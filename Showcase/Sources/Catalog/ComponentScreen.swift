import Drawably
import SwiftUI

/// One component: what it is, every variant of it live, and the code for each.
struct ComponentScreen: View {
    let entry: CatalogEntry

    @Environment(\.showcaseSettings) private var settings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text(entry.summary)
                    .font(.callout)
                    .foregroundStyle(.secondary)

                PenControls()

                ForEach(entry.demos) { demo in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(demo.title)
                            .font(.subheadline.weight(.semibold))
                        if let note = demo.note {
                            Text(note)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        demo.sample()
                            .drawablyTheme(settings.theme)
                            .id(settings.resketchToken)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color.white, in: .rect(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.quaternary)
                            )
                        CodeSnippet(code: demo.code)
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle(entry.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}
