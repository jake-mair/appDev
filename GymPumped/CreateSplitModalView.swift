//
//  CreateSplitModalView.swift
//  GymPumped
//

import SwiftUI
import FirebaseAuth

struct CreateSplitModalView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss

    var onSave: (WorkoutSplit) -> Void

    @State private var splitName: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var schedule: [String: String] = [
        "monday": "Rest",
        "tuesday": "Rest",
        "wednesday": "Rest",
        "thursday": "Rest",
        "friday": "Rest",
        "saturday": "Rest",
        "sunday": "Rest"
    ]
    
    let daysOfWeek = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
    let workoutOptions = ["Rest", "Push", "Pull", "Legs", "Upper", "Lower", "Full Body", "Cardio"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Split Details")) {
                    TextField("Split Name", text: $splitName)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }

                Section(header: Text("Weekly Schedule")) {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Picker(day.capitalized, selection: $schedule[day]) {
                            ForEach(workoutOptions, id: \.self) { workout in
                                Text(workout)
                            }
                        }
                    }
                }
                
                Button("Create Split") {
                    saveSplit()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .navigationTitle("Create Workout Split")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
    }

    private func saveSplit() {
        guard let userId = authService.currentUser?.uid else { return }

        let newSchedule: [String: WorkoutDay] = schedule.mapValues { workoutType in
            WorkoutDay(workoutType: workoutType, exercises: [])
        }
        
        let newSplit = WorkoutSplit(
            name: splitName,
            schedule: newSchedule,
            startDate: startDate.formatted(date: .numeric, time: .omitted),
            endDate: endDate.formatted(date: .numeric, time: .omitted),
            isActive: false,
            userId: userId
        )
        
        onSave(newSplit)
        dismiss()
    }
}

#Preview {
    CreateSplitModalView(onSave: { _ in })
        .environmentObject(AuthService())
}
