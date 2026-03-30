import SwiftUI

struct EditorView: View {
    @Environment(AppState.self) private var appState

    private let sidebarWidth: CGFloat = 280

    var body: some View {
        @Bindable var appState = appState

        HStack(spacing: 0) {
            CanvasView(screenshot: appState.screenshot.image, style: appState.style)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(white: 0.12))

            SidebarView(appState: appState)
                .frame(width: sidebarWidth)
                .background(.ultraThinMaterial)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(Color(nsColor: .separatorColor))
                        .frame(width: 1)
                }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    ExportManager.copyToClipboard(
                        screenshot: appState.screenshot.image,
                        style: appState.style
                    )
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    ExportManager.savePNG(
                        screenshot: appState.screenshot.image,
                        style: appState.style
                    )
                } label: {
                    Label("Save PNG", systemImage: "square.and.arrow.down")
                }
            }
        }
    }
}
