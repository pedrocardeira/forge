import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var state: AppState

    @State private var difficulty: Difficulty = .medium
    @State private var emphasis: MuscleGroup? = nil
    @State private var equipment: Set<Equipment> = [.noEquipment, .household]
    @State private var days = 7
    @State private var muscleGroupsPerWorkout = 2
    @State private var exercisesPerGroup = 3

    var exercisesPerDay: Int {
        max(5, muscleGroupsPerWorkout * exercisesPerGroup)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 54))
                        .foregroundStyle(ForgeTheme.accent)

                    Text("Reply")
                        .font(.system(size: 42, weight: .black, design: .rounded))

                    Text("Your 35-minute weekly home strength plan.")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                Card {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Difficulty")
                            .font(.headline)

                        Picker("Difficulty", selection: $difficulty) {
                            ForEach(Difficulty.allCases) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)

                        Text("Easy, Medium and Hard change exercise selection, sets, reps and rest.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Workout structure")
                            .font(.headline)

                        Stepper("\(muscleGroupsPerWorkout) muscle groups / workout", value: $muscleGroupsPerWorkout, in: 1...4)
                        Stepper("\(exercisesPerGroup) exercises / muscle group", value: $exercisesPerGroup, in: 2...4)

                        Text("\(exercisesPerDay) exercises per workout")
                            .font(.headline)
                            .foregroundStyle(ForgeTheme.accent)

                        Text("Reply never creates fewer than 5 exercises per day.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Give more emphasis to")
                            .font(.headline)

                        Picker(
                            "Emphasis",
                            selection: Binding(
                                get: { emphasis?.rawValue ?? "None" },
                                set: { value in
                                    emphasis = value == "None" ? nil : MuscleGroup(rawValue: value)
                                }
                            )
                        ) {
                            Text("None").tag("None")
                            ForEach(MuscleGroup.allCases) { group in
                                Text(group.rawValue).tag(group.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("What do you have at home?")
                            .font(.headline)

                        ForEach(Equipment.allCases) { item in
                            Button {
                                if equipment.contains(item) {
                                    if item != .noEquipment {
                                        equipment.remove(item)
                                    }
                                } else {
                                    equipment.insert(item)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: equipment.contains(item) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(equipment.contains(item) ? ForgeTheme.accent : .secondary)
                                    Image(systemName: item.icon)
                                        .foregroundStyle(.secondary)
                                    Text(item.rawValue)
                                    Spacer()
                                }
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.primary)
                            }
                        }
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Weekly target")
                            .font(.headline)

                        Stepper("\(days) training days / week", value: $days, in: 3...7)

                        Text("Every day starts with the next unfinished workout. Completed workouts are not repeated until the weekly plan is done.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                PrimaryButton(title: "Create my weekly plan", icon: "calendar.badge.plus") {
                    state.updateAssessment(
                        difficulty: difficulty,
                        emphasis: emphasis,
                        equipment: equipment,
                        days: days,
                        muscleGroupsPerWorkout: muscleGroupsPerWorkout,
                        exercisesPerGroup: exercisesPerGroup
                    )
                    state.isOnboarded = true
                }
            }
            .padding(20)
        }
        .background(ForgeTheme.background.ignoresSafeArea())
    }
}
