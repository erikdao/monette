import SwiftUI

struct CanvasView: View {
    let screenshot: CGImage
    let style: StylePreset

    private var imageWidthPt: CGFloat { CGFloat(screenshot.width) / 2 }
    private var imageHeightPt: CGFloat { CGFloat(screenshot.height) / 2 }
    private var canvasWidth: CGFloat { imageWidthPt + style.padding * 2 }
    private var canvasHeight: CGFloat { imageHeightPt + style.padding * 2 }

    var body: some View {
        GeometryReader { geometry in
            let scale = min(
                geometry.size.width * 0.9 / canvasWidth,
                geometry.size.height * 0.9 / canvasHeight,
                1.0
            )

            compositeView
                .frame(width: canvasWidth, height: canvasHeight)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .scaleEffect(scale)
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    private var compositeView: some View {
        ZStack {
            backgroundView
            screenshotView
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style.background.type {
        case .solid:
            Rectangle().fill(style.background.solidColor)
        case .gradient:
            let (start, end) = gradientEndPoints(angleDegrees: style.background.gradientAngle)
            LinearGradient(
                colors: [style.background.gradientStartColor, style.background.gradientEndColor],
                startPoint: start,
                endPoint: end
            )
        }
    }

    private var screenshotView: some View {
        Image(decorative: screenshot, scale: 2)
            .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
            .shadow(
                color: style.shadow.color.opacity(style.shadow.opacity),
                radius: style.shadow.blur / 2,
                x: style.shadow.offsetX,
                y: style.shadow.offsetY
            )
            .padding(style.padding)
    }

    private func gradientEndPoints(angleDegrees: Double) -> (start: UnitPoint, end: UnitPoint) {
        let angle = angleDegrees * .pi / 180
        let dx = sin(angle)
        let dy = -cos(angle)
        let start = UnitPoint(x: 0.5 - dx * 0.5, y: 0.5 - dy * 0.5)
        let end = UnitPoint(x: 0.5 + dx * 0.5, y: 0.5 + dy * 0.5)
        return (start, end)
    }
}
