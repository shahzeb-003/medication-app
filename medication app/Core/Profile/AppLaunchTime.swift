//
//  AppLaunchTime.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 14/01/2024.
//

import XCTest

final class AppLaunchTime: XCTestCase { 

    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric(waitUntilResponsive: true)]) {
            XCUIApplication().launch()
        }
    }
}
