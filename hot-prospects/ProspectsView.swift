//
//  ProspectsView.swift
//  hot-prospects
//
//  Created by Brian Diesel on 1/29/25.
//

import SwiftUI

struct ProspectsView: View {
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    let filter: FilterType
    
    
    var title: String {
        switch filter {
        case .none:
            return "All Prospects"
        case .contacted:
            return "Contacted Prospects"
        case .uncontacted:
            return "Uncontacted Prospects"
        }
    }
    
    
    var body: some View {
        NavigationStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .navigationTitle(title)
        }
        
    }
}

#Preview {
    ProspectsView(filter: .none)
}
