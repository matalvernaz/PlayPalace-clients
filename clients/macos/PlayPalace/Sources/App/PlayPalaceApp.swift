import SwiftUI

@main
struct PlayPalaceApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        #if os(macOS)
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 980, height: 720)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
        #else
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        #endif
    }
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            switch appState.screen {
            case .login:
                LoginView()
            case .main:
                MainView()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: appState.screen)
    }
}
