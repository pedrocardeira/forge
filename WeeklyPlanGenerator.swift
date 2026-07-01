import Foundation

enum WeeklyPlanGenerator {
    static func generatePlan(from exercises: [Exercise], assessment: UserAssessment) -> [WorkoutPlan] {
        let available = filterExercises(exercises, assessment: assessment)

        let preferredPool: [MuscleGroup] = [
            .chest,
            .back,
            .legs,
            .shoulders,
            .biceps,
            .triceps,
            .glutes,
            .abs,
            .mobility
        ]

        let weeklyPool = preferredPool.filter { group in
            available.contains { $0.muscleGroup == group }
        }

        guard !weeklyPool.isEmpty else {
            return []
        }

        var plans: [WorkoutPlan] = []
        var previousGroups = Set<MuscleGroup>()
        var lastEmphasisDay: Int? = nil

        for day in 0..<assessment.availableDays {
            let groups = groupsForDay(
                day: day,
                weeklyPool: weeklyPool,
                targetCount: assessment.muscleGroupsPerWorkout,
                emphasis: assessment.emphasis,
                previousGroups: previousGroups,
                lastEmphasisDay: lastEmphasisDay
            )

            if let emphasis = assessment.emphasis, groups.contains(emphasis) {
                lastEmphasisDay = day
            }

            let selected = selectExercises(
                from: available,
                groups: groups,
                emphasis: assessment.emphasis,
                exercisesPerGroup: assessment.exercisesPerGroup,
                minimumTotal: 5,
                avoidGroups: previousGroups
            )

            let workoutExercises = selected.map {
                makeWorkoutExercise($0, difficulty: assessment.difficulty)
            }

            let name = groups.map(\.rawValue).joined(separator: " + ")

            plans.append(
                WorkoutPlan(
                    name: name,
                    focus: name,
                    exercises: workoutExercises,
                    estimatedMinutes: assessment.targetMinutes,
                    targetMuscles: groups,
                    status: .pending,
                    completedAt: nil,
                    actualDurationSeconds: nil
                )
            )

            previousGroups = Set(groups)
        }

        return plans
    }

    private static func groupsForDay(
        day: Int,
        weeklyPool: [MuscleGroup],
        targetCount: Int,
        emphasis: MuscleGroup?,
        previousGroups: Set<MuscleGroup>,
        lastEmphasisDay: Int?
    ) -> [MuscleGroup] {
        let safeTarget = min(max(1, targetCount), min(4, weeklyPool.count))
        var groups: [MuscleGroup] = []

        if let emphasis,
           weeklyPool.contains(emphasis),
           !previousGroups.contains(emphasis),
           lastEmphasisDay == nil || day - (lastEmphasisDay ?? -10) > 1 {
            groups.append(emphasis)
        }

        let startIndex = (day * safeTarget) % weeklyPool.count

        for offset in 0..<(weeklyPool.count * 2) {
            guard groups.count < safeTarget else { break }

            let group = weeklyPool[(startIndex + offset) % weeklyPool.count]

            if !groups.contains(group) && !previousGroups.contains(group) {
                groups.append(group)
            }
        }

        if groups.count < safeTarget {
            for group in weeklyPool where groups.count < safeTarget {
                if !groups.contains(group) {
                    groups.append(group)
                }
            }
        }

        return groups
    }

    private static func filterExercises(_ exercises: [Exercise], assessment: UserAssessment) -> [Exercise] {
        exercises.filter { exercise in
            let equipmentMatch = exercise.equipment.isEmpty || exercise.equipment.contains {
                assessment.selectedEquipment.contains($0)
            }

            let difficultyMatch: Bool
            switch assessment.difficulty {
            case .easy:
                difficultyMatch = exercise.level == .easy
            case .medium:
                difficultyMatch = exercise.level == .easy || exercise.level == .medium
            case .hard:
                difficultyMatch = true
            }

            return equipmentMatch && difficultyMatch
        }
    }

    private static func selectExercises(
        from exercises: [Exercise],
        groups: [MuscleGroup],
        emphasis: MuscleGroup?,
        exercisesPerGroup: Int,
        minimumTotal: Int,
        avoidGroups: Set<MuscleGroup>
    ) -> [Exercise] {
        var selected: [Exercise] = []
        let perGroup = min(max(2, exercisesPerGroup), 4)

        for group in groups {
            var target = perGroup

            if group == emphasis {
                target += 1
            }

            let groupPool = exercises.filter {
                $0.muscleGroup == group && !selected.contains($0)
            }

            selected.append(contentsOf: groupPool.prefix(target))
        }

        if selected.count < minimumTotal {
            let sameWorkoutGroupFallback = exercises.filter {
                !selected.contains($0) && groups.contains($0.muscleGroup)
            }

            selected.append(contentsOf: sameWorkoutGroupFallback.prefix(minimumTotal - selected.count))
        }

        if selected.count < minimumTotal {
            let nonPreviousFallback = exercises.filter {
                !selected.contains($0) && !avoidGroups.contains($0.muscleGroup)
            }

            selected.append(contentsOf: nonPreviousFallback.prefix(minimumTotal - selected.count))
        }

        if selected.count < minimumTotal {
            let anyFallback = exercises.filter {
                !selected.contains($0)
            }

            selected.append(contentsOf: anyFallback.prefix(minimumTotal - selected.count))
        }

        return selected
    }

    private static func makeWorkoutExercise(_ exercise: Exercise, difficulty: Difficulty) -> WorkoutExercise {
        let baseReps = exercise.muscleGroup == .abs || exercise.muscleGroup == .mobility ? 35 : 12

        return WorkoutExercise(
            exercise: exercise,
            sets: difficulty.setCount,
            reps: max(6, Int(Double(baseReps) * difficulty.repMultiplier)),
            restSeconds: difficulty.restSeconds
        )
    }

    static func nextPendingWorkout(in plans: [WorkoutPlan]) -> WorkoutPlan? {
        plans.first { $0.status == .pending }
    }

    static func allCompleted(_ plans: [WorkoutPlan]) -> Bool {
        !plans.isEmpty && plans.allSatisfy { $0.status == .completed }
    }
}
