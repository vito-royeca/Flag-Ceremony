//
//  Bool+OSVersion.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/20/23.
//

import Foundation

extension Bool {
    static var iOS13: Bool {
        guard #available(iOS 14, *) else {
            // It's iOS 13 so return true.
            return true
        }
        // It's iOS 14 so return false.
        return false
    }
    
    static var iOS14: Bool {
        guard #available(iOS 15, *) else {
            // It's iOS 14 so return true.
            return true
        }
        // It's iOS 15 so return false.
        return false
    }
    
    static var iOS15: Bool {
        guard #available(iOS 16, *) else {
            // It's iOS 15 so return true.
            return true
        }
        // It's iOS 16 so return false.
        return false
    }
    
    static var iOS16: Bool {
        guard #available(iOS 17, *) else {
            // It's iOS 16 so return true.
            return true
        }
        // It's iOS 17 so return false.
        return false
    }
}
