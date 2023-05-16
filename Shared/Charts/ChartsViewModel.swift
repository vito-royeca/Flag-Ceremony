//
//  ChartsViewModel.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/18/23.
//

import Foundation
import Firebase
import Combine

class ChartsViewModel: NSObject, ObservableObject {
    
    // MARK: - Variables
    
    @Published var topViewedCountries = [FCCountry]()
    @Published var topPlayedCountries = [FCCountry]()
    @Published var topViewers = [FCActivity]()
    @Published var topPlayers = [FCActivity]()
    @Published var users = [FCUser]()
    
//    private var cancelables = Set<AnyCancellable>()
//    private let db: DatabaseReference
//
//    public override init() {
//        db = Database.database().reference()
//    }
    
    @MainActor
    func fetchTopViewedCountries() {
        Task {
            topViewedCountries = await FirebaseManager.sharedInstance.monitorTopViewed()
        }
        
//        let ref = Database.database().reference()
//        db.child("countries").queryOrdered(byChild: FCCountry.Keys.Views).queryStarting(atValue: 1).queryLimited(toLast: 20)
//            .toAnyPublisher()
//            .sink { [weak self] (snapshot: DataSnapshot?) in
//                if let snapshot, let self {
//                    self.topViewedCountries = snapshot.children.compactMap({ FCCountry(snapshot: $0 as! DataSnapshot)})
//                }
//            }
//            .store(in: &cancelables)
        
        // CombineFirebase
//        ref.child("countries").queryOrdered(byChild: FCCountry.Keys.Views).queryStarting(atValue: 1).queryLimited(toLast: 20)
//            .observeSingleEvent(.value)
//            .receive(on: RunLoop.main)
//            .sink { snapshot in
//                print("Value:\(snapshot.value)")
//            }.store(in: &cancelables)
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
