import Drawably
import SwiftUI

/// The live theme every screen draws with, plus the "draw it all again" button.
///
/// Sliding roughness or boil re-renders the whole catalog, which doubles as the
/// manual test that theming actually reaches every control.
@Observable
final class ShowcaseSettings {
    var theme = DrawablyTheme.default
    /// Changing this re-identifies the content, so every control picks a fresh
    /// seed — the closest thing to upstream's `resketch()` across a whole page.
    private(set) var resketchToken = UUID()

    func resketch() {
        resketchToken = UUID()
    }

    func reset() {
        theme = .default
        resketch()
    }
}

extension EnvironmentValues {
    @Entry var showcaseSettings = ShowcaseSettings()
}
