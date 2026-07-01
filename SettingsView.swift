import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var state: AppState

    @State private var difficulty: Difficulty = .medium
    @State private var emphasisRaw: String = "None"
    @State private var equipment: Set<Equipment> = [.noEquipment, .household]
    @State private var days: Int = 7
    @State private var muscleGroupsPerWorkout: Int = 2
    @State private var exercisesPerGroup: Int = 3

    var exercisesPerDay: Int {
        max(5, muscleGroupsPerWorkout * exercisesPerGroup)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Assessment") {
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(Difficulty.allCases) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }

                    Picker("Emphasis", selection: $emphasisRaw) {
                        Text("None").tag("None")
                        ForEach(MuscleGroup.allCases) { group in
                            Text(group.rawValue).tag(group.rawValue)
                        }
                    }

                    Stepper("\(days) training days / week", value: $days, in: 3...7)
                    Stepper("\(muscleGroupsPerWorkout) muscle groups / workout", value: $muscleGroupsPerWorkout, in: 1...4)
                    Stepper("\(exercisesPerGroup) exercises / muscle group", value: $exercisesPerGroup, in: 2...4)

                    Text("\(exercisesPerDay) exercises per workout")
                        .foregroundStyle(ForgeTheme.accent)

                    Button("Apply and rebuild weekly plan") {
                        let emphasis = emphasisRaw == "None" ? nil : MuscleGroup(rawValue: emphasisRaw)

                        state.updateAssessment(
                            difficulty: difficulty,
                            emphasis: emphasis,
                            equipment: equipment,
                            days: days,
                            muscleGroupsPerWorkout: muscleGroupsPerWorkout,
                            exercisesPerGroup: exercisesPerGroup
                        )
                    }
                }

                Section("Equipment") {
                    ForEach(Equipment.allCases) { item in
                        Toggle(item.rawValue, isOn: Binding(
                            get: { equipment.contains(item) },
                            set: { value in
                                if value {
                                    equipment.insert(item)
                                } else if item != .noEquipment {
                                    equipment.remove(item)
                                }
                            }
                        ))
                    }
                }

                Section("Data") {
                    Button("Reset app data", role: .destructive) {
                        state.resetAllData()
                    }
                }

                Section("Pro") {
                    Button("Try Pro free for 7 days") {}
                    Button("Restore Purchases") {}
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                difficulty = state.assessment.difficulty
                emphasisRaw = state.assessment.emphasis?.rawValue ?? "None"
                equipment = state.selectedEquipment
                days = state.assessment.availableDays
                muscleGroupsPerWorkout = state.assessment.muscleGroupsPerWorkout
                exercisesPerGroup = state.assessment.exercisesPerGroup
            }
        }
    }
}
