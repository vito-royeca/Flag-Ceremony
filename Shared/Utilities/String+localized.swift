//
//  String+localized.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 4/20/23.
//

import Foundation

extension String {
    var localized: String {
        var result = Bundle.main.localizedString(forKey: self, value: nil, table: "Localizable")

        if result == self {
            result = Bundle.main.localizedString(forKey: self, value: nil, table: nil)
        }

        return result
    }

    func localized(_ arguments: CVarArg...) -> String {
        return String(format: localized, arguments: arguments)
    }
}
