import Drawably
import SwiftUI

/// The live theme every screen draws with, plus the "draw it all again" button.
///
/// Sliding roughness or boil re-renders the whole catalog, which doubles as the
/// manual test that theming actually reaches every control.
@Observable
final class ShowcaseSettings {
    /// The app's one settings object, and the environment's default value.
    ///
    /// `@Entry` would otherwise allocate a fresh instance on every read of the
    /// environment, which invalidates every dependent on each update. It is
    /// only ever touched on the main actor.
    nonisolated(unsafe) static let shared = ShowcaseSettings()

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
    @Entry var showcaseSettings = ShowcaseSettings.shared
}
