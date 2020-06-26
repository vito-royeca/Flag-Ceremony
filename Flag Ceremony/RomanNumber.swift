//
//  RomanNumber.swift
//  Flag Ceremony
//
//  Created by Jovito Royeca on 26/04/2017.
//  Copyright © 2017 Jovit Royeca. All rights reserved.
//

import UIKit

extension NSNumber {
    /*
     * Create a random number between 1 and 10000
     */
    class func randomNumber() -> NSNumber {
        let max = UInt32(500)
        let random = Int(arc4random_uniform(max) + 1)
        return NSNumber(value: random)
    }
    
    func toRomanNumeral() -> String {
        var integerValue = self.intValue
        var numeralString = ""
        let mappingList: [(Int, String)] = [(1000, "M"),
                                            (900,  "CM"),
                                            (500,  "D"),
                                            (400,  "CD"),
                                            (100,  "C"),
                                            (90,   "XC"),
                                            (50,   "L"),
                                            (40,   "XL"),
                                            (10,   "X"),
                                            (9,    "IX"),
                                            (5,    "V"),
                                            (4,    "IV"),
                                            (1,    "I")]
        
        for i in mappingList where (integerValue >= i.0) {
            while (integerValue >= i.0) {
                integerValue -= i.0
                numeralString += i.1
            }
        }
        return numeralString
    }
}
