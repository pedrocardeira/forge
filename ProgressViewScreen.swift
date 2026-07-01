import SwiftUI

struct ProgressViewScreen: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    HStack(spacing: 14) {
                        QuickStat(title: "Target", value: "35m", icon: "timer")
                        QuickStat(title: "Week", value: state.weeklyProgressText, icon: "calendar")
                    }

                    HStack(spacing: 14) {
                        QuickStat(title: "Workouts", value: "\(state.history.count)", icon: "checkmark.circle.fill")
                        QuickStat(title: "Reports", value: "\(state.reports.count)", icon: "doc.text.fill")
                    }

                    if !state.reports.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Workout reports")
                                .font(.headline)

                            ForEach(state.reports) { report in
                                WorkoutReportCompactCard(report: report)
                            }
                        }
                    }

                    Card {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("History")
                                .font(.headline)

                            if state.history.isEmpty {
                                Text("Complete your first workout to see history here.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(state.history) { item in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(item.workoutName)
                                                .font(.subheadline.bold())
                                            Text(item.date.formatted(date: .abbreviated, time: .omitted))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text("\(item.durationMinutes)m")
                                            .font(.subheadline.bold())
                                    }
                                    Divider()
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(ForgeTheme.background.ignoresSafeArea())
            .navigationTitle("Progress")
        }
    }
}

struct WorkoutReportCompactCard: View {
    var report: WorkoutReport

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(report.workoutName)
                        .font(.headline)
                    Spacer()
                    Text(report.actualMinutesText)
                        .font(.headline.bold())
                        .foregroundStyle(ForgeTheme.accent)
                }

                Text("Planned \(report.plannedMinutes)m • \(report.exercisesCompleted) exercises • \(report.totalSets) sets")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
