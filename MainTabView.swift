import SwiftUI

struct MainTabView: View { var body: some View { TabView { HomeView().tabItem{Label("Home",systemImage:"house.fill")}; ExerciseLibraryView().tabItem{Label("Exercises",systemImage:"figure.strengthtraining.traditional")}; WorkoutsView().tabItem{Label("Workouts",systemImage:"list.bullet.rectangle")}; ProgressViewScreen().tabItem{Label("Progress",systemImage:"chart.line.uptrend.xyaxis")}; SettingsView().tabItem{Label("Settings",systemImage:"gearshape.fill")} }.tint(ForgeTheme.accent) } }
