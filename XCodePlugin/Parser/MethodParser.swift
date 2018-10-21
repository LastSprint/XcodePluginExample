//
//  MethodParser.swift
//  XCodePlugin
//
//  Created by Александр Кравченков on 21/10/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

extension AccessType {
    static var allCAses: [AccessType] {
        return [.private, .public, .internal, .fileprivate]
    }

    static var stringCases: [String] {
        return allCAses.map { "\($0) " }
    }
}

public class MethodParser {

    public enum ParseError: Error, LocalizedError {
        case cantParseMethod
        case cantParseMethodReturnTypeExpression
    }

    public static func parse(sources: [String]) throws {
        for line in sources {
            let trimmedLine = line.trimmed

            let regExpPattern = "\(AccessType.stringCases)?func\\(.*\\) ?(-> ?([A-Z,a-z]+)?)? *{"

            let regExp = try! NSRegularExpression(pattern: regExpPattern, options: [])

            let matches = regExp.matches(in: trimmedLine, options: [.anchored], range: NSRange(0..<trimmedLine.count))

            guard matches.count == 1, let firstMathed = matches.first,
                let stringRange = Range<String.Index>(firstMathed.range, in: line) else {
                    throw ParseError.cantParseMethod
            }
        }
    }

    /// Expected method arguments like this: `var: Type, var: Type`
    public static func parseParameters(string: String) throws -> [Parameter] {
        let delimeter: Character = ","

        let splitedByDeclaration = string.split(separator: delimeter)

        var parameters = [Parameter]()

        for item in splitedByDeclaration {
            let parameter = try ParameterParser.parse(from: String(item))
            parameters.append(parameter)
        }

        return parameters
    }

    /// Excpected function declaration like 'private func(foo: Bar) -> Type {'
    public static func parseReturnType(string: String) throws -> String {

        var findFlag = false
        // index of '>' character
        var lastIndex = 0
        for (index, character) in string.enumerated() {
            if character == "-" {
                findFlag = true
            } else if findFlag && character == ">" {
                lastIndex = index
                break
            } else {
                findFlag = false
            }
        }

        guard findFlag else {
            return "Void"
        }
        let startIndex = string.index(string.startIndex, offsetBy: lastIndex)
        let currentIndex = string.index(after: startIndex)
        let typeDeclaration = string[currentIndex...]
        let replaced = typeDeclaration
            .replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")

        return String(replaced).trimmed
    }
}
