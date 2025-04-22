//
//  MapView.swift
//  Quick Route
//
//  Created by Nicholas Runje on 2/10/25.
//
import SwiftUI
import MapKit // Import the MapKit framework

struct MapViewTest: View {
    @State var routes: [MKRoute]? = nil

    var body: some View {
        RoutesMapView(routes: routes)
            .edgesIgnoringSafeArea(.all)
    }
}

struct RoutesMapView: UIViewRepresentable {
    var routes: [MKRoute]?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Clear previous overlays
        mapView.removeOverlays(mapView.overlays)

        guard let routes = routes else { return }

        for route in routes {
            mapView.addOverlay(route.polyline)
        }

        // Optional: zoom to fit all routes
        if let first = routes.first {
            let rect = routes.reduce(first.polyline.boundingMapRect) {
                $0.union($1.polyline.boundingMapRect)
            }
            mapView.setVisibleMapRect(rect, edgePadding: .init(top: 40, left: 20, bottom: 40, right: 20), animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}


#Preview {
    MapViewTest()
}
