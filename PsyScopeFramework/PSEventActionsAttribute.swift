//
//  PSEventActionsAttribute.swift
//  PsyScopeEditor
//
//  PSEntryContent subclass that deals with the EventActions parameter for all objects

import Foundation


open class PSEventActionsAttribute : PSStringListElement {
    open var actionConditionSets : [(conditions: [PSEventConditionFunction], actions: [PSEventActionFunction])] = []
    
    open let scriptData : PSScriptData
    open let eventEntry : Entry
    open let attributeName : String
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
    
    open func parseAttributeEntry() {
        if let ea = scriptData.getSubEntry(attributeName, entry: eventEntry) {
            self.stringValue = ea.currentValue
            loadMetaData(ea.metaData)
        } else {
            self.stringValue = ""
            loadMetaData("")
        }
    }
    
    open func updateAttributeEntry() {
        scriptData.beginUndoGrouping("Edit Action / Condition")
        if actionConditionSets.count > 0 {
            let actionsEntry = scriptData.getOrCreateSubEntry(attributeName, entry: eventEntry, isProperty: true)
            actionsEntry.currentValue = self.stringValue

        } else {
            //delete if nothing there
            scriptData.deleteNamedSubEntryFromParentEntry(eventEntry, name: attributeName)
        }
        saveMetaData()
        scriptData.endUndoGrouping(true)
    }
    
    
    
    open func newActionConditionSet() {
        actionConditionSets.append((conditions: [],actions: []))
        //dont update entry yet

    }
    
    open func removeActionConditionSet(_ row : Int) {
        if row >= 0 && row < actionConditionSets.count {
            actionConditionSets.remove(at: row)
        }
        updateAttributeEntry()
    }
    
    //returns index of actionCondition so can refresh it
    open func removeActionCondition(_ actionCondition : PSEventActionCondition) -> Int? {
        for (index,ac) in actionConditionSets.enumerated() {
            for (index2,a) in ac.actions.enumerated() {
                if a == actionCondition {
                    actionConditionSets[index].actions.remove(at: index2)
                    updateAttributeEntry()
                    return index
                }
            }
            for (index2,a) in ac.conditions.enumerated() {
                if a == actionCondition {
                    actionConditionSets[index].conditions.remove(at: index2)
                    updateAttributeEntry()
                    return index
                }
            }
        }
        return nil
    }
    
    
    open func getIndexesForActionCondition(_ actionCondition : PSEventActionCondition) -> (index1 : Int, index2 : Int, action : Bool)? {
        for (index,ac) in actionConditionSets.enumerated() {
            for (index2,a) in ac.actions.enumerated() {
                if a == actionCondition {
                    return (index,index2, true)
                }
            }
            for (index2,a) in ac.conditions.enumerated() {
                if a == actionCondition {
                    return (index,index2, false)
                }
            }
        }
        return nil
    }
    
    open func moveActionConditionUp(_ actionCondition : PSEventActionCondition) -> Int {
        if let (index1, index2, isAction) = getIndexesForActionCondition(actionCondition) {
            if isAction {
                if index2 > 0 {
                    let action = actionConditionSets[index1].actions[index2]
                    scriptData.beginUndoGrouping("Move Action")
                    actionConditionSets[index1].actions.remove(at: index2)
                    actionConditionSets[index1].actions.insert(action, at: index2-1)
                    updateAttributeEntry()
                    scriptData.endUndoGrouping()
                    return index2 - 1
                }
                
            }else {
                if index2 > 0 {
                    let action = actionConditionSets[index1].conditions[index2]
                    scriptData.beginUndoGrouping("Move Condition")
                    actionConditionSets[index1].conditions.remove(at: index2)
                    actionConditionSets[index1].conditions.insert(action, at: index2-1)
                    updateAttributeEntry()
                    scriptData.endUndoGrouping()
                    return index2 - 1
                }
            }
            return index2
        }
        return -1
    }
    
    open func moveActionConditionDown(_ actionCondition : PSEventActionCondition) -> Int {
        if let (index1, index2, isAction) = getIndexesForActionCondition(actionCondition) {
            if isAction {
                if index2 < actionConditionSets[index1].actions.count - 1 {
                    let action = actionConditionSets[index1].actions[index2]
                    scriptData.beginUndoGrouping("Move Action")
                    actionConditionSets[index1].actions.remove(at: index2)
                    actionConditionSets[index1].actions.insert(action, at: index2+1)
                    updateAttributeEntry()
                    scriptData.endUndoGrouping()
                    return index2 + 1
                }
                
            } else {
                if index2 < actionConditionSets[index1].conditions.count - 1 {
                    let action = actionConditionSets[index1].conditions[index2]
                    scriptData.beginUndoGrouping("Move Condition")
                    actionConditionSets[index1].conditions.remove(at: index2)
                    actionConditionSets[index1].conditions.insert(action, at: index2+1)
                    updateAttributeEntry()
                    scriptData.endUndoGrouping()
                    return index2 + 1
                }
            }
            return index2
        }
        return -1
    }
    
    open func moveSetUp(_ actionCondition : PSEventActionCondition?) {
        guard let actionCondition = actionCondition else { return }
        if let (index1, _, _) = getIndexesForActionCondition(actionCondition),
            index1 > 0 {
            scriptData.beginUndoGrouping("Move Action Set")
            let set = actionConditionSets[index1]
            actionConditionSets.remove(at: index1)
            actionConditionSets.insert(set, at: index1 - 1)
            updateAttributeEntry()
            scriptData.endUndoGrouping()
        }
    }
    
    open func moveSetDown(_ actionCondition : PSEventActionCondition?) {
        guard let actionCondition = actionCondition else { return }
        if let (index1, _, _) = getIndexesForActionCondition(actionCondition),
            index1 < actionConditionSets.count - 1 {
                scriptData.beginUndoGrouping("Move Action Set")
                let set = actionConditionSets[index1]
                actionConditionSets.remove(at: index1)
                actionConditionSets.insert(set, at: index1 + 1)
                updateAttributeEntry()
                scriptData.endUndoGrouping()
        }
    }
    
    open func appendAction(_ row : Int, action : PSActionInterface) {
        actionConditionSets[row].actions.append(PSEventActionFunction(action: action, values: []))
        setItemExpanded(row, itemIndex: actionConditionSets[row].actions.count - 1, action: true, expanded: true)
        updateAttributeEntry()
    }
    
    open func appendCondition(_ row : Int, condition : PSConditionInterface) {
        actionConditionSets[row].conditions.append(PSEventConditionFunction(condition: condition, values: []))
        setItemExpanded(row, itemIndex: actionConditionSets[row].conditions.count - 1, action: false, expanded: true)
        updateAttributeEntry()
    }
    
    open func removeCondition(_ row : Int, condition : PSConditionInterface) {
        if let index = actionConditionSets[row].conditions.lazy.map({ return $0.functionName }).index(of: condition.type()) {
            actionConditionSets[row].conditions.remove(at: index)
            updateAttributeEntry()
        }
    }
    
    
    override open var stringValue : String {
        
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
                if case .function(let functionElement) = val, functionElement.functionName == ""
                    && functionElement.bracketType == .expression {
                        addActionsFromValues(functionElement.values)
                }
            }
        }
    }
    
    func addActionsFromValues(_ givenValues : [PSEntryElement]) {
        
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
                
            case .function(let function):
                if function.functionName == "Conditions" {
                    if populatingActions {
                        //end of action condition pair so add new set
                        actionConditionSets.append((conditions: [],actions: []))
                        action_condition_count += 1
                    }
                    
                    populatingConditions = true
                    populatingActions = false
                    
                    //iterate through all these to get the PSEventActionFunctions
                    for v in function.values {
                        
                        var found_condition = false
                        
                        switch(v) {
                        case .function(let condition):
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
                        case .function(let action):
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
            case .stringToken(let s):
                if s.value == "=>" {
                    //switch from population conditions to actions
                    populatingActions = false
                    populatingConditions = true
                } else {
                    //error
                    errors.append(PSScriptErrorEventActionsParsingError(s.value, entryName: eventEntry.name))
                }
                
            case .list(let list):
                //error
                errors.append(PSScriptErrorEventActionsParsingError(list.stringValue, entryName: eventEntry.name))
                break
            case .null:
                //error
                errors.append(PSScriptErrorEventActionsParsingError("NULL", entryName: eventEntry.name))
                break
            }
        }
    }
    
    func addAction(_ action : PSFunctionElement, set : Int) -> Bool {
        
        guard let plugin = actionPlugins[action.functionName] else {
            return false
        }
        let new_action = PSEventActionFunction(action: plugin, values: action.values)
        actionConditionSets[set].actions.append(new_action)
        return true
    }
    
    func addCondition(_ condition : PSFunctionElement, set : Int) -> Bool {
        
        guard let plugin = conditionPlugins[condition.functionName] else {
            return false
        }
        
        let new_condition = PSEventConditionFunction(condition: plugin, values: condition.values)
        actionConditionSets[set].conditions.append(new_condition)
        return true
    }
    
    open func userSetItemExpanded(_ setIndex : Int, itemIndex : Int, action : Bool, expanded : Bool) {
        setItemExpanded(setIndex, itemIndex: itemIndex, action: action, expanded: expanded)
        saveMetaData()
        
    }
    
    fileprivate func saveMetaData() {
        let actionsEntry = scriptData.getOrCreateSubEntry(attributeName, entry: eventEntry, isProperty: true)
        actionsEntry.metaData = metaDataToString()
    }
    
    fileprivate func setItemExpanded(_ setIndex : Int, itemIndex : Int, action : Bool, expanded : Bool) {
 
        if action {
            if setIndex < actionConditionSets.count &&  itemIndex < actionConditionSets[setIndex].actions.count {
                actionConditionSets[setIndex].actions[itemIndex].expanded = expanded
            }
        } else {
            if setIndex < actionConditionSets.count &&  itemIndex < actionConditionSets[setIndex].conditions.count {
                actionConditionSets[setIndex].conditions[itemIndex].expanded = expanded
            }
        }

    }
    
    func loadMetaData(_ metaData : String?) {

        if let md = metaData, let data = md.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            do {
                if let ei = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? NSArray,
                let expandedMetaData = ei as? [String] {

                    parseExpandedItemsMetaData(expandedMetaData)
                }
            } catch {
              
            }
        }
    }
    
    func metaDataToString() -> String {
        var savedExpandedMetaData : [String] = []
        for (index,set) in actionConditionSets.enumerated() {
            for (index2, action) in set.actions.enumerated() {
                if action.expanded {
                    savedExpandedMetaData.append(expandedCodeFor(index,itemIndex: index2,action: true)!)
                }
            }
            
            for (index2, condition) in set.conditions.enumerated() {
                if condition.expanded {
                    savedExpandedMetaData.append(expandedCodeFor(index,itemIndex: index2,action: false)!)
                }
            }
        }
        

        do {
            let data = try JSONSerialization.data(withJSONObject: savedExpandedMetaData, options:JSONSerialization.WritingOptions(rawValue: 0))
            return String(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
        } catch {
            return ""
        }
        
    }
    
    func parseExpandedItemsMetaData(_ savedExpandedMetaData : [String]) {
        for metaData in savedExpandedMetaData {
            let (index1, index2, isAction) = indexesForCode(metaData)
            setItemExpanded(index1,itemIndex: index2,action: isAction,expanded: true)
        }
    }

    open func itemIsExpanded(_ setIndex : Int, itemIndex : Int, action : Bool) -> Bool {
        
        if action {
            if setIndex < actionConditionSets.count &&  itemIndex < actionConditionSets[setIndex].actions.count {
                return actionConditionSets[setIndex].actions[itemIndex].expanded
            }
        } else {
            if setIndex < actionConditionSets.count &&  itemIndex < actionConditionSets[setIndex].conditions.count {
                return actionConditionSets[setIndex].conditions[itemIndex].expanded
            }
        }
        return false
    }
    
    open func expandedCodeFor(_ setIndex : Int, itemIndex : Int, action : Bool) -> String? {
        return "\(setIndex),\(itemIndex)," + (action ? "1" : "0")
    }
    
    open func indexesForCode(_ code : String) -> (setIndex : Int, itemIndex : Int, action : Bool) {
        let components = code.components(separatedBy: ",")
        return (Int(components[0])!,Int(components[1])!,components[2] == "1")
    }
}





func PSScriptErrorEventActionsParsingError(_ unknownToken : String, entryName : String) -> PSScriptError {
    return PSScriptError(errorDescription: "Could not parse actions parameter in entry: \(entryName)", detailedDescription: "Unknown function / character / token found: \(unknownToken)", solution: "Remove said token", entryName: entryName, searchString: unknownToken)
}
