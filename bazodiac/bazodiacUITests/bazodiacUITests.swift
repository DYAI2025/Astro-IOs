//
//  bazodiacUITests.swift
//  bazodiacUITests
//
//  Created by Benjamin Poersch on 15.03.26.
//

import XCTest

final class bazodiacUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()
        // App should launch without crash — obsidian background + splash animations start
        XCTAssertTrue(app.windows.firstMatch.exists)
    }

    @MainActor
    func testSplashLanguageGateAppearsAndTransitionsToBirthForm() throws {
        let app = XCUIApplication()
        app.launch()

        // Language gate appears within 6 seconds (animation sequence runs ~4.2s)
        let deutschButton = app.buttons["Deutsch"]
        let gateAppeared = deutschButton.waitForExistence(timeout: 7.0)
        XCTAssertTrue(gateAppeared, "Language gate (Deutsch/English buttons) must appear within 7s")

        deutschButton.tap()

        // Birth form header should appear shortly after
        let header = app.staticTexts["Kosmischer Blueprint"]
        let formAppeared = header.waitForExistence(timeout: 3.0)
        XCTAssertTrue(formAppeared, "BirthFormView header must appear after language selection")
    }

    @MainActor
    func testBirthFormNameFieldAcceptsInput() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--skip-to-birthform"]
        app.launch()

        let nameField = app.textFields["Dein Name"]
        let fieldExists = nameField.waitForExistence(timeout: 3.0)
        XCTAssertTrue(fieldExists, "Name text field should exist in BirthFormView")

        nameField.tap()
        nameField.typeText("Layla")
        XCTAssertEqual(nameField.value as? String, "Layla")
    }

    @MainActor
    func testDashboardLoadsWithMockData() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--skip-to-dashboard"]
        app.launch()

        // Home tab should show name from mock profile
        let cosmosLabel = app.staticTexts["Layla"]
        let dashboardLoaded = cosmosLabel.waitForExistence(timeout: 3.0)
        XCTAssertTrue(dashboardLoaded, "Dashboard should show mock profile name 'Layla'")
    }

    @MainActor
    func testAllTabsAreAccessible() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--skip-to-dashboard"]
        app.launch()

        let tabLabels = ["Kosmos", "Chart", "BaZi", "Wu-Xing", "Levi"]
        for label in tabLabels {
            let tab = app.buttons[label]
            let exists = tab.waitForExistence(timeout: 3.0)
            XCTAssertTrue(exists, "Tab '\(label)' must exist in the tab bar")
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
