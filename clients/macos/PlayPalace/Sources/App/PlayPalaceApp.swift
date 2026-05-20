import SwiftUI

@main
struct PlayPalaceApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        #if os(macOS)
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .installLowVisionEnvironment()
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
                .installLowVisionEnvironment()
        }
        #endif
    }
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.lowVision) private var lv

    var body: some View {
        Group {
            switch appState.screen {
            case .login:
                LoginView()
            case .main:
                MainView()
            }
        }
        .animation(lv.standardAnimation, value: appState.screen)
    }
}
