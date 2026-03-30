import ScreenCaptureKit

@Observable
@MainActor
class PermissionManager {
    var hasPermission: Bool = false

    func checkPermission() {
        hasPermission = CGPreflightScreenCaptureAccess()
    }

    @discardableResult
    func requestPermission() -> Bool {
        let granted = CGRequestScreenCaptureAccess()
        hasPermission = granted
        return granted
    }
}
