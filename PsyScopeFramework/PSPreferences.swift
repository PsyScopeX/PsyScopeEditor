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
            if let val = NSUserDefaults.standardUserDefaults().objectForKey(key) {
                return val
            } else {
                return defaultValue
            }
        }
    }
    
    public  var stringValue : String {
        if let val =  NSUserDefaults.standardUserDefaults().stringForKey(key) {
            return val
        } else if let val = value as? String {
            return val
        } else {
            return ""
        }
    }
    
    public var integerValue : Int {
        return NSUserDefaults.standardUserDefaults().integerForKey(key)
    }
    
    public var boolValue : Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(key)
    }
    
    public func resetToDefault() {
        NSUserDefaults.standardUserDefaults().setObject(self.defaultValue, forKey: key)
    }
}

public let PSPluginPathKey = "pluginPath"

public class PSPreferences {
    
    //warning: do not change these string values as they will mess up bindings!
    public static let cleanUpXSpacing : PSPreference = PSPreference(key: "CleanUpXSpacing", defaultValue: Int(50))
    public static let cleanUpYSpacing : PSPreference = PSPreference(key: "CleanUpYSpacing", defaultValue: Int(75))
    
    public static let showEvents : PSPreference = PSPreference(key: "showingEvents", defaultValue: true)
    public static let showLists : PSPreference = PSPreference(key: "showingLists", defaultValue: true)
    
    public static let psyScopeXPath : PSPreference = PSPreference(key: "psyScopeXPath", defaultValue: ((NSBundle.mainBundle().resourcePath! as NSString).stringByAppendingPathComponent("PsyScopeXCurrentVersion") as NSString).stringByAppendingPathComponent("PsyScope X B77.app"))
    public static let pluginPath : PSPreference = PSPreference(key: PSPluginPathKey, defaultValue: "")
    public static let automaticallyUpdateScript : PSPreference = PSPreference(key: "automaticallyUpdateScript", defaultValue: false)
    public class func getDefaults() -> [String : AnyObject] {
        let defaults : [PSPreference] = [cleanUpXSpacing, cleanUpYSpacing, showEvents, showLists, psyScopeXPath]
        var dic : [String : AnyObject] = [:]
        for d in defaults {
            dic[d.key] = d.defaultValue
        }
        return dic
        
        
    }
}