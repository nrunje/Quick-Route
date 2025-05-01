import SwiftUI

struct SettingsView: View {
    // Pull the shared object from the environment
    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Units")) {
                    Toggle(
                        "Use Metric Units",
                        isOn: $appSettings.useMetricUnits      // 👈 bound directly
                    )
                }
            }
            .navigationTitle("Settings")
        }
    }
}

//#Preview {
//    static var previews: some View {
//        SettingsView()
//            .environmentObject(AppSettings())   // give a dummy instance for preview
//    }
//}
