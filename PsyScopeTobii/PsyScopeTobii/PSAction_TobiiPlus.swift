//
//  PSAction_TobiiPlus.swift
//  PsyScopeEditor
//
//  Created by James on 06/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//


import PsyScopeFramework

class PSAction_TobiiPlus : NSObject, PSActionInterface {
    
    override init() {
        
        typeString = "Tobii Plus"
        userFriendlyNameString = "Tobii Plus Command"
        helpfulDescriptionString = ""
        actionParameters = [PSAttributeParameter_String.self,PSAttributeParameter_String.self]
        actionParameterNames = ["Command:", "Data:"]
        groupString = "Actions / Conditions"
        super.init()
    }
    
    var typeString : String
    var userFriendlyNameString : String
    var helpfulDescriptionString : String
    var groupString : String
    var actionParameters : [NSObject.Type]
    var actionParameterNames : [String]
    
    func type() -> String! {
        return typeString
    }
    
    func userFriendlyName() -> String! {
        return userFriendlyNameString
    }
    
    func helpfulDescription() -> String! {
        return helpfulDescriptionString
    }
    
    func icon() -> NSImage! {
        return nil
    }
    
    func group() -> String! {
        return groupString
    }
    
    func actionCellInterface() -> AnyObject! {
        return nil
    }
    
    func createCellView(entryFunction: PSEventActionFunction!, scriptData: PSScriptData!, expandedHeight: CGFloat) -> PSActionCell! {
        let new_view = PSActionCell(frame:NSRect(x: 0, y: 0, width: 200, height: expandedHeight))
        new_view.setup(self, entryFunction: entryFunction, scriptData: scriptData, parameters: actionParameters, names: actionParameterNames, expandedHeight: expandedHeight)
        return new_view
    }
    
    
    var _cellRowHeightExpanded : CGFloat? = nil
    
    func expandedCellHeight() -> CGFloat {
        
        if let c = _cellRowHeightExpanded {
            return c
        }
        
        let height : CGFloat = 22 + (CGFloat(actionParameters.count) * PSAttributeParameter.defaultHeight)
        _cellRowHeightExpanded = height
        return height
        
    }
}