//
//  PSStringList.swift
//  ScriptScanner
//
//  Created by James on 25/03/2015.
//  Copyright (c) 2015 James Alvarez. All rights reserved.
//

import Foundation
//this class allows you to treat a string array and the value of an entry (containing a list) as one
public class PSStringListContainer : PSStringListElement {
    
    public subscript(index: Int) -> String {
        get {
            return elementToString(values[index], stripped: false)
        }
        
        set(newValue) {
            if !setValueForIndex(index, value: newValue) {
                PSModalAlert("Errors found when attempting to change script value, changes rejected")
            }
        }
    }
    
    public func updateEntry() {
        //override to detect changes
    }
    
    public func removeAtIndex(index : Int) {
        if index < values.count {
            values.removeAtIndex(index)
            updateEntry()
        }
    }
    
    public func setValueForIndex(index : Int, value : String) -> Bool {
        if let v = valueForString(value) {
            values[index] = v
            updateEntry()
            return true
        }
        return false
    }
    
    public func valueForString(stringValue : String) -> PSEntryElement? {
        let parse = PSEntryValueParser(stringValue: stringValue)
        
        if parse.foundErrors {
            return nil
        }
        
        let new_values = parse.values
        
        if new_values.count == 1 {
            return new_values.last!
        } else if new_values.count == 0 {
            return PSEntryElement.Null
        } else {
            let new_func = PSFunctionElement()
            new_func.bracketType = .Square
            new_func.values = new_values
            return PSEntryElement.Function(new_func)
        }
    }
    
    
    
    
    public var count : Int {
        get {
            return values.count
        }
    }
    
    public func insert(element : PSEntryElement , index : Int) {
        values.insert(element, atIndex: index)
        updateEntry()
    }
}