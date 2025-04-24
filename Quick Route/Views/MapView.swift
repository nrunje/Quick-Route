//
//  MapView.swift
//  Quick Route
//
//  Created by Nicholas Runje on 4/23/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var routeViewModel: RouteViewModel

    var body: some View {
        Group {
            if let allRoutes = routeViewModel.routes {
                Map {
                    
                }
            } else {
                MapPlaceholderView()
            }
        }
    }
}

#Preview {
    MapView()
        .environment(RouteViewModel())
}
