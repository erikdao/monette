import SwiftUI

struct BackgroundPicker: View {
    @Binding var background: BackgroundStyle

    private let presetColumns = [GridItem(.adaptive(minimum: 44), spacing: 8)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Background")
                .font(.headline)

            Picker("Type", selection: $background.type) {
                Text("Solid").tag(BackgroundType.solid)
                Text("Gradient").tag(BackgroundType.gradient)
            }
            .pickerStyle(.segmented)

            presetGrid

            colorControls
        }
    }

    private var presetGrid: some View {
        LazyVGrid(columns: presetColumns, spacing: 8) {
            ForEach(GradientPreset.builtIn) { preset in
                presetButton(preset)
            }
        }
    }

    private func presetButton(_ preset: GradientPreset) -> some View {
        Button {
            background.type = .gradient
            background.gradientStartColor = preset.startColor
            background.gradientEndColor = preset.endColor
            background.gradientAngle = preset.angle
        } label: {
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [preset.startColor, preset.endColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var colorControls: some View {
        switch background.type {
        case .solid:
            ColorPicker("Color", selection: $background.solidColor)
        case .gradient:
            ColorPicker("Start", selection: $background.gradientStartColor)
            ColorPicker("End", selection: $background.gradientEndColor)
            LabeledSlider(
                label: "Angle",
                value: $background.gradientAngle,
                range: 0...360,
                format: "%.0f\u{00B0}"
            )
        }
    }
}
