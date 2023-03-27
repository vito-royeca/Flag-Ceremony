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
    
    func fetchData(completion: @escaping () -> Void) {
        guard !isBusy else {
            return
        }

        let id = id
        isBusy.toggle()
        isFailed = false

        FirebaseManager.sharedInstance.findCountry(id) { [weak self] country in
            FirebaseManager.sharedInstance.findAnthem(id) { [weak self] anthem in
                self?.country = country
                self?.anthem = anthem
                self?.isBusy.toggle()
                completion()
            }
        }
    }
    
    func incrementViews() {
        FirebaseManager.sharedInstance.incrementCountryViews(id) { [weak self] result in
            switch result {
            case .success(let country):
//                self?.country?.views = country?.views
//                self?.country?.plays = country?.plays
                self?.country = country
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func incrementPlays() {
        FirebaseManager.sharedInstance.incrementCountryPlays(id) { [weak self] result in
            switch result {
            case .success(let country):
//                self?.country?.views = country?.views
//                self?.country?.plays = country?.plays
                self?.country = country
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func formatLong(text: String) -> String {
        var newText = String(text)
        var period = 0
        var newLines = 0

        for (index, c) in newText.enumerated() {
            if c == "." {
                period += 1
                
                if period == 2 {
                    period = 0
                    let mark = index+newLines+1
                    if newText[mark] == " " {
                        let start = newText.index(newText.startIndex, offsetBy: mark)
                        let end = newText.index(newText.startIndex, offsetBy: mark)
                        newText.replaceSubrange(start...end, with: "\n\n")
                        newLines += 1
                    }
                }
            }
        }
        
        return newText
    }
}
