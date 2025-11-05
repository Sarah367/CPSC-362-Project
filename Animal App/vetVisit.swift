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
                        ForEach(tasksByDate[dateKey] ?? [], id: \.self) { task in
                            Text(task)
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
        .onAppear(perform: loadTasks) // load when the view appears
    }
    
    // MARK: - Functions
    
    func addTask(for dateKey: String) {
        let trimmedTask = newTask.trimmingCharacters(in: .whitespaces)
        guard !trimmedTask.isEmpty else { return }

        if tasksByDate[dateKey] != nil {
            tasksByDate[dateKey]?.append(trimmedTask)
        } else {
            tasksByDate[dateKey] = [trimmedTask]
        }

        saveTasks()
        newTask = "" // clear input
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // only store the day
        return formatter.string(from: date)
    }
    
    func saveTasks() {
        if let data = try? JSONEncoder().encode(tasksByDate) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }
    
    func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode([String: [String]].self, from: data) {
            tasksByDate = decoded
        }
    }
}

#Preview {
    VetVisit()
}
