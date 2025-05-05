//
//  TransportMode.swift
//  Quick Route
//
//  Created by Nicholas Runje on 5/5/25.
//

import Foundation
import MapKit

/// Which kind of directions to request.
enum TransportMode: String, CaseIterable, Identifiable {
    case automobile = "Automobile"
    case walking    = "Walking"
    
    var id: Self { self }
    
    /// MapKit equivalent, handy when you build the MKDirectionsRequest.
    var mkTransportType: MKDirectionsTransportType {
        switch self {
        case .automobile: return .automobile
        case .walking:    return .walking
        }
    }
}
