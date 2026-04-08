import SwiftUI
import Combine

enum AppScreen: Equatable {
    case login
    case main
}

@MainActor
final class AppState: ObservableObject {
    @Published var screen: AppScreen = .login
    @Published var credentials: Credentials?
    @Published var configManager = ConfigManager()

    func loginAndConnect(credentials: Credentials) {
        self.credentials = credentials
        screen = .main
    }

    func returnToLogin() {
        credentials = nil
        screen = .login
    }
}
