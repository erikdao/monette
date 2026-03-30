import SwiftUI

@Observable
class AppState {
    var screenshot: Screenshot
    var style = StylePreset()

    init() {
        if let testImage = Screenshot.createTestImage() {
            self.screenshot = Screenshot(image: testImage)
        } else {
            // Fallback: 1x1 white pixel
            let ctx = CGContext(
                data: nil, width: 1, height: 1,
                bitsPerComponent: 8, bytesPerRow: 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )!
            ctx.setFillColor(CGColor.white)
            ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            self.screenshot = Screenshot(image: ctx.makeImage()!)
        }
    }
}
