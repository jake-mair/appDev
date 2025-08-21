//
//  FirestoreService.swift
//  GymPumped
//

import FirebaseFirestore
import Foundation

// Note: These structs are simplified for this example. You will need to create more comprehensive Swift structs that match your Firestore data model.

struct WorkoutSplit: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var schedule: [String: WorkoutDay]
    var startDate: String
    var endDate: String
    var isActive: Bool
    var isPlanned: Bool?
    var userId: String?
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

class FirestoreService {
    private let db = Firestore.firestore()

    // MARK: - Workout Splits

    func saveWorkoutSplit(userId: String, split: WorkoutSplit) async throws {
        let splitRef = db.collection("workoutSplits").document(split.id ?? UUID().uuidString)
        var splitData = split
        splitData.userId = userId
        splitData.createdAt = Timestamp(date: Date())
        splitData.updatedAt = Timestamp(date: Date())
        
        try await splitRef.setData(from: splitData)
    }

    func getUserWorkoutSplits(userId: String) async throws -> [WorkoutSplit] {
        let splitsQuery = db.collection("workoutSplits")
                            .whereField("userId", isEqualTo: userId)
                            .order(by: "createdAt", descending: true)
        let querySnapshot = try await splitsQuery.getDocuments()
        
        return querySnapshot.documents.compactMap { document in
            try? document.data(as: WorkoutSplit.self)
        }
    }
}
