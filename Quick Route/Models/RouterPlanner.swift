//
//  RouterPlanner.swift
//  Quick Route
//
//  Created by Nicholas Runje on 4/17/25.
//

import Foundation
import CoreLocation
import MapKit // Import MapKit for MKPlacemark

// Define potential errors during route planning
enum RoutePlannerError: Error, LocalizedError {
    case geocodingFailed(address: String, underlyingError: Error?)
    case addressNotFound(address: String) // Can be thrown by preparePlacemarks if essential points yield nil
    case missingRequiredData // If origin or destination string is empty before geocoding
    case geocodingIncomplete // If essential points couldn't be geocoded

    var errorDescription: String? {
        switch self {
        case .geocodingFailed(let address, let underlyingError):
            // Provide more context if possible
            let underlyingMessage = underlyingError?.localizedDescription ?? "An unknown issue occurred."
            return "Geocoding failed for '\(address)'. Reason: \(underlyingMessage)"
        case .addressNotFound(let address):
            return "Address could not be located: '\(address)'."
        case .missingRequiredData:
            return "Origin and Final Destination addresses cannot be empty."
        case .geocodingIncomplete:
            return "Could not determine coordinates for essential route points (Origin/Destination)."
        }
    }
}

// Standalone function to geocode a single address
private func geocodeAddress(_ addressString: String, using geocoder: CLGeocoder) async throws -> CLPlacemark? {
    print("Geocoding individual address: \(addressString)")
    do {
        // Use the async version of geocodeAddressString
        let clPlacemarks = try await geocoder.geocodeAddressString(addressString)
        // Check if at least one placemark was returned
        if let firstPlacemark = clPlacemarks.first {
            print("Found placemark for \(addressString)")
            return firstPlacemark
        } else {
            // Geocoding succeeded but returned no results (equivalent to "not found")
            print("No placemark found for (empty results array): \(addressString)")
            return nil
        }
    } catch {
        // Handle all geocoding service errors (network, service unavailability, etc.)
        print("Geocoding service error for \(addressString): \(error.localizedDescription)")
        throw error
    }
}

struct RoutePlanner {
    // Store original strings
    let originAddress: String
    let intermediateAddressStrings: [String]
    let finalAddress: String

    // Store resulting placemarks (which contain coordinates and address details)
    // Use `private(set)` to allow modification only within this struct (by `preparePlacemarks`)
    private(set) var originPlacemark: MKPlacemark?
    private(set) var intermediatePlacemarks: [MKPlacemark] = []
    private(set) var finalPlacemark: MKPlacemark?

    // Initializer takes the raw strings
    init(origin: String, intermediateDestinations: [String], finalStop: String) {
        self.originAddress = origin
        // Filter out empty/whitespace-only intermediate strings during initialization
        self.intermediateAddressStrings = intermediateDestinations.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        self.finalAddress = finalStop
    }

    // Asynchronous function to perform geocoding for all points
    // Use `mutating` because it modifies the struct's own placemark properties
    // Throws errors defined in RoutePlannerError
    mutating func preparePlacemarks() async throws {
        print("Starting geocoding for route points...")

        // Basic validation: Ensure origin and final stop are provided
        guard !originAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !finalAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw RoutePlannerError.missingRequiredData
        }

        let geocoder = CLGeocoder()

        // Use async let to start geocoding origin and final stop concurrently
        async let originResult: CLPlacemark? = geocodeAddress(originAddress, using: geocoder)
        async let finalResult: CLPlacemark? = geocodeAddress(finalAddress, using: geocoder)

        // Geocode intermediates concurrently using a TaskGroup
        let intermediateResults: [MKPlacemark] = await withTaskGroup(of: MKPlacemark?.self) { group in
            var validPlacemarks = [MKPlacemark]()

            for address in intermediateAddressStrings {
                // Add a task for each intermediate address
                group.addTask {
                    do {
                        if let clPlacemark = try await geocodeAddress(address, using: geocoder) {
                            // Convert valid CLPlacemark to MKPlacemark
                            return MKPlacemark(placemark: clPlacemark)
                        } else {
                            print("Warning: Address not found during geocoding for intermediate stop: \(address)")
                            return nil // Return nil if address not found
                        }
                    } catch {
                        print("Warning: Geocoding failed for intermediate stop '\(address)': \(error.localizedDescription)")
                        return nil // Return nil on error
                    }
                }
            }

            // Collect non-nil results from the group
            for await placemark in group {
                if let validPlacemark = placemark {
                    validPlacemarks.append(validPlacemark)
                }
            }
            // Note: This collects successfully geocoded intermediates but doesn't preserve original order if some fail.
            return validPlacemarks
        }

        // --- Assign Results ---
        // Await concurrent tasks and handle potential errors

        do {
            // Await origin result
            if let clOrigin = try await originResult {
                self.originPlacemark = MKPlacemark(placemark: clOrigin)
                print("Geocoded Origin: \(originPlacemark?.coordinate.latitude ?? 0), \(originPlacemark?.coordinate.longitude ?? 0)")
            } else {
                // If geocodeAddress returned nil (not found), throw specific error
                throw RoutePlannerError.addressNotFound(address: originAddress)
            }
        } catch {
            // Catch errors thrown by geocodeAddress helper (e.g., network)
            throw RoutePlannerError.geocodingFailed(address: originAddress, underlyingError: error)
        }

        do {
            // Await final result
            if let clFinal = try await finalResult {
                self.finalPlacemark = MKPlacemark(placemark: clFinal)
                print("Geocoded Final Stop: \(finalPlacemark?.coordinate.latitude ?? 0), \(finalPlacemark?.coordinate.longitude ?? 0)")
            } else {
                // If geocodeAddress returned nil (not found), throw specific error
                throw RoutePlannerError.addressNotFound(address: finalAddress)
            }
        } catch {
            // Catch errors thrown by geocodeAddress helper
            throw RoutePlannerError.geocodingFailed(address: finalAddress, underlyingError: error)
        }

        // Assign intermediates collected from TaskGroup
        self.intermediatePlacemarks = intermediateResults
        print("Successfully geocoded \(intermediatePlacemarks.count) out of \(intermediateAddressStrings.count) intermediate stops.")

        // Final validation: Check if essential points were actually found after awaiting
        // This check is important because the throws above might be caught if wrapped elsewhere
        guard originPlacemark != nil, finalPlacemark != nil else {
            print("Error: Missing geocoded data for origin or final destination after processing.")
            throw RoutePlannerError.geocodingIncomplete
        }

        print("Placemark preparation complete.")
    }
}
