//
//  RouteViewModel.swift
//  Quick Route
//
//  Created by Nicholas Runje on 4/22/25.
//

import CoreLocation // Required for CLLocationCoordinate2D
import MapKit // Required for MKRoute, CLLocationCoordinate2D
import SwiftUI

/// ViewModel responsible for managing the state and logic for route planning.
class RouteViewModel: Observable, ObservableObject {
    /// Sample text to ensure RouteViewModel is available throughout environment
    @Published var sampleText: String = "Hello from RouteViewModel!"
    
    /// Origin point of navigation
    @Published var origin: String = ""
    
    /// List of INTERMEDIATE destination strings.
//    @Published var intermediateDestinations: [String] = ["Seattle, WA", "Bellevue, WA"] // Start empty now
    @Published var intermediateDestinations: [String] = [] // Start empty now

    /// Final stop of navigation
    @Published var finalStop: String = ""
    
    /// Checking if geocoding is ongoing
    @Published var isPlanningRoute: Bool = false
    
    /// Routes
    @Published var routes: [MKRoute]? = nil
    
    @MainActor
    func testGeocode() async {
        do {
            if let originCoord = try await getCoordinateFrom(address: origin) {
                print("Origin:", originCoord)
            }

            for addr in intermediateDestinations {
                if let coord = try await getCoordinateFrom(address: addr) {
                    print("Intermediate:", coord)
                }
            }

            if let finalCoord = try await getCoordinateFrom(address: finalStop) {
                print("Final stop:", finalCoord)
            }
        } catch {
            print("Error geocoding address:", error)
        }
    }
    
    /// Converts a human-readable address into geographic coordinates using Apple's geocoding service.
    ///
    /// - Parameter address: A full address string.
    /// - Returns: A `CLLocationCoordinate2D` if found, or `nil` if geocoding failed.
    /// - Throws: An error if geocoding fails due to system or network issues.
    func getCoordinateFrom(address: String) async throws -> CLLocationCoordinate2D? {
        return try await withCheckedThrowingContinuation { continuation in
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let location = placemarks?.first?.location {
                    continuation.resume(returning: location.coordinate)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    /// Builds an array of MKRoute objects for each segment of the multi-stop route.
    ///
    /// This function first geocodes all addresses to get their coordinates. Then, it
    /// calculates directions for each leg of the journey: origin to the first waypoint,
    /// each waypoint to the next, and finally the last waypoint to the final destination.
    ///
    /// - Returns: An array of `MKRoute` objects, one for each segment of the route,
    ///            or `nil` if the route cannot be calculated (e.g., origin/destination
    ///            cannot be geocoded, or no routes found for any segment).
    /// - Throws: An error if geocoding *fails* (system/network issue) or if a route
    ///           calculation *fails* (system/network issue with directions service).
    func buildMKRoutes() async throws -> [MKRoute]? { // Changed return type to [MKRoute]?
        print("Building MKRoutes")

        // Get coordinates for origin and final destination.
        // getCoordinateFrom throws on *failure*, returns nil on *no result*.
        // If origin or final cannot be geocoded (returns nil), we cannot plan the route.
        guard let originCoord = try await getCoordinateFrom(address: origin),
              let finalCoord = try await getCoordinateFrom(address: finalStop) else {
            print("Could not geocode origin or final destination address. Cannot plan route.")
            return nil // Cannot calculate route if origin or final is unknown
        }

        let originMapItem = MKMapItem(placemark: MKPlacemark(coordinate: originCoord))
        let finalMapItem = MKMapItem(placemark: MKPlacemark(coordinate: finalCoord))

        // Convert intermediate addresses to MKMapItems, skipping those that return nil from geocoding
        var intermediateMapItems: [MKMapItem] = []
        for address in intermediateDestinations {
            if let coord = try await getCoordinateFrom(address: address) { // getCoordinateFrom throws on failure
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coord))
                intermediateMapItems.append(mapItem)
            } else {
                // Geocoding returned nil for this intermediate address - skip it but continue
                print("Could not geocode intermediate address: \(address). Skipping this stop.")
            }
        }

        // Prepare all stops in order: origin, intermediates, final
        var allStops: [MKMapItem] = [originMapItem]
        allStops.append(contentsOf: intermediateMapItems)
        allStops.append(finalMapItem)

        // If after successful geocoding of origin/final, and adding valid intermediates,
        // we still have less than 2 stops, a route is impossible.
        if allStops.count < 2 {
            print("Not enough valid locations (origin, final, and intermediates) to form a route.")
            return nil // Cannot calculate route with less than 2 valid points
        }

        var routeSegments: [MKRoute] = [] // Array to hold each route segment
        var currentSource = allStops[0] // Start with the origin

        // Iterate through the stops, calculating a route for each segment
        for i in 1 ..< allStops.count {
            let destination = allStops[i]

            let request = MKDirections.Request()
            request.source = currentSource
            request.destination = destination
            request.transportType = .automobile // Or choose other transport types as needed
            request.requestsAlternateRoutes = false // Usually you want just one route per segment

            print("Calculating route from \(currentSource.placemark.coordinate.latitude), \(currentSource.placemark.coordinate.longitude) to \(destination.placemark.coordinate.latitude), \(destination.placemark.coordinate.longitude)")

            let directions = MKDirections(request: request)
            do {
                let response = try await directions.calculate() // calculate throws on *failure*
                if let route = response.routes.first {
                    // Route found for this segment
                    routeSegments.append(route)
                    print("Successfully calculated route segment \(i).")
                } else {
                    // calculate succeeded, but found no routes for this segment.
                    // This means the route *cannot be calculated* as planned.
                    print("No route found for segment \(i). Cannot complete multi-stop route.")
                    return nil // Return nil if *any* segment fails to find a route
                }
            } catch {
                // calculate failed due to a system/network error - throw it
                print("Error calculating route for segment \(i): \(error.localizedDescription). Throwing error.")
                throw error // Re-throw the error if a route calculation *fails*
            }

            // The destination of the current segment becomes the source for the next
            currentSource = destination
        }

        // If we successfully calculated a route for every segment in the loop,
        // the routeSegments array will not be empty (since allStops.count >= 2).
        // We return the array.
        print("Finished building MKRoutes. Found \(routeSegments.count) segments.")
        return routeSegments // Return the array of successfully calculated route segments
    }
}


