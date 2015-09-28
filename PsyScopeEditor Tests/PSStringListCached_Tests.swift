//
//  PSStringListCached_Tests.swift
//  PsyScopeEditor
//
//  Created by James on 24/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Cocoa
import XCTest

class PSStringListCached_Tests: XCTestCase {

    var stringList : PSStringListCachedContainer!
    override func setUp() {
        super.setUp()
        stringList = PSStringListCachedContainer()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_Move0Tom1_DoesNothing() {
        stringList.stringValue = "Value1 Value2 Value3"
        stringList.move(0, to: -1)
        
        
        XCTAssert(stringList.stringValue == "Value1 Value2 Value3", "Incorrect reordering in move method - found \(stringList.stringValue)")
    }
    
    func test_Move0To0_DoesNothing() {
        stringList.stringValue = "Value1 Value2 Value3"
        stringList.move(0, to: 0)
        
        
        XCTAssert(stringList.stringValue == "Value1 Value2 Value3", "Incorrect reordering in move method - found \(stringList.stringValue)")
    }
    
    func test_Move0To1_DoesNothing() {
        stringList.stringValue = "Value1 Value2 Value3"
        stringList.move(0, to: 1)
        
        
        XCTAssert(stringList.stringValue == "Value1 Value2 Value3", "Incorrect reordering in move method - found \(stringList.stringValue)")
    }
    
    func test_Move0To2_Moves0To2() {
        stringList.stringValue = "Value1 Value2 Value3"
        stringList.move(0, to: 2)
        
        
        XCTAssert(stringList.stringValue == "Value2 Value1 Value3", "Incorrect reordering in move method - found \(stringList.stringValue)")
    }
    
    func test_Move0To3_Moves0To3() {
        stringList.stringValue = "Value1 Value2 Value3"
        stringList.move(0, to: 3)
        
        
        XCTAssert(stringList.stringValue == "Value2 Value3 Value1", "Incorrect reordering in move method - found \(stringList.stringValue)")
    }
    
    func test_Move0To3_Moves0To4() {
        stringList.stringValue = "Value1 Value2 Value3"
        stringList.move(0, to: 4)
        
        
        XCTAssert(stringList.stringValue == "Value2 Value3 Value1", "Incorrect reordering in move method - found \(stringList.stringValue)")
    }
    
    //1
    
    func test_Movem1Tom1_Movesm1Tom1() {
        stringList.stringValue = "Value1 Value2 Value3"
        stringList.move(1, to: -1)
        
        
        XCTAssert(stringList.stringValue == "Value2 Value1 Value3", "Incorrect reordering in move method - found \(stringList.stringValue)")
    }
    
    func test_Move1To0_Moves0To0() {
        stringList.stringValue = "Value1 Value2 Value3"
        stringList.move(1, to: 0)
        
        
        XCTAssert(stringList.stringValue == "Value2 Value1 Value3", "Incorrect reordering in move method - found \(stringList.stringValue)")
    }
    
    func test_Move1To1_DoesNothing() {
        stringList.stringValue = "Value1 Value2 Value3"
        stringList.move(1, to: 1)
        
        
        XCTAssert(stringList.stringValue == "Value1 Value2 Value3", "Incorrect reordering in move method - found \(stringList.stringValue)")
    }
    
    func test_Move1To2_DoesNothing() {
        stringList.stringValue = "Value1 Value2 Value3"
        stringList.move(1, to: 2)
        
        
        XCTAssert(stringList.stringValue == "Value1 Value2 Value3", "Incorrect reordering in move method - found \(stringList.stringValue)")
    }
    
    func test_Move1To3_Moves1To3() {
        stringList.stringValue = "Value1 Value2 Value3"
        stringList.move(1, to: 3)
        XCTAssert(stringList.stringValue == "Value1 Value3 Value2", "Incorrect reordering in move method - found \(stringList.stringValue)")
    }
    
    func test_Move1To4_Moves1To4() {
        stringList.stringValue = "Value1 Value2 Value3"
        stringList.move(1, to: 4)
        XCTAssert(stringList.stringValue == "Value1 Value3 Value2", "Incorrect reordering in move method - found \(stringList.stringValue)")
    }
    
    func test_Movem1To2_Moves0To2() {
        stringList.stringValue = "Value1 Value2 Value3"
        stringList.move(-1, to: 2)
        XCTAssert(stringList.stringValue == "Value2 Value1 Value3", "Incorrect reordering in move method - found \(stringList.stringValue)")
    }
    
    func test_Move5To2_Moves3To1() {
        stringList.stringValue = "Value1 Value2 Value3"
        stringList.move(5, to: 1)
        XCTAssert(stringList.stringValue == "Value1 Value3 Value2", "Incorrect reordering in move method - found \(stringList.stringValue)")
    }
    
    func test_Move5To4_DoesNothing() {
        stringList.stringValue = "Value1 Value2 Value3"
        stringList.move(5, to: 4)
        XCTAssert(stringList.stringValue == "Value1 Value2 Value3", "Incorrect reordering in move method - found \(stringList.stringValue)")
    }
    
    func test_Move4To5_DoesNothing() {
        stringList.stringValue = "Value1 Value2 Value3"
        stringList.move(4, to: 5)
        XCTAssert(stringList.stringValue == "Value1 Value2 Value3", "Incorrect reordering in move method - found \(stringList.stringValue)")
    }

    func test_Level1ArrayIn_RawValuesOut() {
        // This is an example of a functional test case.
        let originalValue = "Hello1 Hello2 Hello3"
        stringList.stringValue = originalValue
        
        var success = true
        
        let stringListRawUnstripped = stringList.stringListRawUnstripped
        
        XCTAssert(stringListRawUnstripped.count == 3, "StringList should have three elements, found \(stringListRawUnstripped.count)")
        
        let selfReconstructed = stringListRawUnstripped.joinWithSeparator(" ")
        let stringValueReconstred = stringList.stringValue
        XCTAssert(selfReconstructed == originalValue, "Original value was \(originalValue), self reconstructed was \(selfReconstructed)")
        XCTAssert(selfReconstructed == originalValue, "Original value was \(originalValue), stringValue reconstructed was \(stringValueReconstred)")

    }
    
    func test_Level2ArrayIn_RawUnstrippedValuesOut() {
        // This is an example of a functional test case.
        let originalValue = "[Hello1 Hello2] [Hello3 Hello4] [Hello5 Hello6]"
        stringList.stringValue = originalValue
        
        var success = true
        
        let stringListRawUnstripped = stringList.stringListRawUnstripped
        
        XCTAssert(stringListRawUnstripped.count == 3, "StringList should have three elements, found \(stringListRawUnstripped.count)")
        
        let selfReconstructed = stringListRawUnstripped.joinWithSeparator(" ")
        let stringValueReconstred = stringList.stringValue
        XCTAssert(selfReconstructed == originalValue, "Original value was \(originalValue), self reconstructed was \(selfReconstructed)")
        XCTAssert(selfReconstructed == originalValue, "Original value was \(originalValue), stringValue reconstructed was \(stringValueReconstred)")
        
    }
    
    func test_Level2ArrayIn_RawStrippedValuesOut() {
        // This is an example of a functional test case.
        let originalValue = "[Hello1 Hello2] [Hello3 Hello4] [Hello5 Hello6]"
        let expectedValue = "Hello1 Hello2 Hello3 Hello4 Hello5 Hello6"
        stringList.stringValue = originalValue
        
        var success = true
        
        let stringListRawStripped = stringList.stringListRawStripped
        
        XCTAssert(stringListRawStripped.count == 3, "StringList should have three elements, found \(stringListRawStripped.count)")
        
        let selfReconstructed = stringListRawStripped.joinWithSeparator(" ")

        XCTAssert(selfReconstructed == expectedValue, "Original value was \(originalValue), self reconstructed was \(selfReconstructed), expected \(expectedValue)")
 
    }
    
    func test_InlineEntriesIn_InlineEntryValuesOut() {
        // This is an example of a functional test case.
        let originalValue = "[A: Hello1 B: Hello2] [C: Hello3 D: Hello4] [E: Hello5 F: Hello6]"
        stringList.stringValue = originalValue
        
        var success = true
        var errorList : String = ""
        
        XCTAssert(stringList.values.count == 3,"StringList should have three values, found \(stringList.values.count)")
        
        for value in stringList.values {
            switch (value) {
            case let .Function(functionElement):
                
                
                switch functionElement.bracketType {
                case .InlineEntry:
                    success = false
                    errorList += "Expected Square function, got inline "
                    break
                case .Round:
                    success = false
                    errorList += "Expected Square function, got round "
                case .Square:
                    for functionValue in functionElement.values {
                        
                        
                        switch (functionValue) {
                        case let .Function(inlineFunctionElement):
                            switch inlineFunctionElement.bracketType {
                            case .InlineEntry:
                                break
                            case .Round:
                                success = false
                                errorList += "Expected InlineEntry function, got round "
                            case .Square:
                                success = false
                                errorList += "Expected InlineEntry function, got square "
                            case .Expression:
                                success = false
                                errorList += "Expected InlineEntry function, got expression "
                            }
                            
                        default:
                            success = false
                            errorList += "Expected function, got something else "
                            break
                        }
                    }
                case .Expression:
                    success = false
                    errorList += "Expected Square function, got expression "
                }
                
            
            default:
                success = false
                errorList += "Expected function, got something else "
            }
        }
        
        XCTAssert(success, "Found Errors when parsing inline entries \(errorList)")
        
    }

    func test_InlineEntryIn_InlineEntryValuesOut() {
        // This is an example of a functional test case.
        let originalValue = "[A: Hello1 B: Hello2]"

        stringList.stringValue = originalValue
        
        var success = false
        
        XCTAssert(stringList.values.count == 1,"StringList should have one value, found \(stringList.values.count)")
        
        for value in stringList.values {
            switch (value) {
            case let .Function(functionElement):
                if functionElement.bracketType == .Square {
                    XCTAssert(functionElement.values.count == 2,"Square Function should have two value, found \(functionElement.values.count)")
    
                    switch (functionElement.values.first!) {
                    case let .Function(inlineFunctionElement):
                        if inlineFunctionElement.bracketType == .InlineEntry &&
                        inlineFunctionElement.functionName == "A" {
                            
                            success = true
                            
                        }
                    default:
                        break
                    }
                    
                }
                
            default:
                break
            }
        }
        
        XCTAssert(success, "Found Errors when parsing inline entries")
        
    }
    
    func test_MixedUnaryFunctionAndStrings_CorrectParse() {
        let originalValue = "JamesGroup @\"JamesGroup\" JamesVariable @\"JamesVariable\""
        stringList.stringValue = originalValue
        
        XCTAssert(stringList.values.count == 4,"StringList should have 4 values, found \(stringList.values.count)")
        
        for (index,value) in stringList.values.enumerate() {
            switch (value) {
            case let .StringToken(stringElement):
                
                XCTAssert(index == 0 || index == 2,"String value should be in first or third position")
                
                if index == 0  {
                    XCTAssertEqual(stringElement.value, "JamesGroup", "String Value should be JamesGroup")
                } else if index == 2  {
                    XCTAssertEqual(stringElement.value, "JamesVariable", "String Value should be JamesVariable")
                }
            case let .Function(functionElement):
                if functionElement.bracketType == .Expression {
                    XCTAssert(functionElement.values.count == 2,"Unary Expression should have two values, found \(functionElement.values.count)")
                    
                    XCTAssert(index == 1 || index == 3,"Unary Expression should be in second or fourth position")
                    
                    switch (functionElement.values[0]) {
                    case let .StringToken(stringElement):
                        XCTAssertEqual(stringElement.value,"@","Wrong value")
                    default:
                        XCTAssert(false,"Wrong value")
                    }
                    
                    switch (functionElement.values[1]) {
                    case let .StringToken(stringElement):
                        if index == 1 {
                            XCTAssertEqual(stringElement.value,"JamesGroup","Wrong value")
                        } else if index == 3 {
                            XCTAssertEqual(stringElement.value,"JamesVariable","Wrong value")
                        }
                    default:
                        XCTAssert(false,"Wrong value")
                    }
                    
                }
                
            default:
                XCTAssert(false, "Non stringValue or functionElement found")
            }
        }
    }
    
    func testPercentageSignsAttachedToNumbers_remainAttachedToNumbersAfterParse() {
        let originalValue = "Center 100% Center 100% 0"
        stringList.stringValue = originalValue
        
        XCTAssertEqual(stringList.stringValue, originalValue, "Strings with percentage numbers should be reproduced without spaces in between")
    }

}
