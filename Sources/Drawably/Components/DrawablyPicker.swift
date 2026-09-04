import SwiftUI

/// A select drawn as a sketched box with a pen chevron, opening a sketched
/// popover rather than the system menu — the option list carries a hand-drawn
/// frame and tick, the way upstream draws them into a customisable `<select>`.
///
/// ```swift
/// DrawablyPicker(selection: $tool, options: ["Pen", "Pencil"]) { $0 }
/// ```
public struct DrawablyPicker<Value: Hashable>: View {
    private let options: [Value]
    private let title: (Value) -> String
    private let seed: UInt32?
    @Binding private var selection: Value

    @Environment(\.drawablyTheme) private var theme
    @FocusState private var isFocused: Bool
    @State private var freshSeed = drawablyRandomSeed()
    @State private var isOpen = false

    public init(
        selection: Binding<Value>,
        options: [Value],
        seed: UInt32? = nil,
        title: @escaping (Value) -> String
    ) {
        _selection = selection
        self.options = options
        self.seed = seed
        self.title = title
    }

    public var body: some View {
        Button {
            isOpen = true
        } label: {
            label
        }
        .buttonStyle(PressReportingButtonStyle { _ in })
        .focused($isFocused)
        .accessibilityValue(Text(title(selection)))
        .popover(isPresented: $isOpen) {
            DrawablyPickerList(options: options, selection: $selection, title: title, seed: pickerSeed)
                .presentationCompactAdaptation(.popover)
        }
    }

    private var label: some View {
        HStack(spacing: 0) {
            // Every option is laid out invisibly so the box is already as wide
            // as the widest one — picking never shifts the layout around it.
            ZStack(alignment: .leading) {
                ForEach(options, id: \.self) { option in
                    Text(title(option)).opacity(0)
                }
                Text(title(selection))
            }
            .foregroundStyle(theme.stroke)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .padding(.leading, 12)
        // the gutter the sketched chevron is drawn into
        .padding(.trailing, 34)
        .drawablySketch(
            FieldSketchConfig(focused: isFocused),
            layers: DrawablyGeometry.fieldLayers(
                isFocused: isFocused,
                extra: [
                    SketchLayer(.chevron) { size, o in
                        DrawablyGeometry.selectChevron(size.width, size.height, o)
                    }
                ]
            ),
            seed: seed ?? freshSeed
        )
    }

    private var pickerSeed: UInt32 {
        seed ?? freshSeed
    }
}

/// The popover: a sketched frame round the options, and a pen tick beside the
/// chosen one.
private struct DrawablyPickerList<Value: Hashable>: View {
    let options: [Value]
    @Binding var selection: Value
    let title: (Value) -> String
    let seed: UInt32

    @Environment(\.drawablyTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(options.enumerated()), id: \.element) { index, option in
                Button {
                    selection = option
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        tick(for: option, index: index)
                        Text(title(option))
                            .foregroundStyle(theme.stroke)
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .drawablySketch("picker", layers: [
            SketchLayer(.outline) { size, o in
                DrawablyGeometry.fieldOutline(size.width, size.height, o)
            }
        ], seed: seed)
        .padding(8)
        .background(theme.paper)
    }

    private func tick(for option: Value, index: Int) -> some View {
        Color.clear
            .frame(width: DrawablyGeometry.checkBox, height: DrawablyGeometry.checkBox)
            .drawablySketch(
                "picker.check",
                layers: [
                    SketchLayer(.check, isVisible: option == selection) { size, o in
                        DrawablyGeometry.selectCheckMask(size.width, size.height, o)
                    }
                ],
                // each row gets its own sketch, the way upstream seeds list items
                seed: seed &+ UInt32(truncatingIfNeeded: index)
            )
    }
}
