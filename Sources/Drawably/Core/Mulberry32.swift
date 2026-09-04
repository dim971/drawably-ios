import Foundation

/// The seeded PRNG every sketch is drawn from.
///
/// A direct port of upstream `src/prng.ts`. JavaScript's `Math.imul`, `>>>`
/// and `|` all operate on 32-bit patterns, so the `UInt32` arithmetic here
/// produces bit-identical results — which is what lets the golden fixtures
/// generated from the npm package pin this port down exactly.
public struct Mulberry32: Sendable {
    private var state: UInt32

    public init(seed: UInt32) {
        state = seed
    }

    /// The next value in `[0, 1)`.
    public mutating func next() -> Double {
        state = state &+ 0x6D2B_79F5
        var t = state
        t = (t ^ (t >> 15)) &* (t | 1)
        t ^= t &+ ((t ^ (t >> 7)) &* (t | 61))
        return Double(t ^ (t >> 14)) / 4_294_967_296
    }
}

/// A fresh random seed, as upstream's `randomSeed()` produces.
public func drawablyRandomSeed() -> UInt32 {
    UInt32.random(in: UInt32.min ... UInt32.max)
}
