//
//  ContentView.swift
//  Quick Route
//
//  Created by Nicholas Runje on 2/4/25.
//

import CoreLocation
import MapKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var routeViewModel: RouteViewModel
    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill") // This is the home icon
                    Text("Home")
                }

            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    ContentView()
}
