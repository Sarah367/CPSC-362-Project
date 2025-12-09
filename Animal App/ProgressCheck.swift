import SwiftUI
import Charts

struct ProgressEntry: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var weight: Double
    var notes: String
}

struct ProgressCheck: View {
    @State private var entries: [ProgressEntry] = []
    @State private var showingAddEntry = false
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
                AddProgressEntryView { newEntry in
                    entries.append(newEntry)
                }
            }
        }
    }
}

struct AddProgressEntryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var weight = ""
    @State private var notes = ""
    
    let onSave: (ProgressEntry) -> Void
    
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
                        if let w = Double(weight) {
                            onSave(ProgressEntry(date: Date(), weight: w, notes: notes))
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
    ProgressCheck()
}
