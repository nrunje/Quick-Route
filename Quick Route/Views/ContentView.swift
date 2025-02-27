//
//  ContentView.swift
//  Quick Route
//
//  Created by Nicholas Runje on 2/4/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @ObservedObject var locationManager = LocationManager.shared
    
    var body: some View {
        Group {
            if locationManager.userLocation == nil {
                LocationRequestView()
            } else {
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
                }
            }
        }
    }
}



#Preview {
    ContentView()
}
