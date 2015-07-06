//
//  PSPreferences.swift
//  PsyScopeEditor
//
//  Created by James on 10/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public typealias PSPreference = (key : String, value : NSObject)
public class PSPreferences {
    
    //warning: do not change these string values as they will mess up bindings!
    public static let cleanUpXSpacing : PSPreference = ("CleanUpXSpacing", Int(50))
    public static let cleanUpYSpacing : PSPreference = ("CleanUpYSpacing", Int(75))
    
    public static let showEvents : PSPreference = ("showingEvents", true)
    public static let showLists : PSPreference = ("showingLists", true)
    
    public static let psyScopeXPath : PSPreference = ("psyScopeXPath", "")
    
    public class func getDefaults() -> [String : AnyObject] {
        let defaults : [PSPreference] = [cleanUpXSpacing, cleanUpYSpacing, showEvents, showLists, psyScopeXPath]
        var dic : [String : AnyObject] = [:]
        for d in defaults {
            dic[d.key] = d.value
        }
        return dic
        
        
    }
    
    public class func integerForPreference(pref : PSPreference) -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey(pref.key)
    }
    
    public class func objectForPreference(pref : PSPreference) -> AnyObject? {
        return NSUserDefaults.standardUserDefaults().objectForKey(pref.key)
    }
}