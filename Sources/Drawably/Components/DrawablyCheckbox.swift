import SwiftUI

/// A checkbox whose tick is drawn on, stroke by stroke, when it is ticked.
///
/// ```swift
/// DrawablyCheckbox("Ship it", isOn: $agreed)
/// ```
public struct DrawablyCheckbox<Label: View>: View {
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
            .toggleStyle(DrawablyCheckboxStyle(seed: seed))
    }
}

public extension DrawablyCheckbox where Label == EmptyView {
    init(isOn: Binding<Bool>, seed: UInt32? = nil) {
        self.init(isOn: isOn, seed: seed) { EmptyView() }
    }
}

public extension DrawablyCheckbox where Label == Text {
    init(_ title: LocalizedStringKey, isOn: Binding<Bool>, seed: UInt32? = nil) {
        self.init(isOn: isOn, seed: seed) { Text(title) }
    }
}

/// Draws any SwiftUI `Toggle` as a Drawably checkbox.
public struct DrawablyCheckboxStyle: ToggleStyle {
    /// Upstream sizes the box in CSS; the same 22pt square here.
    public static let side: Double = 22

    var seed: UInt32?

    public init(seed: UInt32? = nil) {
        self.seed = seed
    }

    public func makeBody(configuration: Configuration) -> some View {
        SketchedCheckbox(configuration: configuration, pinnedSeed: seed)
    }

    private struct SketchedCheckbox: View {
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
                    box
                    configuration.label
                }
            }
            .buttonStyle(PressReportingButtonStyle { pressed in
                if pressed { seed.resketch(reduceMotion: reduceMotion) }
            })
            .focused($isFocused)
            .foregroundStyle(theme.stroke)
            .onHover { if $0 { seed.resketch(reduceMotion: reduceMotion) } }
            .accessibilityAddTraits(.isToggle)
            .accessibilityValue(configuration.isOn ? Text("Checked") : Text("Unchecked"))
        }

        private var box: some View {
            Color.clear
                .frame(
                    width: DrawablyCheckboxStyle.side,
                    height: DrawablyCheckboxStyle.side
                )
                .drawablySketch("checkbox", layers: layers, seed: seed.value)
                .animation(.drawablyEase(duration: 0.24), value: configuration.isOn)
        }

        private var layers: [SketchLayer] {
            [
                SketchLayer(.outline) { size, o in
                    DrawablyGeometry.checkboxOutline(size.width, size.height, o)
                },
                // the tick is drawn on rather than faded in, the way upstream
                // animates stroke-dashoffset
                SketchLayer(.check, trim: configuration.isOn ? 1 : 0) { size, o in
                    DrawablyGeometry.checkboxCheck(size.width, size.height, o)
                },
                SketchLayer(.focus, isVisible: isFocused) { size, o in
                    DrawablyGeometry.checkboxFocus(size.width, size.height, o)
                }
            ]
        }
    }
}
