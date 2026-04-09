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

    private var configCancellable: AnyCancellable?

    init() {
        configCancellable = configManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    func loginAndConnect(credentials: Credentials) {
        self.credentials = credentials
        screen = .main
    }

    func returnToLogin() {
        credentials = nil
        screen = .login
    }
}
