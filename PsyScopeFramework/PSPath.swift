//
//  PSPath.swift
//  PsyScopeEditor
//
//  Created by James on 17/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public func PSPath(absolutePath : String, basePath : String) -> String {
    var relPath = relativePath(absolutePath, basePath: basePath)
    
    //relative: ":deleteme:delete:untitled text.txt"
    //one level below relativee "::james.jks:"
    //two levels below relative ":::Deleted Users:james2.dmg:"
    
    var psyPath : String = ""
    for (index, baseComponent) in relPath.pathComponents.enumerate() {
        if (baseComponent == "..") {
            psyPath = psyPath + ":"
        } else {
            psyPath = psyPath + ":" + baseComponent
        }
    }
    return psyPath
}

public func PSStandardPath(psPath : String, basePath : String) -> String {
    if psPath == "" { return basePath }
    var relativeNotationComps = psPath.componentsSeparatedByString("@")
    var absolutePath : String = basePath
    
    let scanner = NSScanner(string: psPath)
    
    var colons : NSString? = ""
    if scanner.scanCharactersFromSet(NSCharacterSet(charactersInString: ":"), intoString: &colons) {
        let ncolons = colons!.length
        if ncolons > 1 {
            for i in 2...ncolons {
                absolutePath = absolutePath.stringByDeletingLastPathComponent
                print(absolutePath)
            }
        }
        
    }
    
    //now on same level so add path components
    let pstrimmedpath = psPath.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: ":"))
    let components = pstrimmedpath.componentsSeparatedByString(":")
    for c in components {
        absolutePath = absolutePath.stringByAppendingPathComponent(c)
    }
    
    return absolutePath
}

func relativePath(absolutePath : String, basePath : String) -> String {
    var absolutePathComponents = absolutePath.pathComponents
    let basePathComponents = basePath.pathComponents
    
    if absolutePathComponents.count < basePathComponents.count {
        return absolutePath
    }
    
    var levelIndex = 0 //number of basePath components in absolute path
    
    for (index, baseComponent) in basePathComponents.enumerate() {
        
        if (baseComponent != absolutePathComponents[index]) {
            break
        }
        levelIndex++
    }
    
    var relativePath : String = ""
    
    
    if levelIndex < basePathComponents.count {
        //outside of base path
        for (var index = levelIndex; index < basePathComponents.count; index++) {
            relativePath = relativePath.stringByAppendingPathComponent("../")
        }
    }
    
    
    for(var index = levelIndex; index < absolutePathComponents.count; index++) {
        relativePath = relativePath.stringByAppendingPathComponent(absolutePathComponents[index])
    }
    
    return relativePath
    
}