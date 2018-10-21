//
//  Class.swift
//  XCodePlugin
//
//  Created by Александр Кравченков on 15/10/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

/// Represents a swift class in meta form
public class Class {
    var properties: [Property]
    var methods: [Method]

    let name: String
    let isStruct: Bool

    public init(name: String, isStruct: Bool) {
        self.name = name
        self.isStruct = isStruct
        self.properties = [Property]()
        self.methods = [Method]()
    }
}
