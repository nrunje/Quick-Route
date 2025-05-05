//
//  AppSettings.swift
//  Quick Route
//
//  Created on 5/1/25. // Or use the appropriate date
//

import Foundation
import Combine // Import Combine for ObservableObject and @Published

/// Global app settings for setting units, etc
class AppSettings: ObservableObject {
    
    /// Stored keys
    private enum Key {
        static let units  = "useMetricUnits"
        static let mode   = "transportMode"
    }
    
    /// Setting for using metric or imperial units
    @Published var useMetricUnits: Bool {
        didSet {
            UserDefaults.standard.set(useMetricUnits, forKey: "useMetricUnits")
        }
    }
    
    /// Published mode
    @Published var transportMode: TransportMode {
        didSet { UserDefaults.standard.set(transportMode.rawValue, forKey: Key.mode) }
    }
    
    init() {
        useMetricUnits = UserDefaults.standard.bool(forKey: "useMetricUnits")
        
        // Transport mode (default to automobile on first launch)
        if let raw = UserDefaults.standard.string(forKey: Key.mode),
           let saved = TransportMode(rawValue: raw) {
            transportMode = saved
        } else {
            transportMode = .automobile
        }
    }
}

