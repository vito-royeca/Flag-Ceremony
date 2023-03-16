//
//  Geodata.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/15/23.
//

import Foundation
import WhirlyGlobe

class Geodata: ObservableObject {
    var mbTilesFetcher = MaplyMBTileFetcher(mbTiles: "geography-class_medres")

    @Published var location = MaplyCoordinateMakeWithDegrees(DefaultLocationLongitude, DefaultLocationLatitude)
    @Published var height = Float(0.8)
    @Published var countries = [FCCountry]()
    
    func fetchAllCountries() {
        if countries.isEmpty {
            FirebaseManager.sharedInstance.fetchAllCountries(completion: { [weak self] (countries: [FCCountry]) in
                self?.countries = countries
            })
        }
    }
}
