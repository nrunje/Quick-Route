//
//  ContentView.swift
//  Quick Route
//
//  Created by Nicholas Runje on 2/4/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @ObservedObject var locationManager = LocationManager.shared
    
    var body: some View {
        Group {
            if locationManager.userLocation == nil {
                LocationRequestView()
            } else {
                Text("\(locationManager.userLocation!)")
            }
        }
    }
}



#Preview {
    ContentView()
}
