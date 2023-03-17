//
//  CountryViewModel.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/16/23.
//

import Foundation

class CountryViewModel: NSObject, ObservableObject {
    // MARK: - Variables
    
    @Published var country: FCCountry?
    @Published var anthem: FCAnthem?
    @Published var isBusy = false
    @Published var isFailed = false
    
    var id: String
    
    // MARK: - Initializers
    
    init(id: String) {
        self.id = id
    }
    
    // MARK: - Methods
    
    func fetchData() {
        guard !isBusy else {
            return
        }

        isBusy.toggle()
        isFailed = false

        FirebaseManager.sharedInstance.findCountry(id) { [weak self] country in
            self?.country = country
            
            guard let id = self?.id else {
                return
            }

            FirebaseManager.sharedInstance.findAnthem(id) { [weak self] anthem in
                self?.isBusy.toggle()
                self?.anthem = anthem
            }
        }
    }
}
