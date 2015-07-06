//
//  PSActionConditionViewMetaData.swift
//  PsyScopeEditor
//
//  Created by James on 27/06/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

public struct PSActionBuilderViewMetaData {
    public let expandedCellHeight : CGFloat
    public let expanded : Bool
}

public struct PSActionBuilderViewMetaDataSet {
    public var actions : [PSActionBuilderViewMetaData] = []
    public var conditions : [PSActionBuilderViewMetaData] = []
    public var actionsHeight : CGFloat = 0
    public var conditionsHeight : CGFloat = 0
}

public let PSEmptyActionBuilderViewMetaDataSet = PSActionBuilderViewMetaDataSet(actions: [], conditions: [], actionsHeight: PSActionsButtonHeight, conditionsHeight: PSConditionsButtonHeight)

public let PSConditionsButtonHeight : CGFloat = CGFloat(30)
public let PSActionsButtonHeight : CGFloat = CGFloat(30)
public let PSCollapsedViewHeight : CGFloat = CGFloat(30)

//since numerous things need this data, we collect it all at the start of a refresh
public func PSActionConditionViewMetaData(actionsAttribute : PSEventActionsAttribute) -> [PSActionBuilderViewMetaDataSet] {
    
    var displayViewMetaData : [PSActionBuilderViewMetaDataSet] = []
    
    
    
    
    var actionsHeight = PSActionsButtonHeight
    var conditionsHeight = PSConditionsButtonHeight
    
    for (setNumber, set) in actionsAttribute.actionConditionSets.enumerate() {
        
        //each set has data for both actions and conditions
        var newSet : PSActionBuilderViewMetaDataSet = PSActionBuilderViewMetaDataSet()
        
        for (row, action) in set.actions.enumerate() {
            
            //to store if the cell is currently expanded or not
            let currentlyExpanded = actionsAttribute.itemIsExpanded(setNumber, itemIndex: row, action: true)
            
            //the action interface knows how high it is (without )
            var expandedCellHeight = action.action.expandedCellHeight()
            
            //if action function has instances or attributes increase hieght to allow for these
            if currentlyExpanded &&  action.hasInstancesOrActiveUntilValueAttributes { expandedCellHeight += 60 }
            
            //put these together and store
            let newViewMetaData : PSActionBuilderViewMetaData = PSActionBuilderViewMetaData(expandedCellHeight: CGFloat(expandedCellHeight), expanded: currentlyExpanded)
            newSet.actions.append(newViewMetaData)
            actionsHeight += CGFloat(2 + (currentlyExpanded ? expandedCellHeight : PSCollapsedViewHeight))
        }
        
        for (row,condition) in set.conditions.enumerate() {
            let currentlyExpanded = actionsAttribute.itemIsExpanded(setNumber, itemIndex: row, action: false)
            let expandedCellHeight = condition.condition.expandedCellHeight()
            let newViewMetaData : PSActionBuilderViewMetaData = PSActionBuilderViewMetaData(expandedCellHeight: expandedCellHeight, expanded: currentlyExpanded)
            newSet.conditions.append(newViewMetaData)
            conditionsHeight += CGFloat(2 + (currentlyExpanded ? expandedCellHeight : PSCollapsedViewHeight))
        }
        

        newSet.actionsHeight = actionsHeight
        newSet.conditionsHeight = conditionsHeight
      
        
        displayViewMetaData.append(newSet)
    }
    return displayViewMetaData
}