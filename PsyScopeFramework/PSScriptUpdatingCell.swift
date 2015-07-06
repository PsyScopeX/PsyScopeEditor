//
//  PSScriptUpdatingCell.swift
//  PsyScopeEditor
//
//  Created by James on 10/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation


//Cell operates on class representing data, calls updateScript, when changes have been made 
//which should cause update in script - this in turn calls updateScriptBlock if provided
public class PSScriptUpdatingCell : NSView {    
    public var scriptData : PSScriptData! = nil
    public var updateScriptBlock : (() -> ())? = nil
    public func updateScript() {
        if let usb = updateScriptBlock{
            usb()
        }
    }
}