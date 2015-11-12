//
//  PSSection.swift
//  PsyScopeEditor
//
//  Created by James on 12/11/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

public struct PSSection {
    let name : String
    let zOrder : Int
    
    public static let Root = PSSection(name: "Root", zOrder: 0)
    public static let ExperimentDefinitions = PSSection(name: "ExperimentDefinitions", zOrder: 1)
    public static let SubjectInfo = PSSection(name: "SubjectInfo", zOrder: 2)
    public static let LogFile = PSSection(name: "LogFile", zOrder: 3)
    public static let GroupDefinitions = PSSection(name: "GroupDefinitions", zOrder: 4)
    public static let BlockDefinitions = PSSection(name: "BlockDefinitions", zOrder: 5)
    public static let TemplateDefinitions = PSSection(name: "TemplateDefinitions", zOrder: 6)
    public static let EventDefinitions = PSSection(name: "EventDefinitions", zOrder: 7)
    public static let ListDefinitions = PSSection(name: "ListDefinitions", zOrder: 8)
    
    public static let VariableDefinitions = PSSection(name: "VariableDefinitions", zOrder: 12)
    public static let PortDefinitions = PSSection(name: "PortDefinitions", zOrder: 14)
    public static let PositionDefinitions = PSSection(name: "PositionDefinitions", zOrder: 14)
    public static let ExecutionEntries = PSSection(name: "ExecutionEntries", zOrder: 15)
    public static let UndefinedEntries = PSSection(name: "UndefinedEntries", zOrder: 100)
}

