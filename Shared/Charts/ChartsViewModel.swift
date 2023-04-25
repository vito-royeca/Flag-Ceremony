//
//  ChartsViewModel.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/18/23.
//

import Foundation

class ChartsViewModel: NSObject, ObservableObject {
    
    // MARK: - Variables
    
    @Published var topViewedCountries = [FCCountry]()
    @Published var topPlayedCountries = [FCCountry]()
    @Published var topViewers = [FCActivity]()
    @Published var topPlayers = [FCActivity]()
    @Published var users = [FCUser]()
    
    @MainActor
    func fetchTopViewedCountries() {
        Task {
            topViewedCountries = await FirebaseManager.sharedInstance.monitorTopViewed()
        }
    }
    
    @MainActor
    func fetchTopPlayedCountries() {
        Task {
            topPlayedCountries = await FirebaseManager.sharedInstance.monitorTopPlayed()
        }
    }
    
    @MainActor
    func fetchTopViewers() {
        Task {
            topViewers = await FirebaseManager.sharedInstance.monitorTopViewers()
        }
    }
    
    @MainActor
    func fetchTopPlayers() {
        Task {
            topPlayers = await FirebaseManager.sharedInstance.monitorTopPlayers()
        }
    }
    
    @MainActor
    func fetchUsers() {
        Task {
            users = await FirebaseManager.sharedInstance.monitorUsers()
        }
    }
    
    func muteData() {
        FirebaseManager.sharedInstance.demonitorTopCharts()
    }
}
