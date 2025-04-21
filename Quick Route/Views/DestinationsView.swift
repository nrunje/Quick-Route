//
//  DestinationsView.swift
//  Quick Route
//
//  Created by Nicholas Runje on 2/4/25.
//  Last Updated: 4/15/25 (Incorporating List, Swipe Delete, Buttons)
//

import CoreLocation
import MapKit
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
        case let .intermediate(index): return "intermediate_\(index)"
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
    @State private var isPlanningRoute: Bool = false

    // **** Add state to hold the calculated route ****
    @State private var calculatedRoute: MKRoute? = nil

    // Helper function to get sheet parameters based on the item
    static func sheetParameters(for item: EditableItem, origin: String, finalStop: String, intermediateDestinations: [String]) -> (text: String, title: String) {
        switch item {
        case .origin:
            return (text: origin, title: "Set Origin Point")
        case .finalStop:
            return (text: finalStop, title: "Set Final Destination")
        case let .intermediate(index):
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
                    // Conditionally display header and List only if not empty
                    if !intermediateDestinations.isEmpty {
                        // Section header
                        Text("Add Stops:")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.bottom, 5)

                        // List for Intermediate Stops (allows swipe-to-delete)
                        List {
                            ForEach(intermediateDestinations.indices, id: \.self) { index in
                                // Use ZStack to layer tap gesture over the button content
                                ZStack {
                                    // Your existing button view - make background clear if needed
                                    DestinationButtonView(
                                        text: intermediateDestinations[index],
                                        placeholder: "Stop \(index + 1)",
                                        isEmpty: intermediateDestinations[index].isEmpty,
                                        color: intermediateDestinations[index].isEmpty ? .blue : .green
                                    ) {
                                        // Action handled by onTapGesture below
                                    }
                                    .buttonStyle(.plain) // Prevents visual conflicts

                                    // Add clear background tap gesture area for editing
                                    Color.clear
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            print("Intermediate Item \(index + 1) tapped for edit")
                                            editingItem = .intermediate(index: index) // Set editing item
                                        }
                                }
                                // Remove list row separator/padding for cleaner look
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .padding(.horizontal) // Apply horizontal padding here
                                .padding(.bottom, 20) // Apply bottom padding here
                            }
                            .onDelete(perform: removeIntermediateStop) // Enable swipe delete
                        }
                        .listStyle(.plain) // Use plain style to minimize List appearance
                        .frame(height: calculateListHeight()) // Give List a frame to avoid layout issues
//                        .padding(.bottom, 10) // Space below the list section
                    } // End of conditional rendering for List
                    // --- END: INTERMEDIATE DESTINATIONS ---

                    // --- ADD INTERMEDIATE STOP BUTTON ---
                    Button {
                        intermediateDestinations.append("") // Just add an empty slot
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
                } // End of inner VStack
            } // End of ScrollView
            .ignoresSafeArea(edges: .top) // Allow content (image) to go under status bar

            // --- BOTTOM BUTTONS ---
            HStack(spacing: 15) {
                // Go Button
                Button {
                    isPlanningRoute = true
                    calculatedRoute = nil // Clear previous route

                    var routePlanner = RoutePlanner(
                        origin: origin,
                        intermediateDestinations: intermediateDestinations,
                        finalStop: finalStop
                    )

                    // Test the origin, intermediate destinations, and final stop by printing
                    // routePlanner.getCoordinateFrom returns a CLLocationCoordinate2D optional
                    Task {
                        do {
                            if let originCoord = try await routePlanner.getCoordinateFrom(address: origin) {
                                print("Origin: \(originCoord)")
                            }

                            for addr in intermediateDestinations {
                                if let intermediateCoord = try await routePlanner.getCoordinateFrom(address: addr) {
                                    print("Intermediate: \(intermediateCoord)")
                                }
                            }

                            if let finalCoord = try await routePlanner.getCoordinateFrom(address: finalStop) {
                                print("Final stop: \(finalCoord)")
                            }

                        } catch {
                            print("Error geocoding address: \(error)")
                        }
                    }

                } label: {
                    // ... (ProgressView or Text label based on isPlanningRoute) ...
                    if isPlanningRoute {
                        ProgressView().progressViewStyle(.circular).tint(.white).padding().frame(maxWidth: .infinity).background(Color.gray).foregroundColor(.white).cornerRadius(10)
                    } else {
                        Text("Go").font(.headline).padding().frame(maxWidth: .infinity).background(Color.blue).foregroundColor(.white).cornerRadius(10)
                    }
                }
                .disabled(isPlanningRoute || origin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || finalStop.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                // Clear Button
                Button {
                    // Action to clear all destinations
                    origin = ""
                    finalStop = ""
                    intermediateDestinations = []
                    isPlanningRoute = false
                    calculatedRoute = nil
                    print("Route Cleared")
                } label: {
                    Text("Clear")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity) // Make buttons share width
                        .background(Color.red) // Clear button color
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal) // Padding for the HStack
            .padding(.vertical, 10) // Padding above/below buttons
            .background(.bar) // Give buttons a background context (adapts to light/dark)
        } // End of outer VStack
        // --- SHEET PRESENTATION ---
        .sheet(item: $editingItem) { item in
            // Use the helper function
            let params = Self.sheetParameters(
                for: item,
                origin: origin,
                finalStop: finalStop,
                intermediateDestinations: intermediateDestinations
            )

            // Create the DestinationSheet View
            DestinationSheet(
                initialText: params.text,
                sheetTitle: params.title
            ) { enteredText in
                // onSave callback from DestinationSheet
                let trimmedText = enteredText.trimmingCharacters(in: .whitespacesAndNewlines)

                // Update the correct state variable based on which item was edited
                switch item {
                case .origin:
                    origin = trimmedText
                    print("Origin updated to: \(trimmedText)")
                case .finalStop:
                    finalStop = trimmedText
                    print("Final Stop updated to: \(trimmedText)")
                case let .intermediate(index):
                    // Safely update intermediate destination
                    if intermediateDestinations.indices.contains(index) {
                        intermediateDestinations[index] = trimmedText
                        print("Intermediate stop \(index + 1) updated to: \(trimmedText)")
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        } // --- End of .sheet modifier ---
    } // End of body

    // **** Function to remove items from the intermediate list ****
    func removeIntermediateStop(at offsets: IndexSet) {
        intermediateDestinations.remove(atOffsets: offsets)
        print("Removed intermediate stop at offsets: \(offsets). Count: \(intermediateDestinations.count)")
    }

    // **** Helper function to calculate List height (adjust rowHeight estimate) ****
    func calculateListHeight() -> CGFloat {
        // Estimate the height of one DestinationButtonView row + padding
        // Adjust this value based on your actual DestinationButtonView layout + .padding(.bottom, 10)
        let rowHeight: CGFloat = 70
        let listContentHeight = CGFloat(intermediateDestinations.count) * rowHeight
        // Return calculated height, ensuring it's non-negative
        return max(0, listContentHeight)
    }
} // End of DestinationsView

// Helper View for the Button Style (extracted for clarity)
struct DestinationButtonView: View {
    let text: String
    let placeholder: String
    let isEmpty: Bool
    let color: Color // Pass the base color
    let action: () -> Void // Action for the button itself

    var body: some View {
        Button(action: action) { // Button still needed for styling/structure
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
    // Add environment objects here if your DestinationSheet or AddressCompleter need them
}
