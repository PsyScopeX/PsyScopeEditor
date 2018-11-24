//
//  PSEventAction.swift
//  PsyScopeEditor
//
//  Entry function subclass which stores an interface to a action/condition plugin, associated with scriptData, allowing editing the values of the function. (Basically specialises PSFunctionElement for a specific action or condition

import Foundation

open class PSEventActionCondition : PSFunctionElement {
    open var expanded : Bool = false
}

open class PSEventActionFunction : PSEventActionCondition {
    open var action : PSActionInterface
    
    open var instancesValue : Int?
    open var activeUntilValue : String?
    
    
    open var hasInstancesOrActiveUntilValueAttributes : Bool {
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
                        integerValue = Int(first) {
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
    
    override open var stringValue : String {
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
    
    open func setInstancesActiveUntilOn(_ on : Bool) {
        if on {
            setActionParameterValues(values, instances: "1", activeUntil: "NONE")
        } else {
            setActionParameterValues(values, instances: nil, activeUntil: nil)
        }
    }
    
    open func setActionParameterValues(_ values : [PSEntryElement], instances : String?, activeUntil : String?) {
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

open class PSEventConditionFunction : PSEventActionCondition {
    open var condition : PSConditionInterface

    public init(condition : PSConditionInterface, values: [PSEntryElement]) {
        self.condition = condition
        super.init()
        self.functionName = condition.type()
        self.values = values
    }
}
