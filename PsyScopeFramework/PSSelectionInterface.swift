//
//  PSSelectionInterface.swift
//  PsyScopeEditor
//
//  Created by James on 17/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public protocol PSSelectionInterface {
    
    //main way to notify of selected entry
    func selectEntry(entry: Entry?)
    
    //for double click action
    func doubleClickEntry(entry: Entry)
    
    //main way to delete an object and alert everyone of that fact
    func deleteObject(layoutObject: LayoutObject)
    
    //main way to delete an object and suggest an alternative selection
    func deleteObject(layoutObject: LayoutObject, andSelect newSelection: Entry?)
    
    //returns the currently selected entry
    func getSelectedEntry() -> Entry?
    
    //returns the latest 'vary by' menu (without actions/targets added)
    func varyByMenu() -> NSMenu
    
    //returns eventactions attribute (used by several controls)
    func getEventActionsAttribute() -> PSEventActionsAttribute?
    
    //returns view meta data for event actions (used by same controls as eventActionsAttribute)
    func getActionConditionViewMetaData() -> [PSActionBuilderViewMetaDataSet]?
    
    //triggers a refresh
    func refresh()
}