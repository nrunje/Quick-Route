//
//  RouteLocation.swift
//  Quick Route
//
//  Created by Nicholas Runje on 3/20/25.
//

import Foundation

// Route model to store location data
struct RouteLocation: Identifiable, Codable {
    var id = UUID()
    var name: String
    var latitude: Double
    var longitude: Double
    var order: Int // For route sequencing
    
    // Example initializer
    init(name: String, latitude: Double, longitude: Double, order: Int) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.order = order
    }
}

class RouteViewModel: ObservableObject {
    @Published var locations: [RouteLocation] = []
    
    func addLocation(name: String, latitude: Double, longitude: Double) {
        let newLocation = RouteLocation(name: name, latitude: latitude, longitude: longitude, order: locations.count)
        locations.append(newLocation)
        saveRoutes()
    }
    
    func saveRoutes() {
        if let encoded = try? JSONEncoder().encode(locations) {
            UserDefaults.standard.set(encoded, forKey: "savedRoutes")
        }
    }
}
