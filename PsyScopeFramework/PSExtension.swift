//
//  PSExtension.swift
//  PsyScopeEditor
//
//  Created by James on 11/02/2015.
//

import Foundation

public class PSExtension {
    public init() {
        
    }
    
    public var helpString : String = ""
    public var type : String = ""
    public var appearsInToolMenu : Bool = true
    public var isEvent : Bool = false
    public var attributes : [PSAttribute] = []
    public var icon : NSImage!
    public var toolClass : PSToolInterface!
}
