# Monette

A lightweight, native macOS screenshot tool with beautiful output. Open-source alternative to CleanShot X / Xnapper.

Named after Claude Monet, Monette turns ordinary screen captures into something polished and share-ready.

![macOS](https://img.shields.io/badge/macOS-26%20(Tahoe)-blue)
![Swift](https://img.shields.io/badge/Swift-6.2-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## What It Does

Monette captures windows or screen regions, then opens a simple editor where you can style screenshots with:

- Gradient or solid color backgrounds (8 gradient presets, 16 solid color swatches)
- Adjustable corner radius, drop shadow, and padding
- Save as PNG or copy to clipboard
- Translucent sidebar with native macOS controls

The composited output is rendered via CoreGraphics at Retina resolution, independent of the preview.

## Current Status

**Phase 1 (Editor View) is complete.** You can style screenshots with backgrounds, shadows, rounded corners, and export them. The app currently uses a test image for development.

**Phase 2 (Window Capture)** is next: ScreenCaptureKit integration, window picker, and Screen Recording permission handling.

See the [Feature Roadmap in CLAUDE.md](CLAUDE.md#feature-roadmap-build-order) for the full plan.

## Build & Run

**Requirements:** macOS 26 (Tahoe), Xcode with Swift 6.2

```bash
# Clone
git clone https://github.com/erikdao/monette.git
cd monette

# Build
xcodebuild -project Monette.xcodeproj -scheme Monette -configuration Debug build

# Run
open ~/Library/Developer/Xcode/DerivedData/Monette-*/Build/Products/Debug/Monette.app
```

The app is unsigned. To bypass Gatekeeper on first run:
```bash
xattr -cr ~/Library/Developer/Xcode/DerivedData/Monette-*/Build/Products/Debug/Monette.app
```

Or right-click the app and select Open.

## Tech Stack

- **Swift 6.2** with strict concurrency
- **SwiftUI** for the editor UI
- **AppKit** for window configuration and clipboard
- **CoreGraphics** for pixel-perfect image compositing
- **ScreenCaptureKit** (planned, Phase 2)
- Zero external dependencies. Apple frameworks only.

## Contributing

Contributions are welcome. Monette is a good project to contribute to if you're interested in native macOS development with SwiftUI.

### Getting Started

1. Fork the repo and clone your fork
2. Open `Monette.xcodeproj` in Xcode (or build from the command line)
3. Pick an issue or area from the roadmap below
4. Create a branch, make your changes, open a PR

### Project Structure

```
Monette/
├── App/            # App entry point, delegate, shared state
├── Editor/         # Main editor view, canvas, sidebar, controls
├── Models/         # Data models (Screenshot, StylePreset)
├── Utilities/      # Image compositing pipeline
└── MonetteApp.swift
```

See [CLAUDE.md](CLAUDE.md) for detailed architecture docs and coding conventions.

### Areas to Contribute

**Phase 2: Window Capture** (next up)
- ScreenCaptureKit integration (`SCScreenshotManager`)
- Window picker UI (list available windows from `SCShareableContent`)
- Screen Recording permission flow

**Phase 3: Area Capture**
- Full-screen overlay for drag-to-select
- Multi-monitor support

**Phase 4: Polish**
- Global hotkeys
- Style presets (save/load)
- Recent captures history

**General improvements**
- Better gradient presets and background options
- Wallpaper/image backgrounds
- Annotation tools (arrows, text, blur)
- Performance optimizations

### Coding Conventions

- Swift 6.2 strict concurrency. Use `@Observable`, not `ObservableObject`.
- `async/await` over completion handlers.
- Keep SwiftUI view bodies small. Extract subviews when they get complex.
- Use `CGImage` for capture output.
- Prefer named constants over magic numbers.
- Build must pass with zero warnings before opening a PR.

### Build Verification

```bash
xcodebuild -project Monette.xcodeproj -scheme Monette -configuration Debug build 2>&1 | tail -20
```

If it says `BUILD SUCCEEDED`, you're good. If not, fix the error before committing.

## License

MIT License. See [LICENSE](LICENSE) for details.
