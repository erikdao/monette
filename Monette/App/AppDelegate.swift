import AppKit
import ScreenCaptureKit

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    let menuBarManager = MenuBarManager()
    var appState: AppState?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupNotifications()
        checkPermissionOnLaunch()
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .startCaptureFlow,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.startCaptureFlow()
            }
        }
    }

    private func setupMenuBar() {
        menuBarManager.setup()

        menuBarManager.onCaptureWindow = { [weak self] in
            self?.startCaptureFlow()
        }

        menuBarManager.onOpenEditor = { [weak self] in
            self?.openEditor()
        }

        menuBarManager.onGrantPermission = { [weak self] in
            self?.showPermissionAlert()
        }

        menuBarManager.onPermissionRecheck = { [weak self] in
            self?.recheckPermission()
        }
    }

    private func checkPermissionOnLaunch() {
        guard let appState else { return }
        appState.permissionManager.checkPermission()
        menuBarManager.updatePermissionState(appState.permissionManager.hasPermission)

        if !appState.permissionManager.hasPermission {
            // Delay slightly to let the app finish launching
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.showPermissionAlert()
            }
        }
    }

    private func recheckPermission() {
        guard let appState else { return }
        appState.permissionManager.checkPermission()
        menuBarManager.updatePermissionState(appState.permissionManager.hasPermission)
    }

    private func startCaptureFlow() {
        guard let appState else { return }

        appState.permissionManager.checkPermission()
        guard appState.permissionManager.hasPermission else {
            showPermissionAlert()
            return
        }

        Task {
            do {
                let windows = try await appState.captureService.availableWindows()
                if windows.isEmpty {
                    showAlert(
                        title: "No Windows Found",
                        message: "No capturable windows are available. Make sure other application windows are open."
                    )
                    return
                }

                menuBarManager.showWindowPicker(windows: windows) { [weak self] window in
                    self?.captureSelectedWindow(window)
                }
            } catch {
                showAlert(
                    title: "Error",
                    message: "Could not list windows: \(error.localizedDescription)"
                )
            }
        }
    }

    private func captureSelectedWindow(_ window: SCWindow) {
        guard let appState else { return }

        Task {
            do {
                try await appState.captureWindow(window)
                openEditor()
            } catch {
                showAlert(
                    title: "Capture Failed",
                    message: error.localizedDescription
                )
            }
        }
    }

    func openEditor() {
        NSApp.activate(ignoringOtherApps: true)

        if let existingWindow = NSApplication.shared.windows.first(where: {
            $0.title == "Monette" && $0.isVisible
        }) {
            existingWindow.makeKeyAndOrderFront(nil)
        } else {
            // Use the environment openWindow approach via notification
            if let window = NSApplication.shared.windows.first(where: { $0.title == "Monette" }) {
                window.makeKeyAndOrderFront(nil)
            } else {
                // Fallback: send the openWindow action
                NotificationCenter.default.post(name: .openEditorWindow, object: nil)
            }
        }
    }

    private func showPermissionAlert() {
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.messageText = "Screen Recording Permission"
        alert.informativeText = "Monette needs Screen Recording permission to capture windows.\n\nYou can still use drag-and-drop and paste to load images.\n\nAfter granting permission in System Settings, you'll need to relaunch Monette."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Later")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            guard let appState else { return }
            appState.permissionManager.requestPermission()
        }
    }

    private func showAlert(title: String, message: String) {
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

extension Notification.Name {
    static let openEditorWindow = Notification.Name("openEditorWindow")
}
