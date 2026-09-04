import Foundation

/// The knobs the stroke engine takes, mirroring upstream's `RoughOptions`.
public struct RoughOptions: Sendable, Equatable {
    /// Base seed. The same seed always yields the same sketch.
    public var seed: UInt32
    /// Multiplies the jitter amplitude of the base sketch. Upstream default `1`.
    public var roughness: Double
    /// Amplitude, in points, of the per-frame flicker. `0` disables boiling.
    public var boil: Double
    /// Seed for the boil pass. `nil` means "no boil pass", which is what the
    /// raw shape generators see; `variants(_:_:count:)` is what fills it in.
    public var boilSeed: UInt32?

    public init(seed: UInt32, roughness: Double = 1, boil: Double = 0, boilSeed: UInt32? = nil) {
        self.seed = seed
        self.roughness = roughness
        self.boil = boil
        self.boilSeed = boilSeed
    }
}
