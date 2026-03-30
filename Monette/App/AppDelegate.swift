import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        configureMainWindow()
    }

    private func configureMainWindow() {
        guard let window = NSApplication.shared.windows.first else { return }
        window.isOpaque = false
        window.backgroundColor = .clear
        window.titlebarAppearsTransparent = true
    }
}
