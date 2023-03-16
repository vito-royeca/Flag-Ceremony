//
//  DatabaseManager.swift
//  Flag Ceremony
//
//  Created by Jovito Royeca on 16/03/2018.
//  Copyright © 2018 Jovit Royeca. All rights reserved.
//

import UIKit
import DATAStack
import Sync

class DatabaseManager: NSObject {
    
    let dataStack = DataStack(modelName: "Flag Ceremony")
    
    // MARK: - Shared Instance
    static let sharedInstance = DatabaseManager()
}
