@testable import Drawably
import Foundation
import Testing

/// Every test here compares this port's output against strings produced by the
/// JavaScript library itself. A failure means the port has drifted, not that a
/// tolerance needs widening.
@Suite("Engine matches upstream")
struct EngineGoldenTests {
    let goldens = Goldens.shared

    @Test("mulberry32 produces the same stream")
    func prngStream() {
        for testCase in goldens.prng {
            var rand = Mulberry32(seed: testCase.seed)
            let produced = (0 ..< testCase.values.count).map { _ in rand.next() }
            #expect(
                produced == testCase.values,
                "seed \(testCase.seed): expected \(testCase.values.prefix(3)), got \(produced.prefix(3))"
            )
        }
    }

    @Test("shape primitives match")
    func primitives() {
        var mismatches: [Mismatch] = []
        for testCase in goldens.shapes {
            let actual = generate(testCase.fn, testCase.args, testCase.opts.rough).svgString
            if actual != testCase.d {
                let label = "\(testCase.fn)(\(testCase.args)) seed \(testCase.opts.seed)"
                mismatches.append(
                    Mismatch(
                        label: "\(label) roughness \(testCase.opts.roughness)",
                        expected: testCase.d, actual: actual
                    )
                )
            }
        }
        #expect(mismatches.isEmpty, Comment(rawValue: report(mismatches)))
    }

    @Test("boil frames match")
    func boilVariants() {
        var mismatches: [Mismatch] = []
        for testCase in goldens.variants {
            let produced = Rough.variants(
                { generate(testCase.fn, testCase.args, $0) },
                testCase.opts.rough,
                count: testCase.n
            )
            #expect(produced.count == testCase.ds.count)
            for (i, path) in produced.enumerated() where path.svgString != testCase.ds[i] {
                let label = "\(testCase.fn) frame \(i) seed \(testCase.opts.seed)"
                mismatches.append(
                    Mismatch(
                        label: "\(label) boil \(testCase.opts.boil ?? 0)",
                        expected: testCase.ds[i], actual: path.svgString
                    )
                )
            }
        }
        #expect(mismatches.isEmpty, Comment(rawValue: report(mismatches)))
    }

    @Test("every control layer matches")
    func controlLayers() {
        var mismatches: [Mismatch] = []
        for testCase in goldens.controls {
            let produced = Rough.variants(
                { generateLayer(testCase.layer, testCase.w, testCase.h, $0) },
                testCase.opts.rough,
                count: testCase.ds.count
            )
            for (i, path) in produced.enumerated() where path.svgString != testCase.ds[i] {
                let label = "\(testCase.layer) \(testCase.w)×\(testCase.h) frame \(i)"
                mismatches.append(
                    Mismatch(
                        label: "\(label) roughness \(testCase.opts.roughness)",
                        expected: testCase.ds[i], actual: path.svgString
                    )
                )
            }
        }
        #expect(mismatches.isEmpty, Comment(rawValue: report(mismatches)))
    }

    @Test("arrow layer matches")
    func arrowLayer() {
        var mismatches: [Mismatch] = []
        for testCase in goldens.arrows {
            let a = testCase.args
            let produced = Rough.variants(
                { Rough.arrow(a[0], a[1], a[2], a[3], $0) },
                testCase.opts.rough,
                count: testCase.ds.count
            )
            for (i, path) in produced.enumerated() where path.svgString != testCase.ds[i] {
                let label = "arrow frame \(i) seed \(testCase.opts.seed)"
                mismatches.append(
                    Mismatch(
                        label: "\(label) roughness \(testCase.opts.roughness)",
                        expected: testCase.ds[i], actual: path.svgString
                    )
                )
            }
        }
        #expect(mismatches.isEmpty, Comment(rawValue: report(mismatches)))
    }

    @Test("the fixtures cover the whole surface")
    func fixtureCoverage() {
        #expect(goldens.upstream == "drawably@0.3.10")
        #expect(goldens.shapes.count > 200)
        #expect(Set(goldens.controls.map(\.layer)).count == 26)
    }
}
