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
    @StateObject private var routeViewModel = RouteViewModel()

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill") // This is the home icon
                    Text("Home")
                }
        }
        // **** Inject the ViewModel into the environment ****
        // All child views within this TabView hierarchy can now access it
        .environmentObject(routeViewModel)
    }
}

#Preview {
    ContentView()
}
