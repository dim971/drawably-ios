# Theming

## The theme

`DrawablyTheme` mirrors upstream's CSS custom properties one for one, defaults
included, and travels down the view tree the way they cascade.

| Property | Type | Default | What it does |
| --- | --- | --- | --- |
| `stroke` | `Color` | `#2724d1` | Line colour for outlines, ticks, chevrons, markers |
| `fill` | `Color` | `#2724d1` | Filled layers: a solid button's blob, a radio's dot, a toggle's knob, a highlight's wash |
| `paper` | `Color` | `.white` | What the ink sits on; a solid button's label is drawn in it, and a picker's list uses it as its background |
| `width` | `Double` | `2` | Stroke width for ordinary layers. Blobs and knobs are always 4, scribbles and focus rings 1.5, a highlight's wash 6 |
| `error` | `Color` | `#d12724` | The `danger` tone and the `error` state |
| `success` | `Color` | `#188a42` | The `success` state |
| `roughness` | `Double` | `1` | Multiplies the jitter amplitude of the base sketch |
| `boil` | `Double` | `0.3` | Per-frame flicker amplitude. `0` renders one still frame |

## Applying it

Replace the whole theme:

```swift
ContentView()
    .drawablyTheme(DrawablyTheme(stroke: .black, fill: .black, roughness: 1.6))
```

or adjust the inherited one, which is usually what you want:

```swift
ContentView()
    .drawablyTheme { theme in
        theme.width = 3
        theme.boil = 0
    }
```

Because it is an environment value, a subtree can differ from its parent:

```swift
VStack {
    DrawablyButton("Normal") {}
    DrawablyButton("Heavier") {}
        .drawablyTheme { $0.width = 4 }
}
```

## Colours

The four named colours are available directly:

```swift
Color.drawablyPenBlue   // #2724d1, upstream's ink
Color.drawablyError     // #d12724
Color.drawablySuccess   // #188a42
Color.drawablyNeutral   // #6e675f, the warm grey of the neutral tone
```

## Seeds

A control without a `seed` picks a fresh one when it appears, and rolls another
whenever it is pressed or hovered. That is the library's whole idea: the sketch
is redrawn, not reused.

Pass a `seed` to pin it — the same seed always produces the same drawing, on
this platform and on Android:

```swift
DrawablyButton("Done", seed: 42) {}
```

A pinned control also stops re-sketching on press, which is what previews,
snapshot tests and screenshots want.

## Turning the movement off

Setting `boil` to `0` renders one still frame instead of three, and skips the
ticker entirely. `accessibilityReduceMotion` does the same, and additionally
stops the press and hover re-sketch — matching what upstream does under
`prefers-reduced-motion`.

## Drawing your own shapes

The engine is public. Anything the components draw, you can draw:

```swift
let options = RoughOptions(seed: 42, roughness: 1, boil: 0)
let path = Rough.roundedRect(3, 3, 114, 30, 8, options).path()
```

Available: `Rough.line`, `roundedRect`, `circle`, `ellipse`, `arrow`,
`checkmark`, `scribbleFill`, and `Rough.variants(_:_:count:)` to get the boil
frames of any of them. `SketchPath.path()` turns the result into a SwiftUI
`Path`.

`DrawablyGeometry` holds the per-control geometry — `buttonOutline`,
`checkboxCheck`, `toggleKnob` and the rest — if you want a shape that matches an
existing control exactly. `DrawablyGeometry.outlineReach(width:roughness:)`
tells you how far inside its box a sketched outline can reach, which is what to
allow if you are putting your own content inside one.
