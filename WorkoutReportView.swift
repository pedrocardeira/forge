import SwiftUI

struct WorkoutReportView: View {
    let report:WorkoutReport
    var onDone:(()->Void)? = nil
    @Environment(\.dismiss) private var dismiss
    var body: some View { NavigationStack{ VStack(spacing:20){ Image(systemName:"checkmark.seal.fill").font(.system(size:70)).foregroundStyle(.green); Text("Workout Complete").font(.largeTitle.bold()); Text(report.workoutName).font(.title3).foregroundStyle(.secondary); VStack(spacing:14){ row("Planned time","\(report.plannedMinutes) min","timer"); row("Actual time",report.actualMinutesText,"clock.fill"); row("Exercises","\(report.exercisesCompleted)","figure.strengthtraining.traditional"); row("Total sets","\(report.totalSets)","number") }.padding(.top,10); Spacer(); PrimaryButton(title:"Done",icon:"checkmark"){ if let onDone { onDone() } else { dismiss() } } }.padding(24).background(ForgeTheme.background.ignoresSafeArea()).navigationTitle("Report").navigationBarTitleDisplayMode(.inline) } }
    func row(_ title:String,_ value:String,_ icon:String) -> some View { Card{ HStack{ Image(systemName:icon).foregroundStyle(ForgeTheme.accent).frame(width:28); Text(title).font(.headline); Spacer(); Text(value).font(.headline.bold()).foregroundStyle(.secondary) } } }
}
