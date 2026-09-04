@testable import Drawably
import Testing

/// `jsToFixed2` only exists so the golden strings can be compared verbatim, so
/// the cases that matter are the ones where it must *not* behave like `%.2f`.
@Suite("JavaScript number formatting")
struct FormattingTests {
    @Test("rounds exact halves away from zero, unlike %.2f")
    func exactHalves() {
        // %.2f would give 0.12 / 11.38 / 0.62 here — round-half-to-even
        #expect(jsToFixed2(0.125) == "0.13")
        #expect(jsToFixed2(0.375) == "0.38")
        #expect(jsToFixed2(0.625) == "0.63")
        #expect(jsToFixed2(11.375) == "11.38")
        #expect(jsToFixed2(-0.125) == "-0.13")
    }

    @Test("handles zero, tiny negatives and plain values")
    func edges() {
        #expect(jsToFixed2(0) == "0.00")
        #expect(jsToFixed2(-0.0) == "0.00")
        #expect(jsToFixed2(-0.001) == "-0.00")
        #expect(jsToFixed2(0.005) == "0.01")
        #expect(jsToFixed2(7.6923076923076925) == "7.69")
        #expect(jsToFixed2(-12.344) == "-12.34")
        #expect(jsToFixed2(100) == "100.00")
    }
}
