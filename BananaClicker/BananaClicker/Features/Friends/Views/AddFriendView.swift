//
//  AddFriendView.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI

/// View for adding a new friend
struct AddFriendView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var viewModel: FriendsViewModel

    @State private var nickname: String = ""
    @State private var isAdding: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Enter nickname", text: $nickname)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    if !nickname.isEmpty {
                        if User.isValidNickname(nickname) {
                            Label("Valid nickname", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.accentGreen)
                        } else {
                            Label("Invalid format (3-20 alphanumeric + underscore)", systemImage: "xmark.circle.fill")
                                .foregroundStyle(.accentRed)
                                .font(.caption)
                        }
                    }
                } header: {
                    Text("Friend's Nickname")
                } footer: {
                    Text("Enter the exact nickname of the person you want to add as a friend.")
                }

                Section {
                    Button {
                        Task {
                            await addFriend()
                        }
                    } label: {
                        if isAdding {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Add Friend")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(!User.isValidNickname(nickname) || isAdding)
                }
            }
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {
                    showError = false
                }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func addFriend() async {
        isAdding = true
        defer { isAdding = false }

        let success = await viewModel.addFriend(nickname: nickname)

        if success {
            dismiss()
        } else {
            errorMessage = viewModel.error?.localizedDescription ?? "Failed to add friend"
            showError = true
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var viewModel = FriendsViewModel()

    AddFriendView(viewModel: $viewModel)
}
