//
//  PSAttributeParameter_Mask.swift
//  PsyScopeEditor
//
//  Created by James on 30/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public class PSAttributeParameter_Mask : PSAttributeParameter_String {
    
    override public func setCustomControl(visible: Bool) {
        super.setCustomControl(visible)
        if textField != nil && textField!.formatter == nil {
            textField!.formatter = PSAttribute_TextMaskFormatter()
        }
    }
}

let PSAttribute_TextMaskFormatterAllowedCharacters = NSCharacterSet.alphanumericCharacterSet()

class PSAttribute_TextMaskFormatter : NSFormatter {
    
    override func stringForObjectValue(obj: AnyObject?) -> String? {
        if obj != nil {
            if let o = obj as? String {
                return o
            }
        }
        return ""
    }
    override func getObjectValue(obj: AutoreleasingUnsafeMutablePointer<AnyObject?>, forString string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
        obj.memory = string
        return true
    }
    override func isPartialStringValid(partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
        
        let c = partialString.characters.count
        if c > 1 {
            return false
        } else if c == 0 {
            return true
        }
        
        let ix = partialString.startIndex
        let ix2 = partialString.endIndex
        let result = partialString.rangeOfCharacterFromSet(PSAttribute_TextMaskFormatterAllowedCharacters, options: [], range: ix..<ix2)
        return result != nil
    }
    override func attributedStringForObjectValue(obj: AnyObject, withDefaultAttributes attrs: [String : AnyObject]?) -> NSAttributedString? {
        return nil
    }
}