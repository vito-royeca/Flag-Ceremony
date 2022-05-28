//
//  Flag_CeremonyApp.swift
//  Shared
//
//  Created by Vito Royeca on 5/28/22.
//

import SwiftUI

@main
struct Flag_CeremonyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
