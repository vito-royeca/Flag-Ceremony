//
//  GeoRectangle+CoreDataProperties.swift
//  
//
//  Created by Jovit Royeca on 14/11/2016.
//
//

import Foundation
import CoreData


extension GeoRectangle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GeoRectangle> {
        return NSFetchRequest<GeoRectangle>(entityName: "GeoRectangle");
    }

    @NSManaged public var east: Double
    @NSManaged public var north: Double
    @NSManaged public var south: Double
    @NSManaged public var west: Double
    @NSManaged public var country: Country?

}
