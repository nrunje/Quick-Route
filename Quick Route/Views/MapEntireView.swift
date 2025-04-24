//
//  MapView.swift
//  Quick Route
//
//  Created by Nicholas Runje on 4/23/25.
//

import MapKit
import SwiftUI

struct MapEntireView: View {
    @EnvironmentObject var routeViewModel: RouteViewModel

    var body: some View {
        Group {
            if let allRoutes = routeViewModel.routes {
                Map {
                    // ----  ROUTE POLYLINES  ----
                    ForEach(allRoutes, id: \.polyline) { route in
                        MapPolyline(route.polyline)
                            .stroke(.blue, lineWidth: 4)
                    }
                        
                }
            } else {
                MapPlaceholderView()
            }
        }
    }
}

#Preview {
    MapEntireView()
        .environment(RouteViewModel())
}
