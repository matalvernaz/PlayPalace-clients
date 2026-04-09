#if os(iOS)
import SwiftUI

// MARK: - Hashable conformance for sheet bindings (iOS only)

extension ServerEntry: Hashable {
    static func == (lhs: ServerEntry, rhs: ServerEntry) -> Bool {
        lhs.serverID == rhs.serverID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(serverID)
    }
}

/// iOS server manager with full NavigationStack-based browsing.
/// Allows adding, editing, and deleting servers and their accounts.
struct ServerManagerView_iOS: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var showingAddServer = false
    @State private var editingServer: ServerEntry?

    private var configManager: ConfigManager { appState.configManager }

    private var sortedServers: [ServerEntry] {
        configManager.servers.values.sorted { $0.name < $1.name }
    }

    var body: some View {
        NavigationStack {
            List {
                // Prominent Add Server button at top of list for VoiceOver discoverability
                Section {
                    Button {
                        showingAddServer = true
                    } label: {
                        Label("Add Server", systemImage: "plus.circle.fill")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.tint)
                    }
                    .accessibilityLabel("Add server")
                    .accessibilityHint("Add a new game server to connect to")
                }

                if sortedServers.isEmpty {
                    Section {
                        Text("No servers configured yet. Tap Add Server above to get started.")
                            .foregroundStyle(.secondary)
                            .accessibilityLabel("No servers configured")
                            .accessibilityHint("Use the Add Server button above to add your first server")
                    }
                } else {
                    Section {
                        ForEach(sortedServers) { server in
                            NavigationLink {
                                ServerDetailView_iOS(serverID: server.serverID)
                                    .environmentObject(appState)
                            } label: {
                                ServerRow_iOS(server: server)
                            }
                            .accessibilityLabel("\(server.name), \(server.host) port \(server.port)")
                            .accessibilityHint("Tap to view accounts and server details")
                        }
                        .onDelete(perform: deleteServers)
                    } header: {
                        Text("Servers")
                            .accessibilityAddTraits(.isHeader)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Server Manager")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityLabel("Close server manager")
                }
            }
            .sheet(isPresented: $showingAddServer) {
                AddEditServerSheet_iOS(mode: .add)
                    .environmentObject(appState)
            }
        }
    }

    private func deleteServers(at offsets: IndexSet) {
        let servers = sortedServers
        for index in offsets {
            configManager.deleteServer(servers[index].serverID)
        }
    }
}

/// A row displaying server name and connection info.
private struct ServerRow_iOS: View {
    let server: ServerEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(server.name)
                .font(.body.weight(.medium))
            Text("\(server.host):\(server.port)")
                .font(.caption)
                .foregroundStyle(.secondary)
            if !server.notes.isEmpty {
                Text(server.notes)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Server Detail View

/// Detail view for a single server, showing its accounts.
struct ServerDetailView_iOS: View {
    @EnvironmentObject var appState: AppState
    let serverID: String

    @State private var showingEditServer = false
    @State private var showingAddAccount = false
    @State private var editingAccount: AccountEntry?

    private var configManager: ConfigManager { appState.configManager }

    private var server: ServerEntry? {
        configManager.servers[serverID]
    }

    private var sortedAccounts: [AccountEntry] {
        guard let server = server else { return [] }
        return server.accounts.values.sorted { $0.username < $1.username }
    }

    var body: some View {
        List {
            // Server info section
            if let server = server {
                Section {
                    LabeledContent("Host", value: "\(server.host):\(server.port)")
                        .accessibilityLabel("Host: \(server.host) port \(server.port)")
                    if !server.notes.isEmpty {
                        LabeledContent("Notes", value: server.notes)
                            .accessibilityLabel("Notes: \(server.notes)")
                    }
                } header: {
                    Text("Server Info")
                        .accessibilityAddTraits(.isHeader)
                }
            }

            // Prominent Add Account button
            Section {
                Button {
                    showingAddAccount = true
                } label: {
                    Label("Add Account", systemImage: "person.badge.plus")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.tint)
                }
                .accessibilityLabel("Add account")
                .accessibilityHint("Add a new login account to this server")
            }

            // Accounts list
            if sortedAccounts.isEmpty {
                Section {
                    Text("No accounts yet. Tap Add Account to create one.")
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("No accounts on this server")
                }
            } else {
                Section {
                    ForEach(sortedAccounts) { account in
                        Button {
                            editingAccount = account
                        } label: {
                            AccountRow_iOS(account: account)
                        }
                        .accessibilityLabel("\(account.username)\(account.email.isEmpty ? "" : ", \(account.email)")")
                        .accessibilityHint("Tap to edit this account. Swipe left to delete.")
                    }
                    .onDelete(perform: deleteAccounts)
                } header: {
                    Text("Accounts")
                        .accessibilityAddTraits(.isHeader)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(server?.name ?? "Server")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEditServer = true
                } label: {
                    Label("Edit Server", systemImage: "pencil")
                }
                .accessibilityLabel("Edit server settings")
                .accessibilityHint("Change the server name, host, port, or notes")
            }
        }
        .sheet(isPresented: $showingEditServer) {
            if let server = server {
                AddEditServerSheet_iOS(
                    mode: .edit(server)
                )
                .environmentObject(appState)
            }
        }
        .sheet(isPresented: $showingAddAccount) {
            AddEditAccountSheet_iOS(serverID: serverID, mode: .add)
                .environmentObject(appState)
        }
        .sheet(item: $editingAccount) { account in
            AddEditAccountSheet_iOS(serverID: serverID, mode: .edit(account))
                .environmentObject(appState)
        }
    }

    private func deleteAccounts(at offsets: IndexSet) {
        let accounts = sortedAccounts
        for index in offsets {
            configManager.deleteAccount(serverID: serverID, accountID: accounts[index].accountID)
        }
    }
}

/// A row showing account username and email.
private struct AccountRow_iOS: View {
    let account: AccountEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(account.username)
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)
            if !account.email.isEmpty {
                Text(account.email)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Add/Edit Server Sheet

/// Sheet for adding or editing a server entry.
struct AddEditServerSheet_iOS: View {
    enum Mode {
        case add
        case edit(ServerEntry)

        var title: String {
            switch self {
            case .add: return "Add Server"
            case .edit: return "Edit Server"
            }
        }

        var isEdit: Bool {
            if case .edit = self { return true }
            return false
        }
    }

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let mode: Mode

    @State private var name = ""
    @State private var host = ""
    @State private var port = "8000"
    @State private var notes = ""

    private var configManager: ConfigManager { appState.configManager }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !host.trimmingCharacters(in: .whitespaces).isEmpty &&
        Int(port) != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Server Name", text: $name)
                        .accessibilityLabel("Server name")
                        .accessibilityHint("A display name for this server")

                    TextField("Host", text: $host)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                        .accessibilityLabel("Server host address")
                        .accessibilityHint("The hostname or IP address of the server")

                    TextField("Port", text: $port)
                        .keyboardType(.numberPad)
                        .accessibilityLabel("Server port number")
                        .accessibilityHint("The port number, usually 8000")
                } header: {
                    Text("Connection")
                        .accessibilityAddTraits(.isHeader)
                }

                Section {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .accessibilityLabel("Notes about this server")
                        .accessibilityHint("Optional. Add any helpful notes.")
                } header: {
                    Text("Notes")
                        .accessibilityAddTraits(.isHeader)
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityLabel("Cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!isValid)
                        .accessibilityLabel("Save server")
                        .accessibilityHint(isValid ? "Save the server configuration" : "Fill in name and host first")
                }
            }
            .onAppear {
                if case .edit(let server) = mode {
                    name = server.name
                    host = server.host
                    port = String(server.port)
                    notes = server.notes
                }
            }
        }
    }

    private func save() {
        let portNum = Int(port) ?? 8000
        switch mode {
        case .add:
            let _ = configManager.addServer(name: name, host: host, port: portNum, notes: notes)
        case .edit(let server):
            configManager.updateServer(id: server.serverID, name: name, host: host, port: portNum, notes: notes)
        }
        dismiss()
    }
}

// MARK: - Add/Edit Account Sheet

/// Sheet for adding or editing an account entry on a specific server.
struct AddEditAccountSheet_iOS: View {
    enum Mode {
        case add
        case edit(AccountEntry)

        var title: String {
            switch self {
            case .add: return "Add Account"
            case .edit: return "Edit Account"
            }
        }
    }

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let serverID: String
    let mode: Mode

    @State private var username = ""
    @State private var password = ""
    @State private var email = ""

    private var configManager: ConfigManager { appState.configManager }

    private var isValid: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Username", text: $username)
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .accessibilityLabel("Account username")
                        .accessibilityHint("The username for logging in")

                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .accessibilityLabel("Account password")
                        .accessibilityHint("The password for logging in")
                } header: {
                    Text("Credentials")
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
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityLabel("Cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!isValid)
                        .accessibilityLabel("Save account")
                        .accessibilityHint(isValid ? "Save the account" : "Enter username and password first")
                }
            }
            .onAppear {
                if case .edit(let account) = mode {
                    username = account.username
                    password = account.password
                    email = account.email
                }
            }
        }
    }

    private func save() {
        switch mode {
        case .add:
            let _ = configManager.addAccount(
                serverID: serverID,
                username: username,
                password: password,
                email: email
            )
        case .edit(let account):
            configManager.updateAccount(
                serverID: serverID,
                accountID: account.accountID,
                username: username,
                password: password
            )
        }
        dismiss()
    }
}

// MARK: - Make AccountEntry work with sheet(item:)

extension AccountEntry: Hashable {
    static func == (lhs: AccountEntry, rhs: AccountEntry) -> Bool {
        lhs.accountID == rhs.accountID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(accountID)
    }
}

#if DEBUG
struct ServerManagerView_iOS_Previews: PreviewProvider {
    static var previews: some View {
        ServerManagerView_iOS()
            .environmentObject(AppState())
    }
}
#endif

#endif
