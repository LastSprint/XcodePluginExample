//
//  Property.swift
//  XCodePlugin
//
//  Created by Александр Кравченков on 15/10/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

/// Represents a mutating type of any variable
public enum VariableMutatingType: String {
    case `let` = "let"
    case `var` = "var"
}

public enum AccessType: String {
    case `public` = "public"
    case `internal` = "internal"
    case `fileprivate` = "fileprivate"
    case `private` = "private"
}

// Represents a method parameter
public struct Parameter {
    let type: String
    let name: String
}

/// Represents a swift variable
public struct Variable {
    let mutating: VariableMutatingType
    let type: String
    let name: String
}

/// Represents a swift property
public struct Property {
    let mutating: VariableMutatingType
    let type: String
    let name: String
    let accessModifier: AccessType
}

extension Property {
    public init(accessModifier: AccessType, variable: Variable) {
        self.init(mutating: variable.mutating, type: variable.type, name: variable.name, accessModifier: accessModifier)
    }
}
