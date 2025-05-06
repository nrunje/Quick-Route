//
//  Quick_RouteApp.swift
//  Quick Route
//
//  Created by Nicholas Runje on 2/4/25.
//

import SwiftUI

@main
struct Quick_RouteApp: App {
    
    @StateObject private var launchMgr = LaunchManager()
    @StateObject private var appSettings: AppSettings
    @StateObject private var routeVM: RouteViewModel

    init() {
        // one shared instance
        let settings = AppSettings()
        _appSettings = StateObject(wrappedValue: settings)
        _routeVM     = StateObject(wrappedValue: RouteViewModel(appSettings: settings))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appSettings)   // 👈 add these two lines
                .environmentObject(routeVM)
                .fullScreenCover(isPresented: .constant(launchMgr.needsWelcome)) {
                    WelcomePager {
                        launchMgr.markCompleted()     // dismiss when done
                    }
                }
//                .sheet(isPresented: .constant(launchMgr.needsWhatsNew)) {
//                    WhatsNewView {
//                        launchMgr.markCompleted()
//                    }
//                }
        }
    }
}
