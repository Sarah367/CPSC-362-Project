# 🐾 FurEver Care - IOS Mobile Application
FurEver Care is an iOS app designed to assist pet owners in monitoring and organizing every facet of their pet’s care. Users can set up comprehensive profiles for their pets, keep a gallery for photos, record health details like veterinary visits, medications, and vaccinations, and monitor weight fluctuations over time. Additionally, the app features a reminder system for upcoming health-related tasks and appointments.

## Four Interactive Feature Cards
### **🐶 Pet Profiles**
- Allows users to create, store, and manage pet profiles.
- Users can add new pet profiles by entering the name, breed, age, and an optional pet profile photo.
- Pet profiles can be updated and deleted.
- There is a “pet selection system”, meaning that the user can select which pet they want the app to focus on; this makes the app dynamic since everything is being updated based on the selected pet.

### **📸 Gallery Tab**
- Allows users to upload photos of their pets as well as add captions to the photos.
- User can select/toggle which pet's gallery to view.
- Images are displayed in a responsive grid layout using LazyVGrid
- User can click on a photo to view it in larger detail. The caption as well as the timestamp (when the photo was added) is displayed for the user in a text-friendly format.
- Photos can be deleted by clicking on them and pressing the “Delete” button.

### **❤️ Health Tab**
- There are 4 main modules within the health tab:
  - *Vet Visit:* Users can plan or check for appointments in this module; users can simply click on a date in the calendar and add their pet’s appointment. Appointments can be created, updated, or deleted.
  - *Medications:* User can add their pet’s medications, along with the duration of when to take the medication. The user has the ability to edit or delete the medication card.
  - *Vaccinations:* User can add vaccines that their pet has taken, as well as set the next due date (when the pet must take their vaccine again). Vaccine information can be edited, and the vaccine card can be deleted.
  - *Weight Tracker:* User can track their pet’s weight; this module will automatically create a chart that displays any fluctuations in weight.

### **🔔 Reminders Tab**
- Users are given the ability to add, create, and delete reminders. 
- These reminders can be scheduled on a specific time and date, along with being repeated on a certain frequency (once, daily, weekly, monthly, yearly).
- Users can see a complete list of their scheduled reminders.
- The interface itself includes a polished “Add Reminder” sheet with form fields and validation for smooth user input!

## 🛠️ Technologies Used
- **SwiftUI**
- **Charts Framework**
- **UserNotifications**
- **UserDefaults for local storage**
- **MVVM-style structuring (lightweight)**

## 📂 Project Structure
```md
├── Models/
│   ├── Pet.swift
|   ├── PhotoItem.swift
│   ├── MedicationItem.swift
│   ├── WeightEntry.swift
|   ├── ScheduledNotifications.swift
│   ├── VaccinationRecord.swift
│
├── Views/
|   ├── HomeView.swift
|   ├── PetsView.swift
|   ├── GalleryView.swift
|   ├── HealthView.swift
|   ├── NotificationsView.swift
|   ├── EnhancedNotificationRow.swift
|   ├── PermissionView.swift
|   ├── EmptyNotifications.swift
|   ├── EditPetView.swift
|
|   ├──LoginView.swift
|   ├──SignUpView.swift
│
|   ├── CustomTabBar.swift
|   ├── TabBarButton.swift
|
|   ├── FeatureCardWithPhoto.swift
|   ├── PhotoGridItem.swift
|   ├── PhotoDetailView.swift
|   ├── CaptionInputView.swift
|
|   ├── EditPetView.swift
|   ├── PetDetailView.swift
|   ├── EmptyPetsView.swift
|   ├── PetsListView.swift
|   ├── PetProfileCard.swift
│
|   ├── HealthButton.swift
│
|   ├── MedicationCheck.swift
|   ├── EditMedicationView.swift
│
|   ├──  VaccinationsView.swift
|   ├──  AddEditVaccination.swift
|   ├──  VaccinationRow.swift
|   ├──  DueSoonRow.swift
|   ├──  EmptyVaccinations.swift
|
|   ├── VetVisit.swift
|   ├── WeightTracker.swift 
│   └── AddWeightEntryView.swift
│
└── Resources/
    ├── Assets.xcassets
    └── Preview Content/
