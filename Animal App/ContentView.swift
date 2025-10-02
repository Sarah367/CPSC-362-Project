//
//  ContentView.swift
//  Animal App
//
//  Created by Andrea Maples on 9/22/25.
//

import SwiftUI

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
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                ScrollView{
                    VStack(spacing: 20) {
                        Text("Home Screen")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        ForEach(0..<3) { index in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .frame(height: 120)
                                .overlay(
                                    VStack {
                                        Text("Feature Card \(index+1)")
                                            .font(.headline)
                                        Text("This would show pet overview")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                )
                                .shadow(color: .black.opacity(0.05), radius: 5)
                                
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct PetsView: View {
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
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(0..<3) { index in
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
                                                Text("Pet Name \(index + 1)")
                                                    .font(.headline)
                                                Text("Breed • Age")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                        }
                                        .padding()
                                    )
                                    .shadow(color: .black.opacity(0.05), radius:5)
                                
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

struct GalleryView: View {
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
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 2) {
                            ForEach(0..<15) { index in
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .aspectRatio(1, contentMode: .fill)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    )
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
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
                                    Vactination()
                                } label: {
                                    Image(systemName: "pills.fill")
                                        .resizable().frame(width:20, height:20)
                                        .foregroundColor(.orange)
                                    Text("Vactinations")
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
// Reminders Button ------------------------------------------------------
                            NavigationLink {
                                    Reminders()
                                } label: {
                                    Image(systemName: "clock.fill")
                                        .resizable().frame(width:20, height:20)
                                        .foregroundColor(.orange)
                                    Text("Reminders")
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}
