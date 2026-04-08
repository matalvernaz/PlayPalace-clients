import SwiftUI

struct RegistrationView: View {
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

    var body: some View {
        VStack(spacing: 16) {
            Text("Register New Account")
                .font(.title2)
                .fontWeight(.semibold)

            Form {
                TextField("Username", text: $username)
                    .accessibilityLabel("Choose a username, 3 to 32 characters")
                SecureField("Password", text: $password)
                    .accessibilityLabel("Choose a password, 8 to 128 characters")
                SecureField("Confirm Password", text: $confirmPassword)
                    .accessibilityLabel("Type your password again to confirm")
                TextField("Email (optional)", text: $email)
                    .accessibilityLabel("Email address, optional")
                TextField("Bio (optional)", text: $bio)
                    .accessibilityLabel("Short bio, optional")
            }
            .formStyle(.grouped)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
                    .accessibilityLabel("Error: \(errorMessage)")
            }

            if let successMessage {
                Text(successMessage)
                    .foregroundStyle(.green)
                    .font(.caption)
                    .accessibilityLabel(successMessage)
            }

            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.escape, modifiers: [])
                Spacer()
                Button("Register") { performRegistration() }
                    .keyboardShortcut(.return, modifiers: [])
                    .disabled(!isValid || isRegistering)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(width: 420)
    }

    private var isValid: Bool {
        username.count >= 3 && username.count <= 32 &&
        password.count >= 8 && password.count <= 128 &&
        password == confirmPassword
    }

    private func performRegistration() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        errorMessage = nil
        isRegistering = true

        // Save the account locally so we can log in later
        let _ = appState.configManager.addAccount(
            serverID: serverID,
            username: username,
            password: password,
            email: email
        )
        successMessage = "Account saved. The server will create it on first login."
        isRegistering = false

        // Auto-dismiss after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}
