import SwiftUI

struct SettingsView: View {
    // Pull the shared object from the environment
    @EnvironmentObject var appSettings: AppSettings
    
    // Pull version/build straight from Info.plist
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    var body: some View {
        NavigationView {
            Form {
                // ----- Units selection -----
                Section(header: Text("Units")) {
                    Toggle(
                        "Use Metric Units",
                        isOn: $appSettings.useMetricUnits      // 👈 bound directly
                    )
                }
                
                // NEW: Transport mode picker
                Section(header: Text("Routing Mode")) {
                    Picker("Mode", selection: $appSettings.transportMode) {
                        ForEach(TransportMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)   // feels like Apple Maps
                }
                
                // -------- App info --------------
                Section(header: Text("About")) {
                    // Version row
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("\(appVersion) (\(buildNumber))")
                            .foregroundColor(.secondary)
                    }
                    .accessibilityElement(children: .combine) // better VoiceOver reading
                    .disabled(true)                           // non-interactive
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
