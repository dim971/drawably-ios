@testable import Drawably
import Testing

/// How many boxes a track hatches is a pure function of the fraction and the
/// step count, so it is checked here rather than through a rendered view.
@Suite("Progress")
struct ProgressTests {
    private func done(_ fraction: Double?, of steps: Int) -> Int {
        drawablyProgressStepsDone(fractionCompleted: fraction, steps: steps)
    }

    @Test("the ends are exact")
    func ends() {
        #expect(done(0, of: 7) == 0)
        #expect(done(1, of: 7) == 7)
    }

    @Test("a step boundary that floating point lands just under still fills")
    func boundary() {
        // 3.0 / 7.0 * 7.0 is 2.9999999999999996, so truncation would show two
        // boxes for a learner standing on step three.
        for total in 1 ... 20 {
            for step in 0 ... total {
                #expect(done(Double(step) / Double(total), of: total) == step)
            }
        }
    }

    @Test("an indeterminate progress view has nothing to fill")
    func indeterminate() {
        #expect(done(nil, of: 7) == 0)
    }

    @Test("a fraction outside zero to one is clamped rather than overflowing")
    func clamped() {
        #expect(done(1.4, of: 7) == 7)
        #expect(done(-0.2, of: 7) == 0)
    }

    @Test("a fraction that is not a finite number carries no information")
    func notFinite() {
        // NaN and the infinities are all treated the same way: they say
        // nothing about how far along the work is, so the track stays empty
        // rather than guessing at one end of it.
        #expect(done(.nan, of: 7) == 0)
        #expect(done(.infinity, of: 7) == 0)
        #expect(done(-.infinity, of: 7) == 0)
    }

    @Test("a track with no steps has nothing to fill")
    func noSteps() {
        #expect(done(0.5, of: 0) == 0)
    }

    @Test("the control clamps its own step and total")
    @MainActor
    func controlClamps() {
        // A total below one would divide by zero in the ProgressView beneath.
        _ = DrawablyProgress(step: 3, of: 0)
        _ = DrawablyProgress(step: -1, of: 7)
        _ = DrawablyProgress(step: 99, of: 7)
        #expect(DrawablyProgressViewStyle(steps: 0).steps == 1)
    }
}
