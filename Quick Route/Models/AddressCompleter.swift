//
//  AddressCompleter.swift
//  Quick Route
//
//  Created by Nicholas Runje on 4/10/25.
//

import Foundation
import MapKit
import Combine // Needed for ObservableObject if not automatically imported with SwiftUI

// Make sure this class conforms to NSObject to be a delegate
class AddressCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    // The completer instance
    private var completer: MKLocalSearchCompleter
    
    // Published property to hold the suggestions. SwiftUI views can subscribe to this.
    @Published var suggestions: [MKLocalSearchCompletion] = []
    
    // Optional: Store the current query fragment
    @Published var queryFragment: String = ""
    
    // Optional: Debounce mechanism
    private var cancellable: AnyCancellable?

    override init() {
        completer = MKLocalSearchCompleter()
        super.init() // Call NSObject's init
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest, .query] 

        // Optional: Bias search results to the user's region (e.g., Renton, WA)
        // You would typically get the user's current location via CLLocationManager
        // For demonstration, let's hardcode a region around Renton
        // Coordinates for Renton, WA approx: 47.4829° N, 122.2171° W
        let rentonCoordinate = CLLocationCoordinate2D(latitude: 47.4829, longitude: -122.2171)
        // Define a region span (adjust size as needed, meters)
        let regionSpan = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5) // Approx 55km radius
        completer.region = MKCoordinateRegion(center: rentonCoordinate, span: regionSpan)
        
        // --- Debouncing Setup ---
        // Use Combine's debounce publisher to avoid excessive API calls
        cancellable = $queryFragment
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main) // Wait 300ms after user stops typing
            .removeDuplicates() // Don't search if the query hasn't changed
            .sink { [weak self] newQuery in
                if !newQuery.isEmpty {
                    self?.completer.queryFragment = newQuery
                    print("Searching for: \(newQuery)") // For debugging
                } else {
                    // Clear suggestions immediately if query is empty
                    self?.suggestions = []
                    self?.completer.queryFragment = "" // Ensure the completer knows it's empty
                     print("Query cleared, clearing suggestions.") // For debugging
                }
            }
    }

    // MARK: - MKLocalSearchCompleterDelegate Methods

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Update the published suggestions array
        // Filter out results without a subtitle, which are often less useful for addresses
        self.suggestions = completer.results.filter { !$0.subtitle.isEmpty }
        print("Suggestions updated: \(self.suggestions.count) items") // For debugging
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Handle errors (e.g., network issue, invalid query)
        print("Error fetching suggestions: \(error.localizedDescription)")
        self.suggestions = [] // Clear suggestions on error
    }
}
