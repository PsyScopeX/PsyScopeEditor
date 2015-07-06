//
//  PSCleanUpLayoutPreferences.swift
//  PsyScopeEditor
//
//  Created by James on 10/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSCleanUpLayoutPreferences  : NSViewController, MASPreferencesViewController {

    override var identifier : String? { get { return "LayoutPreferences" } set { } }
    var toolbarItemImage : NSImage { get { return NSImage(named: NSImageNamePreferencesGeneral)! } }
    var toolbarItemLabel : String! { get { return "General" } }

}