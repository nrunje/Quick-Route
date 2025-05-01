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
    @Published var useMetricUnits: Bool {
        didSet {
            UserDefaults.standard.set(useMetricUnits, forKey: "useMetricUnits")
        }
    }
    
    init() {
        useMetricUnits = UserDefaults.standard.bool(forKey: "useMetricUnits")
    }
}

