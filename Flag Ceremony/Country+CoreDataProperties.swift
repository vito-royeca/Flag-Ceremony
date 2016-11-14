//
//  Country+CoreDataProperties.swift
//  
//
//  Created by Jovit Royeca on 14/11/2016.
//
//

import Foundation
import CoreData


extension Country {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Country> {
        return NSFetchRequest<Country>(entityName: "Country");
    }

    @NSManaged public var countryInfo: String?
    @NSManaged public var geoPt: NSData?
    @NSManaged public var name: String?
    @NSManaged public var seqId: String?
    @NSManaged public var telPref: String?
    @NSManaged public var capital: Capital?
    @NSManaged public var countryCode: CountryCode?
    @NSManaged public var geoRectangle: GeoRectangle?

}
