import SwiftUI
import Charts

struct WeightEntry: Identifiable, Codable {    
    let id: UUID
    let petID: UUID
    var date: Date
    var weight: Double
    var notes: String
}

struct WeightTracker: View {
    @State private var entries: [WeightEntry] = []
    @State private var showingAddEntry = false
    @AppStorage("selectedPetId") private var selectedPetId: String = ""
    @AppStorage("savedPets") private var savedPetsData: Data = Data()
    @State private var selectedPet: Pet?
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Pet Weight Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                if !entries.isEmpty {
                    Chart(entries) { entry in
                        LineMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", entry.weight)
                        )
                        .interpolationMethod(.catmullRom)
                        .symbol(.circle)
                        .foregroundStyle(.orange)
                    }
                    .frame(height: 220)
                    .padding(.horizontal)
                }
                
                if entries.isEmpty {
                    Text("No progress recorded yet.\nTap + to add your first entry!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    List(entries) { entry in
                        VStack(alignment: .leading) {
                            Text("📅 \(entry.date.formatted(date: .abbreviated, time: .omitted))")
                                .font(.headline)
                            Text("Weight: \(entry.weight, specifier: "%.1f") lbs")
                            if !entry.notes.isEmpty {
                                Text("Notes: \(entry.notes)")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(4)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddEntry = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddWeightEntryView(selectedPet: $selectedPet) { newEntry in
                    entries.append(newEntry)
                    saveEntries()
                }
            }
            .onAppear() {
                loadSelectedPet()
                loadEntries()
            }
            .onChange(of: selectedPetId) {
                loadSelectedPet()
                loadEntries()
            }
        }
    }
    
    func keyForPet() -> String {
        selectedPet.map { "weightEntries_\($0.id.uuidString)"} ?? ""
    }
    func saveEntries() {
        guard !keyForPet().isEmpty else { return }
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: keyForPet())
        }
    }
    func loadEntries() {
        guard !keyForPet().isEmpty else { return }
        if let data = UserDefaults.standard.data(forKey: keyForPet()),
           let decoded = try? JSONDecoder().decode([WeightEntry].self, from: data) {
            entries = decoded
        } else {
            entries = []
        }
    }
    func loadSelectedPet() {
        if let decoded = try? JSONDecoder().decode([Pet].self, from: savedPetsData) {
            selectedPet = decoded.first {$0.id.uuidString == selectedPetId}
        }
    }
}

struct AddWeightEntryView: View {
    @Environment(\.dismiss) var dismiss
    //@Environment(\.selectedPet) var selectedPet
    @Binding var selectedPet: Pet?
    let onSave: (WeightEntry) -> Void
    @State private var weight = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Weight (lb)", text: $weight)
                    .keyboardType(.decimalPad)
                TextField("Notes", text: $notes)
            }
            .navigationTitle("Add Progress")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let pet = selectedPet else {return}
                        if let w = Double(weight) {
                            let entry = WeightEntry(
                                id: UUID(),
                                petID: pet.id,
                                date: Date(),
                                weight: w,
                                notes: notes
                            )
                            onSave(entry)
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
#Preview {
    WeightTracker()
}
