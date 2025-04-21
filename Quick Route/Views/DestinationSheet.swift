//
//  DestinationSheet.swift
//  Quick Route
//
//  Created by Nicholas Runje on 4/11/25. // Note: Year corrected to 2025 as in original
//

import SwiftUI
import MapKit

// The sheet view for entering a single destination with autocomplete
struct DestinationSheet: View {
    // StateObject to manage the lifecycle of AddressCompleter for this view
    @StateObject private var completer = AddressCompleter()

    // State for the text entered in the TextField (or selected from suggestions)
    @State private var destinationText: String // Renamed from inputText for clarity
    // Environment variable to dismiss the sheet
    @Environment(\.dismiss) var dismiss
    // Callback function to pass the selected text back
    var onSave: (String) -> Void
    // Title passed from the main view
    let sheetTitle: String

    // Custom initializer
    init(initialText: String, sheetTitle: String, onSave: @escaping (String) -> Void) {
        // Initialize the @State variable correctly using _ prefix
        _destinationText = State(initialValue: initialText)
        self.sheetTitle = sheetTitle
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) { // Reduced spacing

                // --- Text Field for Input ---
                TextField("Enter destination name or address", text: $destinationText)
                    .textFieldStyle(.plain) // Use plain style for better integration
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal) // Add horizontal padding to the container
                    .padding(.top) // Add top padding
                    // Use onChange to update the completer's query fragment
                    .onChange(of: destinationText) { newValue in
                        completer.queryFragment = newValue
                        // Optional: Clear suggestions if text is cleared manually AFTER selection
                        // This prevents the old list from sticking around if user deletes text
                        if newValue.isEmpty {
                            completer.suggestions = []
                        }
                    }

                // --- List of Suggestions ---
                // Only show the list if there are suggestions and the text field isn't empty
                if !completer.suggestions.isEmpty && !destinationText.isEmpty {
                    List(completer.suggestions, id: \.self) { suggestion in
                        VStack(alignment: .leading) {
                            Text(suggestion.title)
                                .font(.headline)
                                .foregroundColor(.primary) // Ensure text is visible in dark/light mode
                            Text(suggestion.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary) // Ensure text is visible
                        }
                        .contentShape(Rectangle()) // Make the whole row tappable
                        .onTapGesture {
                            // When a suggestion is tapped:
                            // 1. Update the text field with the full address
                            destinationText = suggestion.title + (!suggestion.subtitle.isEmpty ? ", \(suggestion.subtitle)" : "")
                            // 2. Clear the suggestions list
                            completer.suggestions = []
                            // 3. Dismiss keyboard (optional but good UX)
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                    .listStyle(.plain) // Use plain style to avoid extra separators/inset
                    .frame(maxHeight: .infinity) // Limit height to prevent taking too much space
                    .padding(.horizontal) // Match horizontal padding of TextField
                    .transition(.opacity.animation(.easeInOut(duration: 0.2))) // Add smooth transition
                }

                Spacer() // Push content to top
            }
            // Removed padding() on VStack to allow List to go edge-to-edge if needed
            .navigationTitle(sheetTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Add a "Done" button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onSave(destinationText) // Pass back the final text
                        dismiss()
                    }
                    // Disable if the final destination text is empty
                    .disabled(destinationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                // Add a "Cancel" button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            // Start search immediately if initial text exists (e.g., editing)
            .onAppear {
                 if !destinationText.isEmpty {
                     completer.queryFragment = destinationText
                 }
            }
        }
    }
}

#Preview {
    DestinationSheet(initialText: "", sheetTitle: "Enter Destination:", onSave: { text in
        print("Saved: \(text)")
    })
}
