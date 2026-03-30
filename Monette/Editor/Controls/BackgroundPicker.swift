import SwiftUI

struct BackgroundPicker: View {
    @Binding var background: BackgroundStyle

    private let presetColumns = [GridItem(.adaptive(minimum: 44), spacing: 8)]

    private static let solidPresets: [Color] = [
        Color(white: 0.08),  // near-black ("no background")
        .black,
        Color(white: 0.2),
        Color(white: 0.95),
        .white,
        .red,
        .orange,
        .yellow,
        .green,
        .mint,
        .cyan,
        .blue,
        .indigo,
        .purple,
        .pink,
        .brown,
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Background")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Picker("Type", selection: $background.type) {
                Text("Solid").tag(BackgroundType.solid)
                Text("Gradient").tag(BackgroundType.gradient)
            }
            .pickerStyle(.segmented)

            if background.type == .gradient {
                gradientPresetGrid
            } else {
                solidPresetGrid
            }

            colorControls
        }
    }

    private var gradientPresetGrid: some View {
        LazyVGrid(columns: presetColumns, spacing: 8) {
            ForEach(GradientPreset.builtIn) { preset in
                gradientPresetButton(preset)
            }
        }
    }

    private var solidPresetGrid: some View {
        LazyVGrid(columns: presetColumns, spacing: 8) {
            ForEach(Array(Self.solidPresets.enumerated()), id: \.offset) { _, color in
                solidPresetButton(color)
            }
        }
    }

    private func gradientPresetButton(_ preset: GradientPreset) -> some View {
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

    private func solidPresetButton(_ color: Color) -> some View {
        Button {
            background.type = .solid
            background.solidColor = color
        } label: {
            RoundedRectangle(cornerRadius: 6)
                .fill(color)
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
