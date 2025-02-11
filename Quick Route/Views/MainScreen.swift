//
//  MainScreen.swift
//  Quick Route
//
//  Created by Nicholas Runje on 2/10/25.
//

import SwiftUI

struct MainScreen: View {
    @ObservedObject var locationManager = LocationManager.shared
    
    var body: some View {
        Text("On main screen")
    }
}

#Preview {
    MainScreen()
}
