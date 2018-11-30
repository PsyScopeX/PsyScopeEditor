//
//  PSAttributeParameter_Mask.swift
//  PsyScopeEditor
//
//  Created by James on 30/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public class PSAttributeParameter_Mask : PSAttributeParameter_String {
    
    override public func setCustomControl(_ visible: Bool) {
        super.setCustomControl(visible)
        if textField != nil && textField!.formatter == nil {
            textField!.formatter = PSAttribute_TextMaskFormatter()
        }
    }
}

let PSAttribute_TextMaskFormatterAllowedCharacters = CharacterSet.alphanumerics

class PSAttribute_TextMaskFormatter : Formatter {
    
    override func string(for obj: Any?) -> String? {
        if obj != nil {
            if let o = obj as? String {
                return o
            }
        }
        return ""
    }
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
                                 for string: String,
                                 errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
    
        obj?.pointee = string as AnyObject
        return true
    }
    override func isPartialStringValid(_ partialString: String,
                                       newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?,
                                       errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        let c = partialString.count
        if c > 1 {
            return false
        } else if c == 0 {
            return true
        }
        
        let ix = partialString.startIndex
        let ix2 = partialString.endIndex
        let result = partialString.rangeOfCharacter(from: PSAttribute_TextMaskFormatterAllowedCharacters, options: [], range: ix..<ix2)
        return result != nil
    }
    override func attributedString(for obj: Any, withDefaultAttributes attrs: [NSAttributedString.Key : Any]?) -> NSAttributedString? {
        return nil
    }
}
