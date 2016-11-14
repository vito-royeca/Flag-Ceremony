//
//  Capital+CoreDataProperties.swift
//  
//
//  Created by Jovit Royeca on 14/11/2016.
//
//

import Foundation
import CoreData


extension Capital {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Capital> {
        return NSFetchRequest<Capital>(entityName: "Capital");
    }

    @NSManaged public var dlst: String?
    @NSManaged public var flg: Double
    @NSManaged public var geoPt: NSData?
    @NSManaged public var name: String?
    @NSManaged public var td: Double
    @NSManaged public var country: Country?

}
