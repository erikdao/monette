import AppKit
import ScreenCaptureKit
import SwiftUI

enum EditorContent {
    case empty
    case loaded(Screenshot)
}

@Observable
@MainActor
class AppState {
    var content: EditorContent = .empty
    var style = StylePreset()

    let captureService = CaptureService()
    let permissionManager = PermissionManager()

    var screenshot: Screenshot? {
        if case .loaded(let s) = content { return s } else { return nil }
    }

    func loadImage(_ image: CGImage, scaleFactor: CGFloat = 2) {
        content = .loaded(Screenshot(image: image, scaleFactor: scaleFactor))
    }

    func captureWindow(_ window: SCWindow) async throws {
        let image = try await captureService.captureWindow(window)
        let scale = NSScreen.main?.backingScaleFactor ?? 2
        content = .loaded(Screenshot(
            image: image,
            scaleFactor: scale,
            windowTitle: window.title,
            appName: window.owningApplication?.applicationName,
            bundleIdentifier: window.owningApplication?.bundleIdentifier
        ))
    }
}
