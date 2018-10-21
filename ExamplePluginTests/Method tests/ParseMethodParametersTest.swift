//
//  ParseMethodParametersTest.swift
//  ExamplePluginTests
//
//  Created by Александр Кравченков on 21/10/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import XCTest

@testable
import ExamplePlugin

public class ParseMethodParametersTest: XCTestCase {

    func testFullDeclaration() {

        // Arrange

        let name = "foo"
        let type = "Bar"

        let source = "\(name): \(type), \(name): \(type)"

        // Act

        var result: [Parameter]!

        do {
            result = try MethodParser.parseParameters(string: source)
        } catch {
            XCTFail("\(error)")
            return
        }

        // Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result.count, 2)
        XCTAssertNotNil(result.first!.name, name)
        XCTAssertNotNil(result.first!.type, type)
        XCTAssertNotNil(result.last!.name, name)
        XCTAssertNotNil(result.last!.type, type)
    }

    func testEmptyDeclaration() {

        // Arrange

        let source = ""

        // Act

        var result: [Parameter]!

        do {
            result = try MethodParser.parseParameters(string: source)
        } catch {
            XCTFail("\(error)")
            return
        }

        // Assert

        XCTAssertNotNil(result)
        XCTAssertTrue(result.isEmpty)
    }

    func testBadDeclarationFeiled() {

        // Arrange

        let source = "foo bar"

        // Act

        var resultError: ParameterParser.ParseError!

        do {
            _ = try MethodParser.parseParameters(string: source)
        } catch {
            resultError = error as? ParameterParser.ParseError
            return
        }

        // Assert

        XCTAssertNotNil(resultError)
        XCTAssertEqual(resultError, ParameterParser.ParseError.cantParseParameter)
    }
}
