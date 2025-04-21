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

    /// Returns the directions for the route (origin -> intermediate stops -> final stop).
    func getRouteDirections() async throws -> MKRoute? {
        // First, get the coordinates for all addresses
        var coordinates: [CLLocationCoordinate2D] = []

        // Get origin
        if let originCoord = try await getCoordinateFrom(address: originAddress) {
            coordinates.append(originCoord)
        }

        // Get intermediate destinations
        for address in intermediateAddressStrings {
            if let intermediateCoord = try await getCoordinateFrom(address: address) {
                coordinates.append(intermediateCoord)
            }
        }

        // Get final destination
        if let finalCoord = try await getCoordinateFrom(address: finalAddress) {
            coordinates.append(finalCoord)
        }

        // Check that we have at least two coordinates (origin and final destination)
        guard coordinates.count > 1 else {
            throw NSError(domain: "RoutePlanner", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not enough locations to form a route."])
        }

        // Request directions
        let directionsRequest = MKDirections.Request()

        // Add waypoints to the directions request
        let originPlacemark = MKPlacemark(coordinate: coordinates[0])
        directionsRequest.source = MKMapItem(placemark: originPlacemark)

        var previousPlacemark = originPlacemark
        for i in 1 ..< coordinates.count {
            let waypointPlacemark = MKPlacemark(coordinate: coordinates[i])
            let waypointItem = MKMapItem(placemark: waypointPlacemark)

            // Set destination for the current segment
            directionsRequest.destination = waypointItem
            directionsRequest.transportType = .automobile

            let directions = MKDirections(request: directionsRequest)
            let response = try await directions.calculate()

            // Take the first route found
            if let route = response.routes.first {
                // Add the route from the current segment to the previous route
                return route
            }

            previousPlacemark = waypointPlacemark
        }

        return nil
    }
}
