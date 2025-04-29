//
//  RouteViewModel.swift
//  Quick Route
//
//  Created by Nicholas Runje on 4/22/25.
//  Updated: 4/28/25
//

import CoreLocation
import MapKit
import SwiftUI

/// Holds all necessary data for one leg of the journey.
struct RouteLegData: Identifiable {
    let id = UUID() // Conformance to Identifiable for ForEach loops
    let route: MKRoute
    let source: MKMapItem
    let destination: MKMapItem
    let addressPair: (String, String) // Original addresses for display
}

/// ViewModel responsible for managing the state and logic for route planning.
class RouteViewModel: ObservableObject { // Removed redundant 'Observable' conformance
    /// Sample text to ensure RouteViewModel is available throughout environment
    @Published var sampleText: String = "Hello from RouteViewModel!"

    /// Origin point of navigation
    @Published var origin: String = ""

    /// List of INTERMEDIATE destination strings.
    @Published var intermediateDestinations: [String] = []

    /// Final stop of navigation
    @Published var finalStop: String = ""

    /// Checking if route planning is ongoing
    @Published var isPlanningRoute: Bool = false

    /// List of all calculated legs of the journey, including route, map items, and addresses.
    /// This replaces the old 'routes: [MKRoute]?' property.
    @Published var calculatedRouteLegs: [RouteLegData]? = nil

    // --- Address Input Management ---

    /// Creates a list of tuples of the string address pairs for validation or preliminary display.
    /// Note: The final addressPair in RouteLegData comes from the input used for geocoding that leg.
    func makeLegAddressPairs() -> [(String, String)]? {
        // 1. Ordered list of non-blank stops
        let orderedStops = ([origin] + intermediateDestinations + [finalStop])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // 2. Need at least A → B
        guard orderedStops.count >= 2 else { return nil }

        // 3. Zip adjacent elements into tuples
        let legs = (0 ..< orderedStops.count - 1).map {
            (orderedStops[$0], orderedStops[$0 + 1])
        }
        return legs.isEmpty ? nil : legs
    }

    // --- Geocoding ---

    /// Converts a human-readable address into geographic coordinates using Apple's geocoding service.
    /// Returns nil if geocoding finds no result for the address.
    /// Throws an error if the geocoding service fails (e.g., network issue).
    func getCoordinateFrom(address: String) async throws -> CLLocationCoordinate2D? {
        // Trim whitespace before geocoding
        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAddress.isEmpty else { return nil } // Don't geocode empty strings

        // Use withCheckedThrowingContinuation for async/await wrapper around completion handler API
        return try await withCheckedThrowingContinuation { continuation in
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(trimmedAddress) { placemarks, error in
                if let error = error {
                    // Geocoding service error
                    print("Geocoding error for '\(trimmedAddress)': \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                } else if let location = placemarks?.first?.location {
                    // Successfully found coordinates
                    continuation.resume(returning: location.coordinate)
                } else {
                    // Geocoding succeeded but found no results for the address
                    print("No coordinates found for address: '\(trimmedAddress)'")
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    // --- Route Calculation ---

    /// Builds an array of RouteLegData objects for each segment of the multi-stop route.
    /// Geocodes all addresses, then calculates MKDirections for each valid leg.
    ///
    /// - Returns: An array of `RouteLegData` objects, one for each segment,
    ///            or `nil` if the route cannot be calculated (e.g., origin/final
    ///            cannot be geocoded, fewer than 2 valid stops, or no route found
    ///            for any required segment).
    /// - Throws: An error if geocoding or route calculation *fails* due to a
    ///           system/network issue.
    @MainActor // Ensure updates to @Published properties happen on the main thread
    func buildAndStoreRoutes() async {
        print("Starting route building process...")
        self.isPlanningRoute = true
        self.calculatedRouteLegs = nil // Clear previous results

        // Get the address pairs first based on current input state
        guard let addressPairs = makeLegAddressPairs() else {
             print("Not enough valid addresses provided to form legs.")
             self.isPlanningRoute = false
             // Optionally set an error message state here
             return
        }

        // --- 1. Geocode all unique addresses ---
        // Create a set of unique addresses to avoid redundant geocoding calls
        let uniqueAddresses = Set(addressPairs.flatMap { [$0.0, $0.1] })
        var coordinateCache: [String: CLLocationCoordinate2D] = [:]
        var geocodingFailed = false

        print("Geocoding addresses: \(uniqueAddresses)")
        for address in uniqueAddresses {
            do {
                if let coord = try await getCoordinateFrom(address: address) {
                    coordinateCache[address] = coord
                    print("Successfully geocoded '\(address)' to \(coord)")
                } else {
                    // Geocoding returned nil (address not found), treat as failure for route planning
                    print("Failed to find coordinates for essential address: '\(address)'")
                    geocodingFailed = true
                    // You might want to provide more specific feedback to the user here
                    // For now, we'll break and prevent route calculation
                    break
                }
            } catch {
                // Geocoding threw an error (network/service issue)
                print("Geocoding service error for '\(address)': \(error.localizedDescription)")
                geocodingFailed = true
                // Handle the error appropriately (e.g., show alert to user)
                break // Stop the process if any geocoding fails critically
            }
        }

        // If any essential geocoding failed, stop.
        guard !geocodingFailed else {
            print("Route planning stopped due to geocoding failure.")
            self.isPlanningRoute = false
            // Optionally set an error message state here
            return
        }
        print("Geocoding complete. Cache: \(coordinateCache)")

        // --- 2. Create MapItems and Calculate Routes Leg by Leg ---
        var routeLegsDataResult: [RouteLegData] = []
        var routeCalculationFailed = false

        for (index, pair) in addressPairs.enumerated() {
            let startAddress = pair.0
            let endAddress = pair.1

            // Retrieve coordinates from our cache (should exist if geocoding didn't fail)
            guard let startCoord = coordinateCache[startAddress],
                  let endCoord = coordinateCache[endAddress] else {
                print("Error: Coordinate missing from cache for leg \(index + 1) (\(startAddress) -> \(endAddress)). This shouldn't happen.")
                routeCalculationFailed = true
                break // Stop if data integrity issue occurs
            }

            let sourceMapItem = MKMapItem(placemark: MKPlacemark(coordinate: startCoord))
            sourceMapItem.name = startAddress // Assign name for potential use in Maps app
            let destinationMapItem = MKMapItem(placemark: MKPlacemark(coordinate: endCoord))
            destinationMapItem.name = endAddress // Assign name

            // --- Calculate route for this specific leg ---
            let request = MKDirections.Request()
            request.source = sourceMapItem
            request.destination = destinationMapItem
            request.transportType = .automobile // Or make this configurable
            request.requestsAlternateRoutes = false

            print("Calculating route for leg \(index + 1): \(startAddress) -> \(endAddress)")
            let directions = MKDirections(request: request)

            do {
                let response = try await directions.calculate() // Throws on network/service error
                if let route = response.routes.first {
                    // Successfully calculated route for this leg
                    print("Successfully calculated route for leg \(index + 1).")
                    let legData = RouteLegData(route: route,
                                               source: sourceMapItem,
                                               destination: destinationMapItem,
                                               addressPair: pair) // Store original addresses
                    routeLegsDataResult.append(legData)
                } else {
                    // Calculation succeeded, but Maps couldn't find a route between these points
                    print("No route found between '\(startAddress)' and '\(endAddress)' for leg \(index + 1).")
                    routeCalculationFailed = true
                    // Handle this failure (e.g., inform user which leg failed)
                    break // Stop the entire process if any leg fails
                }
            } catch {
                // MKDirections calculation failed (network/service error)
                print("Error calculating directions for leg \(index + 1): \(error.localizedDescription)")
                routeCalculationFailed = true
                // Handle the error (e.g., show alert)
                break // Stop the entire process
            }
        } // End of loop through addressPairs

        // --- 3. Update Published State ---
        if routeCalculationFailed {
            print("Route calculation failed for one or more legs.")
            self.calculatedRouteLegs = nil // Ensure no partial route is stored
            // Optionally set an error message state here
        } else if routeLegsDataResult.isEmpty {
             print("No route legs were successfully calculated (might be due to initial address validation).")
             self.calculatedRouteLegs = nil
        }
         else {
            print("Successfully calculated \(routeLegsDataResult.count) route legs.")
            self.calculatedRouteLegs = routeLegsDataResult // Store the complete results
        }

        self.isPlanningRoute = false // Mark planning as finished
        print("Route building process finished.")
    }

    // --- Test Function (Optional) ---
    @MainActor
    func testGeocode() async {
        // This function can remain for basic geocoding tests if needed,
        // but buildAndStoreRoutes now handles the full process.
        print("--- Testing Geocoding ---")
        let addressesToTest = ([origin] + intermediateDestinations + [finalStop])
             .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
             .filter { !$0.isEmpty }

        guard !addressesToTest.isEmpty else {
            print("No addresses to test.")
            return
        }

        for addr in addressesToTest {
             do {
                 if let coord = try await getCoordinateFrom(address: addr) {
                     print("Test Geocode Success: '\(addr)' -> \(coord)")
                 } else {
                     print("Test Geocode No Result: '\(addr)'")
                 }
             } catch {
                 print("Test Geocode Error: '\(addr)' -> \(error.localizedDescription)")
             }
         }
         print("--- Finished Testing Geocoding ---")
    }
}
