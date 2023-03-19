//
//  AccountViewModel.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/18/23.
//

import Foundation
import Firebase

class AccountViewModel: NSObject, ObservableObject {
    @Published var viewedCountries = [FCCountry]()
    @Published var playedCountries = [FCCountry]()
    
    var isLoggedIn: Bool {
        get {
            Auth.auth().currentUser != nil
        }
    }

    func fetchViewedCountries() {
        FirebaseManager.sharedInstance.monitorTopViewed(completion: { [weak self] countries in
            self?.viewedCountries = countries
        })
    }
    
    func fetchPlayedCountries() {
        FirebaseManager.sharedInstance.monitorTopPlayed(completion: { [weak self] countries in
            self?.playedCountries = countries
        })
    }
    
    func muteData() {
        FirebaseManager.sharedInstance.demonitorUserData()
    }
}
