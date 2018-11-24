//
//  PSVariableBaseType.swift
//  PsyScopeEditor
//
//  Created by James on 20/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

//wrapper for enum to pass by ref
open class PSVariableType {
    init() {
        self.type = .stringType //default
    }
    
    init(type : PSVariableTypeEnum) {
        self.type = type
    }
    
    var type : PSVariableTypeEnum
    
    class func Array(_ variableArray : PSVariableArray) -> PSVariableType {
        return PSVariableType(type: PSVariableTypeEnum.array(variableArray))
    }
    
    class func Record(_ variableRecord : PSVariableRecord) -> PSVariableType {
        return PSVariableType(type: PSVariableTypeEnum.record(variableRecord))
    }
    
    class func IntegerType() -> PSVariableType {
        return PSVariableType(type: .integerType)
    }
    class func LongIntegerType() -> PSVariableType {
        return PSVariableType(type: .longIntegerType)
    }

    class func FloatType() -> PSVariableType {
        return PSVariableType(type: .floatType)
    }
    
    class func DoubleType() -> PSVariableType {
        return PSVariableType(type: .doubleType)
    }

    class func StringType() -> PSVariableType {
        return PSVariableType(type: .stringType)
    }

    class func Defined(_ string : String) -> PSVariableType {
        return PSVariableType(type: .defined(string))
    }

    
}

public enum PSVariableTypeEnum {
    case integerType
    case longIntegerType
    case floatType
    case doubleType
    case stringType
    case defined(String)
    case array(PSVariableArray)
    case record(PSVariableRecord)
}



open class PSVariableArray {
    
    init() {
        self.count = 1
        self.type = PSVariableType()
    }
    
    init(count: Int, type : PSVariableType) {
        self.count = count
        self.type = type
    }
    
    var count : Int
    var type : PSVariableType
}

open class PSVariableRecord {
    init(fields : [PSVariableNamedType]) {
        self.fields = fields
    }
    var fields : [PSVariableNamedType]
}

//MARK: Built in types





