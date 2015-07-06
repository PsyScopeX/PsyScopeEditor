//
//  PSGhostEntry.swift
//  PsyScopeEditor
//
//  Created by James on 17/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public class PSGhostEntry : NSObject {

    public var subEntries : [PSGhostEntry] = []
    public var name : String = ""
    public var currentValue : String = ""
    public var type : String = ""
    public var instantiated = false
    public var links : [PSGhostEntry] = []
    public var parent : PSGhostEntry? = nil
    public var level : Int = 0
    public var range : NSRange = NSMakeRange(0, 0)
    public var comments : String = ""
}