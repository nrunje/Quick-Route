//
//  DestinationsView.swift
//  Quick Route
//
//  Created by Nicholas Runje on 2/4/25.
//

import SwiftUI

// Main view displaying the list of destination buttons
struct DestinationsView: View {
    // State variable to hold the list of destination strings.
    // An empty string "" represents an empty slot. Starts with one slot.
    @State private var destinations: [String] = [""]
    // State variable to track which destination index is being edited via the sheet.
    // `nil` means no sheet is presented.
    @State private var editingIndex: Int? = nil

    var body: some View {
        // Use ScrollView in case the list gets long
        ScrollView {
            VStack(alignment: .leading, spacing: 0) { // Use spacing 0 if needed
                // --- COVER AND HEADER ---
                ZStack {
                    Image("destinationscover")
                        .resizable()
                        .aspectRatio(contentMode: .fill) // Fill the frame
                        .frame(height: 200) // Fixed height
                        .clipped() // Clip overflow
                        .overlay(Color.black.opacity(0.4)) // Darken the image

                    VStack {
                        Spacer()
                        Spacer()
                        Text("Quick Route")
                            .foregroundColor(.white) // Make the text white
                            .font(.largeTitle) // Make the text large (you can adjust this)
                            .fontWeight(.bold)
                        Spacer()
                    } // Optional: make it bold for emphasis
                } // Darken the image
                // --- END: COVER AND HEADER --

                // --- PAGE TITLE ---
                Text("Enter destinations:")
                    .font(.headline)
                    .padding([.top, .leading, .trailing]) // Add padding around title
                    .padding(.bottom, 10) // Space below title
                // --- END: PAGE TITLE ---

                // --- DYNAMIC DESTINATION BUTTONS ---
                // Iterate through the indices of the destinations array
                ForEach(destinations.indices, id: \.self) { index in
                    Button(action: {
                        // Set the index to be edited, which triggers the sheet
                        print("Button \(index + 1) tapped")
                        editingIndex = index
                    }) {
                        HStack {
                            // Display the entered destination or the placeholder text
                            Text(destinations[index].isEmpty ? "Destination \(index + 1)" : destinations[index])
                                .font(.headline)
                                .foregroundColor(.white)
                                .lineLimit(1) // Prevent text from wrapping

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        // --- Conditional Background Color ---
                        // If the destination string is empty (placeholder), use blue.
                        // Otherwise (user entered text), use green.
                        .background(destinations[index].isEmpty ? Color.blue : Color.green)
                        // --- End Conditional Background Color ---
                        .cornerRadius(10) // Rounded corners
                    }
                    .padding(.horizontal) // Horizontal padding for the button
                    .padding(.bottom, 10) // Space below each button
                }
                // --- END: DYNAMIC DESTINATION BUTTONS ---

                Spacer() // Push content to top if VStack is not filling screen
            }
        }
        .ignoresSafeArea(edges: .top) // Allow content (image) to go under status bar
        // --- SHEET PRESENTATION ---
        // Use .sheet(item:) which binds to an Optional Identifiable state.
        // When editingIndex is set to a non-nil Int, the sheet appears.
        .sheet(item: $editingIndex) { index in
            // Pass the initial text and the callback function to the sheet
            DestinationSheet(initialText: destinations[index]) { enteredText in
                // --- This code runs when the sheet calls the onSave callback ---
                let trimmedText = enteredText.trimmingCharacters(in: .whitespacesAndNewlines)

                // Update the destination text in our array
                destinations[index] = trimmedText

                // Check if the user just filled the *last* available slot
                if index == destinations.count - 1 && !trimmedText.isEmpty {
                    // If yes, add a new empty slot to the end of the array
                    destinations.append("")
                    print("Added new destination slot. Count: \(destinations.count)")
                }
                // --- End of callback logic ---
            }
            .presentationDetents([.large]) // Allow medium and large sheet sizes
            .presentationDragIndicator(.visible) // Show the drag indicator
        }
    }
}

// The sheet view for entering a single destination
struct DestinationSheet: View {
    // State for the text entered in the TextField
    @State private var inputText: String
    // Environment variable to dismiss the sheet
    @Environment(\.dismiss) var dismiss
    // Callback function to pass the entered text back to DestinationsView
    var onSave: (String) -> Void

    // Custom initializer to receive the initial text and the callback
    init(initialText: String, onSave: @escaping (String) -> Void) {
        // Initialize the @State variable correctly using _ prefix
        _inputText = State(initialValue: initialText)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView { // Wrap in NavigationView for title and potential toolbar items
            VStack(alignment: .leading, spacing: 20) {
                // TextField for entering the destination name
                TextField("Enter destination name or address", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.top) // Add some padding above the text field

                Spacer() // Push content to top
            }
            .padding() // Padding for the VStack content
            .navigationTitle("Enter Destination") // Title for the sheet
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Add a "Done" button to the toolbar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onSave(inputText) // Call the callback with the entered text
                        dismiss() // Dismiss the sheet
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // Disable if empty
                }
                // Add a "Cancel" button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss() // Dismiss the sheet without saving
                    }
                }
            }
        }
    }
}

// Preview provider
#Preview {
    DestinationsView()
}

// Extension to make Int identifiable for the .sheet(item:) modifier
extension Int: Identifiable {
    public var id: Int { self }
}
