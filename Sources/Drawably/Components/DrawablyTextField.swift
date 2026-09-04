import SwiftUI

/// A single-line text field in a sketched box.
///
/// ```swift
/// DrawablyTextField("Your name", text: $name)
/// ```
public struct DrawablyTextField: View {
    private let prompt: LocalizedStringKey
    private let seed: UInt32?
    @Binding private var text: String

    @Environment(\.drawablyTheme) private var theme
    @FocusState private var isFocused: Bool
    @State private var freshSeed = drawablyRandomSeed()

    public init(_ prompt: LocalizedStringKey = "", text: Binding<String>, seed: UInt32? = nil) {
        self.prompt = prompt
        _text = text
        self.seed = seed
    }

    public var body: some View {
        TextField(prompt, text: $text)
            .textFieldStyle(.plain)
            .foregroundStyle(theme.stroke)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .focused($isFocused)
            .drawablySketch(
                FieldSketchConfig(focused: isFocused),
                layers: DrawablyGeometry.fieldLayers(isFocused: isFocused),
                seed: seed ?? freshSeed
            )
    }
}

/// A multi-line text area in a sketched box.
public struct DrawablyTextEditor: View {
    private let minHeight: Double
    private let seed: UInt32?
    @Binding private var text: String

    @Environment(\.drawablyTheme) private var theme
    @FocusState private var isFocused: Bool
    @State private var freshSeed = drawablyRandomSeed()

    public init(text: Binding<String>, minHeight: Double = 96, seed: UInt32? = nil) {
        _text = text
        self.minHeight = minHeight
        self.seed = seed
    }

    public var body: some View {
        TextEditor(text: $text)
            .scrollContentBackground(.hidden)
            .foregroundStyle(theme.stroke)
            .frame(minHeight: minHeight)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .focused($isFocused)
            .drawablySketch(
                FieldSketchConfig(focused: isFocused),
                layers: DrawablyGeometry.fieldLayers(isFocused: isFocused),
                seed: seed ?? freshSeed
            )
    }
}

/// What distinguishes one field's layer set from another.
struct FieldSketchConfig: Hashable {
    let focused: Bool
}

extension DrawablyGeometry {
    /// The box every text-entry control shares: an outline and a focus ring.
    /// Upstream never re-sketches these on hover, so nor do we.
    static func fieldLayers(isFocused: Bool, extra: [SketchLayer] = []) -> [SketchLayer] {
        var layers: [SketchLayer] = [
            SketchLayer(.outline) { size, o in
                DrawablyGeometry.fieldOutline(size.width, size.height, o)
            }
        ]
        layers.append(contentsOf: extra)
        layers.append(
            SketchLayer(.focus, isVisible: isFocused) { size, o in
                DrawablyGeometry.fieldFocus(size.width, size.height, o)
            }
        )
        return layers
    }
}
