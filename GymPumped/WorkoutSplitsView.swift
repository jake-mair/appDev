//
//  WorkoutSplitsView.swift
//  GymPumped
//

import SwiftUI
import FirebaseAuth

// MARK: - WorkoutSplitsView
struct WorkoutSplitsView: View {
    @EnvironmentObject var authService: AuthService

    @State private var splits: [WorkoutSplit] = []
    @State private var isLoading = true
    @State private var showCreateModal = false
    @State private var actionSplit: WorkoutSplit?
    @State private var showDeleteConfirmation = false

    private let firestoreService = FirestoreService()

    var body: some View {
        NavigationView {
            VStack {
                // Custom Header with Gradient
                HStack {
                    Text("Workout Splits")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.neonCyan, Color.neonPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Spacer()
                    
                    Button(action: {
                        showCreateModal = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Create Split")
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(LinearGradient.accentGradient)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
                // End header

                if isLoading {
                    ProgressView()
                } else if splits.isEmpty {
                    EmptySplitsView()
                } else {
                    List {
                        ForEach(splits) { split in
                            WorkoutSplitCard(split: split,
                            onDelete: {
                                actionSplit = split
                                showDeleteConfirmation = true
                            },
                            onStatusChange: {
                                actionSplit = split
                                updateSplitStatus()
                            }
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.inset)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationBarHidden(true)
            .background(Color.clear)
        }
            .onAppear {
                fetchSplits()
            }
            
            .sheet(isPresented: $showCreateModal) {
                CreateSplitModalView(onSave: { newSplit in
                    Task {
                        do {
                            try await firestoreService.saveWorkoutSplit(userId: authService.currentUser!.uid, split: newSplit)
                            fetchSplits()
                        } catch {
                            print("Error saving new workout split: \(error)")
                        }
                    }
                })
            }
            
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Delete Workout Split"),
                    message: Text("Are you sure you want to delete this workout split? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let split = actionSplit, let id = split.id {
                            deleteSplit(splitId: id)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
            
        private func fetchSplits() {
            guard let userId = authService.currentUser?.uid else { return }
            
            isLoading = true
            Task {
                do {
                    let fetchedSplits = try await firestoreService.getUserWorkoutSplits(userId: userId)
                    self.splits = fetchedSplits
                } catch {
                    print("Error fetching workout splits: \(error)")
                    self.splits = []
                }
                isLoading = false
            }
        }
            
        private func deleteSplit(splitId: String) {
            guard let userId = authService.currentUser?.uid else { return }
            Task {
                do {
                    try await firestoreService.deleteWorkoutSplit(userId: userId, splitId: splitId)
                    fetchSplits()
                } catch {
                    print("Error deleting workout split: \(error)")
                }
            }
        }
            
        private func updateSplitStatus() {
            guard let userId = authService.currentUser?.uid, var updatedSplit = actionSplit else { return }
            
            if updatedSplit.isActive {
                updatedSplit.isActive = false
            } else if updatedSplit.isPlanned ?? false {
                updatedSplit.isPlanned = false
                updatedSplit.isActive = true
            } else {
                updatedSplit.isPlanned = true
            }
            
            Task {
                do {
                    try await firestoreService.updateWorkoutSplit(userId: userId, split: updatedSplit)
                    fetchSplits()
                } catch {
                    print("Error updating split status: \(error)")
                }
            }
        }
}



// MARK: - WorkoutSplitCard
struct WorkoutSplitCard: View {
    var split: WorkoutSplit
    var onDelete: () -> Void
    var onStatusChange: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(split.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(split.isActive ? "Active" : (split.isPlanned ?? false ? "Planned" : "Inactive"))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(split.isActive ? Color.green : (split.isPlanned ?? false ? Color.blue : Color.gray))
                    .cornerRadius(20)
                    .onTapGesture {
                        onStatusChange()
                    }
                
                HStack(spacing: 15) {
                    Button(action: {

                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.gray)
                    }
                    
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .onTapGesture {
                            onDelete()
                        }
                }
            }
            
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
                Text("\(split.startDate) - \(split.endDate)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                    Text("Weekly Schedule")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // ADD THIS NEW HSTACK
                HStack(spacing: 10) {
                    ForEach(["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"], id: \.self) { dayAbbr in
                        // Use the map to get the correct key for the schedule dictionary
                        let dayKey = dayKeyMap[dayAbbr] ?? ""
                        // Look up the workout type, defaulting to "Rest" if not found
                        let workoutType = split.schedule[dayKey]?.workoutType ?? "Rest"
                        
                        VStack(spacing: 4) {
                            Text(dayAbbr)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.cardBackground.shadow(.inner(radius: 3, y: 3))) // Added a subtle inner shadow
                                .frame(width: 40, height: 40)
                                .overlay(
                                    VStack(spacing: 2) {
                                        // Use the new helper to get the abbreviation
                                        Text(abbreviation(for: workoutType))
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        // Use the new helper to get the icon
                                        Image(systemName: icon(for: workoutType))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                )
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - WorkoutSplitCard Helpers
private extension WorkoutSplitCard {
    // 1. Maps the display abbreviation to the lowercase key used in your data model
    var dayKeyMap: [String: String] {
        [
            "MON": "monday", "TUE": "tuesday", "WED": "wednesday",
            "THU": "thursday", "FRI": "friday", "SAT": "saturday",
            "SUN": "sunday"
        ]
    }

    // 2. Creates an abbreviation for the workout type text
    func abbreviation(for workoutType: String) -> String {
        guard !workoutType.isEmpty else { return "N/A" }
        if workoutType.count <= 3 {
            return workoutType.uppercased()
        } else if workoutType.lowercased() == "full body" {
            return "FULL"
        } else {
            return String(workoutType.prefix(3)).uppercased()
        }
    }

    // 3. Selects an SF Symbol name based on the workout type
    func icon(for workoutType: String) -> String {
        switch workoutType.lowercased() {
        case "push": return "arrow.up.to.line.compact"
        case "pull": return "arrow.down.to.line.compact"
        case "legs": return "figure.walk"
        case "upper": return "person.fill"
        case "lower": return "figure.lower.body"
        case "full body": return "figure.strengthtraining.traditional"
        case "cardio": return "heart.fill"
        case "rest": return "zzz"
        default: return "questionmark.diamond"
        }
    }
}

// MARK: - EmptySplitsView
struct EmptySplitsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Workout Splits")
                .font(.title2)
                .foregroundColor(.white)
            Text("Create your first workout split to get started.")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService())
}
