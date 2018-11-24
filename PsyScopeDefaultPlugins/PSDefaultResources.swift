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

    func getStringPairs(_ name : String) -> [(String, String)] {
        let pairs : Dictionary<String,String> = PSPlistCache.sharedInstance.cache[name] as! Dictionary<String,String>
        var return_pairs : [(String, String)] = []
        for (key, val): (String, String) in pairs {
            return_pairs.append((key,val))
        }
        return return_pairs
    }
}

class PSJSONCache : NSObject {
    private static var __once: () = {
            Static.instance = PSJSONCache()
            _ = Static.instance?.cache
        }()
    //thread safe singleton pattern
    class var sharedInstance: PSJSONCache {
        struct Static {
            static var instance: PSJSONCache?
            static var token: Int = 0
        }
        
        _ = PSJSONCache.__once
        
        return Static.instance!
    }
    
    lazy var cache: NSDictionary = {
        var theBundle = Bundle(for:self.dynamicType)
        var jsonPaths = theBundle.paths(forResourcesOfType: "json", inDirectory: nil)
        var resource_dictionary = NSMutableDictionary()
        for jsonPath in jsonPaths as [String] {
            var resource_data : Data = FileManager.default.contents(atPath: jsonPath)!
            
            var data_dict = try! JSONSerialization.jsonObject(with: resource_data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                resource_dictionary.addEntries(from: data_dict as [AnyHashable: Any])

        }
        
        return resource_dictionary
        }()
    
    
}


class PSPlistCache : NSObject {
    private static var __once1: () = {
            Static.instance = PSPlistCache()
            _ = Static.instance?.cache
        }()
    //thread safe singleton pattern
    class var sharedInstance: PSPlistCache {
    struct Static {
        static var instance: PSPlistCache?
        static var token: Int = 0
        }
        
        _ = PSPlistCache.__once1
        
        return Static.instance!
    }
    
    lazy var cache: NSDictionary = {
        var theBundle = Bundle(for:self.dynamicType)
        var plistPaths = theBundle.paths(forResourcesOfType: "plist", inDirectory: nil)
        var resource_dictionary = NSMutableDictionary()
        for plistPath in plistPaths as [String] {
            var resource_data : Data = FileManager.default.contents(atPath: plistPath)!
            var error : NSError? = nil
            var data_dict = try! PropertyListSerialization.propertyList(from: resource_data, options: PropertyListSerialization.ReadOptions(rawValue: 0), format: nil)
            
            resource_dictionary.addEntries(from: data_dict as! [AnyHashable: Any])
        }
        
        return resource_dictionary
    }()

    
}
