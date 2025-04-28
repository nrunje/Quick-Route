//
//  HomeView.swift
//  Quick Route
//
//  Created by Nicholas Runje on 4/22/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var routeViewModel: RouteViewModel
    /// State to track which item is being edited via the sheet.
    @State private var editingItem: EditableItem? = nil
    /// State to track if geocoding is ongoing
    @State private var isPlanningRoute: Bool = false

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
//                            .padding(.bottom, 5)

                        // List of waypoints
                        List {
                            ForEach(routeViewModel.intermediateDestinations, id: \.self) { destination in
                                DestinationButtonView(
                                    text: destination,
                                    placeholder: "Enter waypoint",
                                    isEmpty: destination.isEmpty,
                                    color: destination.isEmpty ? .blue : .green
                                ) {
                                    if let idx = routeViewModel.intermediateDestinations.firstIndex(of: destination) {
                                        editingItem = .intermediate(index: idx)
                                    }
                                }
                            }
                            .onDelete { indexSet in
                                routeViewModel.intermediateDestinations.remove(atOffsets: indexSet)
                                routeViewModel.routes = nil
                            }
                        }
                        .listStyle(.plain)
                        .frame(height: calculateListHeight())
                    }
                    // --- END: WAYPOINTS ---

                    // --- ADD WAYPOINT BUTTON ---
                    Button {
                        routeViewModel.intermediateDestinations.append("")
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
                    .padding(.bottom, 10) // Space below button
                    // --- END: FINAL STOP BUTTON ---
                }
            } // END: SCROLLVIEW
            .ignoresSafeArea(edges: .top)

            // BUTTON FOR QUICK FILL (DELETE)
            Button {
                routeViewModel.origin = "123 Queen Anne Ave N, Seattle, WA, United States"
                routeViewModel.finalStop = "456 Southcenter Mall, Tukwila, WA, United States"
                routeViewModel.intermediateDestinations = ["701 5th Ave, Seattle, WA, United States", "400 Broad St, Seattle, WA, United States"]
            } label: {
                Text("Test fill")
            }
            // THIS NEEDS TO BE DELETED

            // --- BOTTOM BUTTONS ---
            HStack(spacing: 15) {
                // --- GO BUTTON ---
                Button {
                    print("Go button clicked")
                    print(routeViewModel.origin)
                    print(routeViewModel.intermediateDestinations)
                    print(routeViewModel.finalStop)
                    isPlanningRoute = true

                    Task {
//                        await routeViewModel.testGeocode() // Test CLLocationCoordinate2D encoding

                        if let allRoutes = try await routeViewModel.buildMKRoutes() {
                            routeViewModel.routes = allRoutes
                            print("Routes from routeViewModel: \(routeViewModel.routes!)")
                        } else {
                            print("Could not compute routes")
                        }
                        
                        isPlanningRoute = false
                    }
                } label: {
                    // ... (ProgressView or Text label based on isPlanningRoute) ...
                    if isPlanningRoute {
                        ProgressView().progressViewStyle(.circular).tint(.white).padding().frame(maxWidth: .infinity).background(Color.gray).foregroundColor(.white).cornerRadius(10)
                    } else {
                        Text("Go").font(.headline).padding().frame(maxWidth: .infinity).background(Color.blue).foregroundColor(.white).cornerRadius(10)
                    }
                }
                .disabled(isPlanningRoute || routeViewModel.origin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || routeViewModel.finalStop.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                // --- END: GO BUTTON ---

                // --- CLEAR BUTTON ---
                Button {
                    print("Clear button clicked")
                    routeViewModel.origin = ""
                    routeViewModel.intermediateDestinations = []
                    routeViewModel.finalStop = ""
                    routeViewModel.routes = nil
                    routeViewModel.isPlanningRoute = false
                } label: {
                    Text("Clear")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity) // Make buttons share width
                        .background(Color.red) // Clear button color
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal) // Padding for the HStack
                .padding(.vertical, 10) // Padding above/below buttons
                .background(.bar) // Give buttons a background context (adapts to light/dark)
                // --- END: CLEAR BUTTON ---
            }
            .padding(.horizontal) // Padding for the HStack
            .padding(.vertical, 10) // Padding above/below buttons
            .background(.bar) // Give buttons a background context (adapts to light/dark)
            // --- END: BOTTOM BUTTONS ---
        } // END: MAIN VSTACK
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
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        } // --- End of .sheet modifier ---
    }

    /// Helper function to calculate List height (adjust rowHeight estimate)
    func calculateListHeight() -> CGFloat {
        // Estimate the height of one DestinationButtonView row + padding
        // Adjust this value based on your actual DestinationButtonView layout + .padding(.bottom, 10)
        let rowHeight: CGFloat = 70
        let listContentHeight = CGFloat(routeViewModel.intermediateDestinations.count) * rowHeight
        // Return calculated height, ensuring it's non-negative
        return max(0, listContentHeight)
    }

    /// Function to remove items from the intermediate list
    func removeIntermediateStop(at offsets: IndexSet) {
        routeViewModel.intermediateDestinations.remove(atOffsets: offsets)
        print("Removed intermediate stop at offsets: \(offsets). Count: \(routeViewModel.intermediateDestinations.count)")
    }

    /// Helper function to get sheet parameters based on the item
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
} // --- END: HOMEVIEW --

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

#Preview {
    HomeView()
        .environment(RouteViewModel())
}
