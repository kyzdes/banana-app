//
//  SettingsView.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI

/// App settings view
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var viewModel: ProfileViewModel

    @State private var showingNicknameEdit = false
    @State private var showingDeleteConfirmation = false
    @State private var newNickname = ""

    var body: some View {
        NavigationStack {
            Form {
                // Profile section
                Section {
                    if let user = viewModel.user {
                        Button {
                            newNickname = user.nickname
                            showingNicknameEdit = true
                        } label: {
                            HStack {
                                Text("Nickname")
                                    .foregroundStyle(.primaryText)
                                Spacer()
                                Text(user.nickname)
                                    .foregroundStyle(.secondaryText)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiaryText)
                            }
                        }
                    }
                } header: {
                    Text("Profile")
                } footer: {
                    Text("You can change your nickname once every 30 days.")
                }

                // Preferences section
                Section {
                    Toggle("Haptic Feedback", isOn: $viewModel.hapticsEnabled)
                    Toggle("Sound Effects", isOn: $viewModel.soundEnabled)
                } header: {
                    Text("Preferences")
                }

                // About section
                Section {
                    Link(destination: URL(string: Constants.URLs.privacyPolicy)!) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                    }

                    Link(destination: URL(string: Constants.URLs.termsOfService)!) {
                        HStack {
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                    }

                    Link(destination: URL(string: Constants.URLs.support)!) {
                        HStack {
                            Text("Support")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                    }
                } header: {
                    Text("About")
                }

                // App info
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0 (1)")
                            .foregroundStyle(.secondaryText)
                    }
                } header: {
                    Text("App Info")
                }

                // Danger zone
                Section {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.logout()
                        }
                    } label: {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                    }

                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete Account", systemImage: "trash.fill")
                    }
                } header: {
                    Text("Account")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Change Nickname", isPresented: $showingNicknameEdit) {
                TextField("New nickname", text: $newNickname)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                Button("Cancel", role: .cancel) {}

                Button("Save") {
                    Task {
                        _ = await viewModel.updateNickname(newNickname)
                    }
                }
                .disabled(!User.isValidNickname(newNickname))
            } message: {
                Text("Enter a new nickname (3-20 alphanumeric characters + underscore)")
            }
            .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}

                Button("Delete", role: .destructive) {
                    Task {
                        let success = await viewModel.deleteAccount()
                        if success {
                            dismiss()
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var viewModel = ProfileViewModel()

    SettingsView(viewModel: $viewModel)
}
