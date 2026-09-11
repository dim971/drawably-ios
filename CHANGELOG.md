# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2026-09-11

### Changed

- A button is drawn at least 44 points tall. Upstream is a web library, and its
  six pixels of vertical padding give a box about 29 points high: comfortable
  with a mouse, too flat for a finger, and under both Apple's 44 and Material's
  48. The drawn box grows rather than the hit area alone, because a control that
  is hard to see is hard to aim at. The new theme property
  `minimumControlHeight` carries it, and `0` restores the original proportions.
  This changes how every button looks, which is why it is a minor version rather
  than a patch.

## [0.2.2] - 2026-09-11

### Fixed

- A control that swaps one variant for another no longer crashes. Paths are
  generated after an update rather than during it, so a layer set that grew in
  this pass was drawn against the previous pass's paths and indexed past their
  end. A badge going from outline to scribble under a finger was enough. The
  layer count is part of the cache key now, so the paths are regenerated when it
  changes, and a layer that has none yet waits for the next pass instead of
  trapping.

## [0.2.1] - 2026-09-11

### Fixed

- `DrawablyProgress` no longer overflows its row. Each box was a fixed 34 points
  wide, so a track of twelve steps measured wider than a phone and pushed
  whatever sat beside it off the screen. The width is now a cap: boxes share the
  row and shrink when there are more of them than fit. A track with room to
  spare is unchanged.

## [0.2.0] - 2026-09-10

### Added

- `DrawablyProgress`: a row of pen boxes, hatched one by one as steps complete.
  This is the first control here with no upstream counterpart, so it carries no
  golden fixture; the rest of the library remains a byte-identical
  transcription. It is built from the public engine and the existing layer
  conventions, and it carries the platform's own progress semantics.
  `DrawablyProgressViewStyle` puts the same drawing on any counted `ProgressView`.

## [0.1.0] - 2026-09-08

First release. A SwiftUI port of [Drawably](https://www.drawably.dev) 0.3.10.

### Added

- The stroke engine, ported from upstream's `prng.ts` and `rough.ts` and pinned
  to byte-identical output by fixtures generated from the published npm package.
- All fifteen upstream controls: button, card, checkbox, radio, toggle, text
  field, text editor, picker, divider, badge, list, underline, highlight,
  circle, arrow.
- `DrawablyTheme`, carrying upstream's CSS custom properties through the
  environment.
- Boiling on a `TimelineView`, honouring `accessibilityReduceMotion`.
- `DrawablyButtonStyle`, `DrawablyCheckboxStyle` and `DrawablyToggleStyle`, so
  existing `Button`s and `Toggle`s can wear the sketch.
- A showcase catalog app with live previews, per-component screens and pen
  controls.

### Changed from upstream

- A pressed button washes its inside with 18% ink. Upstream only does this on
  hover, at 10%, which never happens on a touch device.
- The picker's list carries a drawn tail instead of a platform popover's bubble,
  and is anchored below the field so the tail always points at something.
- A badge's padding is derived from the theme, so the label stays clear of the
  outline at any stroke width or roughness.
- `.drawablyTilt()` is new: on drawably.dev the scatter is the demo page's own
  CSS rather than part of the library.

[Unreleased]: https://github.com/dim971/drawably-ios/compare/0.2.0...HEAD
[0.2.0]: https://github.com/dim971/drawably-ios/releases/tag/0.2.0
[0.1.0]: https://github.com/dim971/drawably-ios/releases/tag/0.1.0
