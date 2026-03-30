import SwiftUI

struct PaddingSlider: View {
    @Binding var padding: CGFloat

    private let minPadding: CGFloat = 0
    private let maxPadding: CGFloat = 120

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Padding")
                .font(.headline)

            LabeledSlider(
                label: "Size",
                value: $padding,
                range: minPadding...maxPadding,
                format: "%.0f px"
            )
        }
    }
}
