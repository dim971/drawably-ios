import SwiftUI

/// How a button's box is filled in.
public enum DrawablyButtonVariant: Sendable, Hashable {
    /// Just the sketched border.
    case outline
    /// A solid ink blob behind the label.
    case solid
    /// Hatched fill.
    case scribble
}

/// The ink a control is drawn in, independent of what it is doing.
public enum DrawablyTone: Sendable, Hashable {
    /// The theme's own ink.
    case standard
    /// Warm grey, for secondary actions.
    case neutral
    /// The theme's error red, for destructive actions.
    case danger
}

/// What a button is currently doing, which recolours its ink and — for
/// `loading` — makes the sketch boil faster.
public enum DrawablyButtonState: Sendable, Hashable {
    case idle
    case loading
    case error
    case success
}

/// A button drawn as a pen sketch: a fresh one on appearance, and another every
/// time it is pressed.
///
/// ```swift
/// DrawablyButton("Done", variant: .solid) { submit() }
/// ```
public struct DrawablyButton<Label: View>: View {
    private let variant: DrawablyButtonVariant
    private let tone: DrawablyTone
    private let state: DrawablyButtonState
    private let seed: UInt32?
    private let action: () -> Void
    private let label: Label

    @FocusState private var isFocused: Bool

    public init(
        variant: DrawablyButtonVariant = .outline,
        tone: DrawablyTone = .standard,
        state: DrawablyButtonState = .idle,
        seed: UInt32? = nil,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.variant = variant
        self.tone = tone
        self.state = state
        self.seed = seed
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button(action: action) { label }
            .buttonStyle(
                DrawablyButtonStyle(
                    variant: variant,
                    tone: tone,
                    state: state,
                    seed: seed,
                    isFocused: isFocused
                )
            )
            .focused($isFocused)
            .disabled(state == .loading)
    }
}

public extension DrawablyButton where Label == Text {
    init(
        _ title: LocalizedStringKey,
        variant: DrawablyButtonVariant = .outline,
        tone: DrawablyTone = .standard,
        state: DrawablyButtonState = .idle,
        seed: UInt32? = nil,
        action: @escaping () -> Void
    ) {
        self.init(variant: variant, tone: tone, state: state, seed: seed, action: action) {
            Text(title)
        }
    }
}

/// Applies the Drawably sketch to any SwiftUI `Button`.
public struct DrawablyButtonStyle: ButtonStyle {
    var variant: DrawablyButtonVariant
    var tone: DrawablyTone
    var state: DrawablyButtonState
    var seed: UInt32?
    var isFocused: Bool

    public init(
        variant: DrawablyButtonVariant = .outline,
        tone: DrawablyTone = .standard,
        state: DrawablyButtonState = .idle,
        seed: UInt32? = nil,
        isFocused: Bool = false
    ) {
        self.variant = variant
        self.tone = tone
        self.state = state
        self.seed = seed
        self.isFocused = isFocused
    }

    public func makeBody(configuration: Configuration) -> some View {
        SketchedButton(configuration: configuration, style: self)
    }

    private struct SketchedButton: View {
        let configuration: Configuration
        let style: DrawablyButtonStyle

        @Environment(\.drawablyTheme) private var theme
        @Environment(\.isEnabled) private var isEnabled
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @State private var freshSeed = drawablyRandomSeed()
        @State private var isHovering = false

        private var seed: UInt32 {
            style.seed ?? freshSeed
        }

        private var toned: DrawablyTheme {
            var theme = theme
            switch style.tone {
            case .standard: break
            case .neutral:
                theme.stroke = .drawablyNeutral
                theme.fill = .drawablyNeutral
            case .danger:
                theme.stroke = theme.error
                theme.fill = theme.error
            }
            return theme
        }

        /// `--drawably-ink`: a state recolours the whole sketch without
        /// touching the theme's own ink.
        private var ink: Color? {
            switch style.state {
            case .error: theme.error
            case .success: theme.success
            case .idle, .loading: nil
            }
        }

        private var labelColor: Color {
            if let ink { return ink }
            return style.variant == .solid ? theme.paper : toned.stroke
        }

        private var layers: [SketchLayer] {
            var layers: [SketchLayer] = []
            if style.variant == .solid {
                layers.append(SketchLayer(.blob) { size, o in
                    DrawablyGeometry.buttonBlob(size.width, size.height, o)
                })
            }
            if style.variant == .scribble {
                layers.append(SketchLayer(.scribble) { size, o in
                    DrawablyGeometry.buttonScribble(size.width, size.height, o)
                })
            }
            layers.append(SketchLayer(.outline, fill: wash) { size, o in
                DrawablyGeometry.buttonOutline(size.width, size.height, o)
            })
            layers.append(SketchLayer(.focus, isVisible: style.isFocused) { size, o in
                DrawablyGeometry.buttonFocus(size.width, size.height, o)
            })
            return layers
        }

        private var wash: Color? {
            drawablyButtonWash(
                ink: labelColor,
                variant: style.variant,
                isEnabled: isEnabled,
                isPressed: configuration.isPressed,
                isHovering: isHovering
            )
        }

        var body: some View {
            configuration.label
                .foregroundStyle(labelColor)
                .padding(.vertical, 6)
                .padding(.horizontal, 14)
                .background(
                    SketchChrome(
                        configuration: ButtonSketchConfig(variant: style.variant),
                        layers: layers,
                        seed: seed,
                        // loading speeds the boil up from 1200ms to 450ms
                        boilPeriod: style.state == .loading ? 0.15 : 0.4,
                        ink: ink,
                        lineWidth: configuration.isPressed ? theme.width * 1.4 : theme.width
                    )
                    .drawablyTheme(toned)
                )
                .contentShape(.rect)
                .opacity(opacity)
                .offset(y: offsetY)
                .scaleEffect(configuration.isPressed ? 0.98 : 1)
                .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
                .onChange(of: configuration.isPressed) { _, pressed in
                    if pressed { resketch() }
                }
                .onHover { hovering in
                    isHovering = hovering
                    if hovering { resketch() }
                }
        }

        private var opacity: Double {
            if !isEnabled, style.state != .loading { return 0.45 }
            return style.state == .loading ? 0.6 : 1
        }

        private var offsetY: Double {
            if configuration.isPressed { return 1 }
            return isHovering && isEnabled && style.state != .loading ? -1 : 0
        }

        /// A press or a hover draws the button again from scratch — a new seed,
        /// not just new boil frames. Reduced motion opts out entirely.
        private func resketch() {
            guard style.seed == nil, !reduceMotion else { return }
            freshSeed = drawablyRandomSeed()
        }
    }
}

/// What distinguishes one button's layer set from another, so the sketch cache
/// knows when it has to regenerate rather than reuse.
///
/// Only the variant changes which shapes exist. Focus and the press wash change
/// how they are painted, which is a redraw, not a regeneration — keeping them
/// out of the key is what stops a button re-sketching itself every time a
/// finger touches it.
private struct ButtonSketchConfig: Hashable {
    let variant: DrawablyButtonVariant
}

/// How much ink a button washes its inside with.
enum DrawablyButtonWash {
    /// Upstream's hover wash.
    static let hover: Double = 0.1
    /// A press gets a stronger one — and gets it on touch devices, where hover
    /// never happens and the sink-and-thicken alone is easy to miss under a
    /// fingertip.
    static let pressed: Double = 0.18
}

/// The wash painted inside a button's outline, or `nil` for none.
///
/// A solid button is already filled, so there would be nothing to see; a
/// disabled one does not react at all.
func drawablyButtonWash(
    ink: Color,
    variant: DrawablyButtonVariant,
    isEnabled: Bool,
    isPressed: Bool,
    isHovering: Bool
) -> Color? {
    guard isEnabled, variant != .solid else { return nil }
    if isPressed { return ink.opacity(DrawablyButtonWash.pressed) }
    return isHovering ? ink.opacity(DrawablyButtonWash.hover) : nil
}
