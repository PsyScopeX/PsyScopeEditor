//
//  PSSubjectVariableToken.swift
//  PsyScopeEditor
//
//  Created by James on 17/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSSubjectVariableToken : NSObject, NSCoding {
    let subjectVariableName : String
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(subjectVariableName)
    }
    required init?(coder aDecoder: NSCoder) {
        subjectVariableName = aDecoder.decodeObject() as! String
    }
    
    init(subjectVariableName: String) {
        self.subjectVariableName = subjectVariableName
    }
    
}