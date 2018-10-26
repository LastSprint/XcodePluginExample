//
//  ParserMethodsSkipBodyTest.swift
//  ExamplePluginTests
//
//  Created by Александр Кравченков on 26/10/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import XCTest

@testable
import ExamplePlugin

public class ParserMethodsSkipBodyTest: XCTestCase {

    public func testSkipWorkSuccessInSimpleCase() {
        // Arrange
        let val = ["func temp() {", "var t = 1", "sdjhfgshjfjsx", "}"]
        // Act

        var result: Int!

        do {
            result = try MethodParser.skipBody(from: val)
        } catch {
            XCTFail("\(error)")
            return
        }

        // Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result, 3)
    }

    public func testSkipWorkWithEmptyBody() {
        // Arrange
        let val = ["func temp() {}"]
        // Act

        var result: Int!

        do {
            result = try MethodParser.skipBody(from: val)
        } catch {
            XCTFail("\(error)")
            return
        }

        // Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result, 0)
    }

}
