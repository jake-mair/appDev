//
//  FirestoreService.swift
//  GymPumped
//

import FirebaseFirestore
import Foundation

struct WorkoutSplit: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var schedule: [String: WorkoutDay]
    var startDate: String
    var endDate: String
    var isActive: Bool
    var isPlanned: Bool?
    var createdAt: Timestamp?
    var updatedAt: Timestamp?
}

struct WorkoutDay: Codable {
    var workoutType: String
    var exercises: [Exercise]
}

struct Exercise: Codable, Identifiable {
    var id: String
    var name: String
    var sets: Int
    var reps: String
    var weight: Int?
    var supersetId: String?
    var supersetLabel: String?
}

// New Structs for Completed Workouts
struct CompletedWorkout: Codable {
    var userId: String
    var date: String
    var completed: Bool
    var exercises: [CompletedExercise]
    var createdAt: Timestamp
}

struct CompletedExercise: Codable {
    var name: String
    var sets: [CompletedSet]
}

struct CompletedSet: Codable {
    var weight: Int
    var reps: Int
    var comment: String?
}

// New Structs for Workout History
struct WorkoutHistory: Codable {
    var userId: String
    var date: String
    var exerciseName: String
    var weight: Int
    var reps: Int
    var setNumber: Int
    var totalSets: Int
    var comment: String?
    var createdAt: Timestamp
}

class FirestoreService {
    private let db = Firestore.firestore()

    // MARK: - Workout Splits

    func saveWorkoutSplit(userId: String, split: WorkoutSplit) async throws {
        let splitRef = db.collection("users").document(userId).collection("workoutSplits").document(split.id ?? UUID().uuidString)
        var splitData = split
        splitData.createdAt = Timestamp(date: Date())
        splitData.updatedAt = Timestamp(date: Date())
        
        try await splitRef.setData(from: splitData)
    }

    func getUserWorkoutSplits(userId: String) async throws -> [WorkoutSplit] {
        let splitsQuery = db.collection("users").document(userId).collection("workoutSplits")
                            .order(by: "createdAt", descending: true)
        let querySnapshot = try await splitsQuery.getDocuments()
        
        return querySnapshot.documents.compactMap { document in
            try? document.data(as: WorkoutSplit.self)
        }
    }
    
    func deleteWorkoutSplit(userId: String, splitId: String) async throws {
        let splitRef = db.collection("users").document(userId).collection("workoutSplits").document(splitId)
        try await splitRef.delete()
    }
    
    func updateWorkoutSplit(userId: String, split: WorkoutSplit) async throws {
        let splitRef = db.collection("users").document(userId).collection("workoutSplits").document(split.id!)
        var splitData = split
        splitData.updatedAt = Timestamp(date: Date())
        
        try await splitRef.setData(from: splitData, merge: true)
    }

    // MARK: - Completed Workouts

    func saveCompletedWorkout(userId: String, date: String, workoutData: CompletedWorkout) async throws {
        let workoutRef = db.collection("completedWorkouts").document("\(userId)_\(date)")
        try await workoutRef.setData(from: workoutData)
    }
    
    func getCompletedWorkouts(userId: String) async throws -> [CompletedWorkout] {
        let workoutsQuery = db.collection("completedWorkouts")
            .whereField("userId", isEqualTo: userId)
        let querySnapshot = try await workoutsQuery.getDocuments()
        
        return querySnapshot.documents.compactMap { document in
            try? document.data(as: CompletedWorkout.self)
        }
    }

    func deleteCompletedWorkout(userId: String, date: String) async throws {
        let workoutRef = db.collection("completedWorkouts").document("\(userId)_\(date)")
        try await workoutRef.delete()
    }
    
    // MARK: - Workout History

    func saveWorkoutHistoryEntry(userId: String, entry: WorkoutHistory) async throws {
        let historyRef = db.collection("workoutHistory").document()
        try await historyRef.setData(from: entry)
    }

    func deleteUserWorkoutHistory(userId: String, date: String) async throws {
        let historyQuery = db.collection("workoutHistory")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isEqualTo: date)
        
        let querySnapshot = try await historyQuery.getDocuments()
        
        let batch = db.batch()
        for document in querySnapshot.documents {
            batch.deleteDocument(document.reference)
        }
        
        try await batch.commit()
    }
}
