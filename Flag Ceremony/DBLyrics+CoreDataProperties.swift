//
//  DBLyrics+CoreDataProperties.swift
//  Flag Ceremony
//
//  Created by Jovito Royeca on 25/03/2018.
//  Copyright © 2018 Jovit Royeca. All rights reserved.
//
//

import Foundation
import CoreData


extension DBLyrics {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBLyrics> {
        return NSFetchRequest<DBLyrics>(entityName: "DBLyrics")
    }

    @NSManaged public var name: String?
    @NSManaged public var text: String?
    @NSManaged public var anthem: DBAnthem?

}
