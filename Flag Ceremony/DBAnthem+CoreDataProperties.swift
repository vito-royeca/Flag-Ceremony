//
//  DBAnthem+CoreDataProperties.swift
//  Flag Ceremony
//
//  Created by Jovito Royeca on 25/03/2018.
//  Copyright © 2018 Jovit Royeca. All rights reserved.
//
//

import Foundation
import CoreData


extension DBAnthem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBAnthem> {
        return NSFetchRequest<DBAnthem>(entityName: "DBAnthem")
    }

    @NSManaged public var background: String?
    @NSManaged public var dateAdopted: NSData?
    @NSManaged public var flagInfo: String?
    @NSManaged public var info: String?
    @NSManaged public var lyricsWriter: NSData?
    @NSManaged public var musicWriter: NSData?
    @NSManaged public var titles: NSData?
    @NSManaged public var wiki: String?
    @NSManaged public var country: DBCountry?
    @NSManaged public var lyrics: NSSet?

}

// MARK: Generated accessors for lyrics
extension DBAnthem {

    @objc(addLyricsObject:)
    @NSManaged public func addToLyrics(_ value: DBLyrics)

    @objc(removeLyricsObject:)
    @NSManaged public func removeFromLyrics(_ value: DBLyrics)

    @objc(addLyrics:)
    @NSManaged public func addToLyrics(_ values: NSSet)

    @objc(removeLyrics:)
    @NSManaged public func removeFromLyrics(_ values: NSSet)

}
