//
//  Constants.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 14/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import Foundation
import UIKit

let CountriesURL = "http://www.geognos.com"
let HymnsURL     = "http://www.nationalanthems.info"
let WikipediaURL = "https://en.wikipedia.org"
let FlagpediaURL = "http://flagpedia.net"

let kBlueColor   = UIColor(red: 0.23, green: 0.35, blue: 0.60, alpha: 1.0)

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

// iTunes Connect App IDs
let CineKo_AppID             = "1105292175"
let Decktracker_AppID        = "913992761"
let FlagCeremony_AppID       = "1180086391"
let FunWithTTS_AppID         = "570754434"
let WTHRM8_AppID             = "1122411144"

// Developer
let DeveloperName    = "Jovito Royeca"
let DeveloperWebsite = "http://jovitoroyeca.com"
let DeveloperTwitter = "@JovitoRoyeca"

struct ImageUtil {
    static func imageWithBorder(fromImage source: UIImage) -> UIImage? {
        let size = source.size
        UIGraphicsBeginImageContext(size)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        source.draw(in: rect, blendMode: .normal, alpha: 1.0)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            context.stroke(rect)
            let newImg =  UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImg
        }
        return nil
    }
}
