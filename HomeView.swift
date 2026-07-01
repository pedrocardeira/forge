import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var state: AppState
    @State private var showWorkout = false
    @State private var showReport: WorkoutReport?

    var todayWorkout: WorkoutPlan {
        state.nextWorkout
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(state.weeklyProgressText)
                                .foregroundStyle(.secondary)
                            Text(WeeklyPlanGenerator.allCompleted(state.workouts) ? "Week complete" : "My Workout")
                                .font(.largeTitle.bold())
                        }
                        Spacer()
                    }

                    Card {
                        VStack(alignment: .leading, spacing: 18) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(todayWorkout.name)
                                        .font(.title2.bold())
                                    Text(todayWorkout.focus)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                VStack(spacing: 4) {
                                    Image(systemName: "timer")
                                    Text("\(todayWorkout.estimatedMinutes)m")
                                        .font(.caption.bold())
                                }
                                .padding(12)
                                .background(ForgeTheme.soft)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }

                            HStack(spacing: 8) {
                                Label(state.assessment.difficulty.rawValue, systemImage: "slider.horizontal.3")
                                Spacer()
                                Label("\(todayWorkout.exercises.count) exercises", systemImage: "list.number")
                            }
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)

                            PrimaryButton(title: WeeklyPlanGenerator.allCompleted(state.workouts) ? "Restart Weekly Plan" : "Start Workout", icon: WeeklyPlanGenerator.allCompleted(state.workouts) ? "arrow.clockwise" : "play.fill") {
                                if WeeklyPlanGenerator.allCompleted(state.workouts) {
                                    state.regenerateWeeklyPlan()
                                } else {
                                    showWorkout = true
                                }
                            }
                        }
                    }

                    HStack(spacing: 14) {
                        QuickStat(title: "Target", value: "35m", icon: "timer")
                        QuickStat(title: "Left", value: "\(state.workouts.filter { $0.status == .pending }.count)", icon: "calendar")
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Weekly Plan")
                            .font(.headline)

                        ForEach(state.workouts) { workout in
                            Card {
                                HStack(spacing: 12) {
                                    Image(systemName: workout.status == .completed ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(workout.status == .completed ? .green : ForgeTheme.accent)
                                        .font(.title2)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(workout.name)
                                            .font(.headline)
                                        Text("\(workout.exercises.count) exercises • \(workout.estimatedMinutes) min")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }

                    if let last = state.reports.first {
                        Button { showReport = last } label: {
                            Card {
                                HStack {
                                    Image(systemName: "doc.text.magnifyingglass")
                                        .foregroundStyle(ForgeTheme.accent)
                                    VStack(alignment: .leading) {
                                        Text("Last workout report")
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Text("\(last.workoutName) • \(last.actualMinutesText)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(ForgeTheme.background.ignoresSafeArea())
            .navigationTitle("Reply")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showWorkout) {
                WorkoutModeView(workout: todayWorkout)
                    .environmentObject(state)
            }
            .sheet(item: $showReport) { report in
                WorkoutReportView(report: report)
            }
        }
    }
}

struct QuickStat: View {
    var title: String
    var value: String
    var icon: String

    var body: some View {
        Card {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(ForgeTheme.accent)
                VStack(alignment: .leading) {
                    Text(value)
                        .font(.title.bold())
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
    }
}
