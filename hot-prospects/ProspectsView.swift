//
//  ProspectsView.swift
//  hot-prospects
//
//  Created by Brian Diesel on 1/29/25.
//

import CodeScanner
import SwiftData
import SwiftUI
import UserNotifications

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
                        
                        Button("Remind Me", systemImage: "bell"){
                            addNotification(for: prospect)
                        }
                        .tint(.orange)
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
    func addNotification(for prospect: Prospect){
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)


            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    if granted {
                        addRequest()
                    } else if let error {
                        print(error.localizedDescription)
                    }
                }
            }
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
