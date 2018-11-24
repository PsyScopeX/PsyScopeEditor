//
//  PSAttributeParameter_Mask.swift
//  PsyScopeEditor
//
//  Created by James on 30/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

open class PSAttributeParameter_Mask : PSAttributeParameter_String {
    
    override open func setCustomControl(_ visible: Bool) {
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
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AutoreleasingUnsafeMutablePointer<AnyObject?>>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<AutoreleasingUnsafeMutablePointer<NSString?>>?) -> Bool {
        obj.pointee = string
        return true
    }
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<AutoreleasingUnsafeMutablePointer<NSString?>>?, errorDescription error: AutoreleasingUnsafeMutablePointer<AutoreleasingUnsafeMutablePointer<NSString?>>?) -> Bool {
        
        let c = partialString.characters.count
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
    override func attributedString(for obj: Any, withDefaultAttributes attrs: [String : Any]?) -> NSAttributedString? {
        return nil
    }
}
