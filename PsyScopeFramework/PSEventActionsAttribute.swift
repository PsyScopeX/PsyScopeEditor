//
//  PSEventActionsAttribute.swift
//  PsyScopeEditor
//
//  PSEntryContent subclass that deals with the EventActions parameter for all objects

import Foundation


public class PSEventActionsAttribute : PSStringListElement {
    public var actionConditionSets : [(conditions: [PSEventConditionFunction], actions: [PSEventActionFunction])] = []
    public let scriptData : PSScriptData
    public let eventEntry : Entry
    public let attributeName : String
    let actionPlugins : [String : PSActionInterface]
    let conditionPlugins : [String : PSConditionInterface]
    var errors : [PSScriptError]
    
    public init(event_entry: Entry, scriptData : PSScriptData, attributeName : String) {
        self.eventEntry = event_entry
        self.scriptData = scriptData
        self.attributeName = attributeName
        actionPlugins = scriptData.pluginProvider.actionPlugins as [String : PSActionInterface]
        conditionPlugins = scriptData.pluginProvider.conditionPlugins as [String : PSConditionInterface]
        
        
        self.errors = []
        super.init()
        parseAttributeEntry()
    }
    
    public func parseAttributeEntry() {
        if let ea = scriptData.getSubEntry(attributeName, entry: eventEntry) {
            self.stringValue = ea.currentValue
            loadMetaData(ea.metaData)
        } else {
            self.stringValue = ""
            loadMetaData("")
        }
    }
    
    public func updateAttributeEntry() {
        scriptData.beginUndoGrouping("Edit Action / Condition")
        if actionConditionSets.count > 0 {
            let actionsEntry = scriptData.getOrCreateSubEntry(attributeName, entry: eventEntry, isProperty: true)
            actionsEntry.currentValue = self.stringValue

        } else {
            //delete if nothing there
            scriptData.deleteNamedSubEntryFromParentEntry(eventEntry, name: attributeName)
        }
        scriptData.endUndoGrouping(true)
    }
    
    
    
    public func newActionConditionSet() {
        actionConditionSets.append((conditions: [],actions: []))
        //dont update entry yet

    }
    
    public func removeActionConditionSet(row : Int) {
        if row >= 0 && row < actionConditionSets.count {
            actionConditionSets.removeAtIndex(row)
        }
        updateAttributeEntry()
    }
    
    //returns index of actionCondition so can refresh it
    public func removeActionCondition(actionCondition : PSEventActionCondition) -> Int? {
        for (index,ac) in actionConditionSets.enumerate() {
            for (index2,a) in ac.actions.enumerate() {
                if a == actionCondition {
                    actionConditionSets[index].actions.removeAtIndex(index2)
                    updateAttributeEntry()
                    return index
                }
            }
            for (index2,a) in ac.conditions.enumerate() {
                if a == actionCondition {
                    actionConditionSets[index].conditions.removeAtIndex(index2)
                    updateAttributeEntry()
                    return index
                }
            }
        }
        return nil
    }
    
    public func appendAction(row : Int, action : PSActionInterface) {
        actionConditionSets[row].actions.append(PSEventActionFunction(action: action, values: []))
        setItemExpanded(row, itemIndex: actionConditionSets[row].actions.count - 1, action: true, expanded: true)
        updateAttributeEntry()
    }
    
    public func appendCondition(row : Int, condition : PSConditionInterface) {
        actionConditionSets[row].conditions.append(PSEventConditionFunction(condition: condition, values: []))
        setItemExpanded(row, itemIndex: actionConditionSets[row].conditions.count - 1, action: false, expanded: true)
        updateAttributeEntry()
    }
    
    public func removeCondition(row : Int, condition : PSConditionInterface) {
        if let index = lazy(actionConditionSets[row].conditions).map({ return $0.functionName }).indexOf(condition.type()) {
            actionConditionSets[row].conditions.removeAtIndex(index)
            updateAttributeEntry()
        }
    }
    
    
    override public var stringValue : String {
        
        get{
            var return_string : String = ""
            
            for (conditions, actions) in actionConditionSets {
                
                if (conditions.count + actions.count) > 0 {
                
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
            }
            return return_string
        }
        
        set {
            //erase previous sets
            actionConditionSets = []
            
            //trigger full parse of value
            super.stringValue = newValue;
            
            //process all functions in the values
            for val in values {
                if case .Function(let functionElement) = val
                    where functionElement.functionName == ""
                    && functionElement.bracketType == .Expression {
                        addActionsFromValues(functionElement.values)
                }
            }
        }
    }
    
    func addActionsFromValues(givenValues : [PSEntryElement]) {
        
        var populatingActions = false
        var populatingConditions = true
        
        //this should consists of conditions entries followed by => followed by actions
        //normally script will have conditions[] => actions[] but sometimes it will just have x[] => y[]
        //if there are empty conditions[] => actions[], then these still must be represented
        //TODO: Currently if an action is not found, it will just be ignored/deleted

        //set up initial array to take the actions/conditions
        var action_condition_count : Int = actionConditionSets.count
        actionConditionSets.append((conditions: [],actions: []))
        

        
        for object in givenValues {
            switch(object) {
                
            case .Function(let function):
                if function.functionName == "Conditions" {
                    if populatingActions {
                        //end of action condition pair so add new set
                        actionConditionSets.append((conditions: [],actions: []))
                        action_condition_count++
                    }
                    
                    populatingConditions = true
                    populatingActions = false
                    
                    //iterate through all these to get the PSEventActionFunctions
                    for v in function.values {
                        
                        var found_condition = false
                        
                        switch(v) {
                        case .Function(let condition):
                            found_condition = addCondition(condition, set: action_condition_count)
                        default:
                            break
                        }
                        
                        if (!found_condition) {
                            errors.append(PSScriptErrorEventActionsParsingError(elementToString(v, stripped: false), entryName: eventEntry.name))
                        }
                    }
                    
                } else if function.functionName == "Actions" {
                    
                    populatingActions = true
                    populatingConditions = false
                    
                    //iterate through all these to get the PSEventActionFunctions
                    for v in function.values {
                        
                        
                        var found_action = false
                        
                        switch(v) {
                        case .Function(let action):
                            found_action = addAction(action, set: action_condition_count)
                            
                        default:
                            break
                        }
                        
                        if (!found_action) {
                            errors.append(PSScriptErrorEventActionsParsingError(elementToString(v, stripped: false), entryName: eventEntry.name))
                        }
                        
                        
                        
                    }
                    
                    
                } else if populatingActions {
                    //we are populating actions, so function should be an action
                    if !addAction(function, set: action_condition_count) {
                        errors.append(PSScriptErrorEventActionsParsingError(function.stringValue, entryName: eventEntry.name))
                    }
                    
                } else if populatingConditions {
                    //we are populating conditions, so function should be an condition
                    if !addCondition(function, set: action_condition_count) {
                        errors.append(PSScriptErrorEventActionsParsingError(function.stringValue, entryName: eventEntry.name))
                    }
                    
                }
                break
            case .StringToken(let s):
                if s.value == "=>" {
                    //switch from population conditions to actions
                    populatingActions = false
                    populatingConditions = true
                } else {
                    //error
                    errors.append(PSScriptErrorEventActionsParsingError(s.value, entryName: eventEntry.name))
                }
                
            case .List(let list):
                //error
                errors.append(PSScriptErrorEventActionsParsingError(list.stringValue, entryName: eventEntry.name))
                break
            case .Null:
                //error
                errors.append(PSScriptErrorEventActionsParsingError("NULL", entryName: eventEntry.name))
                break
            }
        }
    }
    
    func addAction(action : PSFunctionElement, set : Int) -> Bool {
        
        guard let plugin = actionPlugins[action.functionName] else {
            return false
        }
        let new_action = PSEventActionFunction(action: plugin, values: action.values)
        actionConditionSets[set].actions.append(new_action)
        return true
    }
    
    func addCondition(condition : PSFunctionElement, set : Int) -> Bool {
        
        guard let plugin = conditionPlugins[condition.functionName] else {
            return false
        }
        
        let new_condition = PSEventConditionFunction(condition: plugin, values: condition.values)
        actionConditionSets[set].conditions.append(new_condition)
        return true
    }
    
    
    public func setItemExpanded(setIndex : Int, itemIndex : Int, action : Bool, expanded : Bool) {
 
        var name : String
        var a : String
        if action {
            name  = actionConditionSets[setIndex].actions[itemIndex].functionName
            a = "1,"
        } else {
            name  = actionConditionSets[setIndex].conditions[itemIndex].functionName
            a = "0,"
        }
        
        let code = "\(setIndex),\(itemIndex)," + a + name
        expandedItems[code] = expanded
        
        if actionConditionSets.count > 0 {
            let actionsEntry = scriptData.getOrCreateSubEntry(attributeName, entry: eventEntry, isProperty: true)
            actionsEntry.metaData = metaDataToString()
        }
    }
    
    func loadMetaData(metaData : String?) {

        if let md = metaData, data = md.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
            do {
                if let ei = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary {
                    expandedItems = ei as! [String : Bool]
                    validateExpandedItems()
                } else {
                    expandedItems = [:]
                }
            } catch {
                expandedItems = [:]
            }
        } else {
            expandedItems = [:]
        }
    }
    
    func metaDataToString() -> String {

        var data: NSData?
        do {
            data = try NSJSONSerialization.dataWithJSONObject(expandedItems, options:NSJSONWritingOptions(rawValue: 0))
            return String(NSString(data: data!, encoding: NSUTF8StringEncoding)!)
        } catch {
            data = nil
            return ""
        }
        
    }
    
    func validateExpandedItems() {
        let codes = expandedItems.keys
        for code in codes {
            var  ok = false
            var comps = code.componentsSeparatedByString(",")
            let setIndex = Int(comps[0])!
            if setIndex < actionConditionSets.count {
                let itemIndex = Int(comps[1])!
                if comps[2] == "1" {
                    //action
                    if itemIndex < actionConditionSets[setIndex].actions.count {
                        if actionConditionSets[setIndex].actions[itemIndex].functionName == comps[3] {
                            ok = true
                        }
                    }
                } else {
                    //condition
                    if itemIndex < actionConditionSets[setIndex].conditions.count {
                        if actionConditionSets[setIndex].conditions[itemIndex].functionName == comps[3] {
                            ok = true
                        }
                    }
                }
            }
            if (!ok) {
                expandedItems[code] = nil
            }
            
        }
    }

    var expandedItems : [String:Bool] = [:]
    
    public func itemIsExpanded(setIndex : Int, itemIndex : Int, action : Bool) -> Bool {
        
        if setIndex >= actionConditionSets.count {
            return false
        }
        
        var name : String
        var a : String
        if action {
            if itemIndex >= actionConditionSets[setIndex].actions.count { return false }
            name  = actionConditionSets[setIndex].actions[itemIndex].functionName
            a = "1,"
        } else {
            if itemIndex >= actionConditionSets[setIndex].conditions.count { return false }
            name  = actionConditionSets[setIndex].conditions[itemIndex].functionName
            a = "0,"
        }
        
        let code = "\(setIndex),\(itemIndex)," + a + name
        if let e = expandedItems[code] {
            return e
        } else {
            return false
        }
    }
}





func PSScriptErrorEventActionsParsingError(unknownToken : String, entryName : String) -> PSScriptError {
    return PSScriptError(errorDescription: "Could not parse actions parameter in entry: \(entryName)", detailedDescription: "Unknown function / character / token found: \(unknownToken)", solution: "Remove said token", range: NSMakeRange(0,0))
}