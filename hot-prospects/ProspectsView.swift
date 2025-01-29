//
//  ProspectsView.swift
//  hot-prospects
//
//  Created by Brian Diesel on 1/29/25.
//

import CodeScanner
import SwiftData
import SwiftUI

struct ProspectsView: View {
    enum FilterType {
        case none, contacted, uncontacted
    }

    @Environment(\.modelContext) var modelContext
    @Query(sort: \Prospect.name) var prospects: [Prospect]
    @State private var isShowingScanner = false
    @State private var selectedProspects = Set<Prospect>()
    
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
            List(prospects, selection: $selectedProspects) { prospect in
                VStack(alignment: .leading) {
                    Text(prospect.name)
                        .font(.headline)
                    Text(prospect.emailAddress)
                        .foregroundStyle(.secondary)
                }.swipeActions {
                    Button("Delete", systemImage: "trash", role: .destructive){
                        modelContext.delete(prospect)
                    }

                    if prospect.isContacted{
                        Button("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark") {
                                   prospect.isContacted.toggle()
                               }
                               .tint(.blue)
                    } else {
                        Button("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark") {
                            prospect.isContacted.toggle()
                        }
                        .tint(.green)
                    }
                }
                .tag(prospect)
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button("Scan", systemImage: "qrcode.viewfinder") {
                        isShowingScanner = true
                    }
                }
                ToolbarItem(placement: .topBarLeading){
                    EditButton()
                }
                
                if !selectedProspects.isEmpty {
                    ToolbarItem(placement: .bottomBar){
                        Button("Delete Selected", action: delete)
                    }
                }
            }
            .sheet(isPresented: $isShowingScanner){
                CodeScannerView(
                    codeTypes: [.qr],
                    simulatedData: "Brian Diesel\nbrian@designcondition.com",
                    completion: handleScanResult
                )
            }
        }
    }
    
    func delete(){
        for prospect in selectedProspects {
            modelContext.delete(prospect)
        }
    }
    
    func handleScanResult(result: Result<ScanResult, ScanError>) {
       isShowingScanner = false
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }

            let person = Prospect(name: details[0], emailAddress: details[1], isContacted: false)

            modelContext.insert(person)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ProspectsView(filter: .none)
        .modelContainer(for: Prospect.self)
}
