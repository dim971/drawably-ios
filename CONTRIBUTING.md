# Contributing

Thanks for taking a look. Issues and pull requests are both welcome.

## Getting set up

```sh
git clone https://github.com/dim971/drawably-ios
cd drawably-ios
make test          # the engine goldens
make showcase      # build and run the catalog app in the simulator
```

You need Xcode 16+ and [XcodeGen](https://github.com/yonaskolb/XcodeGen)
(`brew install xcodegen`) — the showcase project is generated from
`Showcase/project.yml` rather than checked in.

## Before you open a pull request

```sh
make lint          # swiftformat --lint and swiftlint
make test
```

Three things the review will look for:

**No warnings.** Not in the package, not in the showcase, on the release
toolchain *and* the current Xcode beta. A warning that is tolerated becomes a
warning that is ignored.

**The goldens still pass.** If you touch anything under `Sources/Drawably/Core`
or `Sources/Drawably/Sketch/LayerGeometry.swift`, the fixtures are the contract —
see [docs/fidelity.md](docs/fidelity.md). Changing them means changing what this
library claims to be, so say why in the pull request.

**Parity with Android.** This library has a
[twin](https://github.com/dim971/drawably-android). A change to shared
behaviour — geometry, theming, a control's states — should land in both, or say
plainly why it should not.

## Conventions

- Comments explain *why*, not *what*. If a constant looks arbitrary, say where
  it came from.
- Public API carries doc comments.
- Commit messages describe the change and the reasoning, in prose.

## Reporting a bug

A seed makes a sketch reproducible. If the report is about how something is
drawn, pass a pinned `seed:` and include it — it turns "it looks wrong
sometimes" into something anyone can reproduce.

## Code of conduct

Taking part means following the [Code of Conduct](CODE_OF_CONDUCT.md).
