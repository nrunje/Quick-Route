//
//  HomeView.swift
//  Quick Route
//
//  Created by Nicholas Runje on 4/22/25.
//  Updated: 4/28/25 // Updated comment
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var routeViewModel: RouteViewModel
    /// State to track which item is being edited via the sheet.
    @State private var editingItem: EditableItem? = nil
    // Removed local isPlanningRoute state - now uses routeViewModel.isPlanningRoute
    // @State private var isPlanningRoute: Bool = false
    /// State to turn on validation alert (in case either origin or final stop is left blank)
    @State private var showValidationAlert = false
    /// State to display alert message
    @State private var validationMessage  = ""
    /// State to potentially show errors from route calculation
    @State private var showRouteErrorAlert = false
    @State private var routeErrorMessage = ""


    var body: some View {
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

                    // --- PAGE TITLE ---
                    Text("Set Route Points:") // Changed title slightly
                        .font(.headline)
                        .padding([.top, .leading, .trailing]) // Add padding around title
                        .padding(.bottom, 5) // Space below title
                    // --- END: PAGE TITLE ---

                    // --- ORIGIN BUTTON ---
                    DestinationButtonView(
                        text: routeViewModel.origin,
                        placeholder: "Set Origin Point",
                        isEmpty: routeViewModel.origin.isEmpty,
                        color: .orange // Example color for origin
                    ) {
                        print("Origin Button tapped")
                        editingItem = .origin // Set editing item to origin
                    }
                    .padding(.horizontal) // Horizontal padding for the button
                    .padding(.bottom, 10) // Space below button
                    // --- END: ORIGIN BUTTON ---

                    // --- WAYPOINTS ---
                    if !routeViewModel.intermediateDestinations.isEmpty {
                        // Section header
                        Text("Add Stops:")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.bottom, 5) // Added padding back

                        // List of waypoints
                        // Use List for dynamic content and swipe-to-delete
                        List {
                            ForEach(routeViewModel.intermediateDestinations.indices, id: \.self) { index in
                                // Ensure index is valid before accessing
                                if routeViewModel.intermediateDestinations.indices.contains(index) {
                                    let destination = routeViewModel.intermediateDestinations[index]
                                    DestinationButtonView(
                                        text: destination,
                                        placeholder: "Enter waypoint \(index + 1)", // Dynamic placeholder
                                        isEmpty: destination.isEmpty,
                                        color: destination.isEmpty ? .blue.opacity(0.6) : .blue // Adjusted colors slightly
                                    ) {
                                        editingItem = .intermediate(index: index)
                                    }
                                    // Apply list row styling if needed, e.g., remove separators
                                    .listRowInsets(EdgeInsets()) // Remove default padding
                                    .listRowSeparator(.hidden) // Hide separators
                                    .padding(.bottom, 8) // Add space between buttons in the list
                                }
                            }
                            .onDelete { indexSet in
                                routeViewModel.intermediateDestinations.remove(atOffsets: indexSet)
                                // Clear calculated routes if waypoints change
                                routeViewModel.calculatedRouteLegs = nil
                                routeViewModel.isPlanningRoute = false
                                routeViewModel.totalDistance = 0
                                routeViewModel.totalTravelTime = 0
                            }
                        }
                        .listStyle(.plain) // Use plain style to remove default List background/inset
                        .frame(height: calculateListHeight()) // Calculate height dynamically
                        // Add horizontal padding to match other elements if List adds its own
                         .padding(.horizontal)

                    }
                    // --- END: WAYPOINTS ---

                    // --- ADD WAYPOINT BUTTON ---
                    Button {
                        routeViewModel.intermediateDestinations.append("")
                        // Clear calculated routes if waypoints change
                        routeViewModel.calculatedRouteLegs = nil
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
                    // --- END: ADD WAYPOINT BUTTON ---

                    // --- FINAL STOP BUTTON ---
                    DestinationButtonView(
                        text: routeViewModel.finalStop,
                        placeholder: "Set Final Destination",
                        isEmpty: routeViewModel.finalStop.isEmpty,
                        color: .purple // Example color for final stop
                    ) {
                        print("Final Stop Button tapped")
                        editingItem = .finalStop // Set editing item to final stop
                    }
                    .padding(.horizontal) // Horizontal padding for the button
                    .padding(.bottom, 20) // More space before bottom buttons
                    // --- END: FINAL STOP BUTTON ---
                }
            } // END: SCROLLVIEW
            .ignoresSafeArea(edges: .top)

            // BUTTON FOR QUICK FILL (DELETE LATER)
             Button {
                 routeViewModel.origin = "123 Queen Anne Ave N, Seattle, WA, United States"
                 routeViewModel.finalStop = "456 Southcenter Mall, Tukwila, WA, United States"
                 routeViewModel.intermediateDestinations = ["701 5th Ave, Seattle, WA, United States", "400 Broad St, Seattle, WA, United States"]
                 routeViewModel.calculatedRouteLegs = nil // Clear old routes
             } label: {
                 Text("Test short")
             }
             .padding(10)
            
            /*
            Button {
                routeViewModel.origin = "Renton"
                routeViewModel.finalStop = "Spokane"
                routeViewModel.intermediateDestinations = ["Seattle", "Issaquah", "Leavenworth"]
                routeViewModel.calculatedRouteLegs = nil // Clear old routes
            } label: {
                Text("Test long")
            }
            .padding(10)
             */
            // THIS NEEDS TO BE DELETED

            // --- BOTTOM BUTTONS ---
            HStack(spacing: 15) {
                // --- GO BUTTON ---
                Button {
                    // ---- 1️⃣ Validate ----
                    let trimmedOrigin = routeViewModel.origin.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedFinal  = routeViewModel.finalStop.trimmingCharacters(in: .whitespacesAndNewlines)

                    guard !trimmedOrigin.isEmpty, !trimmedFinal.isEmpty else {
                        validationMessage = trimmedOrigin.isEmpty && trimmedFinal.isEmpty
                            ? "Please enter both an origin and a final destination."
                            : trimmedOrigin.isEmpty
                                ? "Please enter an origin point."
                                : "Please enter a final destination."
                        showValidationAlert = true
                        return // Skip the rest
                    }

                    // ---- 2️⃣ Clean intermediates (ViewModel might do this, but good practice here too) ----
                    routeViewModel.intermediateDestinations.removeAll {
                        $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    }

                    // ---- 3️⃣ Call ViewModel's route building function ----
                    // ViewModel now manages the isPlanningRoute state internally
                    Task {
//                        await routeViewModel.buildAndStoreRoutes() // Basic waypoint navigation
                        await routeViewModel.optimizeAndBuildRoutes() // Held-Karp algo optimization

                        if routeViewModel.calculatedRouteLegs == nil && !routeViewModel.isPlanningRoute {
                             routeErrorMessage = "Could not calculate the route. Please check the addresses and try again."
                             showRouteErrorAlert = true
                        }
                    }
                } label: {
                    // Use the ViewModel's state for the button label/indicator
                    if routeViewModel.isPlanningRoute {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white) // Ensure spinner is visible on colored background
                            .padding()
                            .frame(maxWidth: .infinity)
                            // Use gray when disabled/loading, blue otherwise
                            .background(Color.gray) // Use gray to indicate loading/disabled state
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    } else {
                        Text("Go")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue) // Active color
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                // Disable button based on ViewModel's state
                .disabled(routeViewModel.isPlanningRoute)
                // --- END: GO BUTTON ---

                // --- CLEAR BUTTON ---
                Button {
                    print("Clear button clicked")
                    routeViewModel.origin = ""
                    routeViewModel.intermediateDestinations = []
                    routeViewModel.finalStop = ""
                    // Clear the calculated routes using the correct property
                    routeViewModel.calculatedRouteLegs = nil
                    // Explicitly set planning to false if clearing during planning (optional, ViewModel should handle)
                    // routeViewModel.isPlanningRoute = false
                } label: {
                    Text("Clear")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity) // Make buttons share width
                        .background(Color.red) // Clear button color
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                 // Optionally disable clear button while planning?
                 // .disabled(routeViewModel.isPlanningRoute)

            } // END: HSTACK (Bottom Buttons)
            .padding(.horizontal) // Padding for the HStack
            .padding(.vertical, 10) // Padding above/below buttons
            .background(.bar) // Give buttons a background context (adapts to light/dark)
            // --- END: BOTTOM BUTTONS ---
        } // END: MAIN VSTACK
        .alert("Missing Information",
               isPresented: $showValidationAlert,
               actions: { Button("OK", role: .cancel) { } },
               message: { Text(validationMessage) })
        .alert("Route Error", // Alert for route calculation errors
               isPresented: $showRouteErrorAlert,
               actions: { Button("OK", role: .cancel) { } },
               message: { Text(routeErrorMessage) })
        // --- SHEET PRESENTATION ---
        .sheet(item: $editingItem) { item in
            // Use the helper function
            let params = Self.sheetParameters(
                for: item,
                origin: routeViewModel.origin,
                finalStop: routeViewModel.finalStop,
                intermediateDestinations: routeViewModel.intermediateDestinations
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
                    routeViewModel.origin = trimmedText
                    print("Origin updated to: \(trimmedText)")
                case .finalStop:
                    routeViewModel.finalStop = trimmedText
                    print("Final Stop updated to: \(trimmedText)")
                case let .intermediate(index):
                    // Safely update intermediate destination
                    if routeViewModel.intermediateDestinations.indices.contains(index) {
                        routeViewModel.intermediateDestinations[index] = trimmedText
                        print("Intermediate stop \(index + 1) updated to: \(trimmedText)")
                    }
                }
                // Clear calculated routes if any address changes
                routeViewModel.calculatedRouteLegs = nil
            }
            .presentationDetents([.medium, .large]) // Allow medium and large sheet sizes
            .presentationDragIndicator(.visible) // Show the drag indicator
        } // --- End of .sheet modifier ---
    } // END: Body

    /// Helper function to calculate List height dynamically.
    /// Adjust `rowHeightEstimate` based on your `DestinationButtonView`'s actual height + padding.
    func calculateListHeight() -> CGFloat {
        // Estimate the height needed per row in the List.
        // This includes the DestinationButtonView height and any vertical padding applied *within* the List row.
        let rowHeightEstimate: CGFloat = 65 // Adjust this based on visual inspection/testing
        let listContentHeight = CGFloat(routeViewModel.intermediateDestinations.count) * rowHeightEstimate

        // Define a maximum height to prevent the list from becoming excessively tall.
        let maxHeight: CGFloat = 300 // Example max height, adjust as needed

        // Return the calculated height, constrained by the max height and ensuring it's non-negative.
        return min(max(0, listContentHeight), maxHeight)
    }


    // Removed unused removeIntermediateStop function

    /// Helper function to get sheet parameters based on the item being edited.
    static func sheetParameters(for item: EditableItem, origin: String, finalStop: String, intermediateDestinations: [String]) -> (text: String, title: String) {
        switch item {
        case .origin:
            return (text: origin, title: "Set Origin Point")
        case .finalStop:
            return (text: finalStop, title: "Set Final Destination")
        case let .intermediate(index):
            // Safely check index before accessing
            if intermediateDestinations.indices.contains(index) {
                return (text: intermediateDestinations[index], title: "Edit Stop \(index + 1)")
            } else {
                // Fallback for an invalid index (should ideally not happen)
                print("Warning: Invalid index \(index) passed to sheet. Using defaults.")
                return (text: "", title: "Edit Stop")
            }
        }
    }
} // --- END: HOMEVIEW ---

// --- Helper Views and Enums (Keep these as they are) ---

/// Helper View for the Button Style (extracted for clarity)
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
                    .truncationMode(.tail) // Truncate if too long

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 44) // Ensure minimum tap target size
            // Use a slightly lighter background if empty, or the solid color if filled
            .background(isEmpty ? color.opacity(0.8) : color)
            .cornerRadius(10) // Rounded corners
        }
    }
}

/// Define what kind of destination item we are editing
/// Needed for the .sheet(item:) modifier to work with different types
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

// --- Preview ---
#Preview {
    // Ensure the preview also uses the updated ViewModel structure if needed
    HomeView()
        .environmentObject(RouteViewModel()) // Use environmentObject for preview too
}

