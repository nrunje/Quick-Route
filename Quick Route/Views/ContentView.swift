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
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            DestinationsView()
                .tabItem {
                    Label("Destinations", systemImage: "list.bullet")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            
            Test2View()
                .tabItem {
                    Label("Test", systemImage: "square.and.arrow.up")
                }
        }
    }
}

#Preview {
    ContentView()
}
