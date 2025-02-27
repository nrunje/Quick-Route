//
//  DestinationModel.swift
//  Quick Route
//
//  Created by Nicholas Runje on 2/27/25.
//

import Foundation
import CoreLocation

struct Desetination: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
