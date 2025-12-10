import SwiftUI
import UserNotifications

struct ScheduledNotifications: Identifiable, Codable {
    let id: String
    let title: String
    let date: Date
    let recurrence: Recurrence
}

enum Recurrence: String, CaseIterable, Codable {
    case once = "Once"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}

struct NotificationsView: View {
    @State private var scheduledNotifications: [ScheduledNotifications] = []
    @State private var notificationTitle = ""
    @State private var selectedDate = Date()
    @State private var selectedRecurrence: Recurrence = .daily
    @State private var permissionGranted = false
    @State private var showingPermissionAlert = false
    @StateObject private var notificationDelegate = NotificationDelegate()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                VStack {
                    Text("Pet Reminders")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Never forget your pet care tasks!")
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
                UNUserNotificationCenter.current().delegate = notificationDelegate
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
                        Text("Create New Reminder")
                            .font(.headline)
                        TextField("Reminder title...", text: $notificationTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        DatePicker("Date & Time", selection: $selectedDate, in: Date()...)
                            .datePickerStyle(CompactDatePickerStyle())
                        
                        HStack {
                            Text("Repeat")
                            Spacer()
                            Picker("Recurrence", selection: $selectedRecurrence) {
                                ForEach(Recurrence.allCases, id: \.self) { recurrence in
                                    Text(recurrence.rawValue).tag(recurrence)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
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
                                    EnhancedNotificationRow(
                                        notification: notification,
                                        onDelete: removeNotification
                                    )
                                    
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
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
        
        let identifier = UUID().uuidString
        let trigger = createTrigger(for: selectedDate, recurrence: selectedRecurrence)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(selectedDate)")
                DispatchQueue.main.async {
                    let newNotification = ScheduledNotifications(
                        id: identifier,
                        title: trimmedTitle,
                        date: selectedDate,
                        recurrence: selectedRecurrence
                    )
                    scheduledNotifications.append(newNotification)
                    saveNotifications()
                    notificationTitle = ""
                    selectedDate = Date().addingTimeInterval(3600) // defaults to 1 hour from current time.
                    selectedRecurrence = .daily
                }
            }
        }
    }
    
    private func createTrigger(for date: Date, recurrence: Recurrence) -> UNNotificationTrigger? {
        let calendar = Calendar.current
        let components: DateComponents
        
        switch recurrence {
        case .once:
            // one-time notifs use an exact date
            if date <= Date() {
                // if the date is in the past, make it 5 seconds from now so that we can test to see if the notifs are working.
                return UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            }
            components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
        case .daily:
            components = calendar.dateComponents([.hour, .minute], from: date)
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
        case .weekly:
            components = calendar.dateComponents([.weekday, .hour, .minute], from: date)
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
        case .monthly:
            components = calendar.dateComponents([.day, .hour, .minute], from: date)
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
        case .yearly:
            components = calendar.dateComponents([.month, .day, .hour, .minute], from: date)
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        }
    }

    
    func removeNotification(_ notification: ScheduledNotifications) {
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
           let decoded = try? JSONDecoder().decode([ScheduledNotifications].self, from: data) {
            scheduledNotifications = decoded
        }
    }
}

struct EnhancedNotificationRow: View {
    let notification: ScheduledNotifications
    let onDelete: (ScheduledNotifications) -> Void
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    private func getOrdinalSuffix(for number: Int) -> String {
        switch number {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
    
    private func recurrenceText(for recurrence: Recurrence, date: Date) -> String {
        switch recurrence {
        case .once:
            return "Once on \(dateFormatter.string(from: date))"
        case .daily:
            return "Daily at \(timeString(from: date))"
        case .weekly:
            let weekday = Calendar.current.component(.weekday, from: date)
            let weekdayName = Calendar.current.weekdaySymbols[weekday - 1]
            return "Weekly on \(weekdayName)s at \(timeString(from: date))"
        case .monthly:
            let day = Calendar.current.component(.day, from: date)
            let ordinal = getOrdinalSuffix(for: day)
            return "Monthly on the \(day)\(ordinal) at \(timeString(from: date))"
        case .yearly:
            let month = Calendar.current.component(.month, from: date)
            let day = Calendar.current.component(.day, from: date)
            let monthName = Calendar.current.monthSymbols[month - 1]
            let ordinal = getOrdinalSuffix(for: day)
            return "Yearly on \(monthName) \(day)\(ordinal) at \(timeString(from: date))"
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.body)
                    .fontWeight(.medium)
                Text(recurrenceText(for: notification.recurrence, date: notification.date))
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
