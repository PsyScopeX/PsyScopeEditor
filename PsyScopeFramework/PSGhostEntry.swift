//
//  PSGhostEntry.swift
//  PsyScopeEditor
//
//  Created by James on 17/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

open class PSGhostEntry : NSObject {

    open var subEntries : [PSGhostEntry] = []
    open var name : String = ""
    open var currentValue : String = ""
    open var type : String = ""
    open var instantiated = false
    open var links : [PSGhostEntry] = []
    open var parent : PSGhostEntry? = nil
    open var level : Int = 0
    open var comments : String = ""
}
