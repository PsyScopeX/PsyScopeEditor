//
//  PSConditionAttribute.swift
//  PsyScopeEditor
//
//  Created by James on 15/12/2014.
//

import Foundation
//holds a the value of an attribute holding condition functions in
//'conditions' an array holding PSEventConditionFunction
public class PSConditionAttribute : PSStringListElement {
    var conditions : [PSEventConditionFunction] = []
    var scriptData : PSScriptData
    var conditionEntry : Entry
    
    init(condition_entry: Entry, scriptData : PSScriptData) {
        self.conditionEntry = condition_entry
        self.scriptData = scriptData
        super.init()
    }
    
    func parseFromEntry() {
        
        self.stringValue = conditionEntry.currentValue
        loadMetaData(conditionEntry.metaData)
    }

    func updateEntry() {
        scriptData.beginUndoGrouping("Update Condition Attribute")
        conditionEntry.currentValue = self.stringValue
        scriptData.endUndoGrouping(true)
    }
    
    func removeCondition(_ condition : PSConditionInterface) {
        let name = condition.type()
        if let index = conditions.lazy.map({ $0.functionName }).index(of: name) {
            removeConditionAtIndex(index)
        }
    }
    
    func removeConditionAtIndex(_ index : Int) {
        conditions.remove(at: index)
        updateEntry()
    }
    
    func appendCondition(_ condition : PSConditionInterface) {
        conditions.append(PSEventConditionFunction(condition: condition, values: []))
        setItemExpanded(conditions.count - 1, expanded: true)
        updateEntry()
    }
    
    
    override public var stringValue : String {

        get{
            self.values = self.conditions.map({ PSEntryElement.function(functionElement: $0) } )
            return super.stringValue
        }
        
        set {
            conditions = [] //erase previous...
            let conditionPlugins = scriptData.pluginProvider.conditionPlugins as [String : PSConditionInterface]
            super.stringValue = newValue;
            
            for object in values {
                
                switch(object) {
                case .function(let functionElement):
                    for (_, plugin) in conditionPlugins {
                        if plugin.type() == functionElement.functionName {
                            //match
                            let new_condition = PSEventConditionFunction(condition: plugin, values: [])
                            new_condition.values = functionElement.values
                            conditions.append(new_condition)
                            break
                        }
                    }
                default:
                    break
                }
            }
        }
    }
    
    
    public func setItemExpanded(_ itemIndex : Int, expanded : Bool) {
        let name : String = conditions[itemIndex].functionName
        let code = "\(itemIndex)," + name
        expandedItems[code] = expanded
        conditionEntry.metaData = metaDataToString()
    }
    
    func loadMetaData(_ metaData : String?) {
        if let md = metaData, let data = md.data(using: String.Encoding.utf8, allowLossyConversion: true) {
            do {
                if let ei = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? NSDictionary {
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
        var data: Data?
        do {
            data = try JSONSerialization.data(withJSONObject: expandedItems, options:JSONSerialization.WritingOptions(rawValue: 0))
        } catch  {
            data = nil
        }
        return String(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
    }
    
    func validateExpandedItems() {
        let codes = expandedItems.keys
        for code in codes {
            var  ok = false
            var comps = code.components(separatedBy: ",")
            let itemIndex = Int(comps[0])!
            if itemIndex < conditions.count {
                if conditions[itemIndex].functionName == comps[1] {
                    ok = true
                }
            }
            if (!ok) {
                expandedItems[code] = nil
            }
            
        }
    }
    
    var expandedItems : [String:Bool] = [:]
    
    public func itemIsExpanded(_ itemIndex : Int) -> Bool {
        let name : String = conditions[itemIndex].functionName
        let code = "\(itemIndex)," + name
        if let e = expandedItems[code] {
            return e
        } else {
            return false
        }
    }
    
}
