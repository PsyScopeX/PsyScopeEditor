//
//  PSIntegerOnlyNumberFormatter.swift
//  PsyScopeEditor
//
//  Created by James on 07/02/2015.
//

import Foundation

public func PSIntegerOnlyNumberFormatter() -> NSNumberFormatter {
    
    let intOnlyFormatter = NSNumberFormatter()
    intOnlyFormatter.maximumFractionDigits = 0
    intOnlyFormatter.minimumIntegerDigits = 1
        
    return intOnlyFormatter
}