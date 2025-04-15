//
//  DestinationsView.swift
//  Quick Route
//
//  Created by Nicholas Runje on 2/4/25.
//

import SwiftUI

// Define what kind of destination item we are editing
// Needed for the .sheet(item:) modifier to work with different types
enum EditableItem: Identifiable, Hashable {
    case origin
    case finalStop
    case intermediate(index: Int)

    // Provide a stable ID for the .sheet(item:) modifier
    var id: String {
        switch self {
        case .origin: return "origin"
        case .finalStop: return "finalStop"
        case .intermediate(let index): return "intermediate_\(index)"
        }
    }
}

// Main view displaying the list of destination buttons
struct DestinationsView: View {
    // State for the fixed points
    @State private var origin: String = ""
    @State private var finalStop: String = ""

    // State variable to hold the list of INTERMEDIATE destination strings.
    @State private var intermediateDestinations: [String] = [] // Start empty now

    // State variable to track which item is being edited via the sheet.
    @State private var editingItem: EditableItem? = nil // Use the new enum

    // Helper function to get sheet parameters based on the item
    // This resolves the 'buildExpression' error by simplifying the .sheet closure
    static func sheetParameters(for item: EditableItem, origin: String, finalStop: String, intermediateDestinations: [String]) -> (text: String, title: String) {
        switch item {
        case .origin:
            return (text: origin, title: "Set Origin Point")
        case .finalStop:
            return (text: finalStop, title: "Set Final Destination")
        case .intermediate(let index):
            // Safely check index
            if intermediateDestinations.indices.contains(index) {
                return (text: intermediateDestinations[index], title: "Edit Stop \(index + 1)")
            } else {
                // Handle invalid index case gracefully
                print("Warning: Invalid index \(index) passed to sheet. Using defaults.")
                return (text: "", title: "Edit Stop")
            }
        }
    }


    var body: some View {
        // **** Outer VStack to hold ScrollView and Bottom Buttons ****
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) { // Added some default spacing
                    // --- COVER AND HEADER ---
                    ZStack {
                        // Replace "destinationscover" with your actual image name if different
                        Image("destinationscover")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .overlay(Color.black.opacity(0.4))

                        VStack {
                            Spacer()
                            Spacer()
                            Text("Quick Route")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .padding(.bottom, 10) // Space below header

                    // --- PAGE TITLE ---
                    Text("Set Route Points:") // Changed title slightly
                        .font(.headline)
                        .padding([.top, .leading, .trailing]) // Add padding around title
                        .padding(.bottom, 5) // Space below title
                    // --- END: PAGE TITLE ---


                    // --- ORIGIN BUTTON ---
                    DestinationButtonView(
                        text: origin,
                        placeholder: "Set Origin Point",
                        isEmpty: origin.isEmpty,
                        color: .orange // Example color for origin
                    ) {
                        print("Origin Button tapped")
                        editingItem = .origin // Set editing item to origin
                    }
                    .padding(.horizontal) // Horizontal padding for the button
                    .padding(.bottom, 10) // Space below button


                    // --- INTERMEDIATE DESTINATIONS ---
                    // Only show this section header if there are intermediate stops
                    if !intermediateDestinations.isEmpty {
                         Text("Add Stops:")
                             .font(.headline)
                             .padding(.horizontal)
                             .padding(.bottom, 5)
                     }

                    // Iterate through the indices of the intermediate destinations array
                    ForEach(intermediateDestinations.indices, id: \.self) { index in
                        DestinationButtonView(
                            text: intermediateDestinations[index],
                            placeholder: "Stop \(index + 1)",
                            isEmpty: intermediateDestinations[index].isEmpty,
                            color: intermediateDestinations[index].isEmpty ? .blue : .green // Original colors
                        ) {
                              print("Intermediate Button \(index + 1) tapped")
                              editingItem = .intermediate(index: index) // Set editing item to intermediate
                        }
                        .padding(.horizontal) // Horizontal padding for the button
                        .padding(.bottom, 10) // Space below each button
                    }
                    // --- END: DYNAMIC DESTINATION BUTTONS ---

                    // --- ADD INTERMEDIATE STOP BUTTON ---
                     Button {
                          intermediateDestinations.append("") // Just add an empty slot
                          // Optional: Automatically open sheet for the new stop
                          // editingItem = .intermediate(index: intermediateDestinations.count - 1)
                          print("Added new intermediate stop slot. Count: \(intermediateDestinations.count)")
                     } label: {
                          HStack {
                              Image(systemName: "plus.circle.fill")
                              Text("Add Intermediate Stop")
                          }
                          .padding()
                          .frame(maxWidth: .infinity)
                          .background(Color.secondary.opacity(0.2))
                          .foregroundColor(.blue)
                          .cornerRadius(10)
                     }
                     .padding(.horizontal)
                     .padding(.bottom, 10)


                    // --- FINAL STOP BUTTON ---
                     DestinationButtonView(
                         text: finalStop,
                         placeholder: "Set Final Destination",
                         isEmpty: finalStop.isEmpty,
                         color: .purple // Example color for final stop
                     ) {
                          print("Final Stop Button tapped")
                          editingItem = .finalStop // Set editing item to final stop
                     }
                     .padding(.horizontal) // Horizontal padding for the button
                     .padding(.bottom, 10) // Space below button

                    // Removed the old "Start Navigation" button and Spacer
                } // End of inner VStack
            } // End of ScrollView
            .ignoresSafeArea(edges: .top) // Allow content (image) to go under status bar

            // --- BOTTOM BUTTONS ---
            HStack(spacing: 15) {
                // Go Button
                Button {
                    // Action to print the route details
                    print("\n--- Route Details ---")
                    print("Origin: \(origin.isEmpty ? "Not Set" : origin)")
                    // Filter intermediate destinations to only print non-empty ones
                    let validStops = intermediateDestinations.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                    print("Stops: \(validStops)")
                    print("Final: \(finalStop.isEmpty ? "Not Set" : finalStop)")
                    print("---------------------\n")

                    // Placeholder for actual navigation logic
                    // Add navigation logic here later
                } label: {
                    Text("Go")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity) // Make buttons share width
                        .background(Color.blue)     // Go button color
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Clear Button
                Button {
                    // Action to clear all destinations
                    origin = ""
                    finalStop = ""
                    intermediateDestinations = []
                    print("Route Cleared")
                } label: {
                    Text("Clear")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity) // Make buttons share width
                        .background(Color.red)      // Clear button color
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal) // Padding for the HStack
            .padding(.vertical, 10) // Padding above/below buttons
            .background(.bar) // Give buttons a background context (adapts to light/dark)

        } // End of outer VStack
        // --- SHEET PRESENTATION ---
        // Use .sheet(item:) bound to our Optional EditableItem state.
        .sheet(item: $editingItem) { item in // 'item' is the non-optional EditableItem
            // --- Use the helper function ---
            let params = Self.sheetParameters(
                for: item, // Pass the unwrapped item
                origin: origin,
                finalStop: finalStop,
                intermediateDestinations: intermediateDestinations
            )

            // --- Now, simply create the View ---
            DestinationSheet(
                initialText: params.text, // Use calculated text
                sheetTitle: params.title  // Use calculated title
            ) { enteredText in
                // --- This onSave callback runs when DestinationSheet calls it ---
                let trimmedText = enteredText.trimmingCharacters(in: .whitespacesAndNewlines)

                // Update the correct state variable based on which item was edited
                // Use the 'item' captured by the .sheet closure
                switch item {
                case .origin:
                    origin = trimmedText
                    print("Origin updated to: \(trimmedText)")
                case .finalStop:
                    finalStop = trimmedText
                     print("Final Stop updated to: \(trimmedText)")
                case .intermediate(let index):
                    // Safely update intermediate destination
                    if intermediateDestinations.indices.contains(index) {
                        intermediateDestinations[index] = trimmedText
                        print("Intermediate stop \(index + 1) updated to: \(trimmedText)")
                    }
                }
                // --- End of callback logic ---
            }
            .presentationDetents([.medium, .large]) // Allow medium and large sheet sizes
            .presentationDragIndicator(.visible) // Show the drag indicator
        } // --- End of .sheet modifier ---
    } // End of body
} // End of DestinationsView


// Helper View for the Button Style (extracted for clarity)
struct DestinationButtonView: View {
    let text: String
    let placeholder: String
    let isEmpty: Bool
    let color: Color // Pass the base color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                // Display the entered destination or the placeholder text
                Text(text.isEmpty ? placeholder : text)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1) // Prevent text from wrapping

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .frame(maxWidth: .infinity)
            // Use a slightly lighter background if empty, or the solid color if filled
            .background(isEmpty ? color.opacity(0.8) : color)
            .cornerRadius(10) // Rounded corners
        }
    }
}

// Preview provider
#Preview {
    DestinationsView()
}
