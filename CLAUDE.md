# Monette — macOS Screenshot Tool

A lightweight, native macOS screenshot tool with beautiful output. Personal alternative to CleanShot X / Xnapper. Named after Claude Monet — a little tool that turns ordinary screen captures into something impressionistic and polished.

## Project Overview

Monette is a menu bar app that captures windows or screen regions, then presents a simple editor where the user can add backgrounds, rounded corners, padding, and shadows — producing share-ready PNG screenshots. Built with SwiftUI + AppKit on macOS Tahoe 26, targeting Liquid Glass design.

**This is a personal-use app.** No App Store distribution, no subscriptions, no analytics. Just a fast, beautiful tool that runs on my Mac.

## Tech Stack

- **Language:** Swift 6.2, strict concurrency
- **UI:** SwiftUI (primary) + AppKit (for overlay/capture integration)
- **Capture:** ScreenCaptureKit (`SCScreenshotManager`) — the modern replacement for the deprecated `CGWindowListCreateImage`
- **Image processing:** CoreGraphics, CoreImage
- **Minimum deployment:** macOS 26 (Tahoe)
- **Build system:** Xcode project (`.xcodeproj`), no SPM dependencies initially
- **Design language:** Liquid Glass (`.glassEffect()`, translucent toolbar, adaptive materials)

## Architecture

```
Monette/
├── App/
│   ├── MonetteApp.swift          # @main, menu bar app (no dock icon)
│   ├── AppDelegate.swift           # NSApplicationDelegate for global hotkeys, permissions
│   └── AppState.swift              # Observable shared state
├── Capture/
│   ├── CaptureManager.swift        # ScreenCaptureKit wrapper, SCScreenshotManager
│   ├── WindowPicker.swift          # List available windows via SCShareableContent
│   ├── AreaSelector/
│   │   ├── OverlayWindow.swift     # Borderless, full-screen NSWindow for area selection
│   │   ├── SelectionView.swift     # Mouse drag → selection rect, crosshair, dimensions
│   │   └── OverlayManager.swift    # Multi-monitor overlay coordination
│   └── HotkeyManager.swift         # CGEvent tap for global keyboard shortcuts
├── Editor/
│   ├── EditorView.swift            # Main editor window (SwiftUI)
│   ├── CanvasView.swift            # Screenshot + background + shadow composite preview
│   ├── Controls/
│   │   ├── BackgroundPicker.swift  # Gradient/solid/image background selector
│   │   ├── BorderRadiusSlider.swift
│   │   ├── ShadowControls.swift    # Shadow offset, blur, opacity, color
│   │   ├── PaddingSlider.swift
│   │   └── PresetSelector.swift    # Save/load style presets
│   └── ExportManager.swift         # Composite rendering → PNG file
├── Models/
│   ├── Screenshot.swift            # Captured image + metadata
│   ├── StylePreset.swift           # Background, radius, shadow, padding config
│   └── ExportSettings.swift        # Output path, format, scale factor
├── Utilities/
│   ├── PermissionManager.swift     # Screen recording permission check/request
│   └── ImageCompositor.swift       # CoreGraphics: background + rounded clip + shadow → final image
└── Resources/
    ├── Assets.xcassets              # App icon (Liquid Glass multi-layer), accent colors
    └── Backgrounds/                 # Built-in gradient images
```

### Key Design Decisions

1. **Menu bar app, no dock icon.** Set `LSUIElement = YES` in Info.plist. The editor opens as a standalone window when a screenshot is taken.

2. **SwiftUI for editor, AppKit for overlay.** The area selection overlay needs to be a borderless, transparent, full-screen NSWindow that captures mouse events across all spaces. This is inherently AppKit. The editor UI is SwiftUI with Liquid Glass styling.

3. **ScreenCaptureKit over `screencapture` CLI.** SCScreenshotManager gives us native window filtering, cursor visibility control, and Retina-resolution output without shelling out. It requires Screen Recording permission — handle this gracefully on first launch.

4. **CoreGraphics compositing for export.** The final PNG is rendered via CG, not by screenshotting the editor view. This ensures pixel-perfect output at any scale factor, independent of the preview.

5. **No external dependencies.** Everything uses Apple frameworks. No SPM packages needed for v1.

## Build & Run

```bash
# Build from command line
xcodebuild -project Monette.xcodeproj -scheme Monette -configuration Debug build

# Run
open build/Debug/Monette.app

# Build release
xcodebuild -project Monette.xcodeproj -scheme Monette -configuration Release build
```

The app is unsigned (no Apple Developer Program membership). To run: right-click → Open to bypass Gatekeeper, or:
```bash
xattr -cr build/Debug/Monette.app
```

## Coding Conventions

- Use Swift 6.2 strict concurrency. Mark actors and sendable types explicitly.
- Prefer `async/await` over completion handlers.
- Use `@Observable` (Observation framework) instead of `ObservableObject` + `@Published` — this is the modern pattern for macOS 26.
- Keep SwiftUI view bodies small. If a view body triggers "compiler unable to type-check this expression in reasonable time", break it into smaller subviews.
- Use `CGImage` for capture output (easier to integrate than `CMSampleBuffer`).
- All user-facing strings should be hardcoded English (no localization needed for personal use).
- Prefer named constants over magic numbers for dimensions, padding, default values.

## Permissions

The app needs **Screen Recording** permission. Handle this at startup:

1. Check `CGPreflightScreenCaptureAccess()` on launch.
2. If not granted, show a dialog explaining why it's needed, then call `CGRequestScreenCaptureAccess()`.
3. The user must toggle the permission in System Settings → Privacy & Security → Screen Recording, then relaunch.

**Global hotkeys** require Accessibility permission if using `AXIsProcessTrusted()`. Alternatively, use `CGEvent` taps which work with Screen Recording permission alone.

## Feature Roadmap (Build Order)

Build incrementally. Each phase should produce a working app.

### Phase 1: Editor View (Pure SwiftUI)
Start with a hardcoded test image. Build the editor UI that composites:
- Screenshot on a canvas with configurable background (solid colors, gradients)
- Rounded corners with adjustable radius (0–32px)
- Drop shadow with adjustable blur, offset, opacity, color
- Padding around the screenshot
- "Save as PNG" button → file dialog → write composited image
- Liquid Glass toolbar/controls

**Why start here:** This is 100% SwiftUI, no permissions needed, fastest iteration loop. Claude Code can build and you can verify visually by running the app.

### Phase 2: Window Capture
- Integrate SCScreenshotManager for single-window capture
- Build a window picker (list available windows from SCShareableContent)
- Menu bar icon with "Capture Window" option
- Captured image flows into the editor from Phase 1
- Handle Screen Recording permission flow

### Phase 3: Area Capture
- Full-screen transparent overlay window (AppKit NSWindow)
- Mouse drag to select area with crosshair cursor and dimension labels
- Escape to cancel, mouse-up to capture
- Multi-monitor support (one overlay per screen)

### Phase 4: Global Hotkeys & Polish
- Register global hotkeys (e.g., ⌘⇧4 alternative like ⌃⇧1 for window, ⌃⇧2 for area)
- Style presets (save/load favorite background + radius + shadow combos)
- Copy to clipboard option
- Recent captures history in menu bar dropdown
- Liquid Glass refinements: adaptive glass on toolbar, scroll edge effects

## Liquid Glass Implementation

macOS Tahoe 26 Liquid Glass guidelines:

```swift
// Toolbar items get glass automatically when using standard SwiftUI toolbar
.toolbar {
    ToolbarItem(placement: .automatic) {
        Button("Save") { save() }
    }
}

// Custom floating controls
FloatingControlPanel()
    .glassEffect(.regular.interactive())

// DON'T put glass on content — only on navigation/controls that float above
// ❌ List { item.glassEffect() }
// ✅ ZStack { content; FloatingControls().glassEffect() }
```

Glass is for the **navigation layer** floating above content, not for content itself. The editor's control panel should use glass; the canvas/preview area should not.

## Image Compositing Pipeline

The export pipeline (in `ImageCompositor.swift`) should work like this:

```
Input: CGImage (captured screenshot)
       + StylePreset (background, radius, shadow, padding)

1. Calculate final canvas size:
   canvas = screenshot.size + (padding * 2) on each side

2. Create CGContext at canvas size (@ 2x for Retina)

3. Draw background:
   - Solid color: CGContext.fill()
   - Gradient: CGGradient
   - Image: Draw scaled background image

4. Create rounded rect path inset by padding

5. Apply shadow to context:
   CGContext.setShadow(offset:, blur:, color:)

6. Clip to rounded rect, draw screenshot

7. Export CGContext → CGImage → PNG data → write file
```

## Testing Strategy

- **Unit tests** for `ImageCompositor` (verify output dimensions, non-nil image)
- **Unit tests** for `StylePreset` encoding/decoding
- **Manual testing** for capture (requires Screen Recording permission, can't automate in CI)
- No UI tests needed for personal use — manual verification via screenshots pasted into Claude Code is the feedback loop

## Common Pitfalls (for Claude Code)

1. **Swift Concurrency:** `SCScreenshotManager.captureImage()` is async. Make sure capture calls are on `@MainActor` or properly isolated. Don't wrap async ScreenCaptureKit calls in `DispatchQueue` — use native async/await.

2. **NSWindow for overlays:** The area selection overlay must be `NSWindow` with `styleMask: .borderless`, `level: .screenSaver`, `isOpaque: false`, `backgroundColor: .clear`, `collectionBehavior: [.canJoinAllSpaces, .fullScreenAuxiliary]`.

3. **Retina scaling:** `SCStreamConfiguration.scaleFactor` should match the display's `backingScaleFactor`. The compositor should work in points but render at the native pixel density.

4. **Menu bar app lifecycle:** With `LSUIElement = YES`, there's no main window by default. The editor window must be created and managed explicitly. Use `NSApp.activate(ignoringOtherApps: true)` to bring it to front.

5. **Permission UX:** Screen Recording permission changes require app relaunch. Don't assume the permission is available after requesting — poll or observe the state.

## Reference Projects

These open-source projects are useful architecture references (do NOT copy code, use for patterns):

- `sadopc/ScreenCapture` — Swift 6 + SwiftUI + ScreenCaptureKit menu bar app with annotation tools
- `Brkgng/ScrollSnap` — ScreenCaptureKit-based capture with overlay selection UI architecture
- `KartikLabhshetwar/better-shot` — Tauri+React screenshot tool (cross-reference for editor UX patterns)

## gstack

Use `/browse` from gstack for all web browsing. Never use `mcp__claude-in-chrome__*` tools.

Available skills: `/office-hours`, `/plan-ceo-review`, `/plan-eng-review`, `/plan-design-review`,
`/design-consultation`, `/design-shotgun`, `/review`, `/ship`, `/land-and-deploy`, `/canary`,
`/benchmark`, `/browse`, `/connect-chrome`, `/qa`, `/qa-only`, `/design-review`,
`/setup-browser-cookies`, `/setup-deploy`, `/retro`, `/investigate`, `/document-release`,
`/codex`, `/cso`, `/autoplan`, `/careful`, `/freeze`, `/guard`, `/unfreeze`, `/gstack-upgrade`.

### Recommended gstack workflow for this project

Since this is a native macOS app (not a web app), adapt the gstack workflow:

1. **`/office-hours`** — Use at project start to refine scope and priorities
2. **`/plan-ceo-review`** — Before each phase, review the plan for scope creep
3. **`/plan-eng-review`** — Architecture review before Phase 2 (ScreenCaptureKit integration) and Phase 3 (overlay system) — these have real complexity
4. **`/design-consultation`** — Run once to establish the visual language (Liquid Glass + editor controls layout). Output to DESIGN.md
5. **`/review`** — On every branch before merging. Critical for Swift concurrency correctness
6. **`/ship`** — For commits and PR hygiene, even on a solo project
7. **`/investigate`** — When ScreenCaptureKit or AppKit behaves unexpectedly (and it will)

**Note on `/qa`:** gstack's QA uses a browser, which doesn't apply to a native macOS app. Instead, the feedback loop is: build → run → take screenshot of the result → paste screenshot into Claude Code for visual verification. This is the equivalent of `/qa` for native apps.

### Build verification loop

After every significant code change, Claude Code should:
```bash
# Build and check for errors
xcodebuild -project Monette.xcodeproj -scheme Monette -configuration Debug build 2>&1 | tail -20
```
If the build fails, fix the error before moving on. Never leave the project in a non-compiling state.

## Skill routing

When the user's request matches an available skill, ALWAYS invoke it using the Skill
tool as your FIRST action. Do NOT answer directly, do NOT use other tools first.
The skill has specialized workflows that produce better results than ad-hoc answers.

Key routing rules:
- Product ideas, "is this worth building", brainstorming → invoke office-hours
- Bugs, errors, "why is this broken", 500 errors → invoke investigate
- Ship, deploy, push, create PR → invoke ship
- QA, test the site, find bugs → invoke qa
- Code review, check my diff → invoke review
- Update docs after shipping → invoke document-release
- Weekly retro → invoke retro
- Design system, brand → invoke design-consultation
- Visual audit, design polish → invoke design-review
- Architecture review → invoke plan-eng-review
