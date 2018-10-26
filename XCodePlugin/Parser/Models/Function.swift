//
//  Method.swift
//  XCodePlugin
//
//  Created by Александр Кравченков on 15/10/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

public struct Function {
    let parameters: [Parameter]
    let returnType: String
    let name: String
    let accessType: AccessType
    let isStatic: Bool
}
