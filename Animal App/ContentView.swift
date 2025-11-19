import SwiftUI

struct Pet: Identifiable, Codable {
    var id = UUID()
    var name: String
    var breed: String
    var age: String
    var imageData: Data?
    
    var image: UIImage? {
        get {
            guard let imageData = imageData else { return nil }
            return UIImage(data: imageData)
        }
        set {
            imageData = newValue?.jpegData(compressionQuality: 0.8)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, breed, age, imageData
    }
}

struct PhotoItem: Identifiable, Codable {
    let id: UUID
    var caption: String
    let dateAdded: Date
    var imageData: Data?
    var petId: UUID?
    
    var image: UIImage? {
        guard let imageData = imageData else  { return nil }
        return UIImage(data: imageData)
    }
    
    init(id: UUID = UUID(), image: UIImage, caption: String, dateAdded: Date = Date(), petId: UUID? = nil) {
        self.id = id
        self.caption = caption
        self.dateAdded = dateAdded
        self.petId = petId
        self.imageData = image.jpegData(compressionQuality: 0.8)
    }
}


struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tag(0)
                PetsView(selectedTab: $selectedTab).tag(1)
                GalleryView().tag(2)
                HealthView().tag(3)
                NotificationsView().tag(4)
            }
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }.ignoresSafeArea()
            
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(
                icon: "house.fill",
                label: "Home",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            TabBarButton(
                icon: "pawprint.fill",
                label: "Pets",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            Button(action: {
                selectedTab = 2 // will go to gallery
            }) {
                ZStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 56, height: 56)
                        .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y:4)
                    
                    Image(systemName: "camera.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(y: -8)
            }
            
            TabBarButton(
                icon: "heart.fill",
                label: "Health",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }
            
            TabBarButton(
                icon: "bell.fill",
                label: "Reminders",
                isSelected: selectedTab == 4
            ) {
                selectedTab = 4
            }
            .padding(.horizontal, 8)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(
                Color(.systemBackground)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -2)
            )
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(isSelected ? .orange : .gray)
                
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .orange : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct HomeView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                ScrollView{
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("FurEver Care")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text("Your complete pet care companion")
                                .font(.subheadline)
                                .italic()
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                        
                        // Feature Cards...
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Discover our Awesome Features")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                FeatureCardWithPhoto(
                                    imageName: "dog_profile",
                                    title: "Pet Profiles",
                                    description: "Manage all your pets in one place!",
                                    color: .orange
                                )
                                
                                FeatureCardWithPhoto(
                                    imageName: "dog_vet",
                                    title: "Health Tracking",
                                    description: "Vet visits, medications,  & more!",
                                    color: .red
                                )
                                FeatureCardWithPhoto(
                                    imageName: "dog_camera",
                                    title: "Photo Gallery",
                                    description: "Store precious memories of your furry friend",
                                    color: .purple
                                )
                                FeatureCardWithPhoto(
                                    imageName: "dog_reminder",
                                    title: "Reminders",
                                    description: "Never miss important dates!",
                                    color: .blue
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        //Spacer(minLength: 0)
                        
                        // Sign up / login button at the bottom...
                        VStack(spacing: 12) {
                            Text("Ready to begin your pet care journey?")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Button("Get Started - Manage Your Pets") {
                                selectedTab = 1 // Navigates user to the Pets tab
                            }
                            .buttonStyle(ProminentButtonStyle())
                            
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.orange.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 2)
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationBarHidden(true)
        }
    }
}


struct ProminentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [.orange, .orange.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y:4)
    }
}

struct FeatureCardWithPhoto: View {
    let imageName: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 100)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    Image(systemName: getFeatureIcon())
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(color)
                        .clipShape(Circle())
                        .padding(8),
                    alignment: .topTrailing
                )
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private func getFeatureIcon() -> String {
        switch title {
        case "Pet Profiles": return "pawprint.fill"
        case "Health Tracking": return "heart.fill"
        case "Photo Gallery": return "camera.fill"
        case "Reminders": return "bell.fill"
        default: return "star.fill"
        }
    }
}

struct AuthButtonStyle: ButtonStyle {
    let backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .background(backgroundColor)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
//
//struct LoginView: View {
//    @Environment(\.dismiss) private var dismiss
//    @State private var email = ""
//    @State private var password = ""
//    
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                Text("Login Screen")
//                    .font(.title)
//                    .padding()
//                
//                VStack(spacing: 16) {
//                    TextField("Email", text: $email)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .autocapitalization(.none)
//                        .keyboardType(.emailAddress)
//                    
//                    SecureField("Password", text: $password)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    
//                    Button("Log In") {
//                        dismiss()
//                    }
//                    .buttonStyle(AuthButtonStyle(backgroundColor: .orange))
//                }
//                .padding()
//                
//                Spacer()
//                
//                Button("Close") {
//                    dismiss()
//                }
//                .foregroundColor(.gray)
//            }
//            .padding()
//            .navigationTitle("Log In")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}
//
//struct SignUpView: View {
//    @Environment(\.dismiss) private var dismiss
//    @State private var fullName = ""
//    @State private var email = ""
//    @State private var password = ""
//    @State private var confirmPassword = ""
//    @State private var errorMessage = ""
//    
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                Text("Sign Up Screen")
//                    .font(.title)
//                    .padding()
//                
//                VStack(spacing: 16) {
//                    TextField("Full Name", text: $fullName)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    TextField("Email", text: $email)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .autocapitalization(.none)
//                    SecureField("Password", text: $password)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    SecureField("Confirm Password", text: $confirmPassword)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    
//                    Button("Create Account") {
//                        dismiss()
//                    }
//                    .buttonStyle(AuthButtonStyle(backgroundColor: .blue))
//                }
//                .padding()
//                Spacer()
//                
//                Button("Close") {
//                    dismiss()
//                }
//                .foregroundColor(.gray)
//            }
//            .padding()
//            .navigationTitle("Sign Up")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//    
//}

struct PetsView: View {
    @Binding var selectedTab: Int
    @AppStorage("savedPets") private var savedPetsData: Data = Data()
    @AppStorage("selectedPetId") private var selectedPetId: String = ""
    @State private var pets: [Pet] = []
    @State private var showingAddPet = false
    @State private var showingImagePicker = false
    @State private var newPetImage: UIImage?
    @State private var newPetName = ""
    @State private var newPetBreed = ""
    @State private var newPetAge = ""
    
    var selectedPet: Pet? {
        pets.first { $0.id.uuidString == selectedPetId }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                VStack {
                    Text("Pets Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Manage your pet profiles here")
                        .foregroundColor(.secondary)
                    
                    if let currentPet = selectedPet {
                        VStack {
                            Text("Currently viewing:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(currentPet.name)
                                .font(.headline)
                                .foregroundColor(.orange)
                        }
                        .padding()
                    }
                    
                    if pets.isEmpty {
                        EmptyPetsView(showingAddPet: $showingAddPet)
                    } else {
                        PetsListView(
                            pets: $pets,
                            selectedPetId: $selectedPetId,
                            showingAddPet: $showingAddPet, selectedTab:
                                $selectedTab,
                            onDeletePet: deletePet
                        )
                    }
                    Button(action: {showingAddPet=true}) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add New Pet")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear{ loadPets()}
            .sheet(isPresented: $showingAddPet) {
                AddPetView(
                    petName: $newPetName,
                    petBreed: $newPetBreed,
                    petAge: $newPetAge,
                    petImage: $newPetImage,
                    onSave: addNewPet,
                    onCancel: {
                        showingAddPet = false
                        resetNewPetFields()
                    }
                )
            }
//            .sheet(isPresented: $showingImagePicker) {
//                ImagePicker { image in
//                    newPetImage = image
//                }
//            }
        }
    }
    
    private func addNewPet() {
        let imageData = newPetImage?.jpegData(compressionQuality: 0.8)
        let newPet = Pet(
            name: newPetName.isEmpty ? "New Pet" : newPetName,
            breed: newPetBreed.isEmpty ? "Unknown Breed" : newPetBreed,
            age: newPetAge.isEmpty ? "Unknown Age" : newPetAge,
            imageData: imageData
        )
        pets.append(newPet)
        savePets()
        
        if pets.count == 1 {
            selectedPetId = newPet.id.uuidString
        }
        
        resetNewPetFields()
        showingAddPet = false
    }
    
    
    private func deletePet(_ pet: Pet) {
        if let index = pets.firstIndex(where: { $0.id == pet.id }) {
            deletePhotosForPet(pet.id)
            pets.remove(at: index)
            savePets()
            // If we deleted pet, clear the selection
            if pet.id.uuidString == selectedPetId {
                selectedPetId = ""
            }
        }
    }
    
    private func deletePhotosForPet(_ petId: UUID) {
        if let data = UserDefaults.standard.data(forKey: "savedPhotos"),
           var photos = try? JSONDecoder().decode([PhotoItem].self, from: data) {
            photos.removeAll { $0.petId == petId }
            
            if let encoded = try? JSONEncoder().encode(photos) {
                UserDefaults.standard.set(encoded, forKey: "savedPhotos")
            }
        }
    }
    
    private func resetNewPetFields() {
        newPetName = ""
        newPetBreed = ""
        newPetAge = ""
        newPetImage = nil
    }
    
    private func loadPets() {
        if let decoded = try? JSONDecoder().decode([Pet].self, from: savedPetsData) {
            pets = decoded
        }
    }
    
    private func savePets() {
        if let encoded = try? JSONEncoder().encode(pets) {
            savedPetsData = encoded
        }
    }
}

struct EmptyPetsView: View {
    @Binding var showingAddPet: Bool
    
    var body: some View {
        Spacer()
        VStack(spacing: 20) {
            Image(systemName: "pawprint.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            Text("No pets yet!")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Add your pets to get started!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        Spacer()
    }
}

struct PetsListView: View {
    @Binding var pets: [Pet]
    @Binding var selectedPetId: String
    @Binding var showingAddPet: Bool
    @Binding var selectedTab: Int
    let onDeletePet: (Pet) -> Void
    
    @State private var petToDelete: Pet?
    @State private var showDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(pets) { pet in
                    PetProfileCard(
                        pet: pet,
                        isSelected: pet.id.uuidString == selectedPetId,
                        onSelect: {
                            selectedPetId = pet.id.uuidString
                            selectedTab = 3 // switch to health tab
                        },
                        pets: $pets,
                        onDelete: {
                            petToDelete = pet
                            showDeleteAlert = true
                        }
                    )
                    .contextMenu {
                        Button(role: .destructive) {
                            petToDelete = pet
                            showDeleteAlert = true
                        } label: {
                            Label("Delete Pet", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            petToDelete = pet
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
        .alert("Delete Pet", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {
                petToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let pet = petToDelete {
                    onDeletePet(pet)
                    petToDelete = nil
                }
            }
        } message: {
            if let pet = petToDelete {
                Text("Are you sure you want to delete \(pet.name)? This action cannot be undone and will remove all associated photos and health records.")
            }
        }
    }
}

struct PetProfileCard: View {
    let pet: Pet
    let isSelected: Bool
    let onSelect: () -> Void
    @State private var showingImagePicker = false
    @State private var showingDeleteAlert = false
    @Binding var pets: [Pet]
    let onDelete: (() -> Void)?
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Button(action: onSelect) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .frame(height: 100)
                    .overlay(
                        HStack {
                            Button(action: {
                                showingImagePicker = true
                            }) {
                                if let image = pet.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(isSelected ? Color.orange : Color.gray, lineWidth: 2)
                                        )
                                } else {
                                    Circle()
                                        .fill(Color.orange.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Image(systemName: "pawprint.fill")
                                                .foregroundColor(.orange)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(isSelected ? Color.orange : Color.gray, lineWidth: 2)
                                        )
                                }
                            }
                            .buttonStyle(.plain)
                            
                            VStack(alignment: .leading) {
                                Text(pet.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("\(pet.breed) • \(pet.age)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.orange)
                            } else {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                    )
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                    )
            }
            .buttonStyle(.plain)
            
            Button(action: {
                onDelete?()
            }) {
                Image(systemName: "trash.circle.fill")
                    .font(.title3)
                    .foregroundColor(.red)
                    .padding(4)
                    //.background(Color(.systemBackground))
                    //.clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 1)
            }
            .buttonStyle(.plain)
            .offset(x: -10, y: 30)
        }
        .padding(.horizontal)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker { image in
                if let image = image, let index = pets.firstIndex(where: {$0.id == pet.id}) {
                    pets[index].image=image
                    saveUpdatedPets()
                }
            }
        }
    }
    private func saveUpdatedPets() {
        if let encoded = try? JSONEncoder().encode(pets) {
            UserDefaults.standard.set(encoded, forKey: "savedPets")
        }
    }
}

struct AddPetView: View {
    @Binding var petName: String
    @Binding var petBreed: String
    @Binding var petAge: String
    @Binding var petImage: UIImage?
    
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Photo")) {
                    HStack {
                        Spacer()
                        Button(action: {
                            showImagePicker = true
                        }) {
                            VStack {
                                if let image = petImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.orange.opacity(0.3))
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            VStack {
                                                Image(systemName: "camera.fill")
                                                    .font(.title)
                                                    .foregroundColor(.orange)
                                                Text("Add Photo")
                                                    .font(.caption)
                                                    .foregroundColor(.orange)
                                            }
                                        )
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
                Section(header: Text("Pet Information")) {
                    TextField("Pet Name", text: $petName)
                    TextField("Breed", text: $petBreed)
                    TextField("Age", text: $petAge)
                }
            }
            .navigationTitle("Add New Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                    .disabled(petName.isEmpty)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker { image in
                    petImage = image
                }
            }
        }
    }
}

    struct GalleryView: View {
        @AppStorage("savedPets") private var savedPetsData: Data = Data()
        @AppStorage("selectedPetId") private var selectedPetId: String = ""
        @State private var pets: [Pet] = []
        @State var showPicker = false
        @State private var selectedImage: UIImage?
        @State private var showCaptionSheet = false
        @State private var newCaption = ""
        @State private var photos: [PhotoItem] = []
        @State private var selectedPhoto: PhotoItem?
        @State private var showPhotoDetail = false
        private let columns = [GridItem(.adaptive(minimum: 110), spacing: 8)]
        private let photosStorageKey = "savedPhotos"
        
        var selectedPet: Pet? {
            pets.first { $0.id.uuidString == selectedPetId }
        }
        
        // Filter the photos for the selected pet.
        var filteredPhotos: [PhotoItem] {
            guard let pet = selectedPet else { return [] }
            return photos.filter { $0.petId == pet.id }
        }
        
        var body: some View {
            NavigationView {
                ZStack {
                    Color(.systemGray6).ignoresSafeArea()
                    
                    VStack(spacing: 8) {
                        Text("Photo Gallery")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if pets.isEmpty {
                            Text("Add a pet first to view photos")
                                .foregroundColor(.secondary)
                        } else {
                            HStack {
                                Image(systemName: "pawprint.circle.fill")
                                    .foregroundColor(.orange)
                                Picker("Select Pet", selection: $selectedPetId) {
                                    Text("Select a pet").tag("")
                                    ForEach(pets) { pet in
                                        Text(pet.name).tag(pet.id.uuidString)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                
                                Spacer()
                            }
                        }
                        
                        if selectedPet == nil {
                            Spacer()
                            VStack(spacing: 20) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                Text("No pet selected")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                Text("Select a pet from the dropdown to view their photos!")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            Spacer()
                        } else {
                            if !filteredPhotos.isEmpty {
                                HStack {
                                    Text("\(filteredPhotos.count) photo\(filteredPhotos.count == 1 ? "" : "s")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                    Spacer()
                                }
                            }
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 8) {
                                    ForEach(filteredPhotos) { photo in
                                        PhotoGridItem(
                                            photo: photo,
                                            onTap: {
                                                selectedPhoto = photo
                                                showPhotoDetail = true
                                            }
                                        )
                                    }
                                    // add photo button:
                                    Button {
                                        showPicker = true
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.gray.opacity(0.15))
                                                .aspectRatio(1, contentMode: .fit)
                                            VStack(spacing: 6) {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.title)
                                                    .foregroundColor(.orange)
                                                Text("Add Photo")
                                                    .font(.caption)
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.top, 8)
                            }
                        }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showPicker) {
                //print("ImagePicker sheet appearing") // debug
                ImagePicker { image in
                    if let image = image {
                        selectedImage = image
                        newCaption = ""
                        showPicker = false
                        
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 500_000_000)
                            showCaptionSheet = true
                        }
                    } else {
                        showPicker = false
                    }
                }
            }
            .sheet(isPresented: $showCaptionSheet, onDismiss: {
                // if user dismisses the photo without actually saving it... just set the image to nil.
                selectedImage = nil
                newCaption = ""
            }) {
                if let image = selectedImage, let pet = selectedPet {
                    CaptionInputView(
                        image: image,
                        pet: pet,
                        caption: $newCaption,
                        isPresented: $showCaptionSheet,
                        onSave: { caption in
                            savePhotoWithCaption(caption: caption)
                            selectedImage = nil
                            newCaption = ""
                        }
                    )
                } else {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text("Unable to load image")
                            .font(.headline)
                        Text("Please try selecting the photo again.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Dismiss") {
                            showCaptionSheet = false
                            selectedImage = nil
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                }
            }
            .sheet(isPresented: $showPhotoDetail) {
                if let photo = selectedPhoto {
                    PhotoDetailView(
                        photo: photo,
                        isPresented: $showPhotoDetail,
                        onDelete: {
                            deletePhoto(photo)
                            showPhotoDetail = false
                        }
                    )
                }
            }
            .onAppear {
                loadPets()
                loadPhotos()
            }
            .onChange(of: selectedPetId) { _ in
                // when the pet changes, reload the new photo gallery.
                loadPhotos()
            }
        }
    }
        
        private func savePhotoWithCaption(caption: String) {
            guard let image = selectedImage, let pet = selectedPet else { return }
            
            let newPhoto = PhotoItem(
                image: image,
                caption: caption,
                petId: pet.id // store which pet the photo belongs to.
            )
            photos.append(newPhoto)
            savePhotos()
            selectedImage = nil
            newCaption = ""
        }
        
        private func deletePhoto(_ photo: PhotoItem) {
            photos.removeAll { $0.id == photo.id }
            savePhotos()
        }
        
        // Storage functions:
        
        private func savePhotos() {
            do {
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(photos)
                UserDefaults.standard.set(encoded, forKey: photosStorageKey)
            } catch {
                print("Error saving photos: \(error)")
            }
        }
        
        private func loadPhotos() {
            guard let data = UserDefaults.standard.data(forKey: photosStorageKey) else { return }
            do {
                let decoder = JSONDecoder()
                photos = try decoder.decode([PhotoItem].self, from: data)
            } catch {
                print("Error loading photos: \(error)")
            }
        }
        
        private func loadPets() {
            if let decoded = try? JSONDecoder().decode([Pet].self, from: savedPetsData) {
                pets = decoded
            }
        }
 }

struct PhotoGridItem: View {
    let photo: PhotoItem
    let onTap: () -> Void
    //let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onTap) {
                ZStack(alignment: .bottom) {
                    if let image = photo.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 110, maxHeight: 110)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 110, maxHeight: 110)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    }
                    
                    // Show caption preview
                    if !photo.caption.isEmpty {
                        Text(photo.caption)
                            .font(.system(size: 8))
                            .foregroundColor(.white)
                            .padding(4)
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.7))
                            .lineLimit(1)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
//            Button(action: onDelete) {
//                Image(systemName: "xmark.circle.fill")
//                    .font(.system(size: 20))
//                    .foregroundColor(.red)
//                    .background(Color.white)
//                    .clipShape(Circle())
//            }
//            .padding(4)
        }
    }
}

struct PhotoDetailView: View {
    let photo: PhotoItem
    @Binding var isPresented: Bool
    var onDelete: (() -> Void)? = nil
    @State private var showDeleteConfirm = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let image = photo.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(12)
                            .padding()
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 300)
                            .overlay(
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    Text("Image not available.")
                                        .foregroundColor(.gray)
                                }
                            )
                            .padding()
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        if !photo.caption.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Caption")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(photo.caption)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date Added")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(dateFormatter.string(from: photo.dateAdded))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    if let onDelete = onDelete {
                        Button("Delete Photo", role: .destructive) {
                            showDeleteConfirm = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .padding()
                    }
                }
            }
            .navigationTitle("Photo Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        isPresented = false
                    }
                }
                if onDelete != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Delete", role: .destructive) {
                            showDeleteConfirm = true
                        }
                    }
                }
            }
            .alert("Delete Photo", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    onDelete?() // call delete function
                }
                } message: {
                    Text("Are you sure you want to delete this photo? This action cannot be undone!")
                }
            }
        }
}

struct CaptionInputView: View {
    let image: UIImage?
    let pet: Pet
    @Binding var caption: String
    @Binding var isPresented: Bool
    let onSave: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .cornerRadius(12)
                        .padding()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add a caption")
                        .font(.headline)
                        .foregroundColor(.primary)
                    TextField("Describe this photo...", text: $caption)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .submitLabel(.done)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button("Save Photo") {
                    onSave(caption)
                    isPresented = false
                }
                .buttonStyle(ProminentButtonStyle())
                .padding(.horizontal)
                .disabled(caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.vertical)
            .navigationTitle("Add Caption")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct HealthView: View {
    @AppStorage("savedPets") private var savedPetsData: Data = Data()
    @AppStorage("selectedPetId") private var selectedPetId: String = ""
    @State private var pets: [Pet] = []
    
    var selectedPet: Pet? {
        pets.first { $0.id.uuidString == selectedPetId }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                VStack {
                    VStack(spacing: 8) {
                        Text("Health & Care")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if pets.isEmpty {
                            Text("Add a pet first to view health records")
                                .foregroundColor(.secondary)
                        } else {
                            HStack {
                                Image(systemName: "heart.circle.fill")
                                    .foregroundColor(.orange)
                                
                                Picker("Select Pet", selection: $selectedPetId) {
                                    Text("Select a pet").tag("")
                                    ForEach(pets) { pet in
                                        Text(pet.name).tag(pet.id.uuidString)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    if let pet = selectedPet {
                        Text("Health records for \(pet.name)")
                            .foregroundColor(.secondary)
                        
                        ScrollView {
                            VStack(spacing: 35) {
    // Vet Visit Button ------------------------------------------------------
                                NavigationLink {
                                        VetVisit()
                                    } label: {
                                        Image(systemName: "heart.fill")
                                            .resizable()
                                            .frame(width:20, height:20)
                                            .foregroundColor(.orange)
                                        Text("Vet Visit")
                                            .frame(maxWidth: .infinity)
                                            .frame(maxHeight: 60)
                                        Text("Track and Manage Here")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }.buttonStyle(.bordered)
                                    .buttonBorderShape(.roundedRectangle(radius: 12))
                                    .controlSize(.large)
                                    .font(.headline)
                                    .tint(.gray)
                                    .foregroundColor(.black)
    // Medications Button ----------------------------------------------------
                                NavigationLink {
                                        MedicationCheck()
                                    } label: {
                                        Image(systemName: "stethoscope")
                                            .resizable()
                                            .frame(width:30, height:30)
                                            .foregroundColor(.orange)
                                        Text("Medications")
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 40)
                                        Text("Track and Manage Here")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }.buttonStyle(.bordered)
                                     .buttonBorderShape(.roundedRectangle(radius: 12))
                                     .font(.headline)
                                     .tint(.gray)
                                     .foregroundColor(.black)
    // Vactinations Button ---------------------------------------------------
                                NavigationLink {
                                        VaccinationsView()
                                    } label: {
                                        Image(systemName: "pills.fill")
                                            .resizable().frame(width:20, height:20)
                                            .foregroundColor(.orange)
                                        Text("Vaccinations")
                                            .frame(maxWidth: .infinity)
                                            .frame(maxHeight: 60)
                                        Text("Track and Manage Here")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }.buttonStyle(.bordered)
                                     .buttonBorderShape(.roundedRectangle(radius: 12))
                                     .controlSize(.large)
                                     .font(.headline)
                                     .tint(.gray)
                                     .foregroundColor(.black)
    // Progess Button -------------------------------------------------------
                                NavigationLink {
                                        ProgressCheck()
                                    } label: {
                                        Image(systemName: "chart.bar.fill")
                                            .resizable().frame(width:20, height:20)
                                            .foregroundColor(.orange)
                                        Text("Progress")
                                            .frame(maxWidth: .infinity)
                                            .frame(maxHeight: 60)
                                        Text("Track and Manage Here")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }.buttonStyle(.bordered)
                                     .buttonBorderShape(.roundedRectangle(radius: 12))
                                     .controlSize(.large)
                                     .font(.headline)
                                     .tint(.gray)
                                     .foregroundColor(.black)
                            }
                        }
                    } else {
                        Spacer()
                        VStack(spacing: 20) {
                            Image(systemName: "heart.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("No pet selected")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("Select a pet from the dropdown to view their health records")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear{
                loadPets()
            }
        }
    }
    private func loadPets() {
        if let decoded = try? JSONDecoder().decode([Pet].self, from: savedPetsData) {
            pets = decoded
        }
    }
}

struct HealthButton: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.orange)
            Text(title)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 60)
            Text("Track and Manage Here")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: 12))
        .controlSize(.large)
        .font(.headline)
        .tint(.gray)
        .foregroundColor(.black)
    }
}

struct PetDetailView: View {
    let pet: Pet
    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .fill(Color.orange.opacity(0.3))
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                )
            Text(pet.name)
                .font(.largeTitle)
                .bold()
                        
            Text("\(pet.breed) • \(pet.age)")
                .foregroundColor(.secondary)
                .font(.title3)
                        
            Divider().padding(.vertical)
                        
            VStack(alignment: .leading, spacing: 12) {
                Text("Health Records")
                    .font(.headline)
                Text("Track vet visits, medications, and reminders here.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                            
                Text("Gallery")
                    .font(.headline)
                Text("Photos and memories of \(pet.name).")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
                        
            Spacer()
        }
        .padding()
        .navigationTitle(pet.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}
