//
//  AccountViewModel.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/18/23.
//

import Foundation
import SwiftUI
import Firebase

class AccountViewModel: NSObject, ObservableObject {
    @Published var viewedCountries = [FCCountry]()
    @Published var playedCountries = [FCCountry]()
    @Published var favoriteCountries = [FCCountry]()
    @Published var activity: FCActivity?
    @Published var account: FCUser?

    var isLoggedIn: Bool {
        get {
            Auth.auth().currentUser != nil
        }
    }

    func signOut() {
        do {
            muteData()
            viewedCountries.removeAll()
            playedCountries.removeAll()
            favoriteCountries.removeAll()
            activity = nil
            account = nil
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
    
    func fetchUserData() {
        guard isLoggedIn else {
            return
        }

        FirebaseManager.sharedInstance.fetchUser(completion: { [weak self] account in
            self?.account = account
        })

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
    
    func update(photoURL: URL?, photoDirty: Bool, displayName: String?) {
        FirebaseManager.sharedInstance.updateUser(photoURL: photoURL, photoDirty: photoDirty, displayName: displayName) { [weak self] _ in
            self?.fetchUserData()
        }
    }

    func muteData() {
        FirebaseManager.sharedInstance.demonitorUserActivity()
    }
}
