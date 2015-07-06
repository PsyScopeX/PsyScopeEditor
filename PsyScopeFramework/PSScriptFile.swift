//
//  PSScriptFile.swift
//  PsyScopeEditor
//
//  Created by James on 18/02/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public class PSScriptFile : NSObject {
    public class func FileRefFromPath(path : String, scriptData : PSScriptData) -> String {
        var docPath = scriptData.documentDirectory()!
        var pspath = PSPath(path, basePath: docPath)
        return "FileRef(\"\(pspath)\")"
    }
    
    public class func PathFromFileRef(fileref : String, scriptData : PSScriptData) -> String {
        let range = fileref.rangeOfString("FileRef", options: NSStringCompareOptions.CaseInsensitiveSearch)
        var path = fileref
        if let r = range {
            path.removeRange(r)
        }
        path = path.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\" ()"))
        if scriptData.alertIfNoValidDocumentDirectory() {
            let docPath = scriptData.documentDirectory()!
            return PSStandardPath(path, basePath: docPath)
        } else {
            return ""
        }
    }
}