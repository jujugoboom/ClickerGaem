//
//  SwiftInfiniteTests.swift
//  ClickerGaemTests
//
//  Created by Justin Covell on 9/16/24.
//

import XCTest
@testable import ClickerGaem

final class SwiftInfiniteTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDiv() throws {
        let value: InfiniteDecimal = 10;
        XCTAssert(value.div(value: 5).eq(other: 2))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
