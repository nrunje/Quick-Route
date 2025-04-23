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
    
}
