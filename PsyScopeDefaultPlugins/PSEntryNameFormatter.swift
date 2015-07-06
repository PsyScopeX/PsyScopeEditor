//
//  PSEntryNameFormatter.swift
//  PsyScopeEditor
//
//  Created by James on 16/09/2014.
//

import Foundation


/*

Bug submitted to Apple - hopefully fixed soon

var PSEntryNameFormatterCharacterSet : NSCharacterSet = {
    () -> NSCharacterSet in
    var allowed_characters = NSMutableCharacterSet(charactersInString: " _")
    allowed_characters.formUnionWithCharacterSet(NSCharacterSet.alphanumericCharacterSet())
    return allowed_characters
}()

//makes sure that nume of the words in the string begin with a number
    class PSEntryNameFormatter : NSFormatter {
        override func stringForObjectValue(obj: AnyObject?) -> String? {
            
            if obj == nil {
                //println("stringForObjectValue: obj is nil, returning nil")
                return nil
            }
            if let o = obj as? String {
                    //println("stringForObjectValue:  obj is string, returning \(o)")
                    return o
                }
            
            //println("stringForObjectValue: obj is not string, returning nil")
            return nil
        }

        override func getObjectValue(obj: AutoreleasingUnsafeMutablePointer<AnyObject?>, forString string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
            //println("getObjectValue: \(string)")
            var stringcopy : String = NSString(string: string)
            let obj = stringcopy
            return true
        }
        
        override func isPartialStringValid(partialString: String?, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
            if let s = partialString {
                var illegals : String = join("",s.componentsSeparatedByCharactersInSet(PSEntryNameFormatterCharacterSet))
                var goods = s.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: illegals))
                let newString : NSString = join("", goods)
                
                if String(newString) == s {
                    //println("isPartialStringValid: partial string ok")
                    return true
                }
            }
            
            //println("isPartialStringValid: partial string bad")
            return false
        }
    }

*/