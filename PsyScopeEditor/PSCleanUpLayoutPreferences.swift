//
//  PSCleanUpLayoutPreferences.swift
//  PsyScopeEditor
//
//  Created by James on 10/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSCleanUpLayoutPreferences  : NSViewController, MASPreferencesViewController {


    override var identifier : NSUserInterfaceItemIdentifier? { get { return NSUserInterfaceItemIdentifier(rawValue: "LayoutPreferences") } set { } }
    var toolbarItemImage : NSImage { get { return NSImage(named: NSImage.preferencesGeneralName)! } }
    var toolbarItemLabel : String! { get { return "General" } }

}
