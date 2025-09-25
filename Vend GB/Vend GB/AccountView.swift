import SwiftUI

struct AccountView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showingThemeToggle = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        // Profile Avatar
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 100, height: 100)
                            
                            Text("GB")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 4) {
                            Text("Guest User")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Account features coming soon")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Account Status Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)
                            Text("Account Status")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Status:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Guest Access")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.orange.opacity(0.2))
                                    .foregroundColor(.orange)
                                    .clipShape(Capsule())
                            }
                            
                            HStack {
                                Text("Authentication:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Not Required")
                                    .foregroundColor(.primary)
                            }
                            
                            HStack {
                                Text("Features:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Full Access")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 20)
                    
                    // Theme Settings
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .foregroundColor(.purple)
                            Text("Appearance")
                                .font(.headline)
                        }
                        
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Theme")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("Choose your preferred appearance")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isDarkMode.toggle()
                                        updateAppTheme()
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                                            .foregroundColor(.white)
                                        Text(isDarkMode ? "Light" : "Dark")
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: isDarkMode ? [.orange, .yellow] : [.indigo, .purple]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(Capsule())
                                }
                            }
                            
                            HStack {
                                Text("Current Theme:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(isDarkMode ? "Dark Mode" : "Light Mode")
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 20)
                    
                    // App Settings
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.gray)
                            Text("App Settings")
                                .font(.headline)
                        }
                        
                        VStack(spacing: 0) {
                            SettingsRowView(
                                icon: "bell.fill",
                                title: "Notifications",
                                subtitle: "Push notifications enabled",
                                iconColor: .red
                            )
                            
                            Divider()
                            
                            SettingsRowView(
                                icon: "location.fill",
                                title: "Location",
                                subtitle: "Allow location access for delivery",
                                iconColor: .green
                            )
                            
                            Divider()
                            
                            SettingsRowView(
                                icon: "lock.fill",
                                title: "Privacy",
                                subtitle: "Data collection preferences",
                                iconColor: .blue
                            )
                        }
                    }
                    .padding(20)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 20)
                    
                    // Coming Soon Section
                    VStack(spacing: 16) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 8) {
                            Text("Full Account Features")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("User accounts, order history, favorites, and more features are coming soon!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        
                        Button(action: {}) {
                            Text("Learn More")
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 20)
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
    
    private func updateAppTheme() {
        // This will automatically update the app's color scheme
        // The @AppStorage will persist the setting
    }
}

struct SettingsRowView: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    AccountView()
}
