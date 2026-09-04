@testable import Drawably
import Testing

/// The lean is a pure function of its seed, so it is checked here rather than
/// by measuring pixels on a simulator.
@Suite("Tilt")
struct TiltTests {
    @Test("a seed always gives the same lean")
    func deterministic() {
        #expect(DrawablyTilt.angle(seed: 42) == DrawablyTilt.angle(seed: 42))
        #expect(DrawablyTilt.angle(seed: 42) != DrawablyTilt.angle(seed: 43))
    }

    @Test("it leans both ways, and never further than asked")
    func bounded() {
        let angles = (0 ..< 500).map { DrawablyTilt.angle(seed: UInt32($0), maxDegrees: 2) }
        #expect(angles.allSatisfy { abs($0) <= 2 })
        #expect(angles.contains { $0 < -0.5 })
        #expect(angles.contains { $0 > 0.5 })
    }

    @Test("the default is a couple of degrees")
    func defaultLean() {
        #expect(DrawablyTilt.defaultMaxDegrees == 2)
    }
}
