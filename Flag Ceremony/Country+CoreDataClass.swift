//
//  Country+CoreDataClass.swift
//  
//
//  Created by Jovit Royeca on 14/11/2016.
//
//

import Foundation
import CoreData

@objc(Country)
public class Country: NSManagedObject {

    func getGeoRectangle() -> [String: Double]? {
        if let geoRectangle = geoRectangle {
            return NSKeyedUnarchiver.unarchiveObject(with: geoRectangle as Data) as? [String: Double]
        }
        return nil
    }
    
    func getCountryCodes() -> [String: Any]? {
        if let countryCodes = countryCodes {
            return NSKeyedUnarchiver.unarchiveObject(with: countryCodes as Data) as? [String: Any]
        }
        return nil
    }
    
    func getGeoPt() -> [Float]? {
        if let geoPt = geoPt {
            return NSKeyedUnarchiver.unarchiveObject(with: geoPt as Data) as? [Float]
        }
        return nil
    }
    
    func getGeoRadians() -> [Float]? {
        if let geoRadians = geoRadians {
            return NSKeyedUnarchiver.unarchiveObject(with: geoRadians as Data) as? [Float]
        }
        return nil
    }
}
