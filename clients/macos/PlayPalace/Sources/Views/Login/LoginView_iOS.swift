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
                serverPickerSection
                accountPickerSection
                passwordSection
                connectSection
                registrationSection
            }
            .navigationTitle("PlayPalace")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingGestureSettings = true
                    } label: {
                        Label("Gesture Settings", systemImage: "hand.draw")
                    }
                    .accessibilityLabel("Gesture settings")
                    .accessibilityHint("Customize touch gestures for gameplay")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingServerManager = true
                    } label: {
                        Label("Server Manager", systemImage: "server.rack")
                    }
                    .accessibilityLabel("Open server manager")
                    .accessibilityHint("Add, edit, or remove servers and accounts")
                }
            }
            .sheet(isPresented: $showingGestureSettings) {
                GestureSettingsView(settings: GestureSettings.load())
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
                Text("No servers configured. Tap Server Manager to add one.")
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("No servers configured")
                    .accessibilityHint("Open the server manager from the toolbar to add a server")
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
                    Label("Register New Account", systemImage: "person.badge.plus")
                    Spacer()
                }
            }
            .disabled(selectedServerID == nil)
            .accessibilityLabel("Register new account")
            .accessibilityHint(
                selectedServerID != nil
                    ? "Create a new account on \(selectedServer?.name ?? "this server")"
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

/// iOS registration view presented as a sheet.
/// Allows creating a new account on the selected server.
struct RegistrationView_iOS: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let serverURL: String
    let serverID: String

    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var email = ""
    @State private var bio = ""
    @State private var errorMessage: String?
    @State private var isRegistering = false
    @State private var successMessage: String?

    private var isValid: Bool {
        username.count >= 3 && username.count <= 32 &&
        password.count >= 8 && password.count <= 128 &&
        password == confirmPassword
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Username", text: $username)
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .accessibilityLabel("Choose a username")
                        .accessibilityHint("3 to 32 characters")

                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)
                        .accessibilityLabel("Choose a password")
                        .accessibilityHint("8 to 128 characters")

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

                    TextField("Bio", text: $bio)
                        .accessibilityLabel("Short bio")
                        .accessibilityHint("Optional. Tell others about yourself.")
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

                if let successMessage {
                    Section {
                        Text(successMessage)
                            .foregroundStyle(.green)
                            .accessibilityLabel(successMessage)
                    }
                }

                Section {
                    Button(action: performRegistration) {
                        HStack {
                            Spacer()
                            if isRegistering {
                                ProgressView()
                                    .accessibilityLabel("Registering")
                            } else {
                                Text("Register")
                                    .font(.headline)
                            }
                            Spacer()
                        }
                    }
                    .disabled(!isValid || isRegistering)
                    .accessibilityLabel("Register account")
                    .accessibilityHint(isValid ? "Create your account" : "Fill in all required fields first")
                }
            }
            .navigationTitle("Register")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityLabel("Cancel registration")
                }
            }
        }
    }

    private func performRegistration() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        errorMessage = nil
        isRegistering = true

        let _ = appState.configManager.addAccount(
            serverID: serverID,
            username: username,
            password: password,
            email: email
        )
        successMessage = "Account saved. The server will create it on first login."
        isRegistering = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
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
