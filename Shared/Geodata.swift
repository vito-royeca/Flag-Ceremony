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
    
    @Published var location = MaplyCoordinateMakeWithDegrees(-3.6704, 40.5023)
    @Published var height = Float(0.8)
}
