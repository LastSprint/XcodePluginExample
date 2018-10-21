//
//  ParseMethodReturnTypeTest.swift
//  ExamplePluginTests
//
//  Created by Александр Кравченков on 21/10/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import XCTest

@testable
import ExamplePlugin

public class ParseMethodReturnTypeTest: XCTestCase {

    public func testFullMethodDeclarationCase() {
        // Arrange

        let type = "quux"

        let declaration = "public static func example<Foo where Foo == Bar>(baz: Foo) -> \(type) { }"

        // Act

        var result = ""

        do {
            result = try MethodParser.parseReturnType(string: declaration)
        } catch {
            XCTFail("\(error)")
            return
        }

        // Assert

        XCTAssertEqual(result, type)
    }

    public func testFullMethodDeclarationWithoutBodyBraketsCase() {
        // Arrange

        let type = "quux"

        let declaration = "public static func example<Foo where Foo == Bar>(baz: Foo) -> \(type)"

        // Act

        var result = ""

        do {
            result = try MethodParser.parseReturnType(string: declaration)
        } catch {
            XCTFail("\(error)")
            return
        }

        // Assert

        XCTAssertEqual(result, type)
    }

    public func testFullMethodDeclarationWithImplicitReturnTypeDeclaration() {
        // Arrange

        let type = "Void"

        let declaration = "public static func example<Foo where Foo == Bar>(baz: Foo) { }"

        // Act

        var result = ""

        do {
            result = try MethodParser.parseReturnType(string: declaration)
        } catch {
            XCTFail("\(error)")
            return
        }

        // Assert

        XCTAssertEqual(result, type)
    }
}
