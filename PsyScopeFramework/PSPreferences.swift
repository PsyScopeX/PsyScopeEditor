//
//  PSPreferences.swift
//  PsyScopeEditor
//
//  Created by James on 10/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public struct PSPreference {
    init(key : String, defaultValue : AnyObject) {
        self.key = key
        self.defaultValue = defaultValue
        print("key: \(key) default: \(defaultValue)")
    }
    public let key : String
    public let defaultValue : AnyObject
    public var value : AnyObject {
        get {
            if let val = UserDefaults.standard.object(forKey: key) {
                return val as AnyObject
            } else {
                return defaultValue
            }
        }
    }
    
    public  var stringValue : String {
        if let val =  UserDefaults.standard.string(forKey: key) {
            return val
        } else if let val = value as? String {
            return val
        } else {
            return ""
        }
    }
    
    public var integerValue : Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    
    public var boolValue : Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    public func resetToDefault() {
        UserDefaults.standard.set(self.defaultValue, forKey: key)
    }
}

public let PSPluginPathKey = "pluginPath"

public class PSPreferences {
    
    //warning: do not change these string values as they will mess up bindings!
    public static let cleanUpXSpacing : PSPreference = PSPreference(key: "CleanUpXSpacing", defaultValue: Int(50) as AnyObject)
    public static let cleanUpYSpacing : PSPreference = PSPreference(key: "CleanUpYSpacing", defaultValue: Int(75) as AnyObject)
    
    public static let showEvents : PSPreference = PSPreference(key: "showingEvents", defaultValue: true as AnyObject)
    public static let showLists : PSPreference = PSPreference(key: "showingLists", defaultValue: true as AnyObject)
    
    public static let psyScopeXPath : PSPreference = PSPreference(key: "psyScopeXPath", defaultValue: ((Bundle.main.resourcePath! as NSString).appendingPathComponent("PsyScopeXCurrentVersion") as NSString).appendingPathComponent("PsyScope X B77.app") as AnyObject)
    public static let pluginPath : PSPreference = PSPreference(key: PSPluginPathKey, defaultValue: "" as AnyObject)
    public static let automaticallyUpdateScript : PSPreference = PSPreference(key: "automaticallyUpdateScript", defaultValue: false as AnyObject)
    public class func getDefaults() -> [String : AnyObject] {
        let defaults : [PSPreference] = [cleanUpXSpacing, cleanUpYSpacing, showEvents, showLists, psyScopeXPath]
        var dic : [String : AnyObject] = [:]
        for d in defaults {
            dic[d.key] = d.defaultValue
        }
        return dic
        
        
    }
}
