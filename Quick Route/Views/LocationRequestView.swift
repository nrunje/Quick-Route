//
//  LocationRequestView.swift
//  Quick Route
//
//  Created by Nicholas Runje on 2/10/25.
//

import SwiftUI

struct LocationRequestView: View {
    var body: some View {
        ZStack {
            Color(.systemBlue).ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image(systemName: "paperplane.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 32)
                
                Text("Allow location services for accurate directions")
                    .font(.system(size: 28, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("Start sharing your location?")
                    .multilineTextAlignment(.center)
                    .frame(width: 140)
                    .padding()
                
                Spacer()
                
                VStack {
                    Button {
                        print("Request location from user")
                        LocationManager.shared.requestLocation()
                    } label: {
                        Text("Allow location")
                            .padding()
                            .font(.headline)
                            .foregroundColor(Color(.systemBlue))
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .padding(.horizontal, -32)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .padding()
                    
                    Button {
                        print("Dismiss")
                    } label: {
                        Text("Maybe later")
                    }
                }
                .padding(.bottom, 32)
            }
            .foregroundColor(.white)
        }
    }
}

#Preview {
    LocationRequestView()
}
