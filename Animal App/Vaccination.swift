import SwiftUI

struct VaccinationRecord: Identifiable, Codable {
    let id: UUID
    var vaccineName: String
    var dateAdministered: Date
    var nextDueDate: Date?
    var administeredBy: String
    var notes: String
}

struct VaccinationsView: View {
    @State private var vaccinationRecords: [VaccinationRecord] = []
    @State private var showingAddVaccination = false
    @State private var showingEditVaccination: VaccinationRecord? = nil
    
    let commonVaccines = [
        "Rabies", "DHPP (Distemper)", "Bordetella (Kennel Cough)",
        "Leptospirosis", "Lyme Disease", "Canine Influenza",
        "Parvovirus", "Coronavirus"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                VStack {
                    Text("Vaccination Records")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Keep track of your pet's vaccinations")
                        .foregroundColor(.secondary)
                    
                    if vaccinationRecords.isEmpty {
                        EmptyVaccinationsView()
                    } else {
                        VaccinationListView
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingAddVaccination = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                                .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 25)
                        .padding(.bottom, 25)
                    }
                }
            )
            .sheet(isPresented: $showingAddVaccination) {
                AddEditVaccinationView(onSave: addVaccination)
            }
            .sheet(item: $showingEditVaccination) { record in
                AddEditVaccinationView(vaccinationRecord: record, onSave: updateVaccination)
            }
            .onAppear {
                loadVaccinationRecords()
            }
        }
    }
    
    private var VaccinationListView: some View {
        ScrollView {
            VStack(spacing: 16) {
                let upcomingVaccinations = vaccinationRecords.filter { record in
                    guard let dueDate = record.nextDueDate else { return false }
                    
                    return dueDate > Date() && dueDate < Date().addingTimeInterval(30*24*3600)
                }
                
                if !upcomingVaccinations.isEmpty {
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.title3)
                                Text("Vaccinations Due Soon")
                                    .font(.headline)
                                Spacer()
                                Text("\(upcomingVaccinations.count)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Color.orange)
                                    .cornerRadius(8)
                            }
                            
                            ForEach(upcomingVaccinations) { record in
                                DueSoonRow(record: record)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                }
                
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "syringe.fill")
                                .foregroundColor(.orange)
                                .font(.title3)
                            Text("Vaccination History")
                                .font(.headline)
                            Spacer()
                            Text("\(vaccinationRecords.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(6)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(8)
                        }
                        LazyVStack {
                            ForEach(vaccinationRecords.sorted(by: { $0.dateAdministered > $1.dateAdministered})) { record in
                                VaccinationRow(
                                    record: record,
                                    onEdit: { showingEditVaccination = record},
                                    onDelete: deleteVaccination
                                )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    func addVaccination(_ record: VaccinationRecord) {
        vaccinationRecords.append(record)
        saveVaccinationRecords()
        showingAddVaccination = false
    }
    func updateVaccination(_ updatedRecord: VaccinationRecord) {
        if let index = vaccinationRecords.firstIndex(where: {$0.id == updatedRecord.id}) {
            vaccinationRecords[index] = updatedRecord
            saveVaccinationRecords()
        }
        showingEditVaccination = nil
    }
    func deleteVaccination(_ record: VaccinationRecord) {
        vaccinationRecords.removeAll { $0.id == record.id }
        saveVaccinationRecords()
    }
    func saveVaccinationRecords() {
        if let encoded = try? JSONEncoder().encode(vaccinationRecords) {
            UserDefaults.standard.set(encoded, forKey: "vaccinationRecords")
        }
    }
    func loadVaccinationRecords() {
        if let data = UserDefaults.standard.data(forKey: "vaccinationRecords"),
           let decoded = try? JSONDecoder().decode([VaccinationRecord].self, from: data) {
            vaccinationRecords = decoded
        }
    }
}

struct AddEditVaccinationView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (VaccinationRecord) -> Void
    
    @State private var vaccineName: String
    @State private var dateAdministered: Date
    @State private var nextDueDate: Date?
    @State private var administeredBy: String
    @State private var notes: String
    @State private var showNextDueDate = false
    
    let commonVaccines = [
        "Rabies", "DHPP (Distemper)", "Bordetella (Kennel Cough)",
        "Leptospirosis", "Lyme Disease", "Canine Influenza",
        "Parvovirus", "Coronavirus"
    ]
    init(vaccinationRecord: VaccinationRecord? = nil, onSave: @escaping (VaccinationRecord) -> Void) {
        self.onSave = onSave
        
        if let record = vaccinationRecord {
            _vaccineName = State(initialValue: record.vaccineName)
            _dateAdministered = State(initialValue: record.dateAdministered)
            _nextDueDate = State(initialValue: record.nextDueDate)
            _administeredBy = State(initialValue: record.administeredBy)
            _notes = State(initialValue: record.notes)
            _showNextDueDate = State(initialValue: record.nextDueDate != nil)
        } else {
            _vaccineName = State(initialValue: "")
            _dateAdministered = State(initialValue: Date())
            _nextDueDate = State(initialValue: Date().addingTimeInterval(365*24*3600))
            _administeredBy = State(initialValue: "")
            _notes = State(initialValue: "")
            _showNextDueDate = State(initialValue: true)
        }
    }
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Vaccine Information")) {
                    Picker("Vaccine", selection: $vaccineName) {
                        Text("Select a vaccine").tag("")
                        ForEach(commonVaccines, id: \.self) { vaccine in
                            Text(vaccine).tag(vaccine)
                        }
                    }
                    TextField("Or enter custom vaccine name", text: $vaccineName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Section(header: Text("Administration Details")) {
                    DatePicker("Date Administered", selection: $dateAdministered, displayedComponents: .date)
                    TextField("Administered By (Vet/Clinic)", text: $administeredBy)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Section(header: Text("Next Due Date")) {
                    Toggle("Set Next Due Date", isOn: $showNextDueDate.animation())
                    
                    if showNextDueDate {
                        DatePicker("Next Due Date", selection: Binding(
                            get: { nextDueDate ?? Date().addingTimeInterval(365*24*3600)},
                            set: { nextDueDate = $0 }
                        ), displayedComponents: .date)
                    }
                }
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .navigationTitle(vaccineName.isEmpty ? "Add Vaccination" : vaccineName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let record = VaccinationRecord(
                            id: UUID(),
                            vaccineName: vaccineName,
                            dateAdministered: dateAdministered,
                            nextDueDate: showNextDueDate ? nextDueDate : nil,
                            administeredBy: administeredBy,
                            notes: notes
                        )
                        onSave(record)
                        dismiss()
                    }
                    .disabled(vaccineName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

struct VaccinationRow: View {
    let record: VaccinationRecord
    let onEdit: () -> Void
    let onDelete: (VaccinationRecord) -> Void
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var isDueSoon: Bool {
        guard let dueDate = record.nextDueDate else { return false }
        return dueDate > Date() && dueDate < Date().addingTimeInterval(30 * 24 * 3600)
    }
    
    var isOverdue: Bool {
        guard let dueDate = record.nextDueDate else { return false }
        return dueDate < Date()
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(record.vaccineName)
                    .font(.headline)
                    .foregroundColor(isOverdue ? .red : .primary)
                
                Text("Administered: \(dateFormatter.string(from: record.dateAdministered))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if let dueDate = record.nextDueDate {
                    HStack {
                        Image(systemName: isOverdue ? "exclamationmark.circle.fill" : "calendar")
                            .font(.caption2)
                            .foregroundColor(isOverdue ? .red : (isDueSoon ? .orange : .green))
                        Text("Due: \(dateFormatter.string(from: dueDate))")
                            .font(.caption)
                            .foregroundColor(isOverdue ? .red : (isDueSoon ? .orange : .secondary))
                    }
                }
                if !record.administeredBy.isEmpty {
                    Text("By: \(record.administeredBy)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
            }
            Spacer()
            
            VStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                        .font(.caption)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
                Button(action: {onDelete(record)}) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}

struct DueSoonRow: View {
    let record: VaccinationRecord
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var daysUntilDue: Int {
        guard let dueDate = record.nextDueDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
    }
    
    var body: some View {
        HStack {
            Image(systemName: "bell.fill")
                .foregroundColor(.orange)
                .font(.caption)
            VStack(alignment: .leading, spacing: 2) {
                Text(record.vaccineName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if let dueDate = record.nextDueDate {
                    Text("Due in \(daysUntilDue) days (\(dateFormatter.string(from: dueDate)))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct EmptyVaccinationsView: View {
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Image(systemName: "syringe.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            VStack(spacing: 12) {
                Text("No Vaccination Records")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Text("Tap the + button to add your pet's first vaccination record!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            Spacer()
        }
        .padding(40)
    }
}

#Preview {
    VaccinationsView()
}
