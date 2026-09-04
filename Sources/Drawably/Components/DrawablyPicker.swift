import SwiftUI

/// A select drawn as a sketched box with a pen chevron, opening a sketched
/// list rather than the system menu — the options carry a hand-drawn frame,
/// tail and tick, the way upstream draws them into a customisable `<select>`.
///
/// The list is anchored below the field rather than presented as a popover, so
/// nothing but the sketch is drawn: a system popover would wrap it in a white
/// bubble with a shadow and its own tail, and would decide for itself whether
/// to sit above or below — which the drawn tail cannot follow.
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
    @State private var fieldHeight: Double = 0

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
            isOpen.toggle()
        } label: {
            label
        }
        .buttonStyle(PressReportingButtonStyle { _ in })
        .focused($isFocused)
        .accessibilityValue(Text(title(selection)))
        .background {
            GeometryReader { proxy in
                Color.clear
                    .onAppear { fieldHeight = proxy.size.height }
                    .onChange(of: proxy.size.height, initial: true) { _, height in
                        fieldHeight = height
                    }
            }
        }
        // A scrim behind the list, so a tap anywhere else closes it. Without a
        // popover there is nothing else catching those taps; it is clipped to
        // whatever scrolls the picker, which is the visible area anyway.
        .overlay {
            if isOpen {
                Color.clear
                    .frame(width: 4000, height: 4000)
                    .contentShape(.rect)
                    .onTapGesture { isOpen = false }
            }
        }
        .overlay(alignment: .top) {
            if isOpen {
                DrawablyPickerList(
                    options: options,
                    selection: $selection,
                    title: title,
                    seed: pickerSeed
                ) { isOpen = false }
                    .fixedSize()
                    .offset(y: fieldHeight + 2)
                    .transition(.opacity)
            }
        }
        .zIndex(isOpen ? 1 : 0)
        .animation(.drawablyEase(), value: isOpen)
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

/// The list itself: a sketched frame round the options with a tail pointing
/// back at the field, and a pen tick beside the chosen one.
private struct DrawablyPickerList<Value: Hashable>: View {
    let options: [Value]
    @Binding var selection: Value
    let title: (Value) -> String
    let seed: UInt32
    let close: () -> Void

    @Environment(\.drawablyTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(options.enumerated()), id: \.element) { index, option in
                Button {
                    selection = option
                    close()
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
        // room at the top for the tail, which is drawn inside the box so
        // nothing has to render outside its own bounds
        .padding(.top, DrawablyGeometry.popupTailHeight)
        .drawablySketch("picker", layers: [
            SketchLayer(.outline) { size, o in
                DrawablyGeometry.popupFrame(size.width, size.height, o)
            },
            SketchLayer(.outline) { size, o in
                DrawablyGeometry.popupTail(size.width, size.height, o)
            }
        ], seed: seed)
        // paper goes behind the sketch, so the frame and its tail stay visible
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
