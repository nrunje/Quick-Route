//
//  MapView.swift
//  Quick Route
//
//  Created by Nicholas Runje on 4/23/25.
//

import SwiftUI

struct MapView: View {
    @EnvironmentObject var routeViewModel: RouteViewModel

    var body: some View {
        Group {
            Text(routeViewModel.sampleText)
        }
    }
}

#Preview {
    MapView()
        .environment(RouteViewModel())
}
