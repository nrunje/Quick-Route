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
//    @ObservedObject var locationManager = LocationManager.shared

    var body: some View {
        TabView {
            DestinationsView()
                .tabItem {
                    Label("Destinations", systemImage: "list.bullet")
                }
            
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            
            MapViewTest()
                .tabItem {
                    Label("Test Map", systemImage: "map")
                }
        }
    }
}

#Preview {
    ContentView()
}
