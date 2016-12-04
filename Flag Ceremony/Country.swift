//
//  Country.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 17/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import Foundation
import Firebase

struct Country {
    struct Keys {
        static let Name              = "Name"
        static let Capital           = "Capital"
        static let CapitalDLST       = "DLST"
        static let CapitalTD         = "TD"
        static let CapitalFlg        = "Flg"
        static let CapitalName       = "Name"
        static let CapitalGeoPt      = "GeoPt"
        static let GeoRectangle      = "GeoRactangle"
        static let GeoRectangleWest  = "West"
        static let GeoRectangleEast  = "East"
        static let GeoRectangleNorth = "North"
        static let GeoRectangleSouth = "South"
        static let SeqID             = "SeqID"
        static let GeoPt             = "GeoPt"
        static let TelPref           = "TelPref"
        static let CountryCodes      = "CountryCodes"
        static let CountryCodesTld   = "tld"
        static let CountryCodesIso3  = "iso3"
        static let CountryCodesIso2  = "iso2"
        static let CountryCodesFips  = "fips"
        static let CountryCodesIsoN  = "isoN"
        static let CountryInfo       = "CountryInfo"
        static let Views             = "Views"
        static let Plays             = "Plays"
        static let HasAnthemFile     = "HasAnthemFile"
    }

    // MARK: Properties
    let key: String?
    let ref: FIRDatabaseReference?
    
    let name: String?
    let capital: [String: Any]?
    let geoRectangle: [String: Any]?
    let seqId: Int?
    let geoPt: [Float]?
    let telPref: String?
    let countryCodes: [String: Any]?
    let countryInfo: String?
    let views: Int?
    let plays: Int?
    let hasAnthemFile: Int?
    
    // MARK: Initialization
    init(key: String, dict: [String: Any]) {
        self.key = key
        self.ref = nil
        
        self.name = dict[Keys.Name] as? String
        self.capital = dict[Keys.Capital] as? [String: Any]
        self.geoRectangle = dict[Keys.GeoRectangle] as? [String: Any]
        self.seqId = dict[Keys.SeqID] as? Int
        self.geoPt = dict[Keys.GeoPt] as? [Float]
        self.telPref = dict[Keys.TelPref] as? String
        self.countryCodes = dict[Keys.CountryCodes] as? [String: Any]
        self.countryInfo = dict[Keys.CountryInfo] as? String
        self.plays = dict[Keys.Plays] as? Int
        self.views = dict[Keys.Views] as? Int
        self.hasAnthemFile = dict[Keys.HasAnthemFile] as? Int
    }
    
    init(snapshot: FIRDataSnapshot) {
        let value = snapshot.value as! [String: Any]
        self.key = snapshot.key
        self.ref = snapshot.ref
        
        self.name = value[Keys.Name] as? String
        self.capital = value[Keys.Capital] as? [String: Any]
        self.geoRectangle = value[Keys.GeoRectangle] as? [String: Any]
        self.seqId = value[Keys.SeqID] as? Int
        self.geoPt = value[Keys.GeoPt] as? [Float]
        self.telPref = value[Keys.TelPref] as? String
        self.countryCodes = value[Keys.CountryCodes] as? [String: Any]
        self.countryInfo = value[Keys.CountryInfo] as? String
        self.plays = value[Keys.Plays] as? Int
        self.views = value[Keys.Views] as? Int
        self.hasAnthemFile = value[Keys.HasAnthemFile] as? Int
    }
    
    // MARK: Custom methods
//    func toAnyObject() -> [String: Any] {
//        return [
//            Keys.Name: name,
//            Keys.Capital: capital,
//            Keys.GeoRectangle: geoRectangle,
//            Keys.SeqID: seqId,
//            Keys.GeoPt: geoPt,
//            Keys.TelPref: telPref,
//            Keys.CountryCodes: countryCodes,
//            Keys.CountryInfo: countryInfo
//            Keys.Plays: plays
//            Keys.Views: views
//            Keys.HasAnthemFile: hasAnthemFile    
//        ]
//    }
    
    func getFlagURLForSize(size: FlagSize) -> URL? {
        if let path = Bundle.main.path(forResource: key!.lowercased(), ofType: "png", inDirectory: "data/flags/\(size.rawValue)") {
            if FileManager.default.fileExists(atPath: path) {
                return URL(fileURLWithPath: path)
            }
        }
        
        return nil
    }
    
    func getAudioURL() -> URL? {
        if let path = Bundle.main.path(forResource: key!.lowercased(), ofType: "mp3", inDirectory: "data/anthems") {
            if FileManager.default.fileExists(atPath: path) {
                return URL(fileURLWithPath: path)
            }
        }
        
        return nil
    }
    
    /* 
     * Convert lat/long to radians
     * Radians = Degrees * PI / 180
     * Degrees = Radians * 180 / PI
     */
    func getGeoRadians() -> [Float] {
        return [(geoPt![1] * Float.pi)/180, (geoPt![0] * Float.pi)/180]
    }
    
    func getCapitalGeoRadians() -> [Float] {
        if let capital = capital {
            if let capitalGeoPt = capital[Keys.CapitalGeoPt] as? [Float] {
                return [(capitalGeoPt[1] * Float.pi)/180, (capitalGeoPt[0] * Float.pi)/180]
            }
        }
        
        return [0.0, 0.0]
    }
    
    func emojiFlag() -> String {
        var string = ""
        
        if let countryCodes = countryCodes {
            if let iso2 = countryCodes[Keys.CountryCodesIso2] as? String {
                var country = iso2.uppercased()
                for uS in country.unicodeScalars {
                    string += String(UnicodeScalar(127397 + uS.value)!)
                }
            }
        }
        
        return string
    }

}
