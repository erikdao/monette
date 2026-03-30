import SwiftUI

@main
struct MonetteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            EditorView()
                .environment(appState)
                .preferredColorScheme(.dark)
        }
        .defaultSize(width: 1100, height: 750)
    }
}
