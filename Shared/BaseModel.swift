//
//  BaseModel.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 5/4/23.
//

import Foundation

enum BaseModelStatus {
    case idle, busy, error(Error)
}

class BaseModel: NSObject, ObservableObject {
    var status: BaseModelStatus = .idle
    
    func run(task: Any) {
        
    }
}
