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
        "monday": "Select workout",
        "tuesday": "Select workout",
        "wednesday": "Select workout",
        "thursday": "Select workout",
        "friday": "Select workout",
        "saturday": "Select workout",
        "sunday": "Select workout"
    ]
    
    let daysOfWeek = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
    let workoutOptions = ["Select workout", "Rest", "Push", "Pull", "Legs", "Upper", "Lower", "Full Body", "Cardio"]

    var body: some View {
        VStack(spacing: 20) {
            // Modal Header
            HStack {
                Text("Create Workout Split")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .padding(.bottom, 10)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Split Name Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Split Name")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("e.g., PPL - Summer 2025", text: $splitName)
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    
                    // Start and End Date Inputs
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Start Date")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            DatePicker("", selection: $startDate, displayedComponents: .date)
                                .labelsHidden()
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.cardBackground)
                                .cornerRadius(8)
                                .accentColor(.white)
                            
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("End Date")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            DatePicker("", selection: $endDate, displayedComponents: .date)
                                .labelsHidden()
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.cardBackground)
                                .cornerRadius(8)
                                .accentColor(.white)
                        }
                    }
                    
                    // Weekly Schedule
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekly Schedule")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        ForEach(daysOfWeek, id: \.self) { day in
                            HStack {
                                Text(day.capitalized)
                                    .frame(width: 80, alignment: .leading)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                // This button now has a menu attached to it
                                Menu {
                                    ForEach(workoutOptions, id: \.self) { workout in
                                        Button(workout) {
                                            schedule[day] = workout
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(schedule[day] ?? "Select workout")
                                            .foregroundColor(.white)
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color.cardBackground)
                                    .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            // Action Buttons
            HStack(spacing: 16) {
                Button("Cancel") {
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.cardBackground)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Create Split") {
                    saveSplit()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient.accentGradient)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.darkBackground)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: CGFloat(15))
                .stroke(Color.purple, lineWidth: 2)
            
        )
            
        
    }

    private func saveSplit() {

        let newSchedule: [String: WorkoutDay] = schedule.mapValues { workoutType in
            WorkoutDay(workoutType: workoutType == "Select workout" ? "Rest" : workoutType, exercises: [])
        }
        
        let newSplit = WorkoutSplit(
            name: splitName,
            schedule: newSchedule,
            startDate: startDate.formatted(date: .numeric, time: .omitted),
            endDate: endDate.formatted(date: .numeric, time: .omitted),
            isActive: false
        )
        
        onSave(newSplit)
        dismiss()
    }
}

#Preview {
    CreateSplitModalView(onSave: { _ in })
        .environmentObject(AuthService())
}
