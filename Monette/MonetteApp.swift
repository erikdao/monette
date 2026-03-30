import SwiftUI

@main
struct MonetteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var appState = AppState()

    var body: some Scene {
        Window("Monette", id: "editor") {
            EditorView()
                .environment(appState)
                .preferredColorScheme(.dark)
                .onAppear {
                    appDelegate.appState = appState
                    configureEditorWindow()
                }
        }
        .defaultSize(width: 1100, height: 750)
        .defaultLaunchBehavior(.suppressed)
    }

    private func configureEditorWindow() {
        guard let window = NSApplication.shared.windows.first(where: {
            $0.title == "Monette" || $0.contentView?.subviews.isEmpty == false
        }) else { return }
        window.isOpaque = false
        window.backgroundColor = .clear
        window.titlebarAppearsTransparent = true
    }
}
