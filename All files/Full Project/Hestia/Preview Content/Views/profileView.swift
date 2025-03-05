//
//  predictView.swift
//  Hestia
//
//  Created by Yuri Hoashi on 1/3/2025.
//
//
import SwiftUI



/// This is where user goes to change settings, change profile, logout etc
/// Repetitive use of profile view, so I used AI to quickly make me a generic style, with a UI appropriate for this app
struct profileView: View {
    var body: some View {
        ZStack {
            // Background color for the entire screen
            Color("myGreen")
                .ignoresSafeArea(edges: .all)
            
            Image("farmhouse")
                .resizable()
                .frame(width: 300, height: 150)
                .offset(y: -233)
            
            VStack {
                // Top section with white background instead of light gray
                Spacer()
                Color.white // Changed from "myLightGray" to white
                    .frame(maxWidth: .infinity, maxHeight: 200)
            }
            
            GeometryReader { geometry in
                ZStack {
                    Color.white
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.7) // Set height to 70% of screen height
                        .cornerRadius(50)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                    
                    // Profile Settings List
                    // I acknowledge the use of AI to create a generic profile view page, commonly used sections
                    List {
                        // Account Section
                        Section(header: Text("Account").foregroundColor(Color("myOrange"))
                            .bold()
                        ) {
                            NavigationLink(destination: AccountSettingsView()) {
                                Label("Account Settings", systemImage: "person.circle.fill")
                                    .foregroundColor(.black)
                            }
                            NavigationLink(destination: ChangePasswordView()) {
                                Label("Change Password", systemImage: "lock.fill")
                                    .foregroundColor(.black)
                            }
                        }
                        
                        // Preferences Section
                        Section(header: Text("Preferences").foregroundColor(Color("myOrange"))
                            .bold()
                        ) {
                            NavigationLink(destination: LanguageSettingsView()) {
                                Label("Language", systemImage: "globe")
                                    .foregroundColor(.black)
                            }
                            NavigationLink(destination: ThemeSettingsView()) {
                                Label("Theme", systemImage: "paintbrush.fill")
                                    .foregroundColor(.black)
                            }
                        }
                        
                        // Support Section
                        Section(header: Text("Support")
                            .foregroundColor(Color("myOrange"))
                            .bold()
                        ) {
                            NavigationLink(destination: ContactUsView()) {
                                Label("Contact Us", systemImage: "envelope.fill")
                                    .foregroundColor(.black)
                            }
                            NavigationLink(destination: FAQView()) {
                                Label("FAQ", systemImage: "questionmark.circle.fill")
                                    .foregroundColor(.black)
                            }
                        }
                        
                        // Legal Section
                        Section(header: Text("Legal")
                            .foregroundColor(Color("myOrange"))
                            .bold()
                        ) {
                            NavigationLink(destination: PrivacyPolicyView()) {
                                Label("Privacy Policy", systemImage: "shield.fill")
                                    .foregroundColor(.black)
                            }
                            NavigationLink(destination: TermsOfServiceView()) {
                                Label("Terms of Service", systemImage: "doc.text.fill")
                                    .foregroundColor(.black)
                            }
                        }
                        
                        // Log Out Button
                        Section {
                            Button(action: logout) {
                                Label("Log Out", systemImage: "arrow.backward.circle.fill")
                                    .foregroundColor(Color("myOrange"))
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    
                    .cornerRadius(50)
                }
                .padding(.top, 230)
                .frame(maxHeight: 200, alignment: .top)
            }
        }
    }
    
    private func logout() {
        // Handle logout action here
        print("Logging out...")
    }
}

// Example of individual settings views
struct AccountSettingsView: View {
    var body: some View {
        Text("Account Settings Page")
            .navigationBarTitle("Account Settings", displayMode: .inline)
    }
}

struct ChangePasswordView: View {
    var body: some View {
        Text("Change Password Page")
            .navigationBarTitle("Change Password", displayMode: .inline)
    }
}

struct LanguageSettingsView: View {
    var body: some View {
        Text("Language Settings Page")
            .navigationBarTitle("Language", displayMode: .inline)
    }
}

struct ThemeSettingsView: View {
    var body: some View {
        Text("Theme Settings Page")
            .navigationBarTitle("Theme", displayMode: .inline)
    }
}

struct ContactUsView: View {
    var body: some View {
        Text("Contact Us Page")
            .navigationBarTitle("Contact Us", displayMode: .inline)
    }
}

struct FAQView: View {
    var body: some View {
        Text("FAQ Page")
            .navigationBarTitle("FAQ", displayMode: .inline)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        Text("Privacy Policy Page")
            .navigationBarTitle("Privacy Policy", displayMode: .inline)
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        Text("Terms of Service Page")
            .navigationBarTitle("Terms of Service", displayMode: .inline)
    }
}

#Preview {
    profileView()
}
