//
//  medicationCheck.swift
//  Animal App
//
//  Created by Samuel Z on 10/1/25.
//

import SwiftUI

//struct UserInfo: Identifiable, Codable {
//    let id: UUID
//    var name: String
//    var breed: String
//    var age: Double
//    var medication: String
//    var duration: String
//}

struct MedicationItem: Identifiable, Codable {
    let id: UUID
    let petID: UUID
    var medication: String
    var duration: String
}

struct MedicationCheck: View {
    @State private var medications: [MedicationItem] = []
    
    @State private var newMedication = ""
    @State private var newDuration = ""
    
    // For editing
    @State private var editingMed: MedicationItem? = nil
    @AppStorage("selectedPetId") private var selectedPetId: String = ""
    @AppStorage("savedPets") private var savedPetsData: Data = Data()
    @State private var selectedPet: Pet?

    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()
    
    var body: some View {
        VStack {
            Text("Medications")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text("Check and Update your Pet's Medication")
                .font(.title2)
            
            if selectedPet == nil {
                Text("Please select a pet from the Pets tab.")
                    .foregroundColor(.red)
                    .padding()
            }
            
            TextField("Medication Name", text: $newMedication)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Duration", text: $newDuration)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("+ Add Medication") {
                addMedication()
            }
            .buttonStyle(.borderedProminent)
            .font(.title3)
            .padding(.top, 10)
            
            Divider()
                .padding(.vertical)
            
            ScrollView {
                ForEach(medications) { med in
                    GroupBox {
                        VStack(alignment: .leading, spacing: 6) {
                            
                            Text("Medication: \(med.medication)")
                            Text("Duration: \(med.duration)")
                            
                            HStack {
                                Button("Edit") {
                                    editingMed = med
                                }
                                Button("Delete", role: .destructive) {
                                    deleteMedication(med)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .padding(.horizontal)
                }
            }
//            Button("RESET MEDS") {
//                UserDefaults.standard.removeObject(forKey: "medications")
//                medications = []
//            }
//            .buttonStyle(.bordered)
//            .tint(.red)
//            .padding(.top, 10)
        }
        .padding()
        .onAppear {
            loadSelectedPet()
            loadMedications()
        }
        .onChange (of: selectedPetId) { _ in
            loadSelectedPet()
            loadMedications()
        }
        .sheet(item: $editingMed) { med in
            EditMedicationView(med: med) { updated in
                updateMedication(updated)
            }
        }
    }
    
    func addMedication() {
        guard let pet = selectedPet else {return}
        
        let item = MedicationItem(
            id: UUID(),
            petID: pet.id,
            medication: newMedication,
            duration: newDuration
        )
        medications.append(item)
        saveMedications()

        newMedication = ""
        newDuration = ""
    }
    
    func updateMedication(_ med: MedicationItem) {
        if let index = medications.firstIndex(where: {$0.id == med.id}) {
            medications[index] = med
            saveMedications()
        }
    }

    func deleteMedication(_ med: MedicationItem) {
        medications.removeAll {$0.id == med.id}
        saveMedications()
    }
    
    func loadMedications() {
        guard let data = UserDefaults.standard.data(forKey: "medications"),
              let decoded = try? JSONDecoder().decode([MedicationItem].self, from: data)
        else {return}
        guard let pet = selectedPet else {
            medications = []
            return
        }
        medications = decoded.filter {$0.petID == pet.id}
    }
    
    func saveMedications() {
        if let encoded = try? JSONEncoder().encode(medications) { UserDefaults.standard.set(encoded, forKey:"medications") }
    }
    
    func loadSelectedPet() {
        if let decoded = try? JSONDecoder().decode([Pet].self, from:savedPetsData) {
            selectedPet=decoded.first {$0.id.uuidString == selectedPetId}
        }
    }
}

struct EditMedicationView: View {
    @Environment(\.dismiss) private var dismiss
    @State var med: MedicationItem
    var onSave: (MedicationItem) -> Void
    
    private let numberFormatter = NumberFormatter()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Medication", text: $med.medication)
                TextField("Duration", text: $med.duration)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(med)
                        dismiss()
                    }
                    
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {dismiss()}
                }
            }
        }
    }
}

#Preview {
    MedicationCheck()
}
