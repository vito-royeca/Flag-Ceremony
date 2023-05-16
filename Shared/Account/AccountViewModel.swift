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
    
    @MainActor
    func fetchUserData() async throws {
        guard isLoggedIn else {
            return
        }
        
        Task {
            do {
                for try await user in try await FirebaseManager.sharedInstance.fetchUser() {
                    self.account = user
                }
                
                guard account != nil else {
                    return
                }

//                activity = try await FirebaseManager.sharedInstance.monitorUserActivity()
                for try await act in try await FirebaseManager.sharedInstance.monitorUserActivity() {
                    self.activity = act
                }

                if let views = activity?.views {
                    let keys = Array(views.keys)
                    let countries = try await FirebaseManager.sharedInstance.findCountries(keys: keys)
                    
                    viewedCountries.removeAll()
                    for var country in countries {
                        if let key = country.key {
                            country.userViews = views[key] ?? 0
                            viewedCountries.append(country)
                        }
                    }
                }
                
                if let plays = activity?.plays {
                    let keys = Array(plays.keys)
                    let countries = try await FirebaseManager.sharedInstance.findCountries(keys: keys)
                        
                    playedCountries.removeAll()
                    for var country in countries {
                        if let key = country.key {
                            country.userPlays = plays[key] ?? 0
                            playedCountries.append(country)
                        }
                    }
                }
                
                if let favorites = activity?.favorites {
                    favoriteCountries = try await FirebaseManager.sharedInstance.findCountries(keys: favorites)
                } else {
                    favoriteCountries.removeAll()
                }
            } catch let error {
                throw error
            }
        }
    }
    
    @MainActor
    func toggleFavorite(key: String) {
        Task {
            do {
                try await FirebaseManager.sharedInstance.toggleFavorite(key)
                try await fetchUserData()
            } catch let error {
                
            }
        }
    }
    
    @MainActor
    func update(photoURL: URL?, photoDirty: Bool, displayName: String?) {
        Task {
            do {
                try await FirebaseManager.sharedInstance.updateUser(photoURL: photoURL, photoDirty: photoDirty, displayName: displayName)
                try await fetchUserData()
            } catch let error {
                
            }
        }
    }

    func muteData() {
        FirebaseManager.sharedInstance.demonitorUserActivity()
    }
}
