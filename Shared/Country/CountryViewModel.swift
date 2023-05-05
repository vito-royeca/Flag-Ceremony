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
    @Published var error: Error?
    
    var id: String
    
    // MARK: - Initializers
    
    init(id: String) {
        self.id = id
    }
    
    // MARK: - Methods
    
    @MainActor
    func fetchData() async  {
        guard !isBusy else {
            return
        }

        isBusy.toggle()
        error = nil

        let id = id
        Task {
            do {
                country = try await FirebaseManager.sharedInstance.findCountry(id)
                anthem = try await FirebaseManager.sharedInstance.findAnthem(id)
                isBusy.toggle()
            } catch let error {
                self.error = error
            }
        }
    }
    
    @MainActor
    func incrementViews() async {
        Task {
            do {
                country = try await FirebaseManager.sharedInstance.incrementCountryViews(id)
            } catch let error {
                self.error = error
            }
        }
    }
    
    @MainActor
    func incrementPlays() async {
        Task {
            do {
                country = try await FirebaseManager.sharedInstance.incrementCountryPlays(id)
            } catch let error {
                self.error = error
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
