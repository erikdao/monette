import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct EditorView: View {
    @Environment(AppState.self) private var appState

    private let sidebarWidth: CGFloat = 280

    var body: some View {
        @Bindable var appState = appState

        HStack(spacing: 0) {
            canvasArea
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
                    triggerCapture()
                } label: {
                    Label("Capture", systemImage: "camera.viewfinder")
                }
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    guard let s = appState.screenshot else { return }
                    ExportManager.copyToClipboard(screenshot: s.image, style: appState.style)
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                .disabled(appState.screenshot == nil)
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    guard let s = appState.screenshot else { return }
                    ExportManager.savePNG(screenshot: s.image, style: appState.style)
                } label: {
                    Label("Save PNG", systemImage: "square.and.arrow.down")
                }
                .disabled(appState.screenshot == nil)
            }
        }
    }

    @ViewBuilder
    private var canvasArea: some View {
        Group {
            switch appState.content {
            case .empty:
                EmptyStateView()
            case .loaded(let screenshot):
                CanvasView(
                    screenshot: screenshot.image,
                    scaleFactor: screenshot.scaleFactor,
                    style: appState.style
                )
            }
        }
        .onDrop(of: [.image, .fileURL], isTargeted: nil) { providers in
            handleDrop(providers)
            return true
        }
        .onPasteCommand(of: [UTType.image]) { providers in
            handlePaste(providers)
        }
    }

    private func handleDrop(_ providers: [NSItemProvider]) {
        for provider in providers {
            if provider.canLoadObject(ofClass: NSImage.self) {
                _ = provider.loadObject(ofClass: NSImage.self) { image, _ in
                    guard let nsImage = image as? NSImage,
                          let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
                    else { return }
                    Task { @MainActor in
                        appState.loadImage(cgImage)
                    }
                }
                return
            }

            // Try loading as file URL
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { data, _ in
                guard let urlData = data as? Data,
                      let url = URL(dataRepresentation: urlData, relativeTo: nil),
                      let nsImage = NSImage(contentsOf: url),
                      let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
                else { return }
                Task { @MainActor in
                    appState.loadImage(cgImage)
                }
            }
        }
    }

    private func handlePaste(_ providers: [NSItemProvider]) {
        for provider in providers {
            if provider.canLoadObject(ofClass: NSImage.self) {
                _ = provider.loadObject(ofClass: NSImage.self) { image, _ in
                    guard let nsImage = image as? NSImage,
                          let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
                    else { return }
                    Task { @MainActor in
                        appState.loadImage(cgImage)
                    }
                }
                return
            }
        }
    }

    private func triggerCapture() {
        // Post notification to AppDelegate to start capture flow
        NotificationCenter.default.post(name: .startCaptureFlow, object: nil)
    }
}

extension Notification.Name {
    static let startCaptureFlow = Notification.Name("startCaptureFlow")
}
