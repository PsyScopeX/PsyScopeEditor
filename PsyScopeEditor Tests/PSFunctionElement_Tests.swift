//
//  PSFunctionElement_Tests.swift
//  PsyScopeEditor
//
//  Created by James on 14/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation
import Cocoa
import XCTest

class PSFunctionElement_Tests: XCTestCase {
    
    var functionElement : PSFunctionElement!
    
    override func setUp() {
        super.setUp()
        functionElement = PSFunctionElement()
    }
    
    func test_PortNamesFunction_ExtractsCorrectPortName1() {
        functionElement.stringValue = "PortNames(\"Test\")"
        XCTAssert(functionElement.functionName == "PortNames", "Incorrect function name, found \(functionElement.functionName)")
        let params = functionElement.getParametersStringValue()
        XCTAssert(params == "\"Test\"", "Incorrect values, found \(params)")
        let stringValue = functionElement.stringValue
        XCTAssert(stringValue == "PortNames(\"Test\")", "Incorrect stringValue, found \(stringValue)")
        var values = functionElement.getStrippedStringValues()
        XCTAssert(values.count == 1, "Incorrect number of values, found \(values.count)")
        if values.count == 1 {
            XCTAssert(values[0] == "Test", "Incorrect values, found \(values[0])")
        }
    }
    
    func test_PortNamesFunction_ExtractsCorrectPortName2() {
        functionElement.stringValue = "PortNames(\"Test Test\")"
        XCTAssert(functionElement.functionName == "PortNames", "Incorrect function name, found \(functionElement.functionName)")
        let params = functionElement.getParametersStringValue()
        XCTAssert(params == "\"Test Test\"", "Incorrect values, found \(params)")
        let stringValue = functionElement.stringValue
        XCTAssert(stringValue == "PortNames(\"Test Test\")", "Incorrect stringValue, found \(stringValue)")
        var values = functionElement.getStrippedStringValues()
        XCTAssert(values.count == 1, "Incorrect number of values, found \(values.count)")
        if values.count == 1 {
            XCTAssert(values[0] == "Test Test", "Incorrect values, found \(values[0])")
        }
    }
    
    func test_InlineEntryWithLists_PutsItemsIntoCorrectSubFunction() {
        functionElement.stringValue = "[A: Item1 Item2 B: Item3 Item4]"
        XCTAssert(functionElement.functionName == "", "Function names should be empty")
        
        let correctNumberOfValues = functionElement.values.count == 2
        XCTAssert(correctNumberOfValues,"Function should have two values, found \(functionElement.values.count)")
    }
    
    func test_FunctionWithParametersAndInlineEntries_getStringValues() {
        functionElement.stringValue = "DoSomething[ Parameter1 Parameter2 InlineEntry: InlineEntryValue]"
        XCTAssertEqual("DoSomething", functionElement.functionName,"Function name incorrect")
        let values = functionElement.getStringValues()
        XCTAssertEqual(values.count, 3)
        if values.count != 3 { return }
        XCTAssertEqual(values[0], "Parameter1")
        XCTAssertEqual(values[1], "Parameter2")
        XCTAssertEqual(values[2], "InlineEntry:InlineEntryValue")
        
        var value3IsFunction = false
        
        if case .Function(let inlineFunctionElement) = functionElement.values[2] {
            value3IsFunction = true
            XCTAssertEqual(inlineFunctionElement.functionName, "InlineEntry")
            let inlineValues = inlineFunctionElement.getStringValues()
            XCTAssertEqual(inlineValues.count, 1)
            if inlineValues.count == 1 {
                XCTAssertEqual(inlineValues[0], "InlineEntryValue")
            }
        }
        
        XCTAssert(value3IsFunction, "Inline entry incorrectly parsed - third value should be a funciton")
    }
}