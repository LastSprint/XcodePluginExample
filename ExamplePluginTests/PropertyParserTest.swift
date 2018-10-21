//
//  PropertyParserTest.swift
//  ExamplePluginTests
//
//  Created by Александр Кравченков on 21/10/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import XCTest

@testable
import ExamplePlugin

class PropertyParserTest: XCTestCase {

    public func testPrivateCaseParsingSuccess() {
        // Arrange

        let modificator = AccessType.private
        let modType = VariableMutatingType.var
        let name = "name"
        let type = "Type"

        let source = "\(modificator.rawValue) \(modType.rawValue) \(name): \(type)"

        // Act

        var result: Property!

        do {
            result = try PropertyParser.parse(from: source)
        } catch {
            XCTFail("\(error)")
            return
        }

        // Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result.accessModifier, modificator)
        XCTAssertEqual(result.mutating, modType)
        XCTAssertEqual(result.name, name)
        XCTAssertEqual(result.type, type)
    }

    public func testPublicCaseParsingSuccess() {
        // Arrange

        let modificator = AccessType.public
        let modType = VariableMutatingType.var
        let name = "name"
        let type = "Type"

        let source = "\(modificator.rawValue) \(modType.rawValue) \(name): \(type)"

        // Act

        var result: Property!

        do {
            result = try PropertyParser.parse(from: source)
        } catch {
            XCTFail("\(error)")
            return
        }

        // Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result.accessModifier, modificator)
        XCTAssertEqual(result.mutating, modType)
        XCTAssertEqual(result.name, name)
        XCTAssertEqual(result.type, type)
    }

    public func testExcplicitInternalCaseParsingSuccess() {
        // Arrange

        let modificator = AccessType.internal
        let modType = VariableMutatingType.var
        let name = "name"
        let type = "Type"

        let source = "\(modificator.rawValue) \(modType.rawValue) \(name): \(type)"

        // Act

        var result: Property!

        do {
            result = try PropertyParser.parse(from: source)
        } catch {
            XCTFail("\(error)")
            return
        }

        // Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result.accessModifier, modificator)
        XCTAssertEqual(result.mutating, modType)
        XCTAssertEqual(result.name, name)
        XCTAssertEqual(result.type, type)
    }

    public func testImplicitInternalCaseParsingSuccess() {
        // Arrange

        let modificator = AccessType.internal
        let modType = VariableMutatingType.var
        let name = "name"
        let type = "Type"

        let source = "\(modType.rawValue) \(name): \(type)"

        // Act

        var result: Property!

        do {
            result = try PropertyParser.parse(from: source)
        } catch {
            XCTFail("\(error)")
            return
        }

        // Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result.accessModifier, modificator)
        XCTAssertEqual(result.mutating, modType)
        XCTAssertEqual(result.name, name)
        XCTAssertEqual(result.type, type)
    }

    public func testFileprivateCaseParsingSuccess() {
        // Arrange

        let modificator = AccessType.fileprivate
        let modType = VariableMutatingType.var
        let name = "name"
        let type = "Type"

        let source = "\(modificator.rawValue) \(modType.rawValue) \(name): \(type)"

        // Act

        var result: Property!

        do {
            result = try PropertyParser.parse(from: source)
        } catch {
            XCTFail("\(error)")
            return
        }

        // Assert

        XCTAssertNotNil(result)
        XCTAssertEqual(result.accessModifier, modificator)
        XCTAssertEqual(result.mutating, modType)
        XCTAssertEqual(result.name, name)
        XCTAssertEqual(result.type, type)
    }

    public func testBadSourceFailedWithCantParse() {

        // Arrange

        let source = "var private name"

        // Act

        var throwedError: PropertyParser.ParseError!

        do {
            _ = try PropertyParser.parse(from: source)
        } catch {
            throwedError = error as? PropertyParser.ParseError
        }

        // Assert

        XCTAssertNotNil(throwedError)
        XCTAssertEqual(throwedError, PropertyParser.ParseError.cantParseProperty)
    }
}
