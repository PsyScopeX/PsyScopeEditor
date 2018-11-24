//
//  PSAttributeParameter_Float.swift
//  PsyScopeEditor
//
//  Created by James on 14/02/2015.
//

import Foundation

open class PSAttributeParameter_Float : PSAttributeParameter_String {
    
    override open func setCustomControl(_ visible: Bool) {
        if textField != nil && textField!.formatter == nil {
            textField!.formatter = PSFloatOnlyNumberFormatter()
        }
    }
}
