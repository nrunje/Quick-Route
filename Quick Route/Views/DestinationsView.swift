//
//  DestinationsView.swift
//  Quick Route
//
//  Created by Nicholas Runje on 2/27/25.
//

import SwiftUI

struct DestinationsView: View {
    @State private var showSheet = false

    var body: some View {
        VStack(alignment: .leading) {
            // COVER IMAGE
            Image("destinationscover")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped() // Clip first to constrain the image
//                .blur(radius: 5) // Then blur within the clipped bounds
                .overlay(Color.black.opacity(0.4)) // Darken after blur
            // END: COVER IMAGE

            // PAGE TITLE:
            Text("Enter destinations:")
                .font(.headline)
                .padding(.bottom, 5)
                .padding()
            // END: PAGE TITLE

            // BUTTON
            Button(action: {
                // Action when button is tapped
                print("Destination 1 tapped")
                showSheet = true
            }) {
                HStack {
                    Text("Destination 1")
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            // END: BUTTON

            Spacer() // Push items to top
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showSheet) {
            SheetContentView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

struct SheetContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Destination Options")
                .font(.title2)
                .bold()

            Text("Here’s where you can add info about this destination.")

            Spacer()
        }
        .padding()
    }
}

#Preview {
    DestinationsView()
}
