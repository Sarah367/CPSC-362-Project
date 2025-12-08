//
//  Reminders.swift
//  Animal App
//
//  Created by Samuel Z on 10/1/25.
//

import SwiftUI

struct Appointment: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var date: Date
    
    init(id: UUID = UUID(), text: String, date: Date) {
        self.id = id
        self.text = text
        self.date = date
    }
}

struct Reminders: View {
    @State private var appointments: [Appointment] = []
    @State private var completedAppointments: [Appointment] = []
    
    // UserDefaults keys
    private let appointmentsKey = "appointments"
    private let completedAppointmentsKey = "completedAppointments"
    
    var body: some View {
        VStack {
            Text("Reminders")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Upcoming Appointments")
                .font(.title)
                .padding(.top)
            
            if appointments.isEmpty {
                Text("No upcoming appointments. Tap below to add one.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(appointments.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Enter appointment...", text: $appointments[index].text)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        DatePicker(
                            "Select Date & Time",
                            selection: $appointments[index].date,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                        
                        HStack {
                            Spacer()
                            
                            // ✅ Complete this one appointment
                            Button(action: {
                                let completed = appointments[index]
                                if !completed.text.isEmpty {
                                    completedAppointments.append(completed)
                                    appointments.remove(at: index)
                                    saveAppointments()
                                }
                            }) {
                                Label("Complete", systemImage: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                            
                            // ❌ Remove this appointment
                            Button(action: {
                                appointments.remove(at: index)
                                saveAppointments()
                            }) {
                                Label("Remove", systemImage: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            
            // Add new appointment
            Button("Add Appointment Box") {
                appointments.append(Appointment(text: "", date: Date()))
                saveAppointments()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
            
            Divider()
                .padding(.vertical)
            
            Text("Past Appointments")
                .font(.title)
            
            if completedAppointments.isEmpty {
                Text("No completed appointments yet.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List(completedAppointments) { appointment in
                    VStack(alignment: .leading) {
                        Text(appointment.text)
                            .font(.headline)
                        Text(appointment.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 300)
            }
            
            Spacer()
        }
        .padding()
        .onAppear(perform: loadAppointments)
    }
    
    // MARK: - Saving & Loading
    
    func saveAppointments() {
        let encoder = JSONEncoder()
        if let encodedAppointments = try? encoder.encode(appointments) {
            UserDefaults.standard.set(encodedAppointments, forKey: appointmentsKey)
        }
        if let encodedCompleted = try? encoder.encode(completedAppointments) {
            UserDefaults.standard.set(encodedCompleted, forKey: completedAppointmentsKey)
        }
    }
    
    func loadAppointments() {
        let decoder = JSONDecoder()
        if let savedAppointments = UserDefaults.standard.data(forKey: appointmentsKey),
           let decodedAppointments = try? decoder.decode([Appointment].self, from: savedAppointments) {
            appointments = decodedAppointments
        }
        if let savedCompleted = UserDefaults.standard.data(forKey: completedAppointmentsKey),
           let decodedCompleted = try? decoder.decode([Appointment].self, from: savedCompleted) {
            completedAppointments = decodedCompleted
        }
    }
}

#Preview {
    Reminders()
}
