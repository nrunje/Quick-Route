//
//  MapCard.swift
//  Quick Route
//
//  Created by Nicholas Runje on 4/24/25.
//

import SwiftUI
import MapKit

/// One “card” for a single leg of the trip.
struct MapCard: View {
    let route: MKRoute          // segment to display
    let index: Int              // 0-based position in the trip
    let sourceMapItem: MKMapItem
    let destinationMapItem: MKMapItem
    let addressPair: (String, String)
//    let distance: CLLocationDistance
//    let travelTime: TimeInterval

    @State private var camera: MapCameraPosition = .automatic

    // Convenience text for the header
    private var legTitle: String { "Leg \(index + 1)" }

    // Convenience text for the route subtitle
    private var fromToTitle: String {
        "\(addressPair.0) → \(addressPair.1)"
    }

    var body: some View {
        ZStack {
            Color(.systemBlue).ignoresSafeArea()

            VStack(spacing: 16) {

                // ---- Leg label ------------------------------------------------
                Text(legTitle)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white.opacity(0.9))

                // ---- Square map preview --------------------------------------
                Map(position: $camera) {

                    // Blue route
                    MapPolyline(route.polyline)
                        .stroke(.blue, style: StrokeStyle(lineWidth: 4, lineJoin: .round))

                    // START marker (green)
                    Marker("Start",
                           coordinate: sourceMapItem.placemark.coordinate)
                        .tint(.green)          // tint works on iOS 17+

                    // END marker (red)
                    Marker("End",
                           coordinate: destinationMapItem.placemark.coordinate)
                        .tint(.red)
                }
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .onAppear {
                    let rect = route.polyline.boundingMapRect
                    camera = .rect(rect.insetBy(dx: -rect.size.width  * 0.2,
                                                dy: -rect.size.height * 0.2))
                }

                // ---- From → To text ------------------------------------------
                Text(fromToTitle)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal)

                Spacer(minLength: 0)

                // ---- Export button -------------------------------------------
                Button(action: exportToAppleMaps) {
                    Text("Export to Apple Maps")
                        .fontWeight(.semibold)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundColor(Color(.systemBlue))
                        .clipShape(Capsule())
                }
            }
            .padding(24)
        }
    }

    // MARK: - Export to Apple Maps
    private func exportToAppleMaps() {
        let launchOptions: [String: Any] = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
            MKLaunchOptionsShowsTrafficKey  : true
        ]

        MKMapItem.openMaps(with: [sourceMapItem, destinationMapItem],
                           launchOptions: launchOptions)
    }
}
