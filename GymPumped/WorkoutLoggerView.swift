//
//  WorkoutLoggerView.swift
//  GymPumped
//

import SwiftUI
import FirebaseAuth

struct WorkoutLoggerView: View {
    @EnvironmentObject var authService: AuthService
    
    // State to toggle between activity and list view modes
    @State private var viewMode: ViewMode = .activity
    @State private var isLoading = true
    @State private var activeSplit: WorkoutSplit?
    
    private let firestoreService = FirestoreService()
    
    enum ViewMode {
        case activity
        case list
    }
    
    // Get today's workout based on the active split
    private var todaysWorkout: WorkoutDay? {
        guard let split = activeSplit else { return nil }
        
        let today = Calendar.current.component(.weekday, from: Date())
        
        // Map SwiftUI's weekday to your app's "monday", "tuesday", etc.
        let dayNames = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
        let currentDayName = dayNames[today - 1]
        
        return split.schedule[currentDayName]
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                } else if activeSplit == nil {
                    // No active split found
                    VStack(spacing: 16) {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Active Workout Split")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("Please go to the Splits tab to activate a workout plan.")
                            .foregroundColor(.gray)
                    }
                } else if todaysWorkout?.workoutType == "Rest" {
                    // It's a rest day
                    VStack(spacing: 16) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Rest Day")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("Take a well-deserved break and let your muscles recover.")
                            .foregroundColor(.gray)
                    }
                } else if let workout = todaysWorkout {
                    // A workout is scheduled for today
                    if viewMode == .activity {
                        Text("Workout Activity View for \(workout.workoutType)")
                    } else {
                        Text("Workout List View for \(workout.workoutType)")
                    }
                } else {
                    // No workout scheduled for today
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Workout Today")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("You have a split but no workout is scheduled for today.")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Today's Workout")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewMode = (viewMode == .activity) ? .list : .activity
                    }) {
                        Label("Change View", systemImage: viewMode == .activity ? "list.bullet" : "play.circle")
                    }
                }
            }
        }
        .onAppear {
            fetchActiveSplit()
        }
    }
    
    private func fetchActiveSplit() {
        guard let userId = authService.currentUser?.uid else { return }
        
        isLoading = true
        Task {
            do {
                let fetchedSplits = try await firestoreService.getUserWorkoutSplits(userId: userId)
                self.activeSplit = fetchedSplits.first(where: { $0.isActive })
            } catch {
                print("Error fetching active split: \(error)")
                self.activeSplit = nil
            }
            isLoading = false
        }
    }
}

#Preview {
    WorkoutLoggerView()
        .environmentObject(AuthService())
}
