import AppKit
import CoreGraphics
import SwiftUI

enum ImageCompositor {

    static func composite(screenshot: CGImage, style: StylePreset, scaleFactor: CGFloat = 2) -> CGImage? {
        let imageWidthPt = CGFloat(screenshot.width) / scaleFactor
        let imageHeightPt = CGFloat(screenshot.height) / scaleFactor

        let canvasWidthPt = imageWidthPt + style.padding * 2
        let canvasHeightPt = imageHeightPt + style.padding * 2

        let canvasWidthPx = Int(canvasWidthPt * scaleFactor)
        let canvasHeightPx = Int(canvasHeightPt * scaleFactor)

        guard let context = CGContext(
            data: nil,
            width: canvasWidthPx,
            height: canvasHeightPx,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        // Scale to work in points, CG native Y-up coordinate system
        context.scaleBy(x: scaleFactor, y: scaleFactor)

        let canvasRectPt = CGRect(x: 0, y: 0, width: canvasWidthPt, height: canvasHeightPt)

        // 1. Draw background
        drawBackground(in: context, rect: canvasRectPt, background: style.background)

        // 2. Screenshot rect (inset by padding)
        let screenshotRect = CGRect(
            x: style.padding,
            y: style.padding,
            width: imageWidthPt,
            height: imageHeightPt
        )

        let roundedPath = CGPath(
            roundedRect: screenshotRect,
            cornerWidth: style.cornerRadius,
            cornerHeight: style.cornerRadius,
            transform: nil
        )

        // 3. Draw shadow by filling the rounded rect with shadow enabled
        if style.shadow.opacity > 0 {
            context.saveGState()
            let shadowColor = nsColor(from: style.shadow.color)
                .withAlphaComponent(style.shadow.opacity)
                .cgColor
            context.setShadow(
                offset: CGSize(width: style.shadow.offsetX, height: -style.shadow.offsetY),
                blur: style.shadow.blur,
                color: shadowColor
            )
            context.addPath(roundedPath)
            context.setFillColor(CGColor(gray: 1, alpha: 1))
            context.fillPath()
            context.restoreGState()
        }

        // 4. Clip to rounded rect and draw the screenshot
        context.saveGState()
        context.addPath(roundedPath)
        context.clip()

        // CG draws images in Y-up, so flip within the screenshot rect
        context.saveGState()
        context.translateBy(x: screenshotRect.origin.x, y: screenshotRect.origin.y + screenshotRect.height)
        context.scaleBy(x: 1, y: -1)
        context.draw(screenshot, in: CGRect(origin: .zero, size: screenshotRect.size))
        context.restoreGState()

        context.restoreGState()

        return context.makeImage()
    }

    private static func drawBackground(in context: CGContext, rect: CGRect, background: BackgroundStyle) {
        switch background.type {
        case .solid:
            let color = nsColor(from: background.solidColor).cgColor
            context.setFillColor(color)
            context.fill(rect)

        case .gradient:
            let startCG = nsColor(from: background.gradientStartColor).cgColor
            let endCG = nsColor(from: background.gradientEndColor).cgColor

            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [startCG, endCG] as CFArray,
                locations: [0, 1]
            ) else { return }

            // CSS-convention angle: 0° = bottom-to-top, 90° = left-to-right
            // CG Y-up: cos(0) = 1 = upward, sin(90°) = 1 = rightward
            let angle = background.gradientAngle * .pi / 180
            let dx = sin(angle)
            let dy = cos(angle)
            let cx = rect.midX
            let cy = rect.midY
            let startPoint = CGPoint(x: cx - dx * rect.width / 2, y: cy - dy * rect.height / 2)
            let endPoint = CGPoint(x: cx + dx * rect.width / 2, y: cy + dy * rect.height / 2)

            context.drawLinearGradient(
                gradient,
                start: startPoint,
                end: endPoint,
                options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
            )
        }
    }

    private static func nsColor(from color: Color) -> NSColor {
        let nsColor = NSColor(color)
        return nsColor.usingColorSpace(.sRGB) ?? nsColor
    }
}
