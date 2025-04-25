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
    
    @State private var camera: MapCameraPosition = .automatic
    
    // Convenience text for the header
    private var legTitle: String { "Leg \(index + 1)" }
    
    // Convenience text for the route subtitle
    private var fromToTitle: String {
        let start =  "Start"
        let end   =  "End"
        return "\(start) → \(end)"
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
                    MapPolyline(route.polyline)
                        .stroke(.blue, style: StrokeStyle(lineWidth: 4,
                                                           lineJoin: .round))
                }
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .onAppear {
                    // Fit camera to this polyline with a little padding
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
                Button {
//                    exportToAppleMaps()
                    print("Export button clicked")
                } label: {
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
    
//    // MARK: - Export to Apple Maps
//    private func exportToAppleMaps() {
//        // 1. Make sure the route actually has map items.
//        guard let start = route.source,
//              let end   = route.destination else {
//            assertionFailure("MKRoute is missing source or destination MapItem")
//            return
//        }
//        
//        // 2. Decide how you want the route shown (driving, walking, transit…).
//        let launchOptions: [String : Any] = [
//            MKLaunchOptionsDirectionsModeKey      : MKLaunchOptionsDirectionsModeDriving,
//            MKLaunchOptionsShowsTrafficKey        : true,
//            MKLaunchOptionsMapCenterKey           : NSValue(mkCoordinate: start.placemark.coordinate),
//            MKLaunchOptionsMapSpanKey             : NSValue(mkCoordinateSpan:
//                                    MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
//        ]
//
//        // 3. Fire up Apple Maps.
//        MKMapItem.openMaps(with: [start, end], launchOptions: launchOptions)
//    }
}

#Preview {
    // Minimal dummy route so the preview compiles
    let coords = [CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321),
                  CLLocationCoordinate2D(latitude: 47.6101, longitude: -122.2015)]
    let poly = MKPolyline(coordinates: coords, count: coords.count)
    let dummy = MKRoute()
    dummy.setValue(poly,                                         forKey: "polyline")
    dummy.setValue(MKMapItem(placemark: .init(coordinate: coords[0])), forKey: "source")
    dummy.setValue(MKMapItem(placemark: .init(coordinate: coords[1])), forKey: "destination")
    
    return MapCard(route: dummy, index: 0)
}
