import CoreGraphics
import Foundation

struct Screenshot {
    let image: CGImage
    let scaleFactor: CGFloat
    let createdAt: Date
    let windowTitle: String?
    let appName: String?
    let bundleIdentifier: String?

    init(
        image: CGImage,
        scaleFactor: CGFloat = 2,
        createdAt: Date = Date(),
        windowTitle: String? = nil,
        appName: String? = nil,
        bundleIdentifier: String? = nil
    ) {
        self.image = image
        self.scaleFactor = scaleFactor
        self.createdAt = createdAt
        self.windowTitle = windowTitle
        self.appName = appName
        self.bundleIdentifier = bundleIdentifier
    }

    static func createTestImage() -> CGImage? {
        let width = 1200
        let height = 800

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        let w = CGFloat(width)
        let h = CGFloat(height)

        context.translateBy(x: 0, y: h)
        context.scaleBy(x: 1, y: -1)

        // Dark editor background
        context.setFillColor(CGColor(srgbRed: 0.118, green: 0.118, blue: 0.180, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: w, height: h))

        // Title bar
        let titleBarHeight: CGFloat = 96
        context.setFillColor(CGColor(srgbRed: 0.165, green: 0.165, blue: 0.247, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: w, height: titleBarHeight))

        // Separator line under title bar
        context.setFillColor(CGColor(srgbRed: 0.22, green: 0.22, blue: 0.32, alpha: 1))
        context.fill(CGRect(x: 0, y: titleBarHeight - 2, width: w, height: 2))

        // Traffic light dots
        let dotColors: [(r: Double, g: Double, b: Double)] = [
            (1.0, 0.38, 0.38),
            (1.0, 0.75, 0.28),
            (0.35, 0.78, 0.35),
        ]
        for (i, c) in dotColors.enumerated() {
            let cx = 44.0 + Double(i) * 44.0
            let cy = titleBarHeight / 2
            context.setFillColor(CGColor(srgbRed: c.r, green: c.g, blue: c.b, alpha: 1))
            context.fillEllipse(in: CGRect(x: cx - 12, y: cy - 12, width: 24, height: 24))
        }

        // Title text placeholder
        context.setFillColor(CGColor(srgbRed: 0.5, green: 0.5, blue: 0.58, alpha: 1))
        context.fill(CGRect(x: w / 2 - 100, y: titleBarHeight / 2 - 8, width: 200, height: 16))

        // Code lines
        let codeLines: [(y: CGFloat, indent: CGFloat, width: CGFloat, r: Double, g: Double, b: Double)] = [
            (140, 48, 240, 0.68, 0.47, 0.86),
            (180, 48, 400, 0.56, 0.74, 0.93),
            (220, 48, 160, 0.42, 0.60, 0.42),
            (260, 48, 320, 0.92, 0.72, 0.46),
            (300, 48, 500, 0.56, 0.74, 0.93),
            (340, 96, 360, 0.86, 0.86, 0.90),
            (380, 96, 280, 0.92, 0.72, 0.46),
            (420, 96, 200, 0.68, 0.47, 0.86),
            (460, 48, 140, 0.86, 0.86, 0.90),
            (540, 48, 360, 0.68, 0.47, 0.86),
            (580, 48, 600, 0.86, 0.86, 0.90),
            (620, 96, 440, 0.56, 0.74, 0.93),
            (660, 96, 520, 0.92, 0.72, 0.46),
            (700, 48, 180, 0.86, 0.86, 0.90),
        ]

        for line in codeLines {
            context.setFillColor(CGColor(srgbRed: line.r, green: line.g, blue: line.b, alpha: 1))
            let rect = CGRect(x: line.indent, y: line.y, width: line.width, height: 16)
            let path = CGPath(roundedRect: rect, cornerWidth: 4, cornerHeight: 4, transform: nil)
            context.addPath(path)
            context.fillPath()
        }

        // Line numbers gutter
        for i in 0..<14 {
            let y: CGFloat = 140 + CGFloat(i) * 40
            if y > 700 { break }
            context.setFillColor(CGColor(srgbRed: 0.35, green: 0.35, blue: 0.42, alpha: 1))
            context.fill(CGRect(x: 16, y: y + 2, width: 16, height: 12))
        }

        return context.makeImage()
    }
}
