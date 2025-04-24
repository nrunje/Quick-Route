//
//  MapPlaceholderView .swift
//  Quick Route
//
//  Created by Nicholas Runje on 4/24/25.
//

import SwiftUI

struct MapPlaceholderView: View {
    var body: some View {
        ZStack {
            Color(.systemBlue)
                .ignoresSafeArea(edges: .top)

            VStack {
                Spacer()

                // Map icon
                Image(systemName: "map.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 32)

                // Message
                Text("Ready to plan your trip?")
                    .font(.system(size: 28, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("Head over to the Home tab to create your route.")
                    .multilineTextAlignment(.center)
                    .frame(width: 230)
                    .padding(.top, 4)

                Spacer()
            }
            .foregroundColor(.white)
        }
    }
}

#Preview {
    MapPlaceholderView()
}
