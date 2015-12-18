//
//  PSWindowViewInterface.swift
//  PsyScopeEditor
//
//  Created by James on 17/12/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

public protocol PSWindowViewInterface {

//before accessing any of the items, make sure to set up by passing scriptData
//and allow to pass messages to selection controller with interface
    func setup(scriptData : PSScriptData, selectionInterface : PSSelectionInterface)

//return a tool bar item for the item
    func icon() -> NSImage

//return a tool bar item for the item
    func identifier() -> String

//returns a new view for the central panel
    func midPanelTab() -> NSView

//returns a view for the left panel item (optional)
    func leftPanelTab() -> NSView?

//returns name for the type
    func type() -> String

//called when an object is deleted
    func entryDeleted(entry : Entry)

//called to refresh with selected object
    func refresh()

}