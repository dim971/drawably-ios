import SwiftUI

/// One demo on a component's screen: a live sample and the code behind it.
struct Demo: Identifiable {
    let id: String
    let title: String
    var note: String?
    let sample: () -> AnyView
    let code: String

    init(
        _ title: String,
        note: String? = nil,
        code: String,
        @ViewBuilder sample: @escaping () -> some View
    ) {
        id = title
        self.title = title
        self.note = note
        self.code = code
        self.sample = { AnyView(sample()) }
    }
}

/// One component in the catalog.
///
/// Adding a component means adding an entry here — the home list, the detail
/// screen and the previews all read from this one place.
struct CatalogEntry: Identifiable {
    let id: String
    let name: String
    let summary: String
    let preview: () -> AnyView
    let demos: [Demo]

    init(
        _ name: String,
        summary: String,
        demos: [Demo],
        @ViewBuilder preview: @escaping () -> some View
    ) {
        id = name
        self.name = name
        self.summary = summary
        self.demos = demos
        self.preview = { AnyView(preview()) }
    }
}
