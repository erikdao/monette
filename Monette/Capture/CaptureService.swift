import ScreenCaptureKit

enum CaptureError: Error, LocalizedError {
    case permissionDenied
    case noWindows
    case captureFailed(Error)
    case alreadyCapturing

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Screen Recording permission is required to capture windows."
        case .noWindows:
            return "No capturable windows found."
        case .captureFailed(let error):
            return "Capture failed: \(error.localizedDescription)"
        case .alreadyCapturing:
            return "A capture is already in progress."
        }
    }
}

@MainActor
class CaptureService {
    var isCapturing = false

    /// Get all capturable windows, excluding desktop elements and Monette itself.
    /// Includes off-screen windows for Stage Manager compatibility.
    func availableWindows() async throws -> [SCWindow] {
        let content = try await SCShareableContent.excludingDesktopWindows(
            true,
            onScreenWindowsOnly: false
        )
        return content.windows.filter { window in
            window.frame.width > 100 &&
            window.frame.height > 100 &&
            window.owningApplication?.bundleIdentifier != Bundle.main.bundleIdentifier
        }
    }

    /// Capture a single window at Retina resolution without system shadow.
    func captureWindow(_ window: SCWindow) async throws -> CGImage {
        guard !isCapturing else { throw CaptureError.alreadyCapturing }
        isCapturing = true
        defer { isCapturing = false }

        let filter = SCContentFilter(desktopIndependentWindow: window)
        let config = SCStreamConfiguration()
        config.captureResolution = .best
        config.showsCursor = false
        config.ignoreShadowsSingleWindow = true

        do {
            return try await SCScreenshotManager.captureImage(
                contentFilter: filter,
                configuration: config
            )
        } catch {
            throw CaptureError.captureFailed(error)
        }
    }
}
