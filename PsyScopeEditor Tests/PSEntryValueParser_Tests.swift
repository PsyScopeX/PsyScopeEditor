//
//  PSEntryValueParser_Tests.swift
//  PsyScopeEditor
//
//  Created by James on 01/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Cocoa
import XCTest

class PSEntryValueParser_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testConditionActionsArrowHasNoSurroundingSpaces_CorrectParse() {
        var value = "Conditions[Start[]]=>Actions[\t\t\t\r\t\t\tBeep[ Boing ]\t\t\t ]"
        var parser = PSEntryValueParser(stringValue: value)
        XCTAssert(!parser.foundErrors, "Parser found errors - should be able to parse this value: \(value)")
        
        var correctValueType = false
        if let val = parser.values.first {
            switch(val) {
            case .Null:
                break
            case let .StringToken(stringElement):
                break
            case let .List(stringListElement):
                break
            case let .Function(functionElement):
                if functionElement.functionName == "" && functionElement.bracketType == .Expression {
                    correctValueType = true
                    
                }
                break
            }
        }
        

        XCTAssert(correctValueType, "Parser did not create correct value type)")
        
    }
    
    
    func testConditionActionsArrowWithSurroundingSpaces_CorrectParse() {
        var value = "Conditions[Start[]] => Actions[\t\t\t\r\t\t\tBeep[ Boing ]\t\t\t ]"
        var parser = PSEntryValueParser(stringValue: value)
        XCTAssert(!parser.foundErrors, "Parser found errors - should be able to parse this value: \(value)")
        
        var correctValueType = false
        if let val = parser.values.first {
            switch(val) {
            case .Null:
                break
            case let .StringToken(stringElement):
                break
            case let .List(stringListElement):
                break
            case let .Function(functionElement):
                if functionElement.functionName == "" && functionElement.bracketType == .Expression {
                    correctValueType = true
                }
                break
            }
        }
        
        
        XCTAssert(correctValueType, "Parser did not create correct value type)")
    }
    
    func testPercentageSignsAttachedToNumbers_createStringValuesWithPercentageNumber() {
        let originalValue = "100% 50%"
        let parser = PSEntryValueParser(stringValue: originalValue)
        XCTAssert(!parser.foundErrors, "Parser found errors - should be able to parse this value: \(originalValue)")
        
        XCTAssertEqual(parser.values.count, 2, "There should be only two values")
        
        if parser.values.count < 1 { return}
        
        var firstElementCorrect = false
        switch(parser.values[0]) {
        case let .StringToken(stringElement):
            XCTAssertEqual(stringElement.value, "100%" , "First Element incorrect")
            if stringElement.value == "100%" {
                firstElementCorrect = true
            }
        default:
            break
        }
        
        XCTAssert(firstElementCorrect, "First Element incorrect")
        
        if parser.values.count < 2 { return}
        
        var secondElementCorrect = false
        switch(parser.values[1]) {
        case let .StringToken(stringElement):
            XCTAssertEqual(stringElement.value, "50%" , "Second Element incorrect")
            if stringElement.value == "100%" {
                secondElementCorrect = true
            }
        default:
            break
        }
        
        XCTAssert(firstElementCorrect, "Second Element incorrect")
    }
    
}
