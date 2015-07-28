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
    
    public var currentValues : [String]
    
    
    public var hasInstancesOrActiveUntilValueAttributes : Bool {
        return instancesValue != nil || activeUntilValue != nil
    }
    
    public init(action : PSActionInterface, values: [PSEntryElement]) {
        self.action = action
        self.currentValues = []
        super.init()
        self.functionName = action.type()
        self.values = values
        
        parseInstancesAndActiveUntil()
    }
    
    func parseInstancesAndActiveUntil() {
        //get current values
        for value in values {
            switch(value) {
            case let .StringToken(stringElement):
                currentValues.append(stringElement.quotedValue)
            case let .Function(functionElement):
                if functionElement.functionName.lowercaseString == "instances" {
                    if let first = functionElement.getStrippedStringValues().first,
                        integerValue = Int(first) {
                            instancesValue = integerValue
                    }
                } else if functionElement.functionName.lowercaseString == "activeuntil" {
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
            
            switch(bracketType) {
            case .Square:
                return functionName + "[" + seperator.join(elements) + "]"
            case .Round:
                return functionName + "(" + seperator.join(elements) + ")"
            case .Expression:
                return seperator.join(elements)
            case .InlineEntry:
                return functionName + ":" + seperator.join(elements)
            }
        }
        set {
            fatalError("Cannot set stringValue of PSEventActionFunction subclass")
        }
    }
    
    public override func setStringValues(stringList : [String]) {
        fatalError("Cannot setStringValues of PSEventActionFunction subclass")
        
    }
    
    public func setInstancesActiveUntilOn(on : Bool) {
        if on {
            setActionParameterValues(currentValues, instances: "1", activeUntil: "NONE")
        } else {
            setActionParameterValues(currentValues, instances: nil, activeUntil: nil)
        }
    }
    
    public func setActionParameterValues(values : [String], instances : String?, activeUntil : String?) {
        let value = " ".join(values)
        
        let parse = PSEntryValueParser(stringValue: value)
        self.values = parse.values
        
        if let instances = instances {
            self.values.append(PSFunctionElement.InlineEntryNamed("Instances",values: [instances]))
        }
        
        if let activeUntil = activeUntil {
            self.values.append(PSFunctionElement.InlineEntryNamed("ActiveUntil",values: [activeUntil]))
        }
        
        self.foundErrors = parse.foundErrors
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