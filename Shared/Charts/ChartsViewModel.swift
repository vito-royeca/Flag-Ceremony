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
    
    func fetchTopViewedCountries() {
        FirebaseManager.sharedInstance.monitorTopViewed(completion: { [weak self] countries in
            self?.topViewedCountries = countries
        })
    }
    
    func fetchTopPlayedCountries() {
        FirebaseManager.sharedInstance.monitorTopPlayed(completion: { [weak self] countries in
            self?.topPlayedCountries = countries
        })
    }
    
    func fetchTopViewers() {
        FirebaseManager.sharedInstance.monitorTopViewers(completion: { [weak self] activities in
            self?.topViewers = activities
        })
    }
    
    func fetchTopPlayers() {
        FirebaseManager.sharedInstance.monitorTopPlayers(completion: { [weak self] activities in
            self?.topPlayers = activities
        })
    }
    
    func fetchUsers() {
        FirebaseManager.sharedInstance.monitorUsers(completion: { [weak self] users in
            self?.users = users
        })
    }
}
