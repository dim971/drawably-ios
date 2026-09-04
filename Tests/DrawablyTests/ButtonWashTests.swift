@testable import Drawably
import SwiftUI
import Testing

/// The press wash is a pure function of the button's state, so it is checked
/// here rather than through a synthetic touch on a simulator.
@Suite("Button wash")
struct ButtonWashTests {
    private func wash(
        variant: DrawablyButtonVariant = .outline,
        isEnabled: Bool = true,
        isPressed: Bool = false,
        isHovering: Bool = false
    ) -> Color? {
        drawablyButtonWash(
            ink: .drawablyPenBlue,
            variant: variant,
            isEnabled: isEnabled,
            isPressed: isPressed,
            isHovering: isHovering
        )
    }

    @Test("a press washes the inside with the ink the border is drawn in")
    func pressed() {
        #expect(wash(isPressed: true) == Color.drawablyPenBlue.opacity(DrawablyButtonWash.pressed))
        #expect(wash(variant: .scribble, isPressed: true) != nil)
    }

    @Test("a press reads stronger than a hover, and wins over it")
    func pressBeatsHover() {
        #expect(DrawablyButtonWash.pressed > DrawablyButtonWash.hover)
        #expect(wash(isHovering: true) == Color.drawablyPenBlue.opacity(DrawablyButtonWash.hover))
        #expect(wash(isPressed: true, isHovering: true) ==
            Color.drawablyPenBlue.opacity(DrawablyButtonWash.pressed))
    }

    @Test("at rest, disabled, or solid there is no wash")
    func none() {
        #expect(wash() == nil)
        #expect(wash(isEnabled: false, isPressed: true) == nil)
        // a solid button is already filled with ink
        #expect(wash(variant: .solid, isPressed: true) == nil)
    }
}
