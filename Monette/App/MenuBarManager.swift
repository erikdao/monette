import AppKit
import ScreenCaptureKit
import SwiftUI

@MainActor
class MenuBarManager: NSObject {
    private var statusItem: NSStatusItem!
    private var captureItem: NSMenuItem!
    private var pickerPanel: NSPanel?
    private var pickerHostingController: NSHostingController<WindowPickerView>?

    var onCaptureWindow: (() -> Void)?
    var onOpenEditor: (() -> Void)?
    var onGrantPermission: (() -> Void)?
    var onPermissionRecheck: (() -> Void)?

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(
            systemSymbolName: "camera.viewfinder",
            accessibilityDescription: "Monette"
        )

        let menu = NSMenu()
        menu.delegate = self

        captureItem = NSMenuItem(
            title: "Capture Window...",
            action: #selector(handleCapture),
            keyEquivalent: "1"
        )
        captureItem.keyEquivalentModifierMask = [.control, .shift]
        captureItem.target = self
        menu.addItem(captureItem)

        menu.addItem(.separator())

        let openItem = NSMenuItem(
            title: "Open Editor",
            action: #selector(handleOpenEditor),
            keyEquivalent: ""
        )
        openItem.target = self
        menu.addItem(openItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit Monette",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    func updatePermissionState(_ hasPermission: Bool) {
        if hasPermission {
            captureItem.title = "Capture Window..."
            captureItem.action = #selector(handleCapture)
        } else {
            captureItem.title = "Grant Screen Recording..."
            captureItem.action = #selector(handleGrantPermission)
        }
    }

    func showWindowPicker(windows: [SCWindow], onSelect: @escaping (SCWindow) -> Void) {
        dismissPicker()

        let grouped = Dictionary(grouping: windows) { $0.owningApplication?.bundleIdentifier ?? "" }
        let windowsByApp = grouped.map { (_, windows) in
            (app: windows.first?.owningApplication, windows: windows)
        }.sorted { ($0.app?.applicationName ?? "") < ($1.app?.applicationName ?? "") }

        let pickerView = WindowPickerView(
            windowsByApp: windowsByApp,
            onSelect: { [weak self] window in
                self?.dismissPicker()
                onSelect(window)
            },
            onCancel: { [weak self] in
                self?.dismissPicker()
            }
        )

        let hostingController = NSHostingController(rootView: pickerView)
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 560),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        panel.title = "Select a Window"
        panel.level = .floating
        panel.center()
        panel.contentViewController = hostingController
        panel.isReleasedWhenClosed = false

        self.pickerPanel = panel
        self.pickerHostingController = hostingController

        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }

    func dismissPicker() {
        pickerPanel?.close()
        pickerPanel = nil
        pickerHostingController = nil
    }

    @objc private func handleCapture() {
        onCaptureWindow?()
    }

    @objc private func handleOpenEditor() {
        onOpenEditor?()
    }

    @objc private func handleGrantPermission() {
        onGrantPermission?()
    }
}

extension MenuBarManager: NSMenuDelegate {
    nonisolated func menuWillOpen(_ menu: NSMenu) {
        MainActor.assumeIsolated {
            onPermissionRecheck?()
        }
    }
}
