//
//  Flag_CeremonyUITests.swift
//  Flag CeremonyUITests
//
//  Created by Jovit Royeca on 14/09/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import XCTest

class Flag_CeremonyUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testScreenshots() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        snapshot("02Anthem")
        if UIDevice.current.userInterfaceIdiom == .phone {
            app.navigationBars["Flag_Ceremony.CountryView"].children(matching: .button).matching(identifier: "Back").element(boundBy: 0).tap()
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            app.navigationBars.matching(identifier: "Flag_Ceremony.CountryView").buttons["close window"].tap()
        }
        snapshot("01MapScreen")
        
        let mapButton = tabBarsQuery.buttons["Map"]
        let globeButton = tabBarsQuery.buttons["Globe"]
        globeButton.tap()
        mapButton.tap()
        globeButton.tap()
        snapshot("03Anthem")
        
        let chartsButton = tabBarsQuery.buttons["Charts"]
        chartsButton.tap()
        snapshot("04ChartsScreen")
        
        // record test here...
    }
    
    
}
