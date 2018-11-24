//
//  PSAttributeParameter_Int.swift
//  PsyScopeEditor
//
//  Created by James on 07/02/2015.
//

import Foundation



open class PSAttributeParameter_Int : PSAttributeParameter_String {
    
    override open func setCustomControl(_ visible: Bool) {
        super.setCustomControl(visible)
        if textField != nil && textField!.formatter == nil {
            let formatter = PSIntegerOnlyNumberFormatter()
            textField!.formatter = formatter
        }
    }
}
