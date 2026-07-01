import SwiftUI

struct RootView: View {
    @StateObject private var state = AppState()
    var body: some View { Group { if state.isOnboarded { MainTabView().environmentObject(state) } else { OnboardingView().environmentObject(state) } } }
}
