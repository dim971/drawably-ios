# Getting started

## Install

Swift Package Manager, either in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/dim971/drawably-ios", from: "0.1.0"),
]
```

or in Xcode via **File ▸ Add Package Dependencies…**.

Requires iOS 17+ or macOS 14+ and Swift 6. There are no dependencies.

## Your first control

```swift
import Drawably
import SwiftUI

DrawablyButton("Done", variant: .solid) { submit() }
```

That is a real SwiftUI `Button` with a sketch drawn behind it. It picks a fresh
sketch when it appears, flickers gently while idle, and draws itself again when
you press it.

## Wearing the sketch on controls you already have

Three of the components are also styles, so existing code can put the sketch on
without changing shape:

```swift
Button("Done") { submit() }
    .buttonStyle(DrawablyButtonStyle(variant: .solid))

Toggle("Ship it", isOn: $agreed)
    .toggleStyle(DrawablyCheckboxStyle())

Toggle("Boil", isOn: $boiling)
    .toggleStyle(DrawablyToggleStyle())
```

## Setting the pen

The theme cascades through the environment, so set it once high up:

```swift
ContentView()
    .drawablyTheme { theme in
        theme.stroke = .black
        theme.fill = .black
        theme.roughness = 1.4
    }
```

See [theming.md](theming.md) for every property and what it does.

## Pinning a sketch

Every control takes an optional `seed`. Without one it picks a fresh sketch each
time it appears, which is the point — but previews and snapshot tests want the
same drawing every run:

```swift
DrawablyButton("Done", seed: 42) {}
```

A pinned seed also stops the control re-sketching under a press.

## Annotating

The decorations go on anything, and on `Text` they follow every line the run
wraps onto:

```swift
Text("a fresh pen sketch").drawablyUnderline()
Text("real inputs").drawablyHighlight()
Text("zero dependencies").drawablyCircle()
```

Arrows join two named anchors inside a layer:

```swift
DrawablyArrowLayer(arrows: [DrawablyArrow(from: "hint", to: "send")]) {
    HStack {
        Text("start here").drawablyAnchor("hint")
        Spacer()
        DrawablyButton("Send", variant: .solid) {}.drawablyAnchor("send")
    }
}
```

## Making a screen look hand-placed

```swift
DrawablyButton("Done", variant: .solid) {}
    .drawablyTilt()                 // a small angle, picked once and held
DrawablyCard { … }
    .drawablyTilt(degrees: -1.5)    // or an exact one
```

## Where to go next

- [components.md](components.md) — the full reference
- [theming.md](theming.md) — the theme, seeds, and drawing your own shapes
- [architecture.md](architecture.md) — how a sketch reaches the screen
