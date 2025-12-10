//
//  vetVisit.swift
//  Animal App
//
//  Created by Samuel Z on 9/29/25.
//

import SwiftUI

struct VetVisit: View {
    @State private var selectedDate: Date? = nil
    @State private var newTask: String = ""
    @State private var tasksByDate: [String: [String]] = [:] // Use String for easy storage (formatted date)
    @State private var taskBeingEdited: String = ""
    @State private var editingIndex: Int? = nil
    @State private var showEditSheet = false
    @AppStorage("selectedPetId") private var selectedPetId: String = ""
    @AppStorage("savedPets") private var savedPetsData: Data = Data()
    @State private var selectedPet: Pet?
    
    private let defaultsKey = "tasksByDate" // key to save in UserDefaults
    
    var body: some View {
        Text("Vet Appointments")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding()
        
        Text("Plan or Check for Appointments Below")
            .font(.title2)
        
        ScrollView {
            DatePicker("Select a Date", selection: Binding(
                get: { selectedDate ?? Date() },
                set: { newDate in selectedDate = newDate }
            ), displayedComponents: [.date])
            .datePickerStyle(.graphical)
            .padding()
            
            if let date = selectedDate {
                let dateKey = formatDate(date)
                
                Text("You selected: \(date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.headline)
                    .padding(.top)
                
                HStack {
                    TextField("Enter a new task", text: $newTask)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: {
                        addTask(for: dateKey)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .disabled(newTask.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal)
                
                List {
                    Section(header: Text("Scheduled Tasks")) {
                        ForEach(Array((tasksByDate[dateKey] ?? []).enumerated()), id: \.offset) { index, task in
                            Button(action: {
                                taskBeingEdited = task
                                editingIndex = index
                                showEditSheet = true
                            }) {
                                Text(task)
                                    .foregroundColor(.primary)
                            }
                        }
                        .onDelete { indexSet in
                            deleteTask(at: indexSet, for: dateKey)
                        }
                    }
                }
                .frame(height: 300)
            } else {
                Text("Please select a date above.")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .onAppear {
            loadSelectedPet()
            loadVetVisits()
            if selectedDate == nil {
                selectedDate = Date()
            }
        }
        .onChange(of: selectedPetId) {
            loadSelectedPet()
            loadVetVisits()
        }
        .sheet(isPresented: $showEditSheet) {
            NavigationView {
                Form {
                    TextField("Edit Task", text: $taskBeingEdited)
                }
                .navigationTitle("Edit Task")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            if let idx = editingIndex,
                               let date = selectedDate {
                                let key = formatDate(date)
                                tasksByDate[key]?[idx] = taskBeingEdited
                                saveVetVisits()
                            }
                            showEditSheet = false
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showEditSheet = false
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Functions
    func loadSelectedPet() {
        if let decoded = try? JSONDecoder().decode([Pet].self, from: savedPetsData) {
            selectedPet = decoded.first { $0.id.uuidString == selectedPetId }
        }
    }
    
    func addTask(for dateKey: String) {
        let trimmedTask = newTask.trimmingCharacters(in: .whitespaces)
        guard !trimmedTask.isEmpty else { return }

        if tasksByDate[dateKey] != nil {
            tasksByDate[dateKey]?.append(trimmedTask)
        } else {
            tasksByDate[dateKey] = [trimmedTask]
        }

        saveVetVisits()
        newTask = "" // clear input
    }
    
    func deleteTask(at offsets: IndexSet, for dateKey: String) {
        tasksByDate[dateKey]?.remove(atOffsets: offsets)
        saveVetVisits()
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // only store the day
        return formatter.string(from: date)
    }
    
//    func saveTasks() {
//        if let data = try? JSONEncoder().encode(tasksByDate) {
//            UserDefaults.standard.set(data, forKey: defaultsKey)
//        }
//    }
    
    func loadVetVisits() {
        guard let pet = selectedPet else {
            tasksByDate = [:]
            return
        }
        let key = "vetVisits_\(pet.id.uuidString)"
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([String: [String]].self, from: data) {
            tasksByDate = decoded
        } else {
            tasksByDate = [:]
        }
    }
    
    
    func saveVetVisits() {
        guard let pet = selectedPet else {return}
        
        let key = "vetVisits_\(pet.id.uuidString)"
        if let encoded = try? JSONEncoder().encode(tasksByDate) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}

#Preview {
    VetVisit()
}
