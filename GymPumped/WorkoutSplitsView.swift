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
    @State private var isLoading = false
    @State private var showCreateModal = false

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
                
                if isLoading {
                    ProgressView()
                } else if splits.isEmpty {
                    EmptySplitsView()
                } else {
                    List {
                        ForEach(splits) { split in
                            WorkoutSplitCard(split: split)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.inset)
                    .scrollContentBackground(.hidden)
                }
            }
            // .navigationTitle("Workout Splits")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        showCreateModal = true
//                    }) {
//                        Label("Create Split", systemImage: "plus")
//                            .foregroundColor(.pink)
//                    }
//                }
//            }
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
}

// MARK: - WorkoutSplitCard
struct WorkoutSplitCard: View {
    var split: WorkoutSplit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Name, Status, and Actions
            HStack {
                Text(split.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Status Badge
                Text(split.isActive ? "Active" : "Planned")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(split.isActive ? Color.green : Color.blue)
                    .cornerRadius(20)
                
                // Action Buttons
                HStack(spacing: 15) {
                    Button(action: {
                        // TODO: Implement edit functionality
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        // TODO: Implement delete functionality
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            
            // Date Range
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
                Text("\(split.startDate) - \(split.endDate)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // Weekly Schedule
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                    Text("Weekly Schedule")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 10) {
                    ForEach(["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"], id: \.self) { day in
                        VStack(spacing: 4) {
                            Text(day)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            
                            // Placeholder for workout type
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.cardBackground)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    VStack(spacing: 2) {
                                        Text("R..")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                        Image(systemName: "zzz")
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
    WorkoutSplitsView()
        .environmentObject(AuthService())
}
