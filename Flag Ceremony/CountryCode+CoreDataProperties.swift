//
//  CountryCode+CoreDataProperties.swift
//  
//
//  Created by Jovit Royeca on 14/11/2016.
//
//

import Foundation
import CoreData


extension CountryCode {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CountryCode> {
        return NSFetchRequest<CountryCode>(entityName: "CountryCode");
    }

    @NSManaged public var fips: String?
    @NSManaged public var iso2: String?
    @NSManaged public var iso3: String?
    @NSManaged public var isoN: String?
    @NSManaged public var tld: String?
    @NSManaged public var country: Country?

}
