import AppKit
import UniformTypeIdentifiers

enum ExportManager {

    static func savePNG(screenshot: CGImage, style: StylePreset) {
        guard let composited = ImageCompositor.composite(screenshot: screenshot, style: style) else {
            return
        }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = "screenshot.png"
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK, let url = panel.url else { return }

        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else { return }

        CGImageDestinationAddImage(destination, composited, nil)
        CGImageDestinationFinalize(destination)
    }
}
