//
//  Capital.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 17/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import Foundation

struct Capital {
//    "Capital":
//    {
//    "DLST": "null",
//    "TD": 6.0,
//    "Flg": 2,
//    "Name": "Dhaka",
//    "GeoPt": [23.43, 90.24]
//    },
    
    let dlst: String
    let flg: Double
    let geoPt: [Float]
    let name: String
    let td: Double
    
    /*
     * Convert lat/long to radians
     * Radians = Degrees * PI / 180
     * Degrees = Radians * 180 / PI
     */
    func getGeoRadians() -> [Float] {
        return [(geoPt[1] * Float.pi)/180, (geoPt[0] * Float.pi)/180]
    }
}
