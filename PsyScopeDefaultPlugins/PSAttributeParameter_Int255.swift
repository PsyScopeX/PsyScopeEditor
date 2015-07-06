//
//  PSAttributeParameter_Int255.swift
//  PsyScopeEditor
//
//  Created by James on 30/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public class PSAttributeParameter_Int255 : PSAttributeParameter_String {
    
    override public func setCustomControl(visible: Bool) {
        super.setCustomControl(visible)
        if textField != nil && textField!.formatter == nil {
            let formatter = PSIntegerOnlyNumberFormatter()
            formatter.maximum = 255
            formatter.minimum = 0
            textField!.formatter = formatter
        }
    }
}