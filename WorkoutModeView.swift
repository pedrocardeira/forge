import SwiftUI

struct WorkoutModeView: View {
    @EnvironmentObject private var state: AppState
    let workout: WorkoutPlan
    @Environment(\.dismiss) private var dismiss

    @State private var exerciseIndex = 0
    @State private var currentSet = 1
    @State private var restRemaining: Int = 0
    @State private var elapsedSeconds: Int = 0
    @State private var timer: Timer?
    @State private var showReport: WorkoutReport?

    var current: WorkoutExercise {
        workout.exercises[min(exerciseIndex, workout.exercises.count - 1)]
    }

    var progress: Double {
        guard !workout.exercises.isEmpty else { return 0 }
        let totalSets = workout.exercises.reduce(0) { $0 + $1.sets }
        let completedBefore = workout.exercises.prefix(exerciseIndex).reduce(0) { $0 + $1.sets }
        return Double(completedBefore + currentSet - 1) / Double(max(1, totalSets))
    }

    var elapsedText: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return "\(m)m \(String(format: "%02d", s))s"
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 14) {
                HStack {
                    Button("Close") { dismiss() }
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                    Text(elapsedText)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.75))
                }

                ReplyExerciseVideoPlayer(exercise: current.exercise, height: 255)

                VStack(spacing: 9) {
                    Text("Exercise \(exerciseIndex + 1) of \(workout.exercises.count)")
                        .foregroundStyle(.white.opacity(0.55))

                    Text(current.exercise.name.uppercased())
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("Set \(currentSet) of \(current.sets)")
                        .font(.title3.bold())
                        .foregroundStyle(.white.opacity(0.7))

                    HStack(spacing: 16) {
                        Button { adjustReps(-1) } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title)
                        }

                        Text("\(current.reps) reps")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(ForgeTheme.accent)

                        Button { adjustReps(1) } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                        }
                    }
                    .foregroundStyle(ForgeTheme.accent)

                    ProgressView(value: progress)
                        .tint(ForgeTheme.accent)
                        .padding(.horizontal)
                }

                if restRemaining > 0 {
                    VStack(spacing: 4) {
                        Text("REST")
                            .foregroundStyle(.white.opacity(0.5))
                        Text("\(restRemaining)")
                            .font(.system(size: 52, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }

                Spacer(minLength: 4)

                HStack(spacing: 14) {
                    Button { skip() } label: {
                        Text("Skip")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.white.opacity(0.12))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }

                    Button { doneSet() } label: {
                        Text(restRemaining > 0 ? "Skip Rest" : "Done")
                            .fontWeight(.heavy)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ForgeTheme.accent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }
            }
            .padding(24)
        }
        .onAppear { startMainTimer() }
        .onDisappear { timer?.invalidate() }
        .sheet(item: $showReport) { report in
            WorkoutReportView(report: report) {
                dismiss()
            }
        }
    }

    private func startMainTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
            if restRemaining > 0 {
                restRemaining -= 1
            }
        }
    }

    private func adjustReps(_ delta: Int) {
        let newReps = max(1, current.reps + delta)
        state.updateReps(workoutID: workout.id, exerciseID: current.id, reps: newReps)
    }

    private func doneSet() {
        if restRemaining > 0 {
            restRemaining = 0
            return
        }

        if currentSet < current.sets {
            currentSet += 1
            restRemaining = current.restSeconds
        } else {
            nextExercise()
        }
    }

    private func skip() {
        nextExercise()
    }

    private func nextExercise() {
        restRemaining = 0

        if exerciseIndex + 1 < workout.exercises.count {
            exerciseIndex += 1
            currentSet = 1
        } else {
            finishWorkout()
        }
    }

    private func finishWorkout() {
        timer?.invalidate()
        state.completeWorkout(workout, actualSeconds: max(1, elapsedSeconds))
        showReport = state.reports.first
    }
}
