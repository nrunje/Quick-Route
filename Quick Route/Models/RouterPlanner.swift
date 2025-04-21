//
//  RouterPlanner.swift
//  Quick Route
//
//  Created by Nicholas Runje on 4/17/25.
//

import CoreLocation
import Foundation
import MapKit // Import MapKit for MKPlacemark

/// A utility struct for planning multi-stop routes using human-readable address strings.
///
/// `RoutePlanner` stores an origin, a list of intermediate destinations, and a final stop.
/// It filters out empty or whitespace-only intermediate addresses during initialization,
/// making it robust for user-generated input or raw address data.
///
/// This struct can be used as part of a navigation or mapping feature where addresses
/// are resolved to coordinates asynchronously using Apple's geocoding service.
///
/// - Example:
/// ```swift
/// let planner = RoutePlanner(
///     origin: "123 Queen Anne Ave N, Seattle, WA, United States",
///     intermediateDestinations: ["701 5th Ave, Seattle, WA, United States", "400 Broad St, Seattle, WA, United States"],
///     finalStop: "456 Southcenter Mall, Tukwila, WA, United States"
/// )
/// ```
///
/// - Note:
///   The struct does not convert addresses to coordinates by itself; call `getCoordinateFrom(address:)`
///   for each address as needed.
struct RoutePlanner {
    // Store original strings
    let originAddress: String
    let intermediateAddressStrings: [String]
    let finalAddress: String

    // Initializer takes the raw strings
    init(origin: String, intermediateDestinations: [String], finalStop: String) {
        print("Called RoutePlanner")
        originAddress = origin
        // Filter out empty/whitespace-only intermediate strings during initialization
        intermediateAddressStrings = intermediateDestinations.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        finalAddress = finalStop
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

    func buildMKRoute() async throws -> MKRoute? {
        // Get coordinates
        guard let originCoord = try await getCoordinateFrom(address: originAddress),
              let finalCoord = try await getCoordinateFrom(address: finalAddress) else {
            return nil
        }

        let originMapItem = MKMapItem(placemark: MKPlacemark(coordinate: originCoord))
        let finalMapItem = MKMapItem(placemark: MKPlacemark(coordinate: finalCoord))

        // Convert intermediate addresses to MKMapItems
        var intermediateMapItems: [MKMapItem] = []

        for address in intermediateAddressStrings {
            if let coord = try await getCoordinateFrom(address: address) {
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coord))
                intermediateMapItems.append(mapItem)
            }
        }

        // Prepare route segments
        var route: MKRoute?
        var currentSource = originMapItem

        for waypoint in intermediateMapItems + [finalMapItem] {
            let request = MKDirections.Request()
            request.source = currentSource
            request.destination = waypoint
            request.transportType = .automobile

            let directions = MKDirections(request: request)
            let response = try await directions.calculate()
            if route == nil {
                route = response.routes.first
            } else {
                // You can aggregate routes here if needed
                route = response.routes.first
            }

            currentSource = waypoint
        }

        return route
    }



    
}
