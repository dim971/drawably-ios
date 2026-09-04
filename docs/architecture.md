# Architecture

How a sketch gets from the engine to the screen.

```
Core/          pure maths, no UI types
  Mulberry32      the seeded PRNG, ported bit for bit
  Geometry        sampling, jitter, double stroke, boil frames
  Shapes          line, rounded rect, circle, ellipse, arrow, checkmark, scribble fill
  SVGPath         a debug serialiser, used only by the golden tests
Theme/         DrawablyTheme and its environment key
Sketch/        LayerGeometry, SketchRole, SketchChrome, tilt, seeds
Components/    the fifteen controls
```

## The engine

`Rough` is a direct port of upstream's `rough.ts`. Every shape is a list of
sampled points, jittered twice from one PRNG stream — the second pass 1.4× wider
than the first — and smoothed with a quadratic through the midpoint of each
segment. That double stroke is what reads as a pen going over a line.

Nothing in `Core` knows about SwiftUI. It produces `SketchPath`, a list of
strokes; `SketchPath.path()` turns that into a `Path`.

## Layers

A control is a stack of layers, each a shape plus a role. `SketchRole` says how
a layer is painted — which of the theme's two inks it takes, whether it is
filled, what stroke width overrides the theme, whether it blends. The cases map
one for one onto the path classes in upstream's stylesheet, so the two can be
read against each other.

`DrawablyGeometry` holds the shapes themselves: `buttonOutline`, `checkboxCheck`,
`toggleKnob`, `selectChevron` and the rest, ported from `controls.ts`. These are
public — a shape matching an existing control exactly is sometimes what you
want.

## SketchChrome

The renderer. It generates the boil frames **once** per box size, seed and
options, caches them in `@State`, and only picks which one to stroke on a 400ms
tick. Nothing is generated inside a draw pass.

Upstream animates by stepping a registered CSS custom property through 0, 1, 2
and deriving each path's opacity from it. There is no equivalent here, so a
`TimelineView` drives the index instead, and reduced motion collapses it to a
single still frame.

Layers carry their own presentation state — trim, offset, scale, visibility,
fill — so a tick being drawn on, a knob sliding or a focus ring appearing is a
redraw, not a regeneration. Only the *set* of shapes is part of the cache key.

## The controls

Each control is a thin composition over `SketchChrome` and a real SwiftUI
control. The sketch is a background with no semantics; the `Button`, `Toggle`,
`TextField` or `Menu` underneath keeps VoiceOver, focus and keyboard working
exactly as they would without it. That mirrors upstream, where the SVG is
`aria-hidden` and the real `<input>` stays in the DOM.

Seeds live in `SketchSeed`, which rolls a new one on press or hover unless the
seed is pinned or the device asks for reduced motion — upstream does not even
attach its pointer listeners in that case.

## Where the port stops

The optional "Drawably Pen" TrueType font, the React wrappers, and the
Chromium-only customisable-`<select>` chrome are out of scope. The tilt is the
one thing here that upstream does not have: on drawably.dev the scatter is the
demo page's own CSS.
