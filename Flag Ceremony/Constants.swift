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
let DefaultLocationLatitude  = Float(40.5023056) // Madrid, center of the old-world
let DefaultLocationLongitude = Float(-3.6704803) // Madrid, center of the old-world
let DefaultLocationHeight    = Float(0.8)
let DefaultLocationHeading   = Float(-23.5)
let kLocationLatitude        = "kLocationLatitude"
let kLocationLongitude       = "kLocationLongitude"
let kLocationHeight          = "kLocationHeight"
let kLocationHeading         = "kLocationHeading"

enum FlagSize: String {
    case Big  = "big",
    Mini  = "mini",
    Normal = "normal",
    Ultra = "ultra"
}
