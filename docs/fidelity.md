# Fidelity

This is a port, not a re-interpretation. The claim is specific: **the ported
engine emits byte-identical path data to the JavaScript original**, and it is
tested rather than asserted.

## How it is checked

`Tools/gen-icon.mjs`'s sibling, `Tools/gen-goldens.mjs`, drives the published
npm package (`drawably@0.3.10`) and records its SVG output:

- the first 20 values of `mulberry32` for six seeds, including `0xffffffff`
- every shape primitive across a matrix of seeds, roughness and argument sets
- the boil frames `variants()` produces
- all 26 per-control layers at representative sizes
- the arrow layer, whose two wings share a second PRNG stream

The result is committed as `Tests/DrawablyTests/Fixtures/goldens.json`. The test
suite rebuilds every case through the Swift engine, serialises it with a debug
`svgString()` that matches upstream's formatting exactly, and compares strings.

```sh
swift test
```

A failure means the port has drifted. It never means a tolerance needs
widening — there is no tolerance.

## Regenerating

```sh
cd Tools
npm i drawably@0.3.10
node gen-goldens.mjs > ../Tests/DrawablyTests/Fixtures/goldens.json
```

Do this when tracking a new upstream version, and expect to explain any diff.

## What it took

One reconciliation was needed, in `Core/SVGPath.swift`.

**`Number.prototype.toFixed(2)` is not `%.2f`.** JavaScript rounds exact halves
away from zero; C rounds them to even. `0.125` is `0.13` upstream and would be
`0.12` here. Values like that are common in this geometry — any coordinate that
is a multiple of an eighth lands on one. `jsToFixed2` reproduces the JavaScript
rule, with an explicit branch for the tie.

## The one thing worth watching

The engine calls `cos`, `sin`, `atan2` and `hypot` from the platform's libm, and
sample counts come from `ceil(length / step)`. A last-ulp difference is
invisible in a rounded coordinate but can move a shape across a sampling
boundary — an arrow head is exactly 12 long and sampled every 4, so one extra
point would shift every later PRNG draw and change the rest of the shape.

Darwin agrees with V8 on every case in the fixtures. The Kotlin port had to
route these through fdlibm explicitly, because `java.lang.Math` did not agree.
If a golden ever fails after an OS update, that is the first place to look.

## Cross-platform

[drawably-android](https://github.com/dim971/drawably-android) replays the same
`goldens.json`. Both ports being pinned to the same strings is what makes a
given seed produce the same drawing on iOS, on Android and on the web.
