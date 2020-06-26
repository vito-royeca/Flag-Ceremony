//
//  FirebaseTests.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 17/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import XCTest
import Firebase
import Networking

class FirebaseTests: XCTestCase {
    var ref: FIRDatabaseReference?
    var finished = false
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        ref = FIRDatabase.database().reference()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testInsert() {
        let baseURL = CountriesURL
        let path = "/info/all.json"
        let method:HTTPMethod = .Get
        let headers:[String: String]? = nil
        let paramType:Networking.ParameterType = .json
        let params = "?x=100" as AnyObject
        let completionHandler = { (result: [[String : Any]], error: NSError?) -> Void in
            if let error = error {
                print("error: \(error)")
            } else {
                if let data = result.first {
                    if let countries = data["Results"] as? [String: [String: Any]] {
                        for (key,value) in countries {
                            let country = self.ref!.child("countries").child(key)
                            
                            for (key2,value2) in value {
                                country.child(key2).setValue(value2)
                            }
                        }
                        
                        Thread.sleep(forTimeInterval: 60) // sleep for 180 sec
                        let insertedCountries = self.ref!.child("countries").queryLimited(toFirst: 10)
                        XCTAssertNotNil(insertedCountries)
                        self.finished = true
                    }
                }
            }
        }
        
        NetworkingManager.sharedInstance.doOperation(baseURL,
                                                     path: path,
                                                     method: method,
                                                     headers: headers,
                                                     paramType: paramType,
                                                     params: params,
                                                     completionHandler: completionHandler)
        
        repeat {
            RunLoop.current.run(mode: .defaultRunLoopMode, before:Date.distantFuture)
        } while !finished
    }

}
