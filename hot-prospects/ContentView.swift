//
//  ContentView.swift
//  hot-prospects
//
//  Created by Brian Diesel on 1/27/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = Set<String>()
    
    let users = ["Tohru", "Yuki", "Kyo", "Momiji"]

    var body: some View {
        List(users, id: \.self, selection: $selection) { user in
            Text(user)
        }
        
        if selection.isEmpty == false {
            Text("You selected \(selection.formatted())")
        }
        EditButton()
    }
}

#Preview {
    ContentView()
}
