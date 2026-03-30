import SwiftUI

enum BackgroundType: String, CaseIterable {
    case solid
    case gradient
}

struct GradientPreset: Identifiable {
    let id = UUID()
    let name: String
    let startColor: Color
    let endColor: Color
    let angle: Double

    static let builtIn: [GradientPreset] = [
        GradientPreset(
            name: "Lavender",
            startColor: Color(red: 0.49, green: 0.24, blue: 0.89),
            endColor: Color(red: 0.83, green: 0.28, blue: 0.74),
            angle: 135
        ),
        GradientPreset(
            name: "Ocean",
            startColor: Color(red: 0.0, green: 0.47, blue: 0.75),
            endColor: Color(red: 0.0, green: 0.83, blue: 0.88),
            angle: 135
        ),
        GradientPreset(
            name: "Sunset",
            startColor: Color(red: 1.0, green: 0.42, blue: 0.42),
            endColor: Color(red: 1.0, green: 0.73, blue: 0.2),
            angle: 135
        ),
        GradientPreset(
            name: "Forest",
            startColor: Color(red: 0.13, green: 0.59, blue: 0.33),
            endColor: Color(red: 0.16, green: 0.82, blue: 0.62),
            angle: 135
        ),
        GradientPreset(
            name: "Night",
            startColor: Color(red: 0.09, green: 0.09, blue: 0.22),
            endColor: Color(red: 0.22, green: 0.22, blue: 0.48),
            angle: 135
        ),
        GradientPreset(
            name: "Peach",
            startColor: Color(red: 1.0, green: 0.6, blue: 0.48),
            endColor: Color(red: 1.0, green: 0.82, blue: 0.64),
            angle: 135
        ),
        GradientPreset(
            name: "Minimal",
            startColor: Color(red: 0.93, green: 0.93, blue: 0.96),
            endColor: Color(red: 0.84, green: 0.84, blue: 0.90),
            angle: 135
        ),
        GradientPreset(
            name: "Charcoal",
            startColor: Color(red: 0.18, green: 0.20, blue: 0.25),
            endColor: Color(red: 0.30, green: 0.32, blue: 0.38),
            angle: 135
        ),
    ]
}

struct BackgroundStyle {
    var type: BackgroundType = .gradient
    var solidColor: Color = .white
    var gradientStartColor: Color = Color(red: 0.49, green: 0.24, blue: 0.89)
    var gradientEndColor: Color = Color(red: 0.83, green: 0.28, blue: 0.74)
    var gradientAngle: Double = 135
}

struct ShadowStyle {
    var blur: CGFloat = 20
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 10
    var opacity: Double = 0.3
    var color: Color = .black
}

struct StylePreset {
    var background = BackgroundStyle()
    var cornerRadius: CGFloat = 12
    var shadow = ShadowStyle()
    var padding: CGFloat = 60
}
