import AppKit
import ScreenCaptureKit
import SwiftUI

struct WindowPickerView: View {
    let windowsByApp: [(app: SCRunningApplication?, windows: [SCWindow])]
    let onSelect: (SCWindow) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if windowsByApp.isEmpty {
                emptyState
            } else {
                windowList
            }

            Divider()

            HStack {
                Spacer()
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding(12)
        }
        .frame(minWidth: 400, minHeight: 300)
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "macwindow")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No capturable windows found")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var windowList: some View {
        List {
            ForEach(windowsByApp, id: \.app?.processID) { group in
                Section {
                    ForEach(group.windows, id: \.windowID) { window in
                        WindowRow(window: window)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onSelect(window)
                            }
                    }
                } header: {
                    HStack(spacing: 8) {
                        AppIconView(app: group.app)
                            .frame(width: 20, height: 20)
                        Text(group.app?.applicationName ?? "Unknown")
                            .font(.subheadline.weight(.semibold))
                    }
                }
            }
        }
    }
}

private struct WindowRow: View {
    let window: SCWindow

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "macwindow")
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(windowTitle)
                    .font(.body)
                    .lineLimit(1)

                Text(windowSize)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var windowTitle: String {
        let title = window.title ?? ""
        return title.isEmpty ? "Untitled Window" : title
    }

    private var windowSize: String {
        let w = Int(window.frame.width)
        let h = Int(window.frame.height)
        return "\(w) x \(h)"
    }
}

private struct AppIconView: View {
    let app: SCRunningApplication?

    var body: some View {
        if let app = app,
           let runningApp = NSRunningApplication(processIdentifier: app.processID),
           let icon = runningApp.icon {
            Image(nsImage: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: "app")
                .foregroundStyle(.secondary)
        }
    }
}
