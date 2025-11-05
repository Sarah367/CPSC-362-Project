//
//  medicationCheck.swift
//  Animal App
//
//  Created by Samuel Z on 10/1/25.
//

import SwiftUI

struct UserInfo: Identifiable, Codable {
    let id: UUID
    var name: String
    var breed: String
    var age: Double
    var medication: String
    var duration: String
}

struct MedicationCheck: View {
    @State private var users: [UserInfo] = []
    
    @State private var newName = ""
    @State private var newBreed = ""
    @State private var newAge = 0.0
    @State private var newMedication = ""
    @State private var newDuration = ""
    
    // For editing
    @State private var editingUser: UserInfo? = nil

    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()
    
    var body: some View {
        VStack {
            // ==========================
            // ADD NEW USER
            // ==========================
            Text("Medications")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text("Check and Update your Pet's Medication")
                .font(.title2)
            
            HStack {
                TextField("Name", text: $newName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Breed", text: $newBreed)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Age", value: $newAge, formatter: numberFormatter)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            TextField("Medication Name", text: $newMedication)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Duration", text: $newDuration)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("+ Add Pet") {
                handleUser(action: "add", user: nil)
            }
            .buttonStyle(.borderedProminent)
            .font(.title3)
            .padding(.top, 10)
            
            Divider()
                .padding(.vertical)
            
            // ==========================
            // DISPLAY EXISTING USERS
            // ==========================
            ScrollView {
                ForEach(users) { user in
                    GroupBox {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Pet Information")
                                .font(.headline)
                            
                            Text("Name: \(user.name)")
                            Text("Breed: \(user.breed)")
                            Text("Age: \(user.age, specifier: "%.0f")")
                            Text("Medication: \(user.medication)")
                            Text("Duration: \(user.duration)")
                            
                            HStack {
                                Button("Edit") {
                                    editingUser = user
                                }
                                .buttonStyle(.bordered)
                                
                                Button("Delete", role: .destructive) {
                                    handleUser(action: "delete", user: user)
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding(.top, 6)
                        }
                        .padding(.vertical, 5)
                    } label: {
                        Label("Animal Details", systemImage: "pawprint.fill")
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding()
        .onAppear {
            loadUsers()
        }
        // ✅ Proper sheet presentation with both save & cancel actions
        .sheet(item: $editingUser) { userToEdit in
            EditUserView(user: userToEdit) { updatedUser in
                handleUser(action: "update", user: updatedUser)
                editingUser = nil
            } onCancel: {
                editingUser = nil
            }
        }
    }
    
    // =============================
    //  UNIFIED FUNCTION
    // =============================
    func handleUser(action: String, user: UserInfo?) {
        switch action {
        case "add":
            guard !newName.isEmpty,
                  !newBreed.isEmpty,
                  !newMedication.isEmpty,
                  !newDuration.isEmpty,
                  newAge > 0 else { return }
            
            let newUser = UserInfo(
                id: UUID(),
                name: newName,
                breed: newBreed,
                age: newAge,
                medication: newMedication,
                duration: newDuration
            )
            users.append(newUser)
            saveUsers()
            
            // Clear fields
            newName = ""
            newBreed = ""
            newAge = 0.0
            newMedication = ""
            newDuration = ""
            
        case "update":
            guard let user = user,
                  let index = users.firstIndex(where: { $0.id == user.id }) else { return }
            users[index] = user
            saveUsers()
            
        case "delete":
            guard let user = user else { return }
            users.removeAll { $0.id == user.id }
            saveUsers()
            
        default:
            break
        }
    }
    
    // =============================
    //  SAVE & LOAD
    // =============================
    func saveUsers() {
        if let encoded = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(encoded, forKey: "savedUsers")
        }
    }

    func loadUsers() {
        if let data = UserDefaults.standard.data(forKey: "savedUsers"),
           let decoded = try? JSONDecoder().decode([UserInfo].self, from: data) {
            users = decoded
        }
    }
}

// =============================
// EDIT SHEET VIEW
// =============================
struct EditUserView: View {
    @State var user: UserInfo
    var onSave: (UserInfo) -> Void
    var onCancel: () -> Void
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Pet Info")) {
                    TextField("Name", text: $user.name)
                    TextField("Breed", text: $user.breed)
                    TextField("Age", value: $user.age, formatter: numberFormatter)
                    TextField("Medication", text: $user.medication)
                    TextField("Duration", text: $user.duration)
                }
            }
            .navigationTitle("Edit Pet")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(user)
                    }
                }
            }
        }
    }
}

#Preview {
    MedicationCheck()
}
