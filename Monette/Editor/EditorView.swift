import SwiftUI

struct EditorView: View {
    @Environment(AppState.self) private var appState

    private let inspectorWidth: CGFloat = 280
    private let inspectorCornerRadius: CGFloat = 12
    private let inspectorPadding: CGFloat = 10

    var body: some View {
        @Bindable var appState = appState

        ZStack(alignment: .trailing) {
            CanvasView(screenshot: appState.screenshot.image, style: appState.style)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(white: 0.12))

            inspectorSidebar(appState: $appState)
                .padding(inspectorPadding)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Save PNG") {
                    ExportManager.savePNG(
                        screenshot: appState.screenshot.image,
                        style: appState.style
                    )
                }
            }
        }
    }

    private func inspectorSidebar(appState: Bindable<AppState>) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                BackgroundPicker(background: appState.style.background)
                Divider()
                BorderRadiusSlider(cornerRadius: appState.style.cornerRadius)
                Divider()
                ShadowControls(shadow: appState.style.shadow)
                Divider()
                PaddingSlider(padding: appState.style.padding)
            }
            .padding()
        }
        .frame(width: inspectorWidth)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: inspectorCornerRadius))
        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 4)
    }
}
