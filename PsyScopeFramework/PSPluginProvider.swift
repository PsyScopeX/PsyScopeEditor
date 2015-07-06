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
    public var reservedEntryNames : [String]
    
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
        
        fileImportPlugins = [:]
        for (name , tool) in toolPlugins {
            if let extensions = tool.validDraggedFileExtensions() {
                for ext in extensions as! [String] {
                    if nil == fileImportPlugins[ext] {
                        fileImportPlugins[ext] = []
                    }
                    fileImportPlugins[ext]!.append(tool)
                }
            }
            reservedEntryNames += tool.reservedEntryNames() as! [String]
        }
        
        for (name , tool) in eventPlugins {
            if let extensions = tool.validDraggedFileExtensions() {
                for ext in extensions as! [String] {
                    if nil == fileImportPlugins[ext] {
                        fileImportPlugins[ext] = []
                    }
                    fileImportPlugins[ext]!.append(tool)
                }
            }
            reservedEntryNames += tool.reservedEntryNames() as! [String]
        }
        
        for (name , tool) in attributePlugins {
            reservedEntryNames += tool.reservedEntryNames() as! [String]
        }
        
        super.init()
    }
    
    public func getInterfaceForType(type : String) -> PSToolInterface? {
        if let tool = toolPlugins[type] {
            return tool
        } else if let event = eventPlugins[type] {
            return event
        }
        
        return nil
    }
}