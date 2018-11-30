//
//  PSEventAction.swift
//  PsyScopeEditor
//
//  Entry function subclass which stores an interface to a action/condition plugin, associated with scriptData, allowing editing the values of the function. (Basically specialises PSFunctionElement for a specific action or condition

import Foundation

public class PSEventActionCondition : PSFunctionElement {
    public var expanded : Bool = false
}

public class PSEventActionFunction : PSEventActionCondition {
    public var action : PSActionInterface
    
    public var instancesValue : Int?
    public var activeUntilValue : String?
    
    
    public var hasInstancesOrActiveUntilValueAttributes : Bool {
        return instancesValue != nil || activeUntilValue != nil
    }
    
    public init(action : PSActionInterface, values: [PSEntryElement]) {
        self.action = action
        super.init()
        self.functionName = action.type()
        self.values = values
        
        parseInstancesAndActiveUntil()
    }
    
    func parseInstancesAndActiveUntil() {
        //get current values
        for value in values {
            switch(value) {
            case let .function(functionElement):
                if functionElement.functionName.lowercased() == "instances" {
                    if let first = functionElement.getStrippedStringValues().first,
                        let integerValue = Int(first) {
                            instancesValue = integerValue
                    }
                } else if functionElement.functionName.lowercased() == "activeuntil" {
                    if let first = functionElement.getStrippedStringValues().first {
                        activeUntilValue = first
                    }
                }
            default:
                break
            }
        }
        
        //fill out missing currentValues
        
    }
    
    override public var stringValue : String {
        get {
            let elements = getStringValues()
            
            let seperator : String = " "
            let values = elements.joined(separator: seperator)
            
            switch(bracketType) {
            case .square:
                return functionName + "[" + values + "]"
            case .round:
                return functionName + "(" + values + ")"
            case .expression:
                return values
            case .inlineEntry:
                return functionName + ":" + values
            }
        }
        set {
            fatalError("Cannot set stringValue of PSEventActionFunction subclass")
        }
    }
    
    open override func setStringValues(_ stringList : [String]) {
        fatalError("Cannot setStringValues of PSEventActionFunction subclass")
        
    }
    
    public func setInstancesActiveUntilOn(_ on : Bool) {
        if on {
            setActionParameterValues(values, instances: "1", activeUntil: "NONE")
        } else {
            setActionParameterValues(values, instances: nil, activeUntil: nil)
        }
    }
    
    public func setActionParameterValues(_ values : [PSEntryElement], instances : String?, activeUntil : String?) {
        self.values = values
        
        if let instances = instances {
            self.values.append(PSFunctionElement.InlineEntryNamed("Instances",values: [instances]))
        }
        
        if let activeUntil = activeUntil {
            self.values.append(PSFunctionElement.InlineEntryNamed("ActiveUntil",values: [activeUntil]))
        }
        
        parseInstancesAndActiveUntil()
    }
    
    
}

public class PSEventConditionFunction : PSEventActionCondition {
    public var condition : PSConditionInterface

    public init(condition : PSConditionInterface, values: [PSEntryElement]) {
        self.condition = condition
        super.init()
        self.functionName = condition.type()
        self.values = values
    }
}
