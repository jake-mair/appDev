//
//  WorkoutSplitsView.swift
//  GymPumped
//

import SwiftUI
import FirebaseAuth

struct WorkoutSplitsView: View {
    @EnvironmentObject var authService: AuthService
    
    @State private var splits: [WorkoutSplit] = []
    @State private var isLoading = true
    @State private var showCreateModal = false

    private let firestoreService = FirestoreService()

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                } else if splits.isEmpty {
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
                } else {
                    List {
                        ForEach(splits) { split in
                            VStack(alignment: .leading) {
                                Text(split.name)
                                    .font(.headline)
                                Text("\(split.startDate) - \(split.endDate)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .listRowBackground(Color.clear) // Makes the row backgrounds transparent
                    }
                    .listStyle(InsetGroupedListStyle())
                    .background(Color.clear) // Makes the List background transparent
                }
            }
            .navigationTitle("Workout Splits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreateModal = true
                    }) {
                        Label("Create Split", systemImage: "plus")
                            .foregroundColor(.pink)
                    }
                }
            }
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
