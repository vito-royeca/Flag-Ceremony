//
//  Flag_CeremonyApp.swift
//  Flag Ceremony Watch App
//
//  Created by Vito Royeca on 4/27/23.
//

import SwiftUI
import Firebase

@main
struct Flag_Ceremony_Watch_AppApp: App {
    @StateObject var mapViewModel = MapViewModel()

    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mapViewModel)
        }
    }
}
