//
//  FCActivity.swift
//  Flag Ceremony
//
//  Created by Jovito Royeca on 19/12/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import Foundation

import Firebase

struct FCActivity: Identifiable, Hashable {
    struct Keys {
        static let PlayCount    = "PlayCount"
        static let Plays        = "Plays"
        static let ViewCount    = "ViewCount"
        static let Views        = "Views"
    }
    
    // MARK: - Properties

    var id: String {
        get {
            return key ?? ""
        }
    }
    let key: String?
    let ref: DatabaseReference?
    
    let playCount: Int?
    let plays: [String: Int]?
    let viewCount: Int?
    let views: [String: Int]?
    
    // MARK: - Initialization

    init(key: String, dict: [String: Any]) {
        self.key = key
        self.ref = nil
        
        self.playCount = dict[Keys.PlayCount] as? Int
        self.plays = dict[Keys.Plays] as? [String: Int]
        self.viewCount = dict[Keys.ViewCount] as? Int
        self.views = dict[Keys.Views] as? [String: Int]
    }
    
    init(snapshot: DataSnapshot) {
        let value = snapshot.value as! [String: Any]
        self.key = snapshot.key
        self.ref = snapshot.ref
        
        self.playCount = value[Keys.PlayCount] as? Int
        self.plays = value[Keys.Plays] as? [String: Int]
        self.viewCount = value[Keys.ViewCount] as? Int
        self.views = value[Keys.Views] as? [String: Int]
    }
    
    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
    
    // MARK: - Methods
    
    
}
