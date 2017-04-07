//
//  User.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 17/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import Foundation
import Firebase

struct User {

    struct Keys {
        static let Email        = "email"
        static let PhotoURL     = "photoUrl"
        static let DisplayName  = "displayName"
        static let ProviderData = "providerData"
    }
    
    // MARK: Properties
    let key: String?
    let ref: FIRDatabaseReference?
    
    let email: String?
    let photoURL: String?
    let displayName: String?
    let providerData: [String]?
    
    // MARK: Initialization
    init(key: String, dict: [String: Any]) {
        self.key = key
        self.ref = nil
        
        self.email = dict[Keys.Email] as? String
        self.photoURL = dict[Keys.PhotoURL] as? String
        self.displayName = dict[Keys.DisplayName] as? String
        self.providerData = dict[Keys.ProviderData] as? [String]
    }
    
    init(snapshot: FIRDataSnapshot) {
        let value = snapshot.value as! [String: Any]
        self.key = snapshot.key
        self.ref = snapshot.ref
        
        self.email = value[Keys.Email] as? String
        self.photoURL = value[Keys.PhotoURL] as? String
        self.displayName = value[Keys.DisplayName] as? String
        self.providerData = value[Keys.ProviderData] as? [String]
    }
}
