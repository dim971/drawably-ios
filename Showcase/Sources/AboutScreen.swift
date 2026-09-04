import Drawably
import SwiftUI

/// What this is, where it came from, and who to credit.
struct AboutScreen: View {
    @Environment(\.showcaseSettings) private var settings

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(
                        "Hand-drawn UI controls. Every appearance a fresh pen sketch, boiling like a doodle."
                    )
                    .font(.title3)

                    HStack(spacing: 10) {
                        DrawablyBadge("v0.1.0")
                        DrawablyBadge("MIT", variant: .scribble)
                    }

                    DrawablyDivider()

                    DrawablyCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("A SwiftUI port of Drawably")
                                .font(.headline)
                            Text(
                                "The stroke engine is a direct port of the web library's, "
                                    + "checked against fixtures generated from the published npm "
                                    + "package: the same PRNG stream, the same sample counts, the "
                                    + "same boil frames."
                            )
                            .font(.callout)
                            Link("drawably.dev", destination: URL(string: "https://www.drawably.dev")!)
                                .font(.callout)
                        }
                    }

                    DrawablyList(
                        [
                            "Zero dependencies",
                            "Real controls underneath, so VoiceOver and focus work",
                            "Boils in a timeline, not a render loop"
                        ],
                        id: \.self,
                        marker: .check
                    ) {
                        Text($0)
                    }

                    Text("Upstream Drawably is © 2026 Daniel Belyi, MIT licensed.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .drawablyTheme(settings.theme)
                .id(settings.resketchToken)
                .padding(24)
            }
            .navigationTitle("About")
        }
    }
}
