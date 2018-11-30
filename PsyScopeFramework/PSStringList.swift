//
//  PSStringList.swift
//  PsyScopeEditor
//
//  Created by James on 16/09/2014.
//

import Foundation

private var myContext = 0


public func PSStringListWithBaseEntryNamed(_ name : String, scriptData : PSScriptData) -> PSStringList? {
    if let entry = scriptData.getBaseEntry(name) {
        return PSStringList(entry: entry, scriptData: scriptData)
    }
    return nil
}

//this class binds a stringlist parser to the entry value
open class PSStringList : PSStringListCachedContainer {
    public var entry : Entry!
    public var scriptData : PSScriptData
    public init(entry : Entry, scriptData : PSScriptData) {
        self.entry = entry
        self.scriptData = scriptData
        super.init()
        entry.addObserver(self, forKeyPath: "currentValue", options: NSKeyValueObservingOptions.new, context: &myContext)
        self.stringValue = entry.currentValue //parses the current values
    }
    
    //purely to fail - need to init all members though...
    fileprivate init?(scriptData : PSScriptData) {
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
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext && keyPath == "currentValue" {
            updateValues()
        }
    }
    
    fileprivate func updateValues() {
        if (self.entry.currentValue != nil && self.stringValueCache != self.entry.currentValue) {
            self.stringValue = entry.currentValue //parse
        }
    }
    
    override open func updateEntry() {
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

open class PSStringListCachedContainer : PSStringListContainer {
    
    open override func updateEntry() {
        self.stringListRawUnstrippedCache = getStringValues()
        self.stringListRawStrippedCache = getStrippedStringValues()
        self.stringValueCache = createStringValue()
    }
    
    public var stringListRawUnstripped : [String] {
        get {
            return stringListRawUnstrippedCache
        }
        
        set {
            self.stringValue = newValue.joined(separator: " ")
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
            case .stringToken(let stringElement):
                literals.append(stringElement.value)
            
            default:
            break
            }
        }
        
        return literals
    }
    
    fileprivate var stringListRawUnstrippedCache : [String] = []
    fileprivate var stringListRawStrippedCache : [String] = []
    public var stringValueCache : String = ""
    
    func createStringValue() -> String {
        return super.stringValue
    }

    override open var stringValue : String {
        get {
            return self.stringValueCache
        }
        set {
            super.stringValue = newValue
            updateEntry()
        }
    }
    
    public func indexOfValueWithString(_ string : String) -> Int? {
        for (index,val) in stringListRawUnstrippedCache.enumerated() {
            if val == string {
                return index
            }
        }
        return nil
    }
    
    public func remove(_ string : String) {
        for (index,val) in stringListRawUnstrippedCache.enumerated() {
            if val == string {
                values.remove(at: index)
                updateEntry()
                return
            }
        }
    }
    
    //moves a string at index 'from' to new index - edge cases result in first index / last index
    public func move(_ from : Int, to : Int) {
        var from = from, to = to
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
            to -= 1
        }
        
        let val1 = values[from]
        values.remove(at: from)
        values.insert(val1, at: to)
        updateEntry()
    }
    
    public func swap(_ index1: Int, index2: Int) {
        let val1 = values[index1]
        values[index1] = values[index2]
        values[index2] = val1
        updateEntry()
    }
    
    public func contains(_ string : String) -> Bool {
        return indexOfValueWithString(string) != nil
    }
    
    @discardableResult
    public func appendAsString(_ string : String) -> Bool {
        if let stringElement = assertValidString(string) {
            values.append(PSEntryElement.stringToken(stringElement: stringElement))
            updateEntry()
            return true
        }
        return false
    }
    
    public func insert(_ string : String, index: Int) {
        if let stringElement = assertValidString(string) {
            super.insert(PSEntryElement.stringToken(stringElement: stringElement), index: index)
        }
    }
    
    public func replace(_ oldString : String, newString: String) {
        if let stringElement = assertValidString(newString) {
            for (index,val) in stringListRawUnstrippedCache.enumerated() {
                if val == oldString {
                    values[index] = PSEntryElement.stringToken(stringElement: stringElement)
                    updateEntry()
                    return
                }
            }
        }
    }
    
    fileprivate func assertValidString(_ string : String) -> PSStringElement? {
        if let stringElement = PSStringElement(strippedValue: string) {
            return stringElement
        } else {
            PSModalAlert("Errors found in new element - change rejected")
            return nil
        }
    }
    
}
