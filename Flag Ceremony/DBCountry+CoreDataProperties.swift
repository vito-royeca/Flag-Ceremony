//
//  DBCountry+CoreDataProperties.swift
//  Flag Ceremony
//
//  Created by Jovito Royeca on 25/03/2018.
//  Copyright © 2018 Jovit Royeca. All rights reserved.
//
//

import Foundation
import CoreData


extension DBCountry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBCountry> {
        return NSFetchRequest<DBCountry>(entityName: "DBCountry")
    }

    @NSManaged public var capital: String?
    @NSManaged public var capitalGeoX: Double
    @NSManaged public var capitalGeoY: Double
    @NSManaged public var countryCode: String?
    @NSManaged public var geoX: Double
    @NSManaged public var geoY: Double
    @NSManaged public var hasAnthemFile: Bool
    @NSManaged public var name: String?
    @NSManaged public var anthems: NSSet?

}

// MARK: Generated accessors for anthems
extension DBCountry {

    @objc(addAnthemsObject:)
    @NSManaged public func addToAnthems(_ value: DBAnthem)

    @objc(removeAnthemsObject:)
    @NSManaged public func removeFromAnthems(_ value: DBAnthem)

    @objc(addAnthems:)
    @NSManaged public func addToAnthems(_ values: NSSet)

    @objc(removeAnthems:)
    @NSManaged public func removeFromAnthems(_ values: NSSet)

}
