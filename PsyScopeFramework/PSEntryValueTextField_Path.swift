//
//  PSEntryValueTextField_Path.swift
//  PsyScopeEditor
//
//  Created by James on 03/08/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

public class PSEntryValueTextField_Path : PSEntryValueTextField {
    
    var controller : PSEntryValueController!

    
    public func setup(delegate : PSEntryValueControllerDelegate) {
        controller = PSEntryValueController(mainControl: self, delegate: delegate)
    }
    
    //accepts input of a file ref (or other kind of function)
    override public var stringValue : String {
        get {
            if let fileref = PSScriptFile.FileRefFromPath(superStringValue, scriptData: controller.scriptData) {
                return fileref
            } else {
                return superStringValue
            }
        }
        
        set {
            //incoming fileref
            if let path = PSScriptFile.PathFromFileRef(newValue, scriptData: controller.scriptData) {
                superStringValue = path
            } else {
                superStringValue = newValue
                controller.stringValue = newValue
            }
        }
    }
    
    public var superStringValue : String {
        get {
            return super.stringValue
        }
        
        set {
            super.stringValue = newValue
        }
    }
    
}