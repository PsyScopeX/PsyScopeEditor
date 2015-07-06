//
//  PSVariableBaseType.swift
//  PsyScopeEditor
//
//  Created by James on 20/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

//wrapper for enum to pass by ref
public class PSVariableType {
    init() {
        self.type = .StringType //default
    }
    
    init(type : PSVariableTypeEnum) {
        self.type = type
    }
    
    var type : PSVariableTypeEnum
    
    class func Array(variableArray : PSVariableArray) -> PSVariableType {
        return PSVariableType(type: PSVariableTypeEnum.Array(variableArray))
    }
    
    class func Record(variableRecord : PSVariableRecord) -> PSVariableType {
        return PSVariableType(type: PSVariableTypeEnum.Record(variableRecord))
    }
    
    class func IntegerType() -> PSVariableType {
        return PSVariableType(type: .IntegerType)
    }
    class func LongIntegerType() -> PSVariableType {
        return PSVariableType(type: .LongIntegerType)
    }

    class func FloatType() -> PSVariableType {
        return PSVariableType(type: .FloatType)
    }
    
    class func DoubleType() -> PSVariableType {
        return PSVariableType(type: .DoubleType)
    }

    class func StringType() -> PSVariableType {
        return PSVariableType(type: .StringType)
    }

    class func Defined(string : String) -> PSVariableType {
        return PSVariableType(type: .Defined(string))
    }

    
}

public enum PSVariableTypeEnum {
    case IntegerType
    case LongIntegerType
    case FloatType
    case DoubleType
    case StringType
    case Defined(String)
    case Array(PSVariableArray)
    case Record(PSVariableRecord)
}



public class PSVariableArray {
    
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

public class PSVariableRecord {
    init(fields : [PSVariableNamedType]) {
        self.fields = fields
    }
    var fields : [PSVariableNamedType]
}

//MARK: Built in types





