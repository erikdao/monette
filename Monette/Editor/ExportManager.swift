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

    static func copyToClipboard(screenshot: CGImage, style: StylePreset) {
        guard let composited = ImageCompositor.composite(screenshot: screenshot, style: style) else {
            return
        }

        let rep = NSBitmapImageRep(cgImage: composited)
        guard let pngData = rep.representation(using: .png, properties: [:]) else { return }

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setData(pngData, forType: .png)
    }
}
