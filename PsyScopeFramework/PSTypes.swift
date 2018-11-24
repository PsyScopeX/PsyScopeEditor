//
//  PSTypes.swift
//  PsyScopeEditor
//
//  Created by James on 12/11/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

public struct PSType : Equatable {
    public let name : String
    public let defaultSection : PSSection
    
    public static let Experiment = PSType(name: "Experiment", defaultSection: PSSection.ExperimentDefinitions)
    public static let SubjectInfo = PSType(name: "SubjectInfo", defaultSection: PSSection.SubjectInfo)
    public static let Group = PSType(name: "Group", defaultSection: PSSection.GroupDefinitions)
    public static let Block = PSType(name: "Block", defaultSection: PSSection.BlockDefinitions)
    public static let Template = PSType(name: "Template", defaultSection: PSSection.TemplateDefinitions)
    
    public static let List = PSType(name: "List", defaultSection: PSSection.ListDefinitions)
    public static let Variable = PSType(name: "Variable", defaultSection: PSSection.VariableDefinitions)
    public static let PortNames = PSType(name: "PortNames", defaultSection: PSSection.PortDefinitions)
    public static let Port = PSType(name: "Port", defaultSection: PSSection.PortDefinitions)
    public static let Position = PSType(name: "Position", defaultSection: PSSection.PositionDefinitions)
    public static let Logging = PSType(name: "Logging", defaultSection: PSSection.LogFile)
    public static let ExecutionEntry = PSType(name: "ExecutionEntry", defaultSection: PSSection.ExecutionEntries)
    public static let UndefinedEntry = PSType(name: "", defaultSection: PSSection.UndefinedEntries)
    
    public static let Input = PSType(name: "Input", defaultSection: PSSection.EventDefinitions)
    public static let Text = PSType(name: "Text", defaultSection: PSSection.EventDefinitions)
    public static let Pict = PSType(name: "Pict", defaultSection: PSSection.EventDefinitions)
    public static let KeySequence = PSType(name: "KeySequence", defaultSection: PSSection.EventDefinitions)
    public static let Movie = PSType(name: "Movie", defaultSection: PSSection.EventDefinitions)
    public static let SoundLabel = PSType(name: "SoundLabel", defaultSection: PSSection.EventDefinitions)
    public static let PasteBoard = PSType(name: "PasteBoard", defaultSection: PSSection.EventDefinitions)
    public static let Document = PSType(name: "Document", defaultSection: PSSection.EventDefinitions)
    public static let Paragraph = PSType(name: "Paragraph", defaultSection: PSSection.EventDefinitions)
    public static let NullEvent = PSType(name: "Null", defaultSection: PSSection.EventDefinitions)
    public static let Menu = PSType(name: "Menu", defaultSection: PSSection.Menus)
    
    public static let DefaultTypes : [PSType] = [Experiment, SubjectInfo, Group, Block, Template, List, Variable, PortNames, Port, Position, Logging, ExecutionEntry, UndefinedEntry, Input, Text, Pict, KeySequence, Movie, SoundLabel, PasteBoard, Document, Paragraph, NullEvent, Menu]
    
    public static func FromName(_ name : String) -> PSType {
        if let defaultType = DefaultTypes.filter({$0.name == name}).first {
            return defaultType
        } else {
            return PSType(name: name, defaultSection: PSSection.UndefinedEntries)
        }
    }
}

public func ==(lhs: PSType, rhs: PSType) -> Bool {
    return lhs.name == rhs.name
}

public func !=(lhs: PSType, rhs: PSType) -> Bool {
    return lhs.name != rhs.name
}
