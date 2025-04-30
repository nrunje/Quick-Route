//
//  MapView.swift
//  Quick Route
//
//  Created by Nicholas Runje on 4/23/25.
//  Updated: 4/28/25 // Updated comment
//

import MapKit
import SwiftUI

struct MapView: View {
    @EnvironmentObject var routeViewModel: RouteViewModel

    var body: some View {
        Group {
            // Check the new calculatedRouteLegs property
            if let legs = routeViewModel.calculatedRouteLegs, !legs.isEmpty {
                // Use TabView for a paged scrolling experience, similar to MapCard style
                ScrollView {
                    ForEach(legs) { leg in
                        let legIndex = legs.firstIndex(where: { $0.id == leg.id }) ?? 0
                        
                        // Calculate the index *before* creating the MapCard view
                        MapCard(route: leg.route, index: legIndex, sourceMapItem: leg.source, destinationMapItem: leg.destination, addressPair: leg.addressPair)
                    
                    }
                }

            } else {
                // Display placeholder content when there are no calculated route legs
                MapPlaceholderView()
                // Add padding or adjust alignment as needed for the placeholder
                // .padding(.top, 50)
            }
        }
    }
}

//#Preview {
//    // Create a ViewModel for the preview
//    let previewViewModel = RouteViewModel()
//
//    // --- Create Dummy Data for Preview ---
//    // 1. Coordinates
//    let coord1 = CLLocationCoordinate2D(latitude: 47.6205, longitude: -122.3493) // Space Needle
//    let coord2 = CLLocationCoordinate2D(latitude: 47.6080, longitude: -122.3351) // Columbia Center
//    let coord3 = CLLocationCoordinate2D(latitude: 47.5952, longitude: -122.3321) // T-Mobile Park
//
//    // 2. MapItems
//    let item1 = MKMapItem(placemark: MKPlacemark(coordinate: coord1))
//    item1.name = "Space Needle Area"
//    let item2 = MKMapItem(placemark: MKPlacemark(coordinate: coord2))
//    item2.name = "Columbia Center Area"
//    let item3 = MKMapItem(placemark: MKPlacemark(coordinate: coord3))
//    item3.name = "T-Mobile Park Area"
//
//    // 3. Dummy Routes (just need polylines for visual)
//    let poly1 = MKPolyline(coordinates: [coord1, coord2], count: 2)
//    let route1 = MKRoute()
//    route1.setValue(poly1, forKey: "polyline")
//    route1.setValue(1500.0, forKey: "distance")
//    route1.setValue(300.0, forKey: "expectedTravelTime")
//
//    let poly2 = MKPolyline(coordinates: [coord2, coord3], count: 2)
//    let route2 = MKRoute()
//    route2.setValue(poly2, forKey: "polyline")
//    route2.setValue(1000.0, forKey: "distance")
//    route2.setValue(180.0, forKey: "expectedTravelTime")
//
//    // 4. RouteLegData
//    let leg1 = RouteLegData(route: route1, source: item1, destination: item2, addressPair: ("Space Needle", "Columbia Center"))
//    let leg2 = RouteLegData(route: route2, source: item2, destination: item3, addressPair: ("Columbia Center", "T-Mobile Park"))
//
//    // 5. Assign to ViewModel
//    previewViewModel.calculatedRouteLegs = [leg1, leg2]
//    // --- End Dummy Data ---
//
//    MapView()
//        .environmentObject(previewViewModel) // Use the ViewModel with dummy data
//}
