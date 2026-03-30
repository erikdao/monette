import SwiftUI

struct LabeledSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var format: String = "%.1f"
    var displayMultiplier: Double = 1

    init(label: String, value: Binding<Double>, range: ClosedRange<Double>, format: String = "%.1f", displayMultiplier: Double = 1) {
        self.label = label
        self._value = value
        self.range = range
        self.format = format
        self.displayMultiplier = displayMultiplier
    }

    init(label: String, value: Binding<CGFloat>, range: ClosedRange<CGFloat>, format: String = "%.1f", displayMultiplier: Double = 1) {
        self.label = label
        self._value = Binding(
            get: { Double(value.wrappedValue) },
            set: { value.wrappedValue = CGFloat($0) }
        )
        self.range = Double(range.lowerBound)...Double(range.upperBound)
        self.format = format
        self.displayMultiplier = displayMultiplier
    }

    var body: some View {
        HStack {
            Text(label)
                .frame(width: 60, alignment: .leading)
                .foregroundStyle(.secondary)

            Slider(value: $value, in: range)

            Text(String(format: format, value * displayMultiplier))
                .monospacedDigit()
                .frame(width: 50, alignment: .trailing)
                .foregroundStyle(.secondary)
        }
    }
}
