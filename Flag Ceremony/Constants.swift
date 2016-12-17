//
//  Constants.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 14/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import Foundation

let CountriesURL = "http://www.geognos.com"
let HymnsURL     = "http://www.nationalanthems.info"
let WikipediaURL = "https://en.wikipedia.org"
let FlagpediaURL = "http://flagpedia.net"

// Map and Globe settings
let DefaultLocationLatitude  = Float(14.35)  // Philippines
let DefaultLocationLongitude = Float(121)    // Philippines
let DefaultLocationHeight    = Float(0.8)
let DefaultLocationHeading   = Float(-180)
let DefaultCountry           = "PH"          // Philippines
let kLocationLatitude        = "kLocationLatitude"
let kLocationLongitude       = "kLocationLongitude"
let kLocationHeight          = "kLocationHeight"

enum FlagSize: String {
    case mini  = "mini",
    normal = "normal",
    big = "big",
    ultra = "ultra"
}
