import SwiftUI

#if os(macOS)
struct ServerManagerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedServerID: String?
    @State private var showingAddServer = false
    @State private var showingEditServer = false
    @State private var showingAddAccount = false

    // Add/edit server fields
    @State private var serverName = ""
    @State private var serverHost = ""
    @State private var serverPort = "8000"
    @State private var serverNotes = ""

    // Add account fields
    @State private var accountUsername = ""
    @State private var accountPassword = ""
    @State private var accountEmail = ""

    private var configManager: ConfigManager { appState.configManager }

    var body: some View {
        VStack(spacing: 0) {
            Text("Server Manager")
                .font(.title2)
                .fontWeight(.semibold)
                .padding()

            HStack(spacing: 0) {
                serverListPanel
                Divider()
                detailPanel
            }

            Divider()
            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.escape, modifiers: [])
            }
            .padding()
        }
        .frame(width: 700, height: 500)
        .sheet(isPresented: $showingAddServer) { addServerSheet }
        .sheet(isPresented: $showingEditServer) { editServerSheet }
        .sheet(isPresented: $showingAddAccount) { addAccountSheet }
    }

    // MARK: - Server List

    private var serverListPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            List(selection: $selectedServerID) {
                ForEach(sortedServers, id: \.serverID) { server in
                    VStack(alignment: .leading) {
                        Text(server.name)
                            .fontWeight(.medium)
                        Text("\(server.host):\(server.port)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .tag(server.serverID)
                    .accessibilityLabel("\(server.name), \(server.host) port \(server.port)")
                }
            }
            .listStyle(.sidebar)

            HStack(spacing: 4) {
                Button(action: { showingAddServer = true }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add server")

                Button(action: deleteSelectedServer) {
                    Image(systemName: "minus")
                }
                .disabled(selectedServerID == nil)
                .accessibilityLabel("Remove selected server")
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .frame(width: 220)
    }

    // MARK: - Detail Panel

    private var detailPanel: some View {
        VStack {
            if let id = selectedServerID, let server = configManager.servers[id] {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(server.name).font(.title3).fontWeight(.semibold)
                            Text("\(server.host):\(server.port)")
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Edit") {
                            prepareEditServer(server)
                            showingEditServer = true
                        }
                        .accessibilityLabel("Edit server \(server.name)")
                    }

                    if !server.notes.isEmpty {
                        Text(server.notes)
                            .foregroundStyle(.secondary)
                            .font(.callout)
                    }

                    Divider()

                    HStack {
                        Text("Accounts").font(.headline)
                        Spacer()
                        Button("Add Account") {
                            accountUsername = ""
                            accountPassword = ""
                            accountEmail = ""
                            showingAddAccount = true
                        }
                        .accessibilityLabel("Add account to \(server.name)")
                    }

                    List {
                        ForEach(sortedAccounts(server), id: \.accountID) { account in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(account.username).fontWeight(.medium)
                                    if !account.email.isEmpty {
                                        Text(account.email)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Button(role: .destructive) {
                                    configManager.deleteAccount(serverID: id, accountID: account.accountID)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.borderless)
                                .accessibilityLabel("Remove \(account.username)")
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }
                    .listStyle(.inset)
                }
                .padding()
            } else {
                VStack {
                    Spacer()
                    Text("Select a server to view details.")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Sheets

    private var addServerSheet: some View {
        serverFormSheet(title: "Add Server") {
            let _ = configManager.addServer(
                name: serverName, host: serverHost,
                port: Int(serverPort) ?? 8000, notes: serverNotes
            )
            showingAddServer = false
        }
    }

    private var editServerSheet: some View {
        serverFormSheet(title: "Edit Server") {
            if let id = selectedServerID {
                configManager.updateServer(
                    id: id, name: serverName, host: serverHost,
                    port: Int(serverPort) ?? 8000, notes: serverNotes
                )
            }
            showingEditServer = false
        }
    }

    private func serverFormSheet(title: String, onSave: @escaping () -> Void) -> some View {
        VStack(spacing: 16) {
            Text(title).font(.title3).fontWeight(.semibold)

            Form {
                TextField("Name", text: $serverName)
                    .accessibilityLabel("Server name")
                TextField("Host", text: $serverHost)
                    .accessibilityLabel("Server host address")
                TextField("Port", text: $serverPort)
                    .accessibilityLabel("Server port number")
                TextField("Notes", text: $serverNotes)
                    .accessibilityLabel("Optional notes")
            }
            .formStyle(.grouped)

            HStack {
                Button("Cancel") {
                    showingAddServer = false
                    showingEditServer = false
                }
                .keyboardShortcut(.escape, modifiers: [])
                Spacer()
                Button("Save", action: onSave)
                    .keyboardShortcut(.return, modifiers: [])
                    .disabled(serverName.isEmpty || serverHost.isEmpty)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(width: 400)
    }

    private var addAccountSheet: some View {
        VStack(spacing: 16) {
            Text("Add Account").font(.title3).fontWeight(.semibold)

            Form {
                TextField("Username", text: $accountUsername)
                    .accessibilityLabel("Account username")
                SecureField("Password", text: $accountPassword)
                    .accessibilityLabel("Account password")
                TextField("Email (optional)", text: $accountEmail)
                    .accessibilityLabel("Email address, optional")
            }
            .formStyle(.grouped)

            HStack {
                Button("Cancel") { showingAddAccount = false }
                    .keyboardShortcut(.escape, modifiers: [])
                Spacer()
                Button("Save") {
                    if let id = selectedServerID {
                        let _ = configManager.addAccount(
                            serverID: id, username: accountUsername,
                            password: accountPassword, email: accountEmail
                        )
                    }
                    showingAddAccount = false
                }
                .keyboardShortcut(.return, modifiers: [])
                .disabled(accountUsername.isEmpty || accountPassword.isEmpty)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(width: 400)
    }

    // MARK: - Helpers

    private var sortedServers: [ServerEntry] {
        configManager.servers.values.sorted { $0.name < $1.name }
    }

    private func sortedAccounts(_ server: ServerEntry) -> [AccountEntry] {
        server.accounts.values.sorted { $0.username < $1.username }
    }

    private func prepareEditServer(_ server: ServerEntry) {
        serverName = server.name
        serverHost = server.host
        serverPort = String(server.port)
        serverNotes = server.notes
    }

    private func deleteSelectedServer() {
        if let id = selectedServerID {
            configManager.deleteServer(id)
            selectedServerID = nil
        }
    }
}
#endif
