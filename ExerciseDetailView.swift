import SwiftUI
import AVKit

struct ExerciseDetailView: View {
    @EnvironmentObject private var state: AppState
    let exercise: Exercise
    @State private var added = false

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ReplyExerciseVideoPlayer(exercise: exercise, height: 310)
                    .padding(20)

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.name)
                                .font(.largeTitle.bold())
                            Text(exercise.level.rawValue)
                                .font(.headline)
                                .foregroundStyle(ForgeTheme.accent)
                        }
                        Spacer()
                    }

                    PrimaryButton(title: added ? "Added" : "Add to Workout", icon: added ? "checkmark" : "plus") {
                        state.addExerciseToFirstWorkout(exercise)
                        added = true
                    }

                    InfoSection(title: "Primary", items: exercise.primaryMuscles)
                    InfoSection(title: "Secondary", items: exercise.secondaryMuscles)
                    InfoSection(title: "Equipment", items: exercise.equipment.map(\.rawValue))
                    InstructionSection(title: "How to perform", items: exercise.instructions)
                    InstructionSection(title: "Common mistakes", items: exercise.mistakes, warning: true)
                }
                .padding(20)
            }
        }
        .background(ForgeTheme.background.ignoresSafeArea())
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoSection: View {
    var title: String
    var items: [String]

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.headline)
                FlowTags(items: items)
            }
        }
    }
}

struct InstructionSection: View {
    var title: String
    var items: [String]
    var warning: Bool = false

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.headline)

                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: warning ? "xmark.circle.fill" : "checkmark.circle.fill")
                            .foregroundStyle(warning ? .red : ForgeTheme.accent)
                        Text(item)
                    }
                }
            }
        }
    }
}

struct FlowTags: View {
    var items: [String]

    var body: some View {
        HStack {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(ForgeTheme.soft)
                    .clipShape(Capsule())
            }
            Spacer()
        }
    }
}
