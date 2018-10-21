//
//  SourceEditorCommand.swift
//  XCodePlugin
//
//  Created by Александр Кравченков on 11/10/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import XcodeKit

enum ParseError: Error, LocalizedError {
    case cantReadString
    case cantParseSelection
    case shouldHaveOnlyOneSelection
    case shouldBeSelectedOneLine

    var errorDescription: String? {
        switch self {
        case .cantReadString:
            return "Cant parse file to string array"
        case .cantParseSelection:
            return "Cant parse eselections"
        case .shouldHaveOnlyOneSelection:
            return "Should have only one selection"
        case .shouldBeSelectedOneLine:
            return "Should have selected only one line"
        }
    }
}

enum CodeParseError: Error, LocalizedError {
    case foundUnexceptedClosedBraket
    case cantParseScope
    case cantExecuteClassName

    var errorDescription: String? {
        switch self {
        case .foundUnexceptedClosedBraket:
            return "While parse swift method body we found unexcepted close braket"
        case .cantParseScope:
            return "Cant parse scope (cant find needed count of closed brakets)"
        case .cantExecuteClassName:
            return "Cant execute class name for selected function"
        }
    }
}


class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {

        // Parse all file to string array
        var fileLines: [String]
        var selectionLines: [XCSourceTextRange]
        do {
            fileLines = try self.parseToString(array: invocation.buffer.lines)
            selectionLines = try self.parseToTextRange(array: invocation.buffer.selections)
        } catch {
            completionHandler(error)
            return
        }

        guard selectionLines.count == 1, let selectionLine = selectionLines.first else {
            completionHandler(ParseError.shouldHaveOnlyOneSelection)
            return
        }

        guard selectionLine.start.line == selectionLine.end.line else {
            completionHandler(ParseError.shouldBeSelectedOneLine)
            return
        }
        let slice = fileLines[selectionLine.start.line...]

        var endLineNumber: Int
        var className: String

        do {
            endLineNumber = try self.parseScope(of: [String](slice)) + selectionLine.start.line
            className = try self.getClassName(lines: fileLines, for: selectionLine.start.line)
        } catch {
            completionHandler(error)
            return
        }

        let method = [String](fileLines[selectionLine.start.line...endLineNumber])

        fileLines.removeSubrange(Range<Int>(selectionLine.start.line...endLineNumber))
        // Needs to surround with do/try/catch block

        // <--------- Идеи ---------------->
        // Плагин для вынесения методов в private extension
        // Плагин для внесения кусков кода в do/try/catch
        // Генерация конструктора из свойств

        completionHandler(nil)
    }
    
}

private extension SourceEditorCommand {

    func parseToString(array: NSMutableArray) throws -> [String] {
        return try array.map { value -> String in
            guard let variable = value as? String else { throw ParseError.cantReadString }
            return variable
        }
    }

    func parseToTextRange(array: NSMutableArray) throws -> [XCSourceTextRange] {
        return try array.map { value -> XCSourceTextRange in
            guard let variable = value as? XCSourceTextRange else { throw ParseError.cantParseSelection }
            return variable
        }
    }
}

// MARK: - Code parser

private extension SourceEditorCommand {

    func parseScope(of lines: [String]) throws -> Int {
        var counter = 0;

        for (lineNumber, string) in lines.enumerated() {
            string.forEach {
                if $0 == "{" {
                    counter += 1
                } else if $0 == "}" {
                    counter -= 1
                }
            }

            if counter < 0 {
                throw CodeParseError.foundUnexceptedClosedBraket
            } else if counter == 0 {
                return lineNumber
            }
        }
        throw CodeParseError.cantParseScope
    }


    //  Так просто не получится распарстиь класс. Нужно все таки строить синтаксическое дерево. Ну примитивное. В данном случае, нам нужно понять в чьем скоупе объявлен метод. То есть мы берем верхушку файла, находим первый класс - помечаем что у нас открылся скоуп. Дальше ищем либо еще один класс либо проверяем, что мы в нужной строке. Если мы нашли новый класс - запоминаем его. Если встретили открывающую скобку - увеличили счетчик на 1. Если нет - сбросили. Так получится найти конец для класса. Таким образом мы сможем разбирать класс по интерфейсу. То есть, грубо говоря мы сможем знать где у него вложеные классы, где у него методы и на каких строчках методы начинаются и заканчиваются.  

    /// This method serach class name for code that placed at current line
    /// - Parameters
    ///     - lines: Source code lines
    ///     - number: numver of current code line
    func getClassName(lines: [String], for number: Int) throws -> String {
        let slice = [String](lines[...number]).reversed()

        for string in slice {
            if string.contains(" class ") {

                var memd = ""

                for (index, item)in string.enumerated() {

                    if item == " ", !memd.isEmpty,
                        String(memd.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                            .compare("class") == ComparisonResult.orderedSame {
                        var tempString = string
                        tempString.removeSubrange(string.startIndex...string.index(string.startIndex, offsetBy: index))
                        memd = ""

                        for char in tempString {
                            guard char != "{" || char != " " || char != ":" else {
                                break
                            }

                            memd.append(char)
                        }

                        return memd
                    } else if item == " ", !memd.isEmpty {
                        memd = ""
                    }
                    memd.append(item)
                }
            }
        }
        throw CodeParseError.cantExecuteClassName
    }
}
