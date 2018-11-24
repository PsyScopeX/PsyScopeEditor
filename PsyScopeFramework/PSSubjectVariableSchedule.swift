//
//  PSSubjectVariableSchedule.swift
//  PsyScopeEditor
//
//  Created by James on 20/06/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

//taken care of in storage options (as it is intertwined with the logging)
public enum PSSubjectVariableSchedule {
    case runStart, runEnd, never
    
    public func description() -> String {
        switch self {
        case .runStart:
            return "Start"
        case .runEnd:
            return "End"
        case .never:
            return "Never"
        }
    }
}
