#if os(iOS)
import SwiftUI

/// iOS login view with NavigationStack and Form-based layout.
/// Provides server selection, account selection, password entry, and connection.
struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedServerID: String?
    @State private var selectedAccountID: String?
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var showingServerManager = false
    @State private var showingRegistration = false
    @State private var showingGestureSettings = false
    @State private var showingGettingStarted = false

    private var configManager: ConfigManager { appState.configManager }

    private var sortedServers: [ServerEntry] {
        configManager.servers.values.sorted { $0.name < $1.name }
    }

    private var selectedServer: ServerEntry? {
        guard let id = selectedServerID else { return nil }
        return configManager.servers[id]
    }

    private var sortedAccounts: [AccountEntry] {
        guard let server = selectedServer else { return [] }
        return server.accounts.values.sorted { $0.username < $1.username }
    }

    private var selectedAccount: AccountEntry? {
        guard let sid = selectedServerID, let aid = selectedAccountID else { return nil }
        return configManager.servers[sid]?.accounts[aid]
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        showingGettingStarted = true
                    } label: {
                        Label("Getting Started", systemImage: "questionmark.circle")
                    }
                    .accessibilityLabel("Getting started")
                    .accessibilityHint("Read how to set up a server, register an account, and use in-game gestures. Available offline.")

                    Button {
                        showingServerManager = true
                    } label: {
                        Label("Server Manager", systemImage: "server.rack")
                    }
                    .accessibilityLabel("Server manager")
                    .accessibilityHint("Add, edit, or remove servers and accounts")

                    Button {
                        showingGestureSettings = true
                    } label: {
                        Label("Audio and Gesture Settings", systemImage: "slider.horizontal.3")
                    }
                    .accessibilityLabel("Audio and gesture settings")
                    .accessibilityHint("Adjust music and ambience volume, customize touch gestures")
                }

                serverPickerSection
                accountPickerSection
                passwordSection
                connectSection
                registrationSection
            }
            .navigationTitle("PlayPalace")
            .sheet(isPresented: $showingGestureSettings) {
                GestureSettingsView(settings: GestureSettings.load())
            }
            .sheet(isPresented: $showingGettingStarted) {
                GettingStartedSheet()
            }
            .sheet(isPresented: $showingServerManager) {
                ServerManagerView_iOS()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showingRegistration) {
                if let serverID = selectedServerID,
                   let url = configManager.serverURL(for: serverID) {
                    RegistrationView_iOS(serverURL: url, serverID: serverID)
                        .environmentObject(appState)
                }
            }
            .onAppear(perform: restoreLastSelection)
            .onChange(of: selectedServerID) { _, newValue in
                // Reset account selection when server changes
                selectedAccountID = nil
                password = ""
                // Auto-select last account if available
                if let sid = newValue,
                   let lastAccount = configManager.servers[sid]?.lastAccountID {
                    selectedAccountID = lastAccount
                    password = configManager.servers[sid]?.accounts[lastAccount]?.password ?? ""
                }
            }
            .onChange(of: selectedAccountID) { _, newValue in
                // Auto-fill password from saved account
                if let sid = selectedServerID,
                   let aid = newValue,
                   let account = configManager.servers[sid]?.accounts[aid] {
                    password = account.password
                }
            }
        }
    }

    // MARK: - Sections

    private var serverPickerSection: some View {
        Section {
            if sortedServers.isEmpty {
                Text("No servers configured. Choose Server Manager above to add one.")
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("No servers configured")
                    .accessibilityHint("Choose the Server Manager button near the top of this screen to add a server.")
            } else {
                Picker(selection: $selectedServerID) {
                    Text("Select a server")
                        .tag(nil as String?)
                        .accessibilityLabel("No server selected")
                    ForEach(sortedServers) { server in
                        VStack(alignment: .leading) {
                            Text(server.name)
                            Text("\(server.host):\(server.port)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .tag(server.serverID as String?)
                        .accessibilityLabel("\(server.name), \(server.host) port \(server.port)")
                    }
                } label: {
                    Label("Server", systemImage: "server.rack")
                        .accessibilityLabel("Select server")
                }
                .accessibilityHint("Choose a server to connect to")
            }
        } header: {
            Text("Server")
                .accessibilityAddTraits(.isHeader)
        }
    }

    private var accountPickerSection: some View {
        Section {
            if selectedServerID == nil {
                Text("Select a server first.")
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Select a server first to see available accounts")
            } else if sortedAccounts.isEmpty {
                Text("No accounts on this server. Add one in Server Manager or register below.")
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("No accounts found on this server")
                    .accessibilityHint("Use Server Manager or Register below to add an account")
            } else {
                Picker(selection: $selectedAccountID) {
                    Text("Select an account")
                        .tag(nil as String?)
                        .accessibilityLabel("No account selected")
                    ForEach(sortedAccounts) { account in
                        Text(account.username)
                            .tag(account.accountID as String?)
                            .accessibilityLabel(account.username)
                    }
                } label: {
                    Label("Account", systemImage: "person.fill")
                        .accessibilityLabel("Select account")
                }
                .accessibilityHint("Choose an account to log in with")
            }
        } header: {
            Text("Account")
                .accessibilityAddTraits(.isHeader)
        }
    }

    private var passwordSection: some View {
        Section {
            if let account = selectedAccount {
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .accessibilityLabel("Password for \(account.username)")
                    .accessibilityHint("Enter your password. A saved password is pre-filled if available.")

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .accessibilityLabel("Error: \(errorMessage)")
                }
            } else {
                Text("Select a server and account above.")
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Select a server and account to enter your password")
            }
        } header: {
            Text("Password")
                .accessibilityAddTraits(.isHeader)
        }
    }

    private var connectSection: some View {
        Section {
            Button(action: performLogin) {
                HStack {
                    Spacer()
                    Label("Connect", systemImage: "play.fill")
                        .font(.headline)
                    Spacer()
                }
            }
            .disabled(selectedAccount == nil || password.isEmpty)
            .accessibilityLabel("Connect to server")
            .accessibilityHint(
                selectedAccount != nil
                    ? "Connect to \(selectedServer?.name ?? "server") as \(selectedAccount?.username ?? "user")"
                    : "Select a server and account first"
            )
        }
    }

    private var registrationSection: some View {
        Section {
            Button {
                showingRegistration = true
            } label: {
                HStack {
                    Spacer()
                    Label("Create New Account", systemImage: "person.badge.plus")
                    Spacer()
                }
            }
            .disabled(selectedServerID == nil)
            .accessibilityLabel("Create new account")
            .accessibilityHint(
                selectedServerID != nil
                    ? "Create a new account on \(selectedServer?.name ?? "this server") and connect."
                    : "Select a server first"
            )
        }
    }

    // MARK: - Actions

    private func restoreLastSelection() {
        if let lastServer = configManager.lastServerID {
            selectedServerID = lastServer
            if let lastAccount = configManager.servers[lastServer]?.lastAccountID {
                selectedAccountID = lastAccount
                password = configManager.servers[lastServer]?.accounts[lastAccount]?.password ?? ""
            }
        }
    }

    private func performLogin() {
        guard let serverID = selectedServerID,
              let account = selectedAccount,
              let url = configManager.serverURL(for: serverID) else {
            errorMessage = "Please select a server and account."
            return
        }

        let pw = password.isEmpty ? account.password : password
        guard !pw.isEmpty else {
            errorMessage = "Please enter a password."
            return
        }

        errorMessage = nil
        configManager.setLastUsed(serverID: serverID, accountID: account.accountID)

        let creds = Credentials(
            username: account.username,
            password: pw,
            serverURL: url,
            serverID: serverID,
            accountID: account.accountID,
            refreshToken: account.refreshToken,
            refreshExpiresAt: account.refreshExpiresAt
        )
        appState.loginAndConnect(credentials: creds)
    }
}

// MARK: - Registration View (iOS)

/// Create-account sheet. Saves the credentials locally, then immediately hands
/// off to the main connect flow — the server auto-creates the account during
/// `authorize` when it doesn't already exist and reports errors (username
/// taken with a different password, accounts blocked, rate limited) through
/// the existing disconnect-with-show_message path, so this sheet doesn't need
/// to round-trip with the server separately.
struct RegistrationView_iOS: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let serverURL: String
    let serverID: String

    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var email = ""
    @State private var errorMessage: String?

    private static let minUsernameLength = 3
    private static let maxUsernameLength = 32
    private static let minPasswordLength = 8
    private static let maxPasswordLength = 128

    private var isValid: Bool {
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
        return (Self.minUsernameLength...Self.maxUsernameLength).contains(trimmedUsername.count) &&
            (Self.minPasswordLength...Self.maxPasswordLength).contains(password.count) &&
            password == confirmPassword
    }

    private var serverName: String {
        appState.configManager.servers[serverID]?.name ?? "this server"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Choose a username and password. We'll connect to \(serverName) and either sign you in or create the account if it doesn't exist yet.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Choose a username and password. The app will connect to \(serverName) and either sign you in or create the account if it doesn't exist yet.")
                }

                Section {
                    TextField("Username", text: $username)
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .accessibilityLabel("Choose a username")
                        .accessibilityHint("Between \(Self.minUsernameLength) and \(Self.maxUsernameLength) characters")

                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)
                        .accessibilityLabel("Choose a password")
                        .accessibilityHint("Between \(Self.minPasswordLength) and \(Self.maxPasswordLength) characters")

                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .accessibilityLabel("Confirm password")
                        .accessibilityHint("Type your password again to confirm")
                } header: {
                    Text("Required")
                        .accessibilityAddTraits(.isHeader)
                }

                Section {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .accessibilityLabel("Email address")
                        .accessibilityHint("Optional. Used for account recovery.")
                } header: {
                    Text("Optional")
                        .accessibilityAddTraits(.isHeader)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .accessibilityLabel("Error: \(errorMessage)")
                    }
                }

                Section {
                    Button(action: performRegistration) {
                        HStack {
                            Spacer()
                            Text("Create Account and Connect")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .disabled(!isValid)
                    .accessibilityLabel("Create account and connect")
                    .accessibilityHint(
                        isValid
                            ? "Save these credentials and connect to \(serverName). The server will create the account if it doesn't exist."
                            : "Fill in all required fields first"
                    )
                }
            }
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityLabel("Cancel")
                }
            }
        }
    }

    private func performRegistration() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
        guard !trimmedUsername.isEmpty else {
            errorMessage = "Username can't be empty."
            return
        }
        errorMessage = nil

        guard let accountID = appState.configManager.addAccount(
            serverID: serverID,
            username: trimmedUsername,
            password: password,
            email: email.trimmingCharacters(in: .whitespaces)
        ) else {
            errorMessage = "Couldn't save account locally. Try again."
            return
        }

        appState.configManager.setLastUsed(serverID: serverID, accountID: accountID)

        guard let url = appState.configManager.serverURL(for: serverID) else {
            errorMessage = "Server is missing a valid host or port. Edit it in Server Manager and try again."
            return
        }

        let creds = Credentials(
            username: trimmedUsername,
            password: password,
            serverURL: url,
            serverID: serverID,
            accountID: accountID,
            refreshToken: nil,
            refreshExpiresAt: nil
        )

        // Dismiss before flipping the app screen so the sheet's transition
        // doesn't fight the login → main transition.
        dismiss()
        appState.loginAndConnect(credentials: creds)
    }
}

// MARK: - Getting Started Sheet (offline onboarding)

/// First-run help for new players. Bundled in the app so it works
/// before any server is configured — pulled from `gettingStartedSections`
/// rather than the server's documents library. Each section appears as
/// its own list row so VoiceOver users can flick through topics
/// individually instead of being read the entire manual.
struct GettingStartedSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(gettingStartedSections, id: \.title) { section in
                    SwiftUI.Section(section.title) {
                        ForEach(section.lines, id: \.self) { line in
                            Text(line)
                                .font(.body)
                                .accessibilityLabel(line)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Getting Started")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private struct Topic {
        let title: String
        let lines: [String]
    }

    private var gettingStartedSections: [Topic] {
        [
            Topic(title: "Welcome", lines: [
                "PlayPalace is a multiplayer game room designed for VoiceOver. You can play with friends, on a public server, or against bots.",
                "Everything in the app speaks itself. VoiceOver works too — use whichever feels best.",
            ]),
            Topic(title: "First steps", lines: [
                "1. Choose Server Manager and add a server, or use one of the servers already listed. To add your own you need a host name or IP address and a port (typically 8000).",
                "2. Back on the main screen, pick the server you want.",
                "3. Choose Create New Account to make a new account and connect — the server creates it for you on the first connection. If you already have an account, use Server Manager to save its username and password.",
                "4. Choose Connect.",
            ]),
            Topic(title: "In-game gestures", lines: [
                "PlayPalace games do not use on-screen buttons. The whole screen is the game area, and you interact with gestures.",
                "One finger handles menu navigation: swipe left and right to browse, double-tap to select, single tap to repeat the current item, long press for a status read-out.",
                "Two fingers handle game actions: scrub back and forth to go back, double-tap to perform the primary action (such as roll or draw), swipe up to check the score, swipe down to add a bot. A single two-finger tap stops the app talking when you've heard enough of an announcement.",
                "Three fingers handle the message history: swipe left and right between buffers, up and down between messages, tap to open the help screen, double-tap to repeat the last announcement from the server.",
                "You can change any of these in Audio and Gesture Settings.",
            ]),
            Topic(title: "Always-available controls", lines: [
                "There is a Menu button in the top-right corner of every game screen. It opens Help, Controls, and Chat. It works no matter how gestures are configured, so you can never lock yourself out.",
                "When VoiceOver is on, you can also use the Actions rotor (flick up or down on the game area) to find Help, Controls, Chat, Status, and game actions.",
            ]),
            Topic(title: "Audio", lines: [
                "Background music and ambience volume are in Audio and Gesture Settings. Music keeps playing while you are connected.",
                "Speech rate follows your VoiceOver settings when VoiceOver is on. When it is off, you can adjust the rate inside the app.",
            ]),
            Topic(title: "If something goes wrong", lines: [
                "If the connection drops, the app will automatically try to reconnect.",
                "If gestures stop responding the way you expect, open Audio and Gesture Settings and choose Reset to defaults.",
                "If you cannot find help while in a game, use the Menu button in the top-right of the screen — it is always there.",
            ]),
        ]
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AppState())
    }
}
#endif

#endif
