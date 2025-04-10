//
//  Test2View.swift
//  Quick Route
//
//  Created by Nicholas Runje on 4/10/25.
//
import SwiftUI
import MapKit // Import MapKit here too

struct Test2View: View {
    // MARK: - State Variables

    // Holds the text entered by the user (still needed for the TextField)
    @State private var addressInput: String = ""
    
    // Create an instance of our ObservableObject using @StateObject
    // @StateObject ensures it persists for the view's lifecycle
    @StateObject private var completer = AddressCompleter()

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading) {
            Text("Enter destination")
                .font(.headline)
                .padding(.bottom, 2)

            // The TextField bound to our local state variable
            TextField("e.g., 123 Main St, City, State", text: $addressInput)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom)
                // --- Trigger Update ---
                // Update the completer's queryFragment whenever addressInput changes
                .onChange(of: addressInput) { newValue in
                    // Pass the new input to the AddressCompleter's published property
                    // The debounce logic inside AddressCompleter will handle API calls
                    completer.queryFragment = newValue
                }

            // --- Suggestions List ---
            // List now observes the 'suggestions' published by the AddressCompleter
            // Only show if the user is typing AND there are suggestions
            if !completer.suggestions.isEmpty && !addressInput.isEmpty {
                List(completer.suggestions, id: \.self) { suggestion in
                    // MKLocalSearchCompletion provides title and subtitle
                    VStack(alignment: .leading) {
                        Text(suggestion.title)
                            .fontWeight(.medium)
                        Text(suggestion.subtitle)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .onTapGesture {
                        // Action when a suggestion is tapped:
                        // 1. Set the TextField text based on the suggestion
                        //    (Combine title and subtitle for a fuller address)
                        self.addressInput = "\(suggestion.title), \(suggestion.subtitle)"
                        
                        // 2. Clear the completer query and suggestions
                        //    Setting addressInput triggers onChange, which updates queryFragment
                        //    Or explicitly clear:
                        //    completer.queryFragment = "" // This clears suggestions via the debounce sink
                    }
                }
                .listStyle(.plain)
                .frame(maxHeight: 250) // Adjust max height as needed
            }
            
            Spacer() // Pushes content to the top
        }
        .padding()
        .navigationTitle("Address Autocomplete (MapKit)")
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        Test2View()
    }
}
