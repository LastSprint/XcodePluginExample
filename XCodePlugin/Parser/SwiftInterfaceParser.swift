//
//  SwiftInterfaceParser.swift
//  XCodePlugin
//
//  Created by Александр Кравченков on 15/10/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

extension String {
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Reoresents a parse result
public struct ParseResult<Type> {
    /// It's a result of parsing current lines
    let result: Type
    /// New index calculated after parse `result` elements form source code
    let newIndex: Int
}

public class VariableParser {

    enum ParseError: Error, LocalizedError {
        case cantParseVariable
        case cantParseMutatingType
        case cantParseNameAndType
    }

    public static let declarationDelimeter: Character = " "
    public static let nameTypeDelimeter: Character = ":"
    public static let regExpPattern = "(var|let)\(declarationDelimeter)\\D+\(nameTypeDelimeter)\\D+"

    /// Try parse variable from source code
    /// Parameters:
    ///     - sources: It's a array of source code lines
    ///     - startFrom: It's an index which will be used current parser from start parsing `sources`
    public static func parse(from line: String) throws -> Variable {
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)

        let regExp = try! NSRegularExpression(pattern: regExpPattern, options: [])

        let matches = regExp.matches(in: trimmedLine, options: [.anchored], range: NSRange(0..<trimmedLine.count))

        guard matches.count == 1, let firstMathed = matches.first,
            let stringRange = Range<String.Index>(firstMathed.range, in: line) else {
                throw ParseError.cantParseVariable
        }

        let substring = trimmedLine[stringRange]

        let splitedByDeclaration = substring.split(separator: declarationDelimeter)

        guard let mutatingTypeString = splitedByDeclaration.first,
            let mutationgType = VariableMutatingType(rawValue: String(mutatingTypeString)) else {
                throw ParseError.cantParseMutatingType
        }

        let resultString = splitedByDeclaration.dropFirst().reduce("", { return "\($0)\($1)"} )

        let splitedByType = resultString.split(separator: nameTypeDelimeter)

        guard splitedByType.count == 2, let name = splitedByType.first, let type = splitedByType.last else {
            throw ParseError.cantParseNameAndType
        }

        return Variable(mutating: mutationgType, type: String(type).trimmed, name: String(name).trimmed)

    }
}

public class ParameterParser {

    enum ParseError: Error, LocalizedError {
        case cantParseParameter
        case cantParseNameAndType
    }
    public static let nameTypeDelimeter: Character = ":"
    public static let reqExpPattern = "\\D+\(nameTypeDelimeter)\\D+"

    public static func parse(from source: String) throws -> Parameter {
        let trimmedLine = source.trimmingCharacters(in: .whitespacesAndNewlines)
        let regExp = try! NSRegularExpression(pattern: reqExpPattern, options: [])
        let matches = regExp.matches(in: trimmedLine, options: [.anchored], range: NSRange(0..<trimmedLine.count))
        guard matches.count == 1, let firstMathed = matches.first,
            let stringRange = Range<String.Index>(firstMathed.range, in: source) else {
            throw ParseError.cantParseParameter
        }
        let splitedByType = source[stringRange].split(separator: nameTypeDelimeter)
        guard splitedByType.count == 2, let name = splitedByType.first, let type = splitedByType.last else {
            throw ParseError.cantParseNameAndType
        }
        return Parameter(type: String(type).trimmed, name: String(name).trimmed)
    }
}

public class PropertyParser {


    enum ParseError: Error, LocalizedError {
        case cantParseProperty
        case badCountOfIlementsInLine
        case atThisTimeSupportOnlyAccessModificatorParsing
        case cantParseAccessModifier
    }

    public static func parse(from line: String) throws -> Property {
        let trimmedLine = line.trimmed
        let modifiers = ["private ", "public ", "internal ", "fileprivate "].reduce("", { "\($0)|\($1)"})
        let regExpPattern = "(\(modifiers))?\(VariableParser.regExpPattern)"

        let regExp = try! NSRegularExpression(pattern: regExpPattern, options: [])

        let matches = regExp.matches(in: trimmedLine, options: [.anchored], range: NSRange(0..<trimmedLine.count))

        guard matches.count == 1, let firstMathed = matches.first,
            let stringRange = Range<String.Index>(firstMathed.range, in: line) else {
                throw ParseError.cantParseProperty
        }

        let splitedByWhSpAndReversed = Array(trimmedLine[stringRange].split(separator: " ").reversed())

        guard splitedByWhSpAndReversed.count >= 3 else {
            throw ParseError.badCountOfIlementsInLine
        }

        let variablePart = splitedByWhSpAndReversed[0...2].reversed().reduce("") { "\($0) \($1)" }
        let propertyPart = splitedByWhSpAndReversed[3...]

        var accessModificator: AccessType!

        if propertyPart.isEmpty {
            accessModificator = .internal
        } else if let modificator = propertyPart.first,
            let accessType = AccessType(rawValue: String(modificator)){
            accessModificator = accessType
        } else {
            throw ParseError.cantParseAccessModifier
        }

        let variable = try VariableParser.parse(from: variablePart)

        return Property(accessModifier: accessModificator, variable: variable)
    }
}

