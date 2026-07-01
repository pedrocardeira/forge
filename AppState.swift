import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var assessment: UserAssessment = .defaultValue { didSet { save() } }
    @Published var selectedEquipment: Set<Equipment> = [.noEquipment, .household] { didSet { save() } }
    @Published var workouts: [WorkoutPlan] = [] { didSet { save() } }
    @Published var history: [WorkoutHistory] = [] { didSet { save() } }
    @Published var reports: [WorkoutReport] = [] { didSet { save() } }
    @Published var isOnboarded: Bool = false { didSet { save() } }

    private let storageKey = "reply.persisted.state.v13"
    private var isLoading = false

    init() {
        load()
        if workouts.isEmpty || hasConsecutiveMuscleOverlap(workouts) {
            regenerateWeeklyPlan()
        }
    }

    var availableExercises: [Exercise] {
        DemoData.exercises.filter { exercise in
            exercise.equipment.isEmpty || exercise.equipment.contains { selectedEquipment.contains($0) }
        }
    }

    var nextWorkout: WorkoutPlan {
        WeeklyPlanGenerator.nextPendingWorkout(in: workouts) ?? workouts.first ?? DemoData.sampleWorkout
    }

    var weeklyProgressText: String {
        let completed = workouts.filter { $0.status == .completed }.count
        return "\(completed)/\(workouts.count) completed"
    }


    private func hasConsecutiveMuscleOverlap(_ plans: [WorkoutPlan]) -> Bool {
        guard plans.count > 1 else { return false }

        for index in 1..<plans.count {
            let previous = muscleGroups(for: plans[index - 1])
            let current = muscleGroups(for: plans[index])

            if !previous.isDisjoint(with: current) {
                return true
            }
        }

        return false
    }

    private func muscleGroups(for workout: WorkoutPlan) -> Set<MuscleGroup> {
        if !workout.targetMuscles.isEmpty {
            return Set(workout.targetMuscles)
        }

        return Set(workout.exercises.map { $0.exercise.muscleGroup })
    }

    func completeWorkout(_ workout: WorkoutPlan, actualSeconds: Int) {
        guard let index = workouts.firstIndex(where: { $0.id == workout.id }) else { return }

        workouts[index].status = .completed
        workouts[index].completedAt = Date()
        workouts[index].actualDurationSeconds = actualSeconds

        let totalSets = workout.exercises.reduce(0) { $0 + $1.sets }

        let report = WorkoutReport(
            workoutName: workout.name,
            completedAt: Date(),
            plannedMinutes: workout.estimatedMinutes,
            actualSeconds: actualSeconds,
            exercisesCompleted: workout.exercises.count,
            totalSets: totalSets
        )

        reports.insert(report, at: 0)
        history.insert(
            WorkoutHistory(
                workoutName: workout.name,
                date: Date(),
                durationMinutes: max(1, actualSeconds / 60),
                exercisesCompleted: workout.exercises.count
            ),
            at: 0
        )
    }

    func regenerateWeeklyPlan() {
        assessment.selectedEquipment = selectedEquipment
        workouts = WeeklyPlanGenerator.generatePlan(from: DemoData.exercises, assessment: assessment)
    }

    func updateAssessment(
        difficulty: Difficulty,
        emphasis: MuscleGroup?,
        equipment: Set<Equipment>,
        days: Int,
        muscleGroupsPerWorkout: Int,
        exercisesPerGroup: Int
    ) {
        assessment.difficulty = difficulty
        assessment.emphasis = emphasis
        assessment.selectedEquipment = equipment
        assessment.availableDays = days
        assessment.targetMinutes = 35
        assessment.muscleGroupsPerWorkout = muscleGroupsPerWorkout
        assessment.exercisesPerGroup = exercisesPerGroup
        selectedEquipment = equipment
        regenerateWeeklyPlan()
    }

    func addExerciseToFirstWorkout(_ exercise: Exercise) {
        if workouts.isEmpty {
            workouts.append(
                WorkoutPlan(
                    name: "My Workout",
                    focus: exercise.muscleGroup.rawValue,
                    exercises: [],
                    estimatedMinutes: 35,
                    targetMuscles: [exercise.muscleGroup]
                )
            )
        }

        workouts[0].exercises.append(
            WorkoutExercise(
                exercise: exercise,
                sets: assessment.difficulty.setCount,
                reps: 12,
                restSeconds: assessment.difficulty.restSeconds
            )
        )
    }

    func updateReps(workoutID: UUID, exerciseID: UUID, reps: Int) {
        guard let wIndex = workouts.firstIndex(where: { $0.id == workoutID }),
              let eIndex = workouts[wIndex].exercises.firstIndex(where: { $0.id == exerciseID }) else { return }
        workouts[wIndex].exercises[eIndex].reps = max(1, reps)
    }

    func resetAllData() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        isLoading = true
        assessment = .defaultValue
        selectedEquipment = [.noEquipment, .household]
        history = []
        reports = []
        isOnboarded = false
        isLoading = false
        regenerateWeeklyPlan()
        save()
    }

    private func save() {
        guard !isLoading else { return }

        let state = PersistedReplyState(
            assessment: assessment,
            selectedEquipment: selectedEquipment,
            workouts: workouts,
            history: history,
            reports: reports,
            isOnboarded: isOnboarded
        )

        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let state = try? JSONDecoder().decode(PersistedReplyState.self, from: data) else {
            return
        }

        isLoading = true
        assessment = state.assessment
        selectedEquipment = state.selectedEquipment
        workouts = state.workouts
        history = state.history
        reports = state.reports
        isOnboarded = state.isOnboarded
        isLoading = false
    }
}
