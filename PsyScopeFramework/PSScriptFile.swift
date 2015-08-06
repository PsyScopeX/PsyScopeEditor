//
//  PSScriptFile.swift
//  PsyScopeEditor
//
//  Created by James on 18/02/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public class PSScriptFile : NSObject {
    public class func FileRefFromPath(path : String, scriptData : PSScriptData) -> String? {
        if let docPath = scriptData.documentDirectory(),
            pspath = PSPath(path, basePath: docPath) {
            return "FileRef(\"\(pspath)\")"
        } else {
            return nil
        }
    }
    
    public class func PathFromFileRef(fileref : String, scriptData : PSScriptData) -> String? {
        
        //should be fileref function nothing else
        
        let function = PSFunctionElement()
        function.stringValue = fileref
        
        //check function is named fileref
        if function.functionName == "FileRef" {
            
            //check there are no other functions contained within
            for value in function.values {
                if case .Function = value {
                    return nil
                }
            }
            var path = function.getParametersStringValue()
            path = path.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\" ()"))
            if scriptData.alertIfNoValidDocumentDirectory() {
                if let docPath = scriptData.documentDirectory() {
                    return PSStandardPath(path, basePath: docPath)
                }
            }
        }
        
        return nil
    }
}