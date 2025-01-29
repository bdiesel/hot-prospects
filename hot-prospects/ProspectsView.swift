//
//  ProspectsView.swift
//  hot-prospects
//
//  Created by Brian Diesel on 1/29/25.
//

import SwiftData
import SwiftUI

struct ProspectsView: View {
    enum FilterType {
        case none, contacted, uncontacted
    }

    @Environment(\.modelContext) var modelContext
    @Query(sort: \Prospect.name) var prospects: [Prospect]

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

    init(filter: FilterType) {
        self.filter = filter

        if filter != .none {
            let showContactedOnly = filter == .contacted

            _prospects = Query(filter: #Predicate {
                $0.isContacted == showContactedOnly
            }, sort: [SortDescriptor(\Prospect.name)])
        }
    }
    
    var body: some View {
        NavigationStack {
            List(prospects) { prospect in
                VStack(alignment: .leading) {
                    Text(prospect.name)
                        .font(.headline)
                    Text(prospect.emailAddress)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(title)
            .toolbar {
                Button("Scan", systemImage: "qrcode.viewfinder") {
                                let prospect = Prospect(
                                    name: "Brian Diesel",
                                    emailAddress: "brian@designcondition.com",
                                    isContacted: false)
                        modelContext.insert(prospect)
                    }
            }
        }
    }
    
}

#Preview {
    ProspectsView(filter: .none)
        .modelContainer(for: Prospect.self)
}
