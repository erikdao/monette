import SwiftUI

struct EditorView: View {
    @Environment(AppState.self) private var appState

    private let inspectorWidth: CGFloat = 280

    var body: some View {
        @Bindable var appState = appState

        HStack(spacing: 0) {
            CanvasView(screenshot: appState.screenshot.image, style: appState.style)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(white: 0.12))

            Divider()

            inspectorSidebar(appState: $appState)
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
    }
}
