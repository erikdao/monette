import SwiftUI

struct BorderRadiusSlider: View {
    @Binding var cornerRadius: CGFloat

    private let minRadius: CGFloat = 0
    private let maxRadius: CGFloat = 32

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Corner Radius")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            LabeledSlider(
                label: "Radius",
                value: $cornerRadius,
                range: minRadius...maxRadius,
                format: "%.0f px"
            )
        }
    }
}
