import SwiftUI

/// A pill switch with an ink blob that slides across it.
///
/// ```swift
/// DrawablyToggle("Boil", isOn: $boiling)
/// ```
public struct DrawablyToggle<Label: View>: View {
    private let seed: UInt32?
    private let isOn: Binding<Bool>
    private let label: Label

    public init(isOn: Binding<Bool>, seed: UInt32? = nil, @ViewBuilder label: () -> Label) {
        self.isOn = isOn
        self.seed = seed
        self.label = label()
    }

    public var body: some View {
        Toggle(isOn: isOn) { label }
            .toggleStyle(DrawablyToggleStyle(seed: seed))
    }
}

public extension DrawablyToggle where Label == EmptyView {
    init(isOn: Binding<Bool>, seed: UInt32? = nil) {
        self.init(isOn: isOn, seed: seed) { EmptyView() }
    }
}

public extension DrawablyToggle where Label == Text {
    init(_ title: LocalizedStringKey, isOn: Binding<Bool>, seed: UInt32? = nil) {
        self.init(isOn: isOn, seed: seed) { Text(title) }
    }
}

/// Draws any SwiftUI `Toggle` as a Drawably switch.
public struct DrawablyToggleStyle: ToggleStyle {
    public static let width: Double = 44
    public static let height: Double = 24

    var seed: UInt32?

    public init(seed: UInt32? = nil) {
        self.seed = seed
    }

    public func makeBody(configuration: Configuration) -> some View {
        SketchedToggle(configuration: configuration, pinnedSeed: seed)
    }

    private struct SketchedToggle: View {
        let configuration: Configuration
        let pinnedSeed: UInt32?

        @Environment(\.drawablyTheme) private var theme
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @FocusState private var isFocused: Bool
        @State private var seed: SketchSeed

        init(configuration: Configuration, pinnedSeed: UInt32?) {
            self.configuration = configuration
            self.pinnedSeed = pinnedSeed
            _seed = State(initialValue: SketchSeed(pinned: pinnedSeed))
        }

        var body: some View {
            Button {
                configuration.isOn.toggle()
            } label: {
                HStack(spacing: 8) {
                    configuration.label
                    pill
                }
            }
            .buttonStyle(PressReportingButtonStyle { pressed in
                if pressed { seed.resketch(reduceMotion: reduceMotion) }
            })
            .focused($isFocused)
            .foregroundStyle(theme.stroke)
            .onHover { if $0 { seed.resketch(reduceMotion: reduceMotion) } }
            .accessibilityAddTraits(.isToggle)
            .accessibilityValue(configuration.isOn ? Text("On") : Text("Off"))
        }

        private var pill: some View {
            Color.clear
                .frame(
                    width: DrawablyToggleStyle.width,
                    height: DrawablyToggleStyle.height
                )
                .drawablySketch("toggle", layers: layers, seed: seed.value)
                .animation(.drawablyEase(), value: configuration.isOn)
        }

        /// The knob is drawn at the left end and slid across; its travel is the
        /// pill's width less its height, so the circle lands centred either way.
        private var travel: Double {
            configuration.isOn
                ? DrawablyGeometry.toggleKnobTravel(
                    DrawablyToggleStyle.width,
                    DrawablyToggleStyle.height
                )
                : 0
        }

        private var layers: [SketchLayer] {
            [
                SketchLayer(.outline) { size, o in
                    DrawablyGeometry.toggleOutline(size.width, size.height, o)
                },
                SketchLayer(.knob, offsetX: travel) { size, o in
                    DrawablyGeometry.toggleKnob(size.width, size.height, o)
                },
                SketchLayer(.focus, isVisible: isFocused) { size, o in
                    DrawablyGeometry.toggleFocus(size.width, size.height, o)
                }
            ]
        }
    }
}
