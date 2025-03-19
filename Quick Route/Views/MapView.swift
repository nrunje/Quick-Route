//
//  MapView.swift
//  Quick Route
//
//  Created by Nicholas Runje on 2/10/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject private var locationManager = LocationManager.shared
    @State private var region = MKCoordinateRegion()
    @State private var sheetOffset: CGFloat = 0
    @State private var sheetHeight: CGFloat = 300 // Adjust this value as needed
    
    var body: some View {
        ZStack {
            // Map
            Map(coordinateRegion: $region)
                .ignoresSafeArea(edges: .top)
                .onAppear() {
                    print(locationManager.userLocation)
                    
                    if let location = locationManager.userLocation {
                        region = MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                    }
            }
            // END Map

            
            
        }
    }
}

#Preview {
    MapView()
}
