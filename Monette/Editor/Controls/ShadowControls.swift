import SwiftUI

struct ShadowControls: View {
    @Binding var shadow: ShadowStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shadow")
                .font(.headline)

            LabeledSlider(
                label: "Blur",
                value: $shadow.blur,
                range: 0...60,
                format: "%.0f"
            )

            LabeledSlider(
                label: "Offset X",
                value: $shadow.offsetX,
                range: -30...30,
                format: "%.0f"
            )

            LabeledSlider(
                label: "Offset Y",
                value: $shadow.offsetY,
                range: -30...30,
                format: "%.0f"
            )

            LabeledSlider(
                label: "Opacity",
                value: $shadow.opacity,
                range: 0...1,
                format: "%.0f%%",
                displayMultiplier: 100
            )

            ColorPicker("Color", selection: $shadow.color)
        }
    }
}
