//
//  PSStringList.swift
//  PsyScopeEditor
//
//  Created by James on 16/09/2014.
//

import Foundation

private var myContext = 0


public func PSStringListWithBaseEntryNamed(name : String, scriptData : PSScriptData) -> PSStringList? {
    if let entry = scriptData.getBaseEntry(name) {
        return PSStringList(entry: entry, scriptData: scriptData)
    }
    return nil
}

//this class binds a stringlist parser to the entry value
public class PSStringList : PSStringListCachedContainer {
    public var entry : Entry!
    public var scriptData : PSScriptData
    public init(entry : Entry, scriptData : PSScriptData) {
        self.entry = entry
        self.scriptData = scriptData
        super.init()
        entry.addObserver(self, forKeyPath: "currentValue", options: NSKeyValueObservingOptions.New, context: &myContext)
        self.stringValue = entry.currentValue //parses the current values
    }
    
    //purely to fail - need to init all members though...
    private init?(scriptData : PSScriptData) {
        self.scriptData = scriptData
        super.init()
        return nil
    }
    
    public convenience init?(baseEntryName : String, scriptData : PSScriptData) {
        if let entry = scriptData.getBaseEntry(baseEntryName) {
            self.init(entry: entry,scriptData: scriptData)
        } else {
            self.init(scriptData: scriptData)
            return nil
        }
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [NSObject : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &myContext && keyPath == "currentValue" {
            updateValues()
        }
    }
    
    private func updateValues() {
        if (self.entry.currentValue != nil && self.stringValueCache != self.entry.currentValue) {
            self.stringValue = entry.currentValue //parse
        }
    }
    
    override public func updateEntry() {
        super.updateEntry()
        let currentStringValue = self.stringValueCache //newly created cache from super.updateEntry()
        if (self.entry.currentValue != currentStringValue) {
            entry.currentValue = currentStringValue
        }
    }
    
    deinit {
        if entry != nil {
            entry.removeObserver(self, forKeyPath: "currentValue", context: &myContext)
        }
    }
}

public class PSStringListCachedContainer : PSStringListContainer {
    
    public override func updateEntry() {
        self.stringListRawUnstrippedCache = getStringValues()
        self.stringListRawStrippedCache = getStrippedStringValues()
        self.stringValueCache = createStringValue()
    }
    
    public var stringListRawUnstripped : [String] {
        get {
            return stringListRawUnstrippedCache
        }
        
        set {
            self.stringValue = " ".join(newValue)
        }
    }
    
    public var stringListRawStripped : [String] {
        get {
            return stringListRawStrippedCache
        }
        
    }
    
    //gets only the string listerals, ignoring inline entries and functions
    public var stringListLiteralsOnly : [String] {
        var literals : [String] = []
        for val in values {
            switch (val) {
            case .StringValue(let stringElement):
                literals.append(stringElement.value)
            
            default:
            break
            }
        }
        
        return literals
    }
    
    private var stringListRawUnstrippedCache : [String] = []
    private var stringListRawStrippedCache : [String] = []
    public var stringValueCache : String = ""
    
    func createStringValue() -> String {
        return super.stringValue
    }

    override public var stringValue : String {
        get {
            return self.stringValueCache
        }
        set {
            super.stringValue = newValue
            updateEntry()
        }
    }
    
    public func indexOfValueWithString(string : String) -> Int? {
        for (index,val) in stringListRawUnstrippedCache.enumerate() {
            if val == string {
                return index
            }
        }
        return nil
    }
    
    public func remove(string : String) {
        for (index,val) in stringListRawUnstrippedCache.enumerate() {
            if val == string {
                values.removeAtIndex(index)
                updateEntry()
                return
            }
        }
    }
    
    //moves a string at index 'from' to new index - edge cases result in first index / last index
    public func move(var from : Int, var to : Int) {
        if from < 0 {
            from = 0
        } else if from >= values.count {
            from = values.count - 1
        }
        
        if to > values.count {
            to = values.count
        } else if to < 0 {
            to = 0
        }
        
        if from < to {
            to--
        }
        
        let val1 = values[from]
        values.removeAtIndex(from)
        values.insert(val1, atIndex: to)
        updateEntry()
    }
    
    public func swap(index1: Int, index2: Int) {
        let val1 = values[index1]
        values[index1] = values[index2]
        values[index2] = val1
        updateEntry()
    }
    
    public func contains(string : String) -> Bool {
        return indexOfValueWithString(string) != nil
    }
    
    public func appendAsString(string : String) -> Bool {
        if let stringElement = assertValidString(string) {
            values.append(PSEntryElement.StringValue(stringElement))
            updateEntry()
            return true
        }
        return false
    }
    
    public func insert(string : String, index: Int) {
        if let stringElement = assertValidString(string) {
            super.insert(PSEntryElement.StringValue(stringElement), index: index)
        }
    }
    
    public func replace(oldString : String, newString: String) {
        if let stringElement = assertValidString(newString) {
            for (index,val) in stringListRawUnstrippedCache.enumerate() {
                if val == oldString {
                    values[index] = PSEntryElement.StringValue(stringElement)
                    updateEntry()
                    return
                }
            }
        }
    }
    
    private func assertValidString(string : String) -> PSStringElement? {
        if let stringElement = PSStringElement(strippedValue: string) {
            return stringElement
        } else {
            PSModalAlert("Errors found in new element - change rejected")
            return nil
        }
    }
    
}