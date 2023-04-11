//
//  Tests_iOSLaunchTests.swift
//  Tests iOS
//
//  Created by Vito Royeca on 5/28/22.
//

import XCTest
@testable import Flag_Ceremony

class Tests_iOSLaunchTests: XCTestCase {
    let app = XCUIApplication()

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = true
        app.launchEnvironment = ["isUITest": "true"]
    }

    func testLaunch() throws {
        app.launch()
        setupSnapshot(app)

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

//        let attachment = XCTAttachment(screenshot: app.screenshot())
//        attachment.name = "Launch Screen"
//        attachment.lifetime = .keepAlways
//        add(attachment)

        let tabBar = XCUIApplication().tabBars["Tab Bar"]

        // #2
        snapshot("02Anthem")
        let closeButton = app.buttons["Close"].firstMatch
        XCTAssertTrue(closeButton.waitForExistence(timeout: 1))
        XCTAssert(closeButton.exists)
        closeButton.tap()
        
        // #1
        let mapButton = tabBar.buttons["Map"]
        XCTAssertTrue(mapButton.waitForExistence(timeout: 5))
        snapshot("01Map")

        // #3
        let globeButton = tabBar.buttons["Globe"]
        XCTAssertTrue(globeButton.waitForExistence(timeout: 5))
        globeButton.tap()
        sleep(5)
        snapshot("03Globe")

        // #4
        let chartsButton = tabBar.buttons["Charts"]
        chartsButton.tap()
        snapshot("04Charts")
    }
}
