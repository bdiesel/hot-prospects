//
//  hot_prospectsApp.swift
//  hot-prospects
//
//  Created by Brian Diesel on 1/27/25.
//

import SwiftData
import SwiftUI

@main
struct hot_prospectsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Prospect.self)
    }
}
