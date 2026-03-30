import SwiftUI

struct SidebarView: View {
    @Bindable var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                BackgroundPicker(background: $appState.style.background)
                Divider()
                BorderRadiusSlider(cornerRadius: $appState.style.cornerRadius)
                Divider()
                ShadowControls(shadow: $appState.style.shadow)
                Divider()
                PaddingSlider(padding: $appState.style.padding)
            }
            .padding()
        }
    }
}
