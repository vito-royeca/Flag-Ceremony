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
    @Published var favoriteCountries = [FCCountry]()
    @Published var activity: FCActivity?

    var account: User? {
        get {
            Auth.auth().currentUser
        }
    }

    func signOut() {
        do {
            muteData()
            viewedCountries.removeAll()
            playedCountries.removeAll()
            favoriteCountries.removeAll()
            activity = nil
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
    
    func fetchUserData() {
        guard account != nil else {
            return
        }

        FirebaseManager.sharedInstance.monitorUserActivity(completion: { [weak self] activity in
            self?.activity = activity

            if let views = activity?.views {
                let keys = Array(views.keys)
                FirebaseManager.sharedInstance.findCountries(keys: keys, completion: { countries in
                    self?.viewedCountries.removeAll()

                    for var country in countries {
                        if let key = country.key {
                            country.userViews = views[key] ?? 0
                            self?.viewedCountries.append(country)
                        }
                    }
                })

            }
            
            if let plays = activity?.plays {
                let keys = Array(plays.keys)
                FirebaseManager.sharedInstance.findCountries(keys: keys, completion: { countries in
                    self?.playedCountries.removeAll()

                    for var country in countries {
                        if let key = country.key {
                            country.userPlays = plays[key] ?? 0
                            self?.playedCountries.append(country)
                        }
                    }
                })

            }
            
            if let favorites = activity?.favorites {
                FirebaseManager.sharedInstance.findCountries(keys: favorites, completion: { countries in
                    self?.favoriteCountries = countries
                })
            } else {
                self?.favoriteCountries.removeAll()
            }
        })
    }
    
    func toggleFavorite(key: String) {
        FirebaseManager.sharedInstance.toggleFavorite(key) { [weak self] result in
            self?.fetchUserData()
        }
    }
    
    func muteData() {
        FirebaseManager.sharedInstance.demonitorUserActivity()
    }
}
