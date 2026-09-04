import SwiftUI

/// One option in a radio group: a sketched ring that gains a dot when picked.
///
/// ```swift
/// DrawablyRadio("Pen", selection: $tool, value: .pen)
/// DrawablyRadio("Pencil", selection: $tool, value: .pencil)
/// ```
public struct DrawablyRadio<Value: Hashable, Label: View>: View {
    /// Upstream sizes the ring in CSS; the same 22pt square here.
    public static var side: Double {
        22
    }

    @Binding private var selection: Value
    private let value: Value
    private let seed: UInt32?
    private let label: Label

    @Environment(\.drawablyTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var isFocused: Bool
    @State private var seedBox: SketchSeed

    public init(
        selection: Binding<Value>,
        value: Value,
        seed: UInt32? = nil,
        @ViewBuilder label: () -> Label
    ) {
        _selection = selection
        self.value = value
        self.seed = seed
        self.label = label()
        _seedBox = State(initialValue: SketchSeed(pinned: seed))
    }

    private var isSelected: Bool {
        selection == value
    }

    public var body: some View {
        Button {
            selection = value
        } label: {
            HStack(spacing: 8) {
                ring
                label
            }
        }
        .buttonStyle(PressReportingButtonStyle { pressed in
            if pressed { seedBox.resketch(reduceMotion: reduceMotion) }
        })
        .focused($isFocused)
        .foregroundStyle(theme.stroke)
        .onHover { if $0 { seedBox.resketch(reduceMotion: reduceMotion) } }
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var ring: some View {
        Color.clear
            .frame(width: Self.side, height: Self.side)
            .drawablySketch("radio", layers: layers, seed: seedBox.value)
            .animation(.drawablyEase(), value: isSelected)
    }

    private var layers: [SketchLayer] {
        [
            SketchLayer(.outline) { size, o in
                DrawablyGeometry.radioOutline(size.width, size.height, o)
            },
            // the dot pops in from half size rather than fading
            SketchLayer(.dot, isVisible: isSelected, scale: isSelected ? 1 : 0.5) { size, o in
                DrawablyGeometry.radioDot(size.width, size.height, o)
            },
            SketchLayer(.focus, isVisible: isFocused) { size, o in
                DrawablyGeometry.radioFocus(size.width, size.height, o)
            }
        ]
    }
}

public extension DrawablyRadio where Label == Text {
    init(
        _ title: LocalizedStringKey,
        selection: Binding<Value>,
        value: Value,
        seed: UInt32? = nil
    ) {
        self.init(selection: selection, value: value, seed: seed) { Text(title) }
    }
}
