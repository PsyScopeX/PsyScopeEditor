//
//  PSEntryValueTextField_String.swift
//  PsyScopeEditor
//
//  Created by James on 03/08/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

public class PSEntryValueTextField_String : PSEntryValueTextField {
    
    override public var stringValue : String {
        get {
            return controller.stringValue
        }
        
        set {
            controller.stringValue = newValue
        }
    }

}