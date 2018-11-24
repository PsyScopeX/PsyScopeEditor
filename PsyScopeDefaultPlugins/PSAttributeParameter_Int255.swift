//
//  PSAttributeParameter_Int255.swift
//  PsyScopeEditor
//
//  Created by James on 30/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

open class PSAttributeParameter_Int255 : PSAttributeParameter_String {
    
    override open func setCustomControl(_ visible: Bool) {
        super.setCustomControl(visible)
        if textField != nil && textField!.formatter == nil {
            let formatter = PSIntegerOnlyNumberFormatter()
            formatter.maximum = 255
            formatter.minimum = 0
            textField!.formatter = formatter
        }
    }
}
