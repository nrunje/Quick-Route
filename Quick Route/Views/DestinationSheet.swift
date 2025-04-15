//
//  DestinationSheet.swift
//  Quick Route
//
//  Created by Nicholas Runje on 4/11/25.
//

import SwiftUI

// The sheet view for entering a single destination
struct DestinationSheet: View {
    // State for the text entered in the TextField
    @State private var inputText: String
    // Environment variable to dismiss the sheet
    @Environment(\.dismiss) var dismiss
    // Callback function to pass the entered text back to DestinationsView
    var onSave: (String) -> Void
    // Title passed from the main view
    let sheetTitle: String

    // Custom initializer to receive the initial text, title, and the callback
    init(initialText: String, sheetTitle: String, onSave: @escaping (String) -> Void) {
        // Initialize the @State variable correctly using _ prefix
        _inputText = State(initialValue: initialText)
        self.sheetTitle = sheetTitle
        self.onSave = onSave
    }

    var body: some View {
        NavigationView { // Wrap in NavigationView for title and potential toolbar items
            VStack(alignment: .leading, spacing: 20) {

                // ** Basic TextField - MapKit Autocomplete UI is NOT added here **
                TextField("Enter destination name or address", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.top) // Add some padding above the text field
                    // If you want it to look similar to the MapKit example's input:
                    // .padding()
                    // .background(Color(.systemGray6))
                    // .cornerRadius(10)

                Spacer() // Push content to top
            }
            .padding() // Padding for the VStack content
            .navigationTitle(sheetTitle) // Use the passed-in title
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

#Preview {
    DestinationSheet(initialText: "", sheetTitle: "Enter Destination:", onSave: { _ in })
}
