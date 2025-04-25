//
//  MapView.swift
//  Quick Route
//
//  Created by Nicholas Runje on 4/23/25.
//

import MapKit
import SwiftUI

struct MapView: View {
    @EnvironmentObject var routeViewModel: RouteViewModel

    var body: some View {
        // Use a ScrollView to allow vertical scrolling if multiple MapCards exist
        ScrollView {
            // Use a VStack to arrange the MapCards vertically within the single Map tab
            VStack(spacing: 20) { // Added spacing for better visual separation
                if let allRoutes = routeViewModel.routes, !allRoutes.isEmpty { // Also check if the array is not empty
                    ForEach(Array(allRoutes.enumerated()), id: \.element.polyline) { idx, route in
                        MapCard(route: route, index: idx)
                            // Optional: Add padding around each card if desired
                            .padding(.horizontal)
                    }
                } else {
                    // Display placeholder content when there are no routes
                    MapPlaceholderView()
                        .padding(.top, 50) // Give placeholder some top padding
                }
            }
            // Optional: Add padding to the top of the VStack content
            .padding(.top)
        }
        // You might want a title for the Map screen, requires NavigationView context usually
//         .navigationTitle("Calculated Routes") // Example if placed within a NavigationView
    }
}

#Preview {
    MapView()
        .environment(RouteViewModel())
}
