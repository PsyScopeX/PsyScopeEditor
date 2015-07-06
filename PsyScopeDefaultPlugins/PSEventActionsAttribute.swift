//
//  PSEventActionsAttribute.swift
//  PsyScopeEditor
//
//  Created by James on 13/11/2014.
//  Copyright (c) 2014 James. All rights reserved.
//

import Foundation

class PSEventActionsAttribute : PSEntryContent {
    var actionConditionSets : [([PSEventCondition],[PSEventAction])] = []
    var scriptData : PSScriptData
    var eventEntry : Entry
    
    

    init(event_entry: Entry, scriptData : PSScriptData) {
        self.eventEntry = event_entry
        self.scriptData = scriptData
        super.init()
    }
    
    func parseEvent() {
        //now do eventActions parameter
        if let ea = scriptData.getSubEntry("EventActions", entry: eventEntry) {
            self.stringValue = ea.currentValue
        }
    }
    
    func newActionConditionSet() {
        actionConditionSets.append([],[])
    }
    
    func removeActionConditionSet(row : Int) {
        if row >= 0 && row < actionConditionSets.count {
            actionConditionSets.removeAtIndex(row)
        }
    }
    
    //returns index of actionCondition so can refresh it
    func removeActionCondition(actionCondition : PSEventActionCondition) -> Int? {
        for (index,ac) in enumerate(actionConditionSets) {
            for (index2,a) in enumerate(ac.1) {
                if a == actionCondition {
                    actionConditionSets[index].1.removeAtIndex(index2)
                    return index
                }
            }
            for (index2,a) in enumerate(ac.0) {
                if a == actionCondition {
                    actionConditionSets[index].0.removeAtIndex(index2)
                    return index
                }
            }
        }
        return nil
    }
    
    func appendAction(row : Int, action : PSActionInterface) {
        actionConditionSets[row].1.append(PSEventAction(action: action))
    }
    
    func appendCondition(row : Int, condition : PSActionInterface) {
        actionConditionSets[row].0.append(PSEventCondition(condition: condition))
        
    }
    
    
    override var stringValue : String! {
        
        get{
            var return_string : String = ""
            
            for (conditions, actions) in actionConditionSets {
                return_string += "Conditions[ "
                for condition in conditions {
                    return_string += condition.stringValue
                    return_string += " "
                }
                return_string += "] => Actions[ "
                for action in actions {
                    return_string += action.stringValue
                    return_string += " "
                }
                return_string += "] "
            }
            return return_string
        }
        
        set {
            actionConditionSets = [] //erase previous...
            let actionPlugins = scriptData.pluginProvider.actionPlugins as [String : PSActionInterface]
            let conditionPlugins = scriptData.pluginProvider.conditionPlugins as [String : PSActionInterface]
            super.stringValue = newValue;
            
            if newValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" {
                return //do not process if empty
            }
            
            var populatingActions = false
            var populatingConditions = true
            
            //this should consists of conditions entries followed by => followed by actions
            //normally script will have conditions[] => actions[] but sometimes it will just have x[] => y[]
            //if there are empty conditions[] => actions[], then these still must be represented
            //TODO: Currently if an action is not found, it will just be ignored/deleted
            
            //set up initial array to take the actions/conditions
            var action_condition_count : Int = 0
            actionConditionSets.append([],[])
            
            
            for object in values {
                if let function = object as? PSEntryFunction {
                    if function.functionName == "Conditions" {
                        if populatingActions {
                            //end of action condition pair so add new set
                            actionConditionSets.append([],[])
                            action_condition_count++
                        }
                        
                        populatingConditions = true
                        populatingActions = false
                        
                        //iterate through all these to get the PSEventActions
                        for v in function.values {
                            if let condition = v as? PSEntryFunction {
                                for (name, plugin) in conditionPlugins {
                                    if plugin.type() == condition.functionName {
                                        //match condition
                                        var new_condition = PSEventCondition(condition: plugin)
                                        new_condition.values = condition.values
                                        actionConditionSets[action_condition_count].0.append(new_condition)
                                        break
                                    }
                                }
                                
                            }
                        }
                        
                    } else if function.functionName == "Actions" {
                        
                        populatingActions = true
                        populatingConditions = false
                        
                        //iterate through all these to get the PSEventActions
                        for v in function.values {
                            if let action = v as? PSEntryFunction {
                                for (name, plugin) in actionPlugins {
                                    if plugin.type() == action.functionName {
                                        //match
                                        var new_action = PSEventAction(action: plugin)
                                        new_action.values = action.values
                                        actionConditionSets[action_condition_count].1.append(new_action)
                                        break
                                    }
                                }
                                
                            }
                        }
                        
                        
                    } else if populatingActions {
                        //we are populating actions, so function should be an action
                        for (name, plugin) in actionPlugins {
                            if plugin.type() == function.functionName {
                                //match
                                var new_action = PSEventAction(action: plugin)
                                new_action.values = function.values
                                actionConditionSets[action_condition_count].1.append(new_action)
                                break
                            }
                        }
                        
                    } else if populatingConditions {
                        //we are populating conditions, so function should be an condition
                        for (name, plugin) in conditionPlugins {
                            if plugin.type() == function.functionName {
                                //match
                                var new_condition = PSEventCondition(condition: plugin)
                                new_condition.values = function.values
                                actionConditionSets[action_condition_count].0.append(new_condition)
                                break
                            }
                        }
                        
                    }
                } else if let s = object as? NSString {
                    if s == "=>" {
                        //switch from population conditions to actions
                        populatingActions = false
                        populatingConditions = true
                    }
                }
            }
        }
        
    }
}


class PSEventActionCondition : PSEntryFunction {
    func edit(scriptData : PSScriptData) {
        fatalError("Use of virtual edit function on PSEventActionCondition")
    }
}

class PSEventAction : PSEventActionCondition {
    var action : PSActionInterface
    init(action : PSActionInterface) {
        self.action = action
        super.init()
        self.functionName = action.type()
    }
    override func edit(scriptData : PSScriptData) {
        action.editAction(self, scriptData: scriptData)
    }
    
    
}

class PSEventCondition : PSEventActionCondition {
    var condition : PSActionInterface
    init(condition : PSActionInterface) {
        self.condition = condition
        super.init()
        self.functionName = condition.type()
    }
    override func edit(scriptData : PSScriptData) {
        condition.editAction(self, scriptData: scriptData)
    }
}