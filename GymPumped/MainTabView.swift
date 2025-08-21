//
//  MainTabView.swift
//  GymPumped
//

import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        TabView {
            WorkoutSplitsView()
                .tabItem {
                    Label("Splits", systemImage: "dumbbell.fill")
                }

            WorkoutLoggerView()
                .tabItem {
                    Label("Workout", systemImage: "play.circle.fill")
                }

            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(.purple) // Sets the color of the selected tab icon
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthService())
}
