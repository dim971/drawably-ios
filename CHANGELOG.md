# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0]

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

[Unreleased]: https://github.com/dim971/drawably-ios/compare/0.1.0...HEAD
[0.1.0]: https://github.com/dim971/drawably-ios/releases/tag/0.1.0
