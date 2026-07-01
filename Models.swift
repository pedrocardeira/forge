import Foundation
import SwiftUI

enum MuscleGroup: String, CaseIterable, Identifiable, Codable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case legs = "Legs"
    case glutes = "Glutes"
    case abs = "Abs"
    case mobility = "Mobility"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .chest: return "figure.strengthtraining.traditional"
        case .back: return "figure.core.training"
        case .shoulders: return "figure.arms.open"
        case .biceps: return "dumbbell"
        case .triceps: return "figure.strengthtraining.functional"
        case .legs: return "figure.run"
        case .glutes: return "figure.walk"
        case .abs: return "figure.core.training"
        case .mobility: return "figure.flexibility"
        }
    }
}

enum Equipment: String, CaseIterable, Identifiable, Codable {
    case noEquipment = "No Equipment"
    case household = "Household Objects"
    case dumbbells = "Dumbbells"
    case resistanceBands = "Resistance Bands"
    case pullUpBar = "Pull-up Bar"
    case bench = "Bench"
    case kettlebell = "Kettlebell"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .noEquipment: return "figure.strengthtraining.traditional"
        case .household: return "house.fill"
        case .dumbbells: return "dumbbell"
        case .resistanceBands: return "point.3.connected.trianglepath.dotted"
        case .pullUpBar: return "rectangle.split.3x1"
        case .bench: return "rectangle.roundedtop"
        case .kettlebell: return "scalemass"
        }
    }
}

enum Difficulty: String, CaseIterable, Identifiable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var id: String { rawValue }

    var setCount: Int {
        switch self {
        case .easy: return 2
        case .medium: return 3
        case .hard: return 4
        }
    }

    var repMultiplier: Double {
        switch self {
        case .easy: return 0.85
        case .medium: return 1.0
        case .hard: return 1.2
        }
    }

    var restSeconds: Int {
        switch self {
        case .easy: return 75
        case .medium: return 60
        case .hard: return 45
        }
    }
}

enum ExerciseLevel: String, CaseIterable, Identifiable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    var id: String { rawValue }
}

enum WorkoutStatus: String, Codable {
    case pending
    case completed
}

struct Exercise: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var muscleGroup: MuscleGroup
    var primaryMuscles: [String]
    var secondaryMuscles: [String]
    var equipment: [Equipment]
    var level: ExerciseLevel
    var videoName: String
    var remoteVideoURL: String? = nil
    var instructions: [String]
    var mistakes: [String]

    init(
        id: UUID = UUID(),
        name: String,
        muscleGroup: MuscleGroup,
        primaryMuscles: [String],
        secondaryMuscles: [String],
        equipment: [Equipment],
        level: ExerciseLevel,
        videoName: String,
        remoteVideoURL: String? = nil,
        instructions: [String],
        mistakes: [String]
    ) {
        self.id = id
        self.name = name
        self.muscleGroup = muscleGroup
        self.primaryMuscles = primaryMuscles
        self.secondaryMuscles = secondaryMuscles
        self.equipment = equipment
        self.level = level
        self.videoName = videoName
        self.remoteVideoURL = remoteVideoURL
        self.instructions = instructions
        self.mistakes = mistakes
    }
}

struct WorkoutExercise: Identifiable, Codable, Hashable {
    var id = UUID()
    var exercise: Exercise
    var sets: Int
    var reps: Int
    var restSeconds: Int
}

struct WorkoutPlan: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var focus: String
    var exercises: [WorkoutExercise]
    var estimatedMinutes: Int
    var targetMuscles: [MuscleGroup] = []
    var status: WorkoutStatus = .pending
    var completedAt: Date? = nil
    var actualDurationSeconds: Int? = nil
}

struct WorkoutHistory: Identifiable, Codable {
    var id = UUID()
    var workoutName: String
    var date: Date
    var durationMinutes: Int
    var exercisesCompleted: Int
}

struct UserAssessment: Codable {
    var difficulty: Difficulty
    var emphasis: MuscleGroup?
    var selectedEquipment: Set<Equipment>
    var availableDays: Int
    var targetMinutes: Int
    var muscleGroupsPerWorkout: Int
    var exercisesPerGroup: Int

    var exercisesPerDay: Int {
        max(5, muscleGroupsPerWorkout * exercisesPerGroup)
    }

    static let defaultValue = UserAssessment(
        difficulty: .medium,
        emphasis: nil,
        selectedEquipment: [.noEquipment, .household],
        availableDays: 7,
        targetMinutes: 35,
        muscleGroupsPerWorkout: 2,
        exercisesPerGroup: 3
    )
}

struct WorkoutReport: Identifiable, Codable {
    var id = UUID()
    var workoutName: String
    var completedAt: Date
    var plannedMinutes: Int
    var actualSeconds: Int
    var exercisesCompleted: Int
    var totalSets: Int

    var actualMinutesText: String {
        let minutes = actualSeconds / 60
        let seconds = actualSeconds % 60
        return "\(minutes)m \(seconds)s"
    }
}

struct PersistedReplyState: Codable {
    var assessment: UserAssessment
    var selectedEquipment: Set<Equipment>
    var workouts: [WorkoutPlan]
    var history: [WorkoutHistory]
    var reports: [WorkoutReport]
    var isOnboarded: Bool
}
