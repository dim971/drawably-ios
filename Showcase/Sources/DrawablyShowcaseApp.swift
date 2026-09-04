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
