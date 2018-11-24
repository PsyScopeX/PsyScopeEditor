//
//  PSExtension.swift
//  PsyScopeEditor
//
//  Created by James on 11/02/2015.
//

import Foundation

open class PSExtension {
    public init() {
        
    }
    
    open var helpString : String = ""
    open var type : String = ""
    open var appearsInToolMenu : Bool = true
    open var isEvent : Bool = false
    open var attributes : [PSAttribute] = []
    open var icon : NSImage!
    open var toolClass : PSToolInterface!
}
