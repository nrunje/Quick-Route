//
//  MapView.swift
//  Quick Route
//
//  Created by Nicholas Runje on 2/10/25.
//

import MapKit
import SwiftUI

struct MapView: View {
    // Observes the location
    @ObservedObject private var locationManager = LocationManager.shared
    // Creates the region, and also the default region (contiguous US)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795), // Default: Center of continental US (approx.)
        span: MKCoordinateSpan(latitudeDelta: 35.0, longitudeDelta: 65.0) // Zoom level to fit continental US
    )

    // State to track if the initial centering has happened
    @State private var hasCenteredOnUser = false

    var body: some View {
        ZStack {
            // Map
            Map(coordinateRegion: $region, showsUserLocation: true)
                .ignoresSafeArea(edges: .top)
                .onAppear {
                    locationManager.requestLocation() // Call requestLocation when the view appears
                }
                .onChange(of: locationManager.userLocation) { _, newLocation in
                    // Check if we have a new, valid location
                    guard let userLocation = newLocation else { return }

                    // Center the map on the user's location *once*
                    if !hasCenteredOnUser {
                        region = MKCoordinateRegion(
                            center: userLocation.coordinate,
                            // Zoom in closer to the user's location
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                        hasCenteredOnUser = true // Mark that we've centered
                    }
                }
        }
        // END Map
    }
}

#Preview {
    MapView()
}
