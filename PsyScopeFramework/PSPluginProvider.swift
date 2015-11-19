//
//  PSPluginProvider.swift
//  PsyScopeEditor
//
//  Created by James on 11/02/2015.
//

import Foundation
public class PSPluginProvider : NSObject {
    public var toolPlugins : [String : PSToolInterface]
    public var attributePlugins : [String : PSAttributeInterface]
    public var eventPlugins : [String : PSToolInterface]
    public var actionPlugins : [String : PSActionInterface]
    public var conditionPlugins : [String : PSConditionInterface]
    public var attributeSourceTools : [String : PSToolInterface]
    public var extensions : [PSExtension]
    public var eventExtensions : [PSExtension]
    public var attributes : [PSAttribute]
    public var fileImportPlugins : [String : [PSToolInterface]]
    public var reservedEntryNames : [String] //Entry names which are reserved for special purposes
    public var illegalEntryNames : [String] //Entry names which are fully illegal
    
    public init(attributePlugins: [String : PSAttributeInterface], toolPlugins: [String : PSToolInterface], eventPlugins: [String : PSToolInterface], actionPlugins: [String : PSActionInterface], conditionPlugins: [String : PSConditionInterface], attributeSourceTools: [String : PSToolInterface],extensions : [PSExtension],eventExtensions : [PSExtension],attributes : [PSAttribute]) {

        self.attributePlugins = attributePlugins
        self.eventPlugins = eventPlugins
        self.toolPlugins = toolPlugins
        self.actionPlugins = actionPlugins
        self.conditionPlugins = conditionPlugins
        self.attributeSourceTools = attributeSourceTools
        self.extensions = extensions
        self.attributes = attributes
        self.eventExtensions = eventExtensions
        self.reservedEntryNames = []
        self.illegalEntryNames = []
        
        fileImportPlugins = [:]
        for (_ , tool) in toolPlugins {
            if let extensions = tool.validDraggedFileExtensions() {
                for ext in extensions as! [String] {
                    if nil == fileImportPlugins[ext] {
                        fileImportPlugins[ext] = []
                    }
                    fileImportPlugins[ext]!.append(tool)
                }
            }
            reservedEntryNames += tool.getReservedEntryNames() as! [String]
            illegalEntryNames += tool.getIllegalEntryNames() as! [String]
            
        }
        
        for (_ , tool) in eventPlugins {
            if let extensions = tool.validDraggedFileExtensions() {
                for ext in extensions as! [String] {
                    if nil == fileImportPlugins[ext] {
                        fileImportPlugins[ext] = []
                    }
                    fileImportPlugins[ext]!.append(tool)
                }
            }
            reservedEntryNames += tool.getReservedEntryNames() as! [String]
            illegalEntryNames += tool.getIllegalEntryNames() as! [String]
        }
        
        for (_ , tool) in attributePlugins {
            reservedEntryNames += tool.getReservedEntryNames() as! [String]
            illegalEntryNames += tool.getIllegalEntryNames() as! [String]
        }
        
        super.init()
    }
    
    public func getInterfaceForType(type : PSType) -> PSToolInterface? {
        if let tool = toolPlugins[type.name] {
            return tool
        } else if let event = eventPlugins[type.name] {
            return event
        }
        
        return nil
    }
    
    public func entryNameIsReservedOrIllegal(entryName : String) -> Bool {
        let reserved : [String] = illegalEntryNames + reservedEntryNames
        return reserved.contains(entryName)
    }
}