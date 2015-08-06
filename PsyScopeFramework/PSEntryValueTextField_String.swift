//
//  PSEntryValueTextField_String.swift
//  PsyScopeEditor
//
//  Created by James on 03/08/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

public class PSEntryValueTextField_String : NSTextField {
    
    var controller : PSEntryValueController!
    
    public func setup(delegate : PSEntryValueControllerDelegate) {
        controller = PSEntryValueController(mainControl: self, delegate: delegate)
    }
    
    override public var stringValue : String {
        get {
            return controller.stringValue
        }
        
        set {
            controller.stringValue = newValue
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