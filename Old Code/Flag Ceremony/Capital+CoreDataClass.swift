//
//  Capital+CoreDataClass.swift
//  
//
//  Created by Jovit Royeca on 14/11/2016.
//
//

import Foundation
import CoreData

@objc(Capital)
public class Capital: NSManagedObject {

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
