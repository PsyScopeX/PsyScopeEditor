//
//  PSPath.swift
//  PsyScopeEditor
//
//  Created by James on 17/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public func PSPath(_ absolutePath : String, basePath : String) -> String? {
    let relPath = relativePath(absolutePath, basePath: basePath)
    
    //check for illegal characters
    let illegalCharacters = CharacterSet(charactersIn: ":?%*|\"<>{}[]()")
    if absolutePath.rangeOfCharacter(from: illegalCharacters) != nil ||
        basePath.rangeOfCharacter(from: illegalCharacters) != nil {
            return nil
    }
    
    //relative: ":deleteme:delete:untitled text.txt"
    //one level below relativee "::james.jks:"
    //two levels below relative ":::Deleted Users:james2.dmg:"
    
    var psyPath : String = ""
    for (_, baseComponent) in (relPath as NSString).pathComponents.enumerated() {
        if (baseComponent == "..") {
            psyPath = psyPath + ":"
        } else {
            psyPath = psyPath + ":" + baseComponent
        }
    }
    return psyPath
}

public func PSStandardPath(_ psPath : String, basePath : String) -> String? {
    
    //check for illegal characters
    let psillegalCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>{}[]()")
    let illegalCharacters = CharacterSet(charactersIn: ":?%*|\"<>{}[]()")
    if psPath.rangeOfCharacter(from: psillegalCharacters) != nil ||
        basePath.rangeOfCharacter(from: illegalCharacters) != nil {
            return nil
    }
    
    
    if psPath == "" { return basePath }
    var absolutePath : String = basePath
    
    let scanner = Scanner(string: psPath)
    
    var colons : NSString? = ""
    if scanner.scanCharacters(from: CharacterSet(charactersIn: ":"), into: &colons) {
        let ncolons = colons!.length
        if ncolons > 1 {
            for _ in 2...ncolons {
                absolutePath = (absolutePath as NSString).deletingLastPathComponent
            }
        }
        
    }
    
    //now on same level so add path components
    let pstrimmedpath = psPath.trimmingCharacters(in: CharacterSet(charactersIn: ":"))
    let components = pstrimmedpath.components(separatedBy: ":")
    for c in components {
        absolutePath = (absolutePath as NSString).appendingPathComponent(c)
    }
    
    return absolutePath
}

func relativePath(_ absolutePath : String, basePath : String) -> String {
    var absolutePathComponents = (absolutePath as NSString).pathComponents
    let basePathComponents = (basePath as NSString).pathComponents
    
    if absolutePathComponents.count < basePathComponents.count {
        return absolutePath
    }
    
    var levelIndex = 0 //number of basePath components in absolute path
    
    for (index, baseComponent) in basePathComponents.enumerated() {
        
        if (baseComponent != absolutePathComponents[index]) {
            break
        }
        levelIndex++
    }
    
    var relativePath : String = ""
    
    
    if levelIndex < basePathComponents.count {
        //outside of base path
        for (var index = levelIndex; index < basePathComponents.count; index++) {
            relativePath = (relativePath as NSString).appendingPathComponent("../")
        }
    }
    
    
    for(var index = levelIndex; index < absolutePathComponents.count; index++) {
        relativePath = (relativePath as NSString).appendingPathComponent(absolutePathComponents[index])
    }
    
    return relativePath
    
}
