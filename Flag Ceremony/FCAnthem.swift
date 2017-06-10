//
//  Anthem.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 23/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import Foundation
import Firebase

struct Anthem {
    struct Keys {
        static let Wiki         = "wiki"
        static let NativeTitle  = "nativeTitle"
        static let Title        = "title"
        static let DateAdopted  = "dateAdopted"
        static let LyricsWriter = "lyricsWriter"
        static let MusicWriter  = "musicWriter"
        static let Lyrics       = "lyrics"
        static let LyricsName   = "name"
        static let LyricsText   = "text"
        static let Info         = "info"
        static let FlagInfo     = "flagInfo"
        static let Background   = "background"
    }
    
    // MARK: Properties
    let key: String?
    let ref: DatabaseReference?
    
    let wiki: String?
    let nativeTitle: String?
    let title: String?
    let dateAdopted: [String]?
    let lyricsWriter: [String]?
    let musicWriter: [String]?
    let lyrics: [[String: Any]]?
    let info: String?
    let flagInfo: String?
    let background: String?
    
    // MARK: Initialization
    init(key: String, dict: [String: Any]) {
        self.key = key
        self.ref = nil
        
        self.wiki = dict[Keys.Wiki] as? String
        self.nativeTitle = dict[Keys.NativeTitle] as? String
        self.title = dict[Keys.Title] as? String
        self.dateAdopted = dict[Keys.DateAdopted] as? [String]
        self.lyricsWriter = dict[Keys.LyricsWriter] as? [String]
        self.musicWriter = dict[Keys.MusicWriter] as? [String]
        self.lyrics = dict[Keys.Lyrics] as? [[String: Any]]
        self.info = dict[Keys.Info] as? String
        self.flagInfo = dict[Keys.FlagInfo] as? String
        self.background = dict[Keys.Background] as? String
    }
    
    init(snapshot: DataSnapshot) {
        let value = snapshot.value as! [String: Any]
        self.key = snapshot.key
        self.ref = snapshot.ref
        
        self.wiki = value[Keys.Wiki] as? String
        self.nativeTitle = value[Keys.NativeTitle] as? String
        self.title = value[Keys.Title] as? String
        self.dateAdopted = value[Keys.DateAdopted] as? [String]
        self.lyricsWriter = value[Keys.LyricsWriter] as? [String]
        self.musicWriter = value[Keys.MusicWriter] as? [String]
        self.lyrics = value[Keys.Lyrics] as? [[String: Any]]
        self.info = value[Keys.Info] as? String
        self.flagInfo = value[Keys.FlagInfo] as? String
        self.background = value[Keys.Background] as? String
    }
}
