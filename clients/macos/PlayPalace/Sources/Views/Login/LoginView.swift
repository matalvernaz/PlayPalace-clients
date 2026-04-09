import SwiftUI

#if os(macOS)
struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingServerManager = false
    @State private var showingRegistration = false
    @State private var selectedServerID: String?
    @State private var selectedAccountID: String?
    @State private var password = ""
    @State private var errorMessage: String?

    private var configManager: ConfigManager { appState.configManager }

    private var selectedServer: ServerEntry? {
        guard let id = selectedServerID else { return nil }
        return configManager.servers[id]
    }

    private var selectedAccount: AccountEntry? {
        guard let sid = selectedServerID, let aid = selectedAccountID else { return nil }
        return configManager.servers[sid]?.accounts[aid]
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider()
            HStack(spacing: 0) {
                serverList
                Divider()
                loginForm
            }
        }
        .frame(minWidth: 700, minHeight: 480)
        .sheet(isPresented: $showingServerManager) {
            ServerManagerView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showingRegistration) {
            if let serverID = selectedServerID,
               let url = configManager.serverURL(for: serverID) {
                RegistrationView(serverURL: url, serverID: serverID)
                    .environmentObject(appState)
            }
        }
        .onAppear(perform: restoreLastSelection)
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Text("PlayPalace")
                .font(.title2)
                .fontWeight(.semibold)
            Spacer()
            Button("Server Manager") {
                showingServerManager = true
            }
            .accessibilityLabel("Open server manager")
            .accessibilityHint("Add, edit, or remove servers")
        }
        .padding()
        .background(.bar)
    }

    // MARK: - Server/Account Tree

    private var serverList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Servers & Accounts")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 12)

            List(selection: Binding(
                get: { selectedAccountID ?? selectedServerID },
                set: { handleTreeSelection($0) }
            )) {
                ForEach(sortedServers, id: \.serverID) { server in
                    Section(header: serverHeader(server)) {
                        ForEach(sortedAccounts(server), id: \.accountID) { account in
                            Label(account.username, systemImage: "person.fill")
                                .tag(account.accountID)
                                .accessibilityLabel("\(account.username) on \(server.name)")
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .accessibilityLabel("Server and account list")
        }
        .frame(width: 240)
    }

    private var sortedServers: [ServerEntry] {
        configManager.servers.values.sorted { $0.name < $1.name }
    }

    private func sortedAccounts(_ server: ServerEntry) -> [AccountEntry] {
        server.accounts.values.sorted { $0.username < $1.username }
    }

    private func serverHeader(_ server: ServerEntry) -> some View {
        HStack {
            Image(systemName: "server.rack")
            Text(server.name)
                .fontWeight(.medium)
        }
        .tag(server.serverID)
        .accessibilityLabel("Server: \(server.name)")
    }

    // MARK: - Login Form

    private var loginForm: some View {
        VStack(spacing: 20) {
            Spacer()

            if let server = selectedServer, let account = selectedAccount {
                VStack(spacing: 12) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)

                    Text("Log In")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("\(account.username) on \(server.name)")
                        .foregroundStyle(.secondary)

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 300)
                        .onSubmit(performLogin)
                        .accessibilityLabel("Password for \(account.username)")

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                            .accessibilityLabel("Error: \(errorMessage)")
                    }

                    Button(action: performLogin) {
                        Text("Connect")
                            .frame(maxWidth: 200)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .keyboardShortcut(.return, modifiers: [])
                    .accessibilityLabel("Connect to \(server.name) as \(account.username)")

                    Button("Register New Account") {
                        showingRegistration = true
                    }
                    .buttonStyle(.link)
                    .accessibilityHint("Create a new account on this server")
                }
            } else if selectedServerID != nil {
                VStack(spacing: 12) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                    Text("Select an account or add one in the Server Manager.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "server.rack")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                    Text("Select a server to get started.")
                        .foregroundStyle(.secondary)
                    if configManager.servers.isEmpty {
                        Text("Use the Server Manager to add a server.")
                            .foregroundStyle(.tertiary)
                            .font(.caption)
                    }
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    // MARK: - Actions

    private func handleTreeSelection(_ id: String?) {
        guard let id else { return }
        // Check if it's a server ID
        if configManager.servers[id] != nil {
            selectedServerID = id
            selectedAccountID = nil
            return
        }
        // Check if it's an account ID
        for (sid, server) in configManager.servers {
            if server.accounts[id] != nil {
                selectedServerID = sid
                selectedAccountID = id
                // Pre-fill password
                password = server.accounts[id]?.password ?? ""
                return
            }
        }
    }

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
#endif
