import SwiftUI
import UserNotifications

struct ScheduledNotifications: Identifiable, Codable {
    let id: String
    let title: String
    let time: Date
}

struct NotificationsView: View {
    @State private var scheduledNotifications: [ScheduledNotification] = []
    @State private var notificationTitle = ""
    @State private var selectedDate = Date()
    @State private var permissionGranted = false
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                VStack {
                    Text("Pet Reminders")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Never forget your pet's care tasks")
                        .foregroundColor(.secondary)
                    
                    if !permissionGranted {
                        PermissionView(
                            onEnable: requestPermission,
                            showingAlert: $showingPermissionAlert
                        )
                    } else {
                        NotificationSchedulerView
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                checkPermission()
                loadScheduledNotifications()
            }
            .alert("Notification Permission Required", isPresented: $showingPermissionAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Please enable notifications in Settings to create custom reminders for your pet!")
            }
        }
    }
    
    // Main notification view
    private var NotificationSchedulerView: some View {
        ScrollView {
            VStack(spacing: 25) {
                // new notif card
                GroupBox {
                    VStack(alignment: .leading, spacing: 16) {
                        //                        HStack {
                        //                            Image(systemName: "plus.circle.fill")
                        //                                .foregroundColor(.orange)
                        //                                .font(.title3)
                        //                            Text("Create New Reminder")
                        //                                .font(.headline)
                        //
                        //                            Spacer()
                        //                        }
                        
                        TextField("Reminder title...", text: $notificationTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        DatePicker("Time", selection: $selectedDate, displayedComponents: .hourAndMinute)
                            .datePickerStyle(CompactDatePickerStyle())
                        Button(action: scheduleNotification) {
                            HStack {
                                Image(systemName: "bell.fill")
                                Text("Schedule Reminder")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.orange)
                            .cornerRadius(10)
                        }
                        .disabled(notificationTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                        .opacity(notificationTitle.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
                    }
                    .padding(.vertical, 8)
                }
//                } label: {
//                    Label("New Reminder", systemImage: "plus.circle.fill")
//                }
                
                // scheduled notifs
                if scheduledNotifications.isEmpty {
                    EmptyNotificationsView()
                } else {
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "list.bullet")
                                    .foregroundColor(.orange)
                                    .font(.title3)
                                
                                Text("Scheduled Reminders")
                                    .font(.headline)
                                Spacer()
                                
                                Text("\(scheduledNotifications.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(6)
                                    .background(Color.orange.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            
                            LazyVStack(spacing: 12) {
                                ForEach(scheduledNotifications) { notification in
                                    NotificationRow(
                                        notification: notification,
                                        onDelete: removeNotification
                                    )
                                    
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
//                    label: {
//                        Label("Your Reminders", systemImage: "bell.fill")
//                    }
                }
            }
            .padding()
        }
    }
    
    // notif functions...
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    permissionGranted = true
                } else {
                    showingPermissionAlert = true
                }
            }
        }
    }
    
    func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                permissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleNotification() {
        let trimmedTitle = notificationTitle.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedTitle.isEmpty else { return }
        
        let content = UNMutableNotificationContent()
        content.title = trimmedTitle
        content.body = "Time to care for your pet. 🐶"
        content.sound = .default
        
        // triggered by time (will repeat daily)
        let components = Calendar.current.dateComponents([.hour, .minute], from: selectedDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                DispatchQueue.main.async {
                    let newNotification = ScheduledNotification(
                        id: identifier,
                        title: trimmedTitle,
                        time: selectedDate
                    )
                    scheduledNotifications.append(newNotification)
                    saveNotifications()
                    notificationTitle = ""
                    selectedDate = Date() // reset time to the current time...
                }
            }
        }
    }
    
    func removeNotification(_ notification: ScheduledNotification) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id])
        scheduledNotifications.removeAll { $0.id == notification.id }
        saveNotifications()
    }
    
    func saveNotifications() {
        if let encoded = try? JSONEncoder().encode(scheduledNotifications) {
            UserDefaults.standard.set(encoded, forKey: "scheduledNotifications")
        }
    }
    
    func loadScheduledNotifications() {
        if let data = UserDefaults.standard.data(forKey: "scheduledNotifications"),
           let decoded = try? JSONDecoder().decode([ScheduledNotification].self, from: data) {
            scheduledNotifications = decoded
        }
    }
}

// data model
struct ScheduledNotification: Identifiable, Codable {
    let id: String
    let title: String
    let time: Date
}

// supporting views

struct PermissionView: View {
    let onEnable: () -> Void
    @Binding var showingAlert: Bool
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Image(systemName: "bell.slash.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            VStack(spacing: 12) {
                Text("Enable Reminders")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Get notified about feeding times, medications, vet appointments, and more.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: onEnable) {
                HStack {
                    Image(systemName: "bell.fill")
                    Text("Enable Notifications")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(Color.orange)
                .cornerRadius(12)
            }
            .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
            
            Spacer()
        }
        .padding()
    }
}

struct NotificationRow: View {
    let notification: ScheduledNotification
    let onDelete: (ScheduledNotification) -> Void
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.body)
                    .fontWeight(.medium)
                Text("Daily at \(timeFormatter.string(from: notification.time))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            
            Button(action: { onDelete(notification)}) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}

struct EmptyNotificationsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Reminders Yet")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Text("Create your first reminder above to get started!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
    }
}

#Preview {
    NotificationsView()
}
