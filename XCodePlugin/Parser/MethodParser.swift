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
        case cantParseAccessType
        case cantParseMetaMethodInformation
        case cantParseName
        case cantParseBody
    }

    public static func parse(sources: [String]) throws -> ParseResult<Function> {

        var index = 0

        for (index, line) in sources.enumerated() {
            let trimmedLine = line.trimmed

            let regExpPattern = "\(AccessType.stringCases)?func\\(.*\\) ?(-> ?([A-Z,a-z]+)?)? *{"

            let regExp = try! NSRegularExpression(pattern: regExpPattern, options: [])

            let matches = regExp.matches(in: trimmedLine, options: [.anchored], range: NSRange(0..<trimmedLine.count))

            guard matches.count == 1, let firstMathed = matches.first,
                let stringRange = Range<String.Index>(firstMathed.range, in: line) else {
                    throw ParseError.cantParseMethod
            }

            let decalration = trimmedLine.substring(with: stringRange)

            var needsToMatch = false
            var saveSymbols = false
            var searchStart = true
            var searchEnd = false

            var openBraketsCount = 0

            var resultString = ""

            for character in decalration {
                if searchStart {
                    if character == "<" {
                        needsToMatch = true
                    } else if character == ">" {
                        needsToMatch = false
                    } else if character == "(" && !needsToMatch {
                        saveSymbols = true
                        searchEnd = true
                        searchStart = false
                    }
                } else if searchEnd {
                    if character == "(" {
                        openBraketsCount += 1
                    } else if character == ")" {
                        if openBraketsCount == 0 {
                            break
                        } else {
                            openBraketsCount-=1
                        }
                    }
                    resultString.append(character)
                }
            }


            let parameters = try parseParameters(string: resultString)
            let returnType = try parseReturnType(string: decalration)

            let splitedByWhitespace = decalration.split(separator: " ")

            // private static func blablabla() -> dfsdf

            var accessType: AccessType
            var isStatic = false

            if splitedByWhitespace[0] == "static" {
                isStatic = true
                if splitedByWhitespace[1] == "func" {
                    accessType = .private
                } else if let guardedAccessType = AccessType(rawValue: String(splitedByWhitespace[1])) {
                    accessType = guardedAccessType
                } else {
                    throw ParseError.cantParseAccessType
                }
            } else if let guardedAccessType = AccessType(rawValue: String(splitedByWhitespace[0])) {
                accessType = guardedAccessType

                if splitedByWhitespace[1] == "static" {
                    isStatic = true
                }
            } else {
                throw ParseError.cantParseMetaMethodInformation
            }

            let splitedByOpenBraket = decalration.split(separator: "(")

            guard let itemBeforeBrakets = decalration.split(separator: "(").first else {
                throw ParseError.cantParseName
            }

            var nameDeclaration = String(itemBeforeBrakets).trimmed.reversed()
            var name = ""
            for character in nameDeclaration {
                if character == " " {
                    break
                } else {
                    name.append(character)
                }
            }

            let endLineIndex = try skipBody(from: sources[index...].map { $0 })
            let functionModel = Function(parameters: parameters, returnType: returnType, name: name, accessType: accessType, isStatic: isStatic)
            return ParseResult(result: functionModel, newIndex: endLineIndex)
        }

        throw ParseError.cantParseMethod
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

    static func skipBody(from sources: [String]) throws -> Int {
        var openBraketsCount = 0
        for (index, line) in sources.enumerated() {
            for char in line {
                if char == "{" {
                    openBraketsCount += 1
                } else if char == "}" {
                    openBraketsCount -= 1
                }
            }

            if openBraketsCount == 0 {
                return index
            }
        }

        throw ParseError.cantParseBody

    }
}
