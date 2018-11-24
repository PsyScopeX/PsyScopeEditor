//
//  PSIntegerOnlyNumberFormatter.swift
//  PsyScopeEditor
//
//  Created by James on 07/02/2015.
//

import Foundation

public func PSIntegerOnlyNumberFormatter() -> NumberFormatter {
    
    let intOnlyFormatter = NumberFormatter()
    intOnlyFormatter.maximumFractionDigits = 0
    intOnlyFormatter.minimumIntegerDigits = 1
        
    return intOnlyFormatter
}
