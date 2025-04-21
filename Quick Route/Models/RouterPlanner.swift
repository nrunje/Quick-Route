//
//  RouterPlanner.swift
//  Quick Route
//
//  Created by Nicholas Runje on 4/17/25.
//

import Foundation
import CoreLocation
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
        self.originAddress = origin
        // Filter out empty/whitespace-only intermediate strings during initialization
        self.intermediateAddressStrings = intermediateDestinations.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        self.finalAddress = finalStop
        
    }
    
    /// Converts a human-readable address into geographic coordinates using Apple's geocoding service.
    ///
    /// - Parameters:
    ///   - address: A full address string (e.g., "4750 Smithers Ave S, Renton, WA, United States").
    ///   - completion: A closure that returns an optional `CLLocationCoordinate2D`.
    ///                 The value is `nil` if the geocoding fails.
    ///
    /// - Note:
    ///   This method performs an asynchronous operation. Network availability and geocoding accuracy
    ///   can affect the result. Always handle the `nil` case gracefully.
    ///
    /// - Important:
    ///   Make sure to call UI updates from the main thread inside the completion block if needed.
    ///
    /// - Example:
    /// ```swift
    /// getCoordinateFrom(address: "1 Infinite Loop, Cupertino, CA") { coordinate in
    ///     if let coordinate = coordinate {
    ///         print("Lat: \(coordinate.latitude), Lon: \(coordinate.longitude)")
    ///     }
    /// }
    /// ```
    func getCoordinateFrom(address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let location = placemarks?.first?.location {
                completion(location.coordinate)
            } else {
                print("No location found for address.")
                completion(nil)
            }
        }
    }
    
}
