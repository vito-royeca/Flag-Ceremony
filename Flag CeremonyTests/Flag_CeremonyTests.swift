//
//  Flag_CeremonyTests.swift
//  Flag CeremonyTests
//
//  Created by Jovit Royeca on 14/09/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import XCTest
import DATAStack
import DATASource
import Networking
@testable import Flag_Ceremony

class Flag_CeremonyTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
    
    func testDownloadCountries() {
        API.sharedInstance.fetchCountries(completion: {(error: NSError?) in
            if let error = error {
                print("error: \(error)")
            } else {
                var countries:[Country]?
                let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Country")
                request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
                
                do {
                    try countries = API.sharedInstance.dataStack.mainContext.fetch(request) as? [Country]
                    
                    for country in countries! {
                        if let countryCodes = country.getCountryCodes() {
                            
                            for (_,value) in countryCodes {
                                if let value = value as? String {
                                    if let url = URL(string: "\(HymnsURL)/\(value).mp3") {
                                        let docsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                                        let localPath = "\(docsPath)/\(value).mp3"
                                        
                                        if !FileManager.default.fileExists(atPath: localPath) && flagFound {
                                            let existsHandler = { (fileExistsAtServer: Bool) -> Void in
                                                if fileExistsAtServer {
                                                    print ("downloading... \(country.name!)")
                                                    let completionHandler = { (data: Data?, error: NSError?) -> Void in
                                                        if let error = error {
                                                            print("error: \(error)")
                                                        } else {
                                                            do {
                                                                try data!.write(to: URL(fileURLWithPath: localPath))
                                                                print("saved: \(localPath)")
                                                            } catch {
                                                                
                                                            }
                                                        }
                                                    }
                                                    NetworkingManager.sharedInstance.downloadFile(url: url, completionHandler: completionHandler)
                                                }
                                            }
                                            NetworkingManager.sharedInstance.fileExistsAt(url: url, completion: existsHandler);
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    
                }
            }
        })
    }
    
    func downloadFile() {
        
    }
    
    func testDownloadAnthems() {
        /*
        {"BD":
            {
                "Name": "Bangladesh",
                "Capital":
                {
                    "DLST": "null",
                    "TD": 6.0,
                    "Flg": 2,
                    "Name": "Dhaka",
                    "GeoPt": [23.43, 90.24]
                },
                "GeoRectangle":
                {
                    "West": 88.0283279419,
                    "East": 92.6736831665,
                    "North": 26.6319484711,
                    "South": 20.7433319092
                },
                "SeqID": 19,
                "GeoPt": [24.0, 90.0],
                "TelPref": "880",
                "CountryCodes":
                {
                    "tld": "bd",
                    "iso3": "BGD",
                    "iso2": "BD",
                    "fips": "BG",
                    "isoN": 50
                },
                "CountryInfo": "http://www.geognos.com/geo/en/cc/bd.html"
            }
        }*/
    }
}
