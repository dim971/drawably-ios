import SwiftUI

/// How many of a track's steps are drawn as done.
///
/// Free, and pure, so the rounding is tested without a view: a fraction that
/// lands a hair under a step boundary, as `3.0 / 7.0 * 7.0` does, still fills
/// three boxes rather than two.
func drawablyProgressStepsDone(fractionCompleted: Double?, steps: Int) -> Int {
    guard steps > 0, let fraction = fractionCompleted, fraction.isFinite else { return 0 }
    let done = (fraction.clamped(to: 0 ... 1) * Double(steps)).rounded()
    return Int(done)
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

/// A row of pen boxes, hatched one by one as the steps are completed.
///
/// ```swift
/// DrawablyProgress(step: 3, of: 7)
/// ```
///
/// It wraps a real `ProgressView`, so the platform reads it out as progress.
/// Unlike the rest of the library this control has no upstream counterpart;
/// see `docs/components.md`.
public struct DrawablyProgress: View {
    private let step: Int
    private let total: Int
    private let seed: UInt32?

    /// A track of `total` boxes with the first `step` of them hatched.
    ///
    /// Both are clamped: a step past the end fills the track, a negative one
    /// empties it, and a total below one draws a single box.
    public init(step: Int, of total: Int, seed: UInt32? = nil) {
        self.total = max(1, total)
        self.step = min(max(0, step), self.total)
        self.seed = seed
    }

    public var body: some View {
        ProgressView(value: Double(step), total: Double(total))
            .progressViewStyle(DrawablyProgressViewStyle(steps: total, seed: seed))
    }
}

/// Draws any SwiftUI `ProgressView` as a row of pen boxes.
///
/// An indeterminate `ProgressView`, one built without a value, has nothing to
/// fill, so it draws an empty track. This control is for progress that is
/// counted.
public struct DrawablyProgressViewStyle: ProgressViewStyle {
    /// How many boxes a track has when the call site does not say.
    public static let defaultSteps = 10

    var steps: Int
    var seed: UInt32?

    public init(steps: Int = defaultSteps, seed: UInt32? = nil) {
        self.steps = max(1, steps)
        self.seed = seed
    }

    public func makeBody(configuration: Configuration) -> some View {
        SketchedProgress(configuration: configuration, steps: steps, pinnedSeed: seed)
    }

    private struct SketchedProgress: View {
        let configuration: Configuration
        let steps: Int
        let pinnedSeed: UInt32?

        @Environment(\.drawablyTheme) private var theme
        @State private var freshSeed = drawablyRandomSeed()

        private var stepsDone: Int {
            drawablyProgressStepsDone(
                fractionCompleted: configuration.fractionCompleted, steps: steps
            )
        }

        var body: some View {
            HStack(spacing: DrawablyGeometry.progressSegmentGap) {
                // Each box runs off its own seed. Sharing one would draw the
                // same rectangle seven times, which reads as a printed rule
                // rather than as a hand.
                ForEach(0 ..< steps, id: \.self) { index in
                    segment(isDone: index < stepsDone, offset: UInt32(index))
                }
            }
            .foregroundStyle(theme.stroke)
            .accessibilityElement(children: .ignore)
            .accessibilityValue(
                Text((configuration.fractionCompleted ?? 0)
                    .formatted(.percent.precision(.fractionLength(0))))
            )
        }

        private func segment(isDone: Bool, offset: UInt32) -> some View {
            Color.clear
                .frame(
                    width: DrawablyGeometry.progressSegmentWidth,
                    height: DrawablyGeometry.progressSegmentHeight
                )
                .drawablySketch(
                    "progress",
                    layers: [
                        SketchLayer(.outline) { size, o in
                            DrawablyGeometry.progressSegment(size.width, size.height, o)
                        },
                        SketchLayer(.scribble, isVisible: isDone) { size, o in
                            DrawablyGeometry.progressScribble(size.width, size.height, o)
                        }
                    ],
                    seed: (pinnedSeed ?? freshSeed) &+ offset
                )
                .animation(.drawablyEase(duration: 0.24), value: isDone)
        }
    }
}
