//
//  ParameterParserTest.swift
//  ExamplePluginTests
//
//  Created by Александр Кравченков on 18/10/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import XCTest

@testable
import ExamplePlugin

public class ParameterParserTest: XCTestCase {

    public func testThatSimpleCaseParsedSuccess() {

        // Arrange

        let source = "type: Int"

        // Act

        var parameter: Parameter!

        do {
           parameter = try ParameterParser.parse(from: source)
        } catch {
            XCTFail("\(error)")
            return
        }

        // Assert

        XCTAssertEqual(parameter!.name, "type")
        XCTAssertEqual(parameter!.type, "Int")
    }

    public func testThatBadDeclarationParsingSuccess() {
        // Arrange

        let source = "type : Int"

        // Act

        var parameter: Parameter!

        do {
            parameter = try ParameterParser.parse(from: source)
        } catch {
            XCTFail("\(error)")
            return
        }

        // Assert

        XCTAssertEqual(parameter!.name, "type")
        XCTAssertEqual(parameter!.type, "Int")
    }
}
