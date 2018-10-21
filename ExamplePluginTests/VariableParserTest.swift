//
//  ExamplePluginTests.swift
//  ExamplePluginTests
//
//  Created by Александр Кравченков on 15/10/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import XCTest
@testable import ExamplePlugin

class VariableParserTest: XCTestCase {

    /// Try to parse most commun variable declaration
    func testThatSimpleCAsePArsedSuccess() {

        // Arrange

        let source = "var templ: Int"

        var result: Variable!

        // Act

        do {
            result = try VariableParser.parse(from: source)
        } catch {
            XCTFail("\(error)")
            return
        }

        // Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result.mutating, .var)
        XCTAssertEqual(result.name, "templ")
        XCTAssertEqual(result.type, "Int")
    }

    func testThatLetParseSuccess() {
        // Arrange

        let source = "let templ: Int"

        var result: Variable!

        // Act

        do {
            result = try VariableParser.parse(from: source)
        } catch {
            XCTFail("\(error)")
            return
        }

        // Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result.mutating, .let)
        XCTAssertEqual(result.name, "templ")
        XCTAssertEqual(result.type, "Int")
    }

    func testThatBadDeclarationFormatParseSuccess() {
        // Arrange

        let source = "var templ : Int"

        var result: Variable!

        // Act

        do {
            result = try VariableParser.parse(from: source)
        } catch {
            XCTFail("\(error)")
            return
        }

        // Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result.mutating, .var)
        XCTAssertEqual(result.name, "templ")
        XCTAssertEqual(result.type, "Int")
    }

    func testThatShortDeclarationSuccess() {
        // Arrange

        let source = "var templ:Int"

        var result: Variable!

        // Act

        do {
            result = try VariableParser.parse(from: source)
        } catch {
            XCTFail("\(error)")
            return
        }

        // Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result.mutating, .var)
        XCTAssertEqual(result.name, "templ")
        XCTAssertEqual(result.type, "Int")
    }

    func testThatPArseFalling() {
        
    }
}
