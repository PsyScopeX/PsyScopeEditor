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
    static let sharedInstance = PSJSONCache()
    private override init() { } // prevent creating another instances.
    
    lazy var cache: NSDictionary = {
        var theBundle = Bundle(for:type(of: self))
        var jsonPaths = theBundle.paths(forResourcesOfType: "json", inDirectory: nil)
        var resource_dictionary = NSMutableDictionary()
        for jsonPath in jsonPaths as [String] {
            var resource_data : Data = FileManager.default.contents(atPath: jsonPath)!
            
            var data_dict = try! JSONSerialization.jsonObject(with: resource_data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                resource_dictionary.addEntries(from: data_dict as! [AnyHashable: Any])

        }
        
        return resource_dictionary
        }()
    
    
}


class PSPlistCache : NSObject {
    
    static let sharedInstance = PSPlistCache()
    private override init() { } // prevent creating another instances.
    
    lazy var cache: NSDictionary = {
        var theBundle = Bundle(for:type(of: self))
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
