//
//  PSDefaultResources.swift
//  PsyScopeEditor
//
//  Created by James on 05/09/2014.
//

import Cocoa
import Swift

//Used to get an array of string pairs from a named resource dictionary - the names of the resource dictionary
//are in the Constants.file
class PSDefaultResources: NSObject {

    func getStringPairs(name : String) -> [(String, String)] {
        let pairs : Dictionary<String,String> = PSPlistCache.sharedInstance.cache[name] as! Dictionary<String,String>
        var return_pairs : [(String, String)] = []
        for (key, val): (String, String) in pairs {
            return_pairs.append((key,val))
        }
        return return_pairs
    }
}

class PSJSONCache : NSObject {
    //thread safe singleton pattern
    class var sharedInstance: PSJSONCache {
        struct Static {
            static var instance: PSJSONCache?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = PSJSONCache()
            _ = Static.instance?.cache
        }
        
        return Static.instance!
    }
    
    lazy var cache: NSDictionary = {
        var theBundle = NSBundle(forClass:self.dynamicType)
        var jsonPaths = theBundle.pathsForResourcesOfType("json", inDirectory: nil)
        var resource_dictionary = NSMutableDictionary()
        for jsonPath in jsonPaths as [String] {
            var resource_data : NSData = NSFileManager.defaultManager().contentsAtPath(jsonPath)!
            
            var data_dict = try! NSJSONSerialization.JSONObjectWithData(resource_data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                resource_dictionary.addEntriesFromDictionary(data_dict as [NSObject : AnyObject])

        }
        
        return resource_dictionary
        }()
    
    
}


class PSPlistCache : NSObject {
    //thread safe singleton pattern
    class var sharedInstance: PSPlistCache {
    struct Static {
        static var instance: PSPlistCache?
        static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = PSPlistCache()
            _ = Static.instance?.cache
        }
        
        return Static.instance!
    }
    
    lazy var cache: NSDictionary = {
        var theBundle = NSBundle(forClass:self.dynamicType)
        var plistPaths = theBundle.pathsForResourcesOfType("plist", inDirectory: nil)
        var resource_dictionary = NSMutableDictionary()
        for plistPath in plistPaths as [String] {
            var resource_data : NSData = NSFileManager.defaultManager().contentsAtPath(plistPath)!
            var error : NSError? = nil
            var data_dict = try! NSPropertyListSerialization.propertyListWithData(resource_data, options: NSPropertyListReadOptions(rawValue: 0), format: nil)
            
            resource_dictionary.addEntriesFromDictionary(data_dict as! [NSObject : AnyObject])
        }
        
        return resource_dictionary
    }()

    
}
