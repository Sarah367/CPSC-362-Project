import SwiftUI

struct Pet: Identifiable, Codable {
    var id = UUID()
    var name: String
    var breed: String
    var age: String
}
struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                PetsView()
                    .tag(1)
                GalleryView()
                    .tag(2)
                HealthView()
                    .tag(3)
                MoreView()
                    .tag(4)
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
                icon: "ellipsis.circle.fill",
                label: "More",
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
    @State private var showLogin = false
    @State private var showSignUp = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                ScrollView{
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            Text("FurEver Care")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text("Your complete pet care companion")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
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
                            
                            Button("Create Your Profile") {
                                showSignUp = true
                            }
                            .buttonStyle(ProminentButtonStyle())
                            
                            HStack(spacing: 4) {
                                Text("Already have an account?")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Button("Log In") {
                                    showLogin = true
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                            }
//                            Button("Already have an account? Log In!") {
//                                showLogin = true
//                            }
//                            .font(.subheadline)
//                            .foregroundColor(.blue)
                            
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
            .sheet(isPresented: $showLogin) {
                LoginView()
            }
            .sheet(isPresented: $showSignUp) {
                SignUpView()
            }
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
//                .aspectRatio(1.2, contentMode: .fill)
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

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Login Screen")
                    .font(.title)
                    .padding()
                
                VStack(spacing: 16) {
                    TextField("Email", text: .constant(""))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("Password", text: .constant(""))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Log In") {
                        // Login logic goes here
                        dismiss()
                    }
                    .buttonStyle(AuthButtonStyle(backgroundColor: .orange))
                }
                .padding()
                
                Spacer()
                
                Button("Close") {
                    dismiss()
                }
                .foregroundColor(.gray)
            }
            .padding()
            .navigationTitle("Log In")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Sign Up Screen")
                    .font(.title)
                    .padding()
                
                VStack(spacing: 16) {
                    TextField("Full Name", text: .constant(""))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Email", text: .constant(""))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    SecureField("Password", text: .constant(""))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    SecureField("Confirm Password", text: .constant(""))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Create Account") {
                        // Sign up logic goes here...
                        dismiss()
                    }
                    .buttonStyle(AuthButtonStyle(backgroundColor: .blue))
                }
                .padding()
                Spacer()
                
                Button("Close") {
                    dismiss()
                }
                .foregroundColor(.gray)
            }
            .padding()
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PetsView: View {
    @AppStorage("savedPets") private var savedPetsData: Data = Data()
    @State private var pets: [Pet] = []
    
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
                    
                    NavigationLink(destination: AddPetView(pets: $pets, savePets: savePets)) {
                        Label("Add New Pet", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.orange)
                            .padding()
                    }
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(pets) { pet in
                                NavigationLink(destination: PetDetailView(pet: Pet(id: pet.id, name: pet.name, breed: pet.breed, age: pet.age))) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .frame(height: 100)
                                        .overlay(
                                            HStack{
                                                Circle()
                                                    .fill(Color.orange.opacity(0.3))
                                                    .frame(width:60, height:60)
                                                    .overlay(
                                                        Image(systemName: "pawprint.fill")
                                                            .foregroundColor(.orange)
                                                    )
                                                VStack(alignment: .leading) {
                                                    Text(pet.name)
                                                        .font(.headline)
                                                    Text("\(pet.breed) • \(pet.age)")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                                Spacer()
                                            }
                                                .padding()
                                        )
                                        .shadow(color: .black.opacity(0.05), radius:5)
                                }
                                // Delete button
                                Button(action: {
                                    deletePet(pet: pet)
                                }) {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(Color(.red))
                                        .padding(.leading, 8)
                                }
                            }
                            .padding(.horizontal)
                            
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear { loadPets() }
        }
    }
    
    private func deletePet(pet: Pet) {
        if let index = pets.firstIndex(where: { $0.id == pet.id }) {
            pets.remove(at: index)
            savePets()
        }
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

struct AddPetView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var pets: [Pet]
    var savePets: () -> Void
    
    @State private var petName: String = ""
    @State private var breed: String = ""
    @State private var age: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("New Pet")) {
                TextField("Name", text: $petName)
                TextField("Breed", text: $breed)
                TextField("Age", text: $age)
            }
            
            Button("Save") {
                let newPet = Pet(name: petName, breed: breed, age: age)
                pets.append(newPet)
                savePets()
                dismiss()
            }
        }
        .navigationTitle("Add New Pet")
    }
}

struct GalleryView: View {
    @State var showPicker = false
    @State var selectedImage: [UIImage] = [] // array of multiple images
    private let columns = [GridItem(.adaptive(minimum: 110), spacing: 8)]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                VStack {
                    
                    Text("Photo Gallery")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Your pet's photos and memories")
                        .foregroundColor(.secondary)
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(selectedImage.indices, id: \.self) { index in
                                Color.clear
                                    .aspectRatio(1, contentMode: .fit)
                                    .overlay(
                                        Image(uiImage: selectedImage[index])
                                            .resizable()
                                            .scaledToFill()
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    //.background(Color.gray.opacity(0.15))
                                
                            }
                            // Rectangular Button:
                            Button{
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
            .navigationBarHidden(true)
            .sheet(isPresented: $showPicker) {
                ImagePicker { img in
                    if let img { selectedImage.append(img) }
                }
            }
        }
    }
}

struct HealthView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                VStack {
                    Text("Health & Care")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Track your pet's health records")
                        .foregroundColor(.secondary)
                    Spacer(minLength: 50)
                    
                    
                    ScrollView {
                        VStack(spacing: 35) {
// Vet Visit Button ------------------------------------------------------
                            Button {
                                } label: {
                                    Image(systemName: "heart.fill").resizable().frame(width:20, height:20).foregroundColor(.orange)
                                    Text("Vet Visit").frame(maxWidth: .infinity).frame(maxHeight: 60)
                                    Text("Track and Manage Here").font(.caption).foregroundColor(.secondary)
                            }.buttonStyle(.bordered).buttonBorderShape(.roundedRectangle(radius: 12)).controlSize(.large).font(.headline).tint(.gray).foregroundColor(.black)
// Medications Button ----------------------------------------------------
                            Button {
                                } label: {
                                    Image(systemName: "stethoscope").resizable().frame(width:30, height:30).foregroundColor(.orange)
                                    Text("Medications").frame(maxWidth: .infinity).frame(height: 40)
                                    Text("Track and Manage Here").font(.caption).foregroundColor(.secondary)
                            }.buttonStyle(.bordered).buttonBorderShape(.roundedRectangle(radius: 12)).font(.headline).tint(.gray).foregroundColor(.black)
// Vaccinations Button ---------------------------------------------------
                            Button {
                                } label: {
                                    Image(systemName: "pills.fill").resizable().frame(width:20, height:20).foregroundColor(.orange)
                                    Text("Vaccinations").frame(maxWidth: .infinity).frame(maxHeight: 60)
                                    Text("Track and Manage Here").font(.caption).foregroundColor(.secondary)
                            }.buttonStyle(.bordered).buttonBorderShape(.roundedRectangle(radius: 12)).controlSize(.large).font(.headline).tint(.gray).foregroundColor(.black)
// Reminders Button ------------------------------------------------------
                            Button {
                                } label: {
                                    Image(systemName: "clock.fill").resizable().frame(width:20, height:20).foregroundColor(.orange)
                                    Text("Reminders").frame(maxWidth: .infinity).frame(maxHeight: 60)
                                    Text("Track and Manage Here").font(.caption).foregroundColor(.secondary)
                            }.buttonStyle(.bordered).buttonBorderShape(.roundedRectangle(radius: 12)).controlSize(.large).font(.headline).tint(.gray).foregroundColor(.black)
// Progess Button -------------------------------------------------------
                            Button {
                                } label: {
                                    Image(systemName: "chart.bar.fill").resizable().frame(width:20, height:20).foregroundColor(.orange)
                                    Text("Progress").frame(maxWidth: .infinity).frame(maxHeight: 60)
                                    Text("Track and Manage Here").font(.caption).foregroundColor(.secondary)
                                }.buttonStyle(.bordered).buttonBorderShape(.roundedRectangle(radius: 12)).controlSize(.large).font(.headline).tint(.gray).foregroundColor(.black)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct MoreView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                VStack {
                    Text("More")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Settings and additional features")
                        .foregroundColor(.secondary)
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(0..<6) { index in
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemBackground))
                                    .frame(height: 60)
                                    .overlay(
                                        HStack {
                                            Image(systemName: ["gear", "bell.fill", "questionmark.circle", "info.circle", "person.fill", "square.and.arrow.up"][index])
                                                .foregroundColor(.orange)
                                                .font(.title3)
                                            Text(["Settings", "Notifications","Help", "About", "Account", "Share"][index])
                                                .font(.headline)
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                            .padding()
                                    )
                                    .shadow(color: .black.opacity(0.05), radius: 5)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
        }
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
