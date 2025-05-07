//
//  WelcomePager.swift
//  Quick Route
//
//  Created by Nicholas Runje on 5/6/25.
//

import SwiftUI

struct WelcomePager: View {
    let done: () -> Void
    @State private var page = 0
    private let pages = [
        ("map.fill",  "Welcome to Quick Route"),
        ("bolt.fill", "Find the quickest way to your destination, all in seconds"),
        ("gearshape", "Tap Go and drive")
    ]

    var body: some View {
        VStack {
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { i in
                    VStack(spacing: 24) {
                        Image(systemName: pages[i].0)
                            .font(.system(size: 60))
                        Text(pages[i].1)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                    }
                    .tag(i)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                }
            }
            .tabViewStyle(.page)

            Button(page == pages.count - 1 ? "Get Started" : "Next") {
                if page < pages.count - 1 {
                    withAnimation { page += 1 }
                } else {
                    done()
                }
            }
            .padding()
        }
    }
}

#Preview {
    WelcomePager {
        
    }
}
