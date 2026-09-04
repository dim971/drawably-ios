import SwiftUI

/// Reports press state without changing how the label looks.
///
/// Lets a custom `ToggleStyle` keep `Button`'s hit testing and press timing
/// while still driving the re-sketch that upstream hangs off `pointerdown`.
struct PressReportingButtonStyle: ButtonStyle {
    let onPressChange: (Bool) -> Void

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(.rect)
            .onChange(of: configuration.isPressed) { _, pressed in onPressChange(pressed) }
    }
}

/// Owns the seed for a control that re-sketches when touched.
///
/// A pinned seed disables the behaviour, and so does reduced motion — matching
/// upstream, which does not even attach its pointer listeners in that case.
@Observable
final class SketchSeed {
    private(set) var value: UInt32

    init(pinned: UInt32?) {
        self.pinned = pinned
        value = pinned ?? drawablyRandomSeed()
    }

    private let pinned: UInt32?

    func resketch(reduceMotion: Bool) {
        guard pinned == nil, !reduceMotion else { return }
        value = drawablyRandomSeed()
    }
}
