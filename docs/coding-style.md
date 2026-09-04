# Coding style

The baseline is the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
Read those first; this document only records how they apply here, and the few
places this project deliberately does something else.

Formatting is not discussed below because it is not negotiated: `.swiftformat`
and `.swiftlint.yml` decide it, and `make lint` is the arbiter.

## Naming

### Clarity at the point of use

The guideline that does the most work here. A control is read far more often
than it is written, so the call site is what the name is designed for:

```swift
DrawablyButton("Done", variant: .solid, tone: .danger) { submit() }
Text("a fresh pen sketch").drawablyUnderline()
DrawablyGeometry.outlineReach(width: theme.width, roughness: theme.roughness)
```

`outlineReach(width:roughness:)` reads as a phrase and says what it returns.
`outlineOffset(_:_:)` would have saved characters and cost the reader the two
things they need to know.

### Omit needless words, name by role

`SketchLayer`, not `SketchLayerObject`. `role`, not `roleEnum`. The parameter in
`variants(_:_:count:)` is `count`, not `numberOfVariants` — the type already
says it is a number.

### Boolean properties assert something about the receiver

`isVisible`, `isFilled`, `usesFillColor`, `isInteractive`. Never `visible` or
`shouldFill`.

### Side effects decide the part of speech

`resketch()` mutates, so it is imperative. `angle(seed:maxDegrees:)` returns a
value and does nothing else, so it is a noun phrase. If you find yourself
writing `getAngle()`, the answer is a property.

### Prefixing

Everything public is prefixed `Drawably` — `DrawablyButton`, `DrawablyTheme`,
`DrawablyGeometry` — because this library is designed to sit alongside whatever
design system an app already uses, and `Button` would collide. Modifiers follow:
`drawablyTilt()`, `drawablyUnderline()`, `drawablyTheme(_:)`.

`Rough`, `SketchPath`, `Subpath` and `Pt` are the exception. They are the engine's
own vocabulary, they mirror upstream's names, and prefixing them would make the
transcription harder to check against the original.

## Argument labels

Follow the guidelines, with one deliberate exception.

**The exception: the engine is a transcription.** `Core` and
`Sketch/LayerGeometry.swift` keep upstream's positional signatures:

```swift
Rough.roundedRect(3, 3, 114, 30, 8, options)   // x, y, w, h, radius
DrawablyGeometry.checkboxCheck(w, h, options)
```

The guidelines would want `roundedRect(x:y:width:height:cornerRadius:)`. We do
not, because these functions exist to be read side by side with `rough.ts` and
`controls.ts` when a golden fails. Legibility against the original beats
legibility in isolation, and the surface is small and rarely called directly.

Everywhere above that layer, the guidelines apply normally.

**Defaulted parameters go last**, and there are a lot of them: `seed` is always
optional and always last but for the trailing closure.

## Documentation

Every public declaration carries a doc comment. Not a restatement of the name —
if the comment would only repeat the signature, the comment is not the problem,
the name is.

Say what the reader cannot infer:

```swift
/// The seed a control is drawn from.
///
/// A pinned seed never changes, which is what previews and tests want; an
/// unpinned one is rolled again whenever the control is touched.
```

## Comments explain why, not what

The single rule this codebase cares most about, because a lot of its constants
came from somewhere non-obvious and would otherwise look arbitrary:

```swift
// At chevron scale, full roughness turns the V into noise.
public static let chevronRoughness: Double = 0.4
```

```swift
// The shared vertex is deliberately duplicated: midpoint smoothing would
// otherwise round the corner off.
```

If a number looks arbitrary, say where it came from. If a line exists to work
around something, say what.

## Rules particular to this project

**The engine is a transcription, not an interpretation.** Anything under
`Sources/Drawably/Core` mirrors upstream's structure and operation order,
including things that would otherwise be refactored away. The golden fixtures
enforce this — see [fidelity.md](fidelity.md).

**Generate geometry once.** Shapes are built per box size, seed and options and
cached. Nothing is generated inside a draw pass, and presentation state — trim,
offset, scale, visibility, fill — is never part of a cache key.

**The sketch carries no semantics.** Every control wraps a real SwiftUI control.
If a change makes the sketch itself interactive, it is the wrong change.

**No warnings**, on the release Xcode and the current beta.

**Public API is `Sendable` where it can be**, and the package builds under the
Swift 6 language mode with strict concurrency. Reach for `@MainActor` before
`nonisolated(unsafe)`, and if you use the latter, say why in a comment.

## What is enforced mechanically

| Rule | By |
| --- | --- |
| Formatting, one-line `if` bodies, import order | `swiftformat` (`.swiftformat`) |
| Line length, nesting, cyclomatic complexity, type and identifier names | `swiftlint` (`.swiftlint.yml`) |
| Doc comments on public declarations | `swiftlint` (`missing_docs`) |
| Byte-identical engine output | `swift test` |
| Zero warnings | CI |

Everything else in this document is a review conversation.
