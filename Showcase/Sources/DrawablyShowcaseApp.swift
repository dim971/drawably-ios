import Drawably
import SwiftUI

@main
struct DrawablyShowcaseApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                CatalogHomeScreen()
                    .tabItem { Label("Catalog", systemImage: "square.grid.2x2") }
                AboutScreen()
                    .tabItem { Label("About", systemImage: "info.circle") }
            }
        }
    }
}
