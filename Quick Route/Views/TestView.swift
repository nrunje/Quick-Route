//
//  TestView.swift
//  Quick Route
//
//  Created by Nicholas Runje on 4/9/25.
//

import SwiftUI

// Main view structure renamed to TestView
struct TestView: View {
    // State variable to hold the list of location strings.
    // Starts with one empty string to show the initial text field.
    @State private var locations: [String] = [""]

    var body: some View {
        // Use a ScrollView in case the list gets long
        ScrollView {
            // Arrange text fields vertically
            VStack(alignment: .leading) {
                Text("Enter Locations:")
                    .font(.headline)
                    .padding(.bottom, 5)

                // Iterate through the indices of the locations array
                ForEach(locations.indices, id: \.self) { index in
                    // Create a TextField for each location
                    TextField("Enter location \(index + 1)", text: $locations[index])
                        .textFieldStyle(RoundedBorderTextFieldStyle()) // Apply basic styling
                        .padding(.bottom, 5) // Add some space below each text field
                        .onChange(of: locations[index]) { _, newValue in
                            // Check if this is the last text field and it's not empty
                            if index == locations.count - 1 && !newValue.isEmpty {
                                // Add a new empty string to the array, triggering a new TextField
                                locations.append("")
                            }
                            // Optional: Remove empty fields if they are not the last one
                            // and the user clears the text after adding a new one.
                            // This prevents multiple empty fields if the user goes back and clears previous entries.
                            else if index < locations.count - 1 && newValue.isEmpty && locations.last!.isEmpty {
                                // Check if the field being cleared is the second to last one
                                // and the last one is still empty (meaning it was just added)
                                if index == locations.count - 2 {
                                    // Remove the last empty field that was just added
                                    locations.removeLast()
                                }
                            }
                        }

                    // --- Add vertical dots conditionally ---
                    // Show dots only if this is NOT the last item in the array
                    if index < locations.count - 1 {
                        // Use a VStack to stack dots vertically
                        VStack(spacing: -2) { // Adjust spacing between dots
                            Text(".")
                            Text(".")
                            Text(".")
                        }
                        .font(.caption) // Style the dots
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center) // Center the VStack
                        .padding(.vertical, 4) // Add vertical spacing around the dots
                    } else {
                        // Add some padding below the very last text field
                        Spacer().frame(height: 5)
                    }
                    // --- End of added dots ---
                }
                Spacer() // Pushes content to the top
            }
            .padding() // Add padding around the VStack
        }
        .navigationTitle("Location Entry") // Optional: Add a title if used in NavigationView
    }
}

#Preview {
    TestView()
}
