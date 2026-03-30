import SwiftUI

@main
struct MonetteApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            EditorView()
                .environment(appState)
        }
        .defaultSize(width: 1100, height: 750)
    }
}
