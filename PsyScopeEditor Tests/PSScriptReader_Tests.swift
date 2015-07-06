//
//  PSScriptReader_Tests.swift
//  PsyScopeEditor
//
//  Created by James on 09/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Cocoa
import XCTest

class PSScriptReader_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //method_input_output

    func testScriptReader_EmptyString_EmptyGhostScript() {
        var input = ""
        var reader = PSScriptReader(script: input)
        var success = reader.ghostScript.entries.count == 0
        XCTAssert(success, "Pass")
    }

    func testScriptReader_SingleEmptyEntry_SingleGhostEntry() {
        var input = "Hello::"
        var reader = PSScriptReader(script: input)
        var success = reader.ghostScript.entries.count == 1
        let entry = reader.ghostScript.entries[0]
        success = success && entry.name == "Hello"
        success = success && entry.subEntries.count == 0
        success = success && entry.currentValue == ""
        XCTAssert(success)
    }
    
    func testScriptReader_TwoEmptyEntries_TwoGhostEntries() {
        var input = "Hello::\nHello2::"
        var reader = PSScriptReader(script: input)
        
        let nEntries = reader.ghostScript.entries.count == 2
        XCTAssert(nEntries, "Two entries should be created")
        
        
        if nEntries {
            let entries = reader.ghostScript.entries
            
            XCTAssert(entries[0].name == "Hello","First entry name should be Hello")
            XCTAssert(entries[0].subEntries.count == 0, "First entry should have no sub entries")
            XCTAssert(entries[0].currentValue == "", "First entry should have empty current value")

            XCTAssert(entries[1].name == "Hello2","Second entry name should be Hello2")
            XCTAssert(entries[1].subEntries.count == 0, "Second entry should have no sub entries")
            XCTAssert(entries[1].currentValue == "", "Second entry should have empty current value")
        }
    }
    
    func testScriptReader_SpaceAfterEntryName_StillParsesEntryName() {
        var input = "\"Tobii Lower Right YCoordinate\" :: 1200\nType: Number\nDialog: Standard\nDefault: 1200"
        var reader = PSScriptReader(script: input)
        
        let noErrors = reader.errors.count == 0
        XCTAssert(noErrors, "There should be no errors")
        
        let nEntries = reader.ghostScript.entries.count == 1
        XCTAssert(nEntries, "One entry should be created")
        if nEntries {
            let entries = reader.ghostScript.entries
            let nSubEntries = entries[0].subEntries.count == 3
            XCTAssert(nEntries, "Three sub entries should be created")
        }
    }
    
    func testScriptReader_ExtraQuoteInEntryName_ProducesError() {
        var input = "\"Tobii Lower \"Right YCoordinate\" :: 1200"
        var reader = PSScriptReader(script: input)
        
        let noErrors = reader.errors.count == 0
        XCTAssert(!noErrors, "There should be an error")
        
        let noEntries = reader.ghostScript.entries.count == 0
        XCTAssert(noEntries, "No entries should be created")
    }
    
    func testScriptReader_NoFinalQuoteInEntryName_ProducesError() {
        var input = "\"Tobii Lower Right YCoordinate :: 1200"
        var reader = PSScriptReader(script: input)
        
        let noErrors = reader.errors.count == 0
        XCTAssert(!noErrors, "There should be an error")
        
        let noEntries = reader.ghostScript.entries.count == 0
        XCTAssert(noEntries, "No entries should be created")
    }
    
    func testScriptReader_NoBeginingQuoteInEntryName_ProducesError() {
        var input = "Tobii Lower Right YCoordinate\" :: 1200"
        var reader = PSScriptReader(script: input)
        
        let noErrors = reader.errors.count == 0
        XCTAssert(!noErrors, "There should be an error")
        
        let noEntries = reader.ghostScript.entries.count == 0
        XCTAssert(noEntries, "No entries should be created")
    }
    
    func testScriptReader_EntryLineWithComment_PopulatesComment() {
        var input = "\"Tobii Lower Right YCoordinate\" :: 1200 # Helloooo!"
        var reader = PSScriptReader(script: input)
        
        let noErrors = reader.errors.count == 0
        XCTAssert(noErrors, "There should be no errors")
        
        let oneEntry = reader.ghostScript.entries.count == 1
        XCTAssert(oneEntry, "No entries should be created")
        
        if oneEntry {
            let expectedComment = " Helloooo!"
            let entries = reader.ghostScript.entries
            let comentCorrect = entries[0].comments == expectedComment
            XCTAssert(comentCorrect, "Comment was incorrect, expected \(expectedComment) found \(entries[0].comments)")
        }
    }
    
    func testScriptReader_EntryLineWithComment_PopulatesCorrectComment() {
        var input = "\"Tobii Lower Right YCoordinate\" :: 1200 # Helloooo!\n# Not this one"
        var reader = PSScriptReader(script: input)
        
        let noErrors = reader.errors.count == 0
        XCTAssert(noErrors, "There should be no errors")
        
        let oneEntry = reader.ghostScript.entries.count == 1
        XCTAssert(oneEntry, "No entries should be created")
        
        if oneEntry {
            let expectedComment = " Helloooo!"
            let entries = reader.ghostScript.entries
            let comentCorrect = entries[0].comments == expectedComment
            XCTAssert(comentCorrect, "Comment was incorrect, expected \(expectedComment) found \(entries[0].comments)")
        }
    }
    
    func testScriptReader_EntryLineWithNoComment_HasNoComment() {
        var input = "\"Tobii Lower Right YCoordinate\" :: 1200 \n# Not this comment\n# Nor this one"
        var reader = PSScriptReader(script: input)
        
        let noErrors = reader.errors.count == 0
        XCTAssert(noErrors, "There should be no errors")
        
        let oneEntry = reader.ghostScript.entries.count == 1
        XCTAssert(oneEntry, "No entries should be created")
        
        if oneEntry {
            let expectedComment = ""
            let entries = reader.ghostScript.entries
            let comentCorrect = entries[0].comments == expectedComment
            XCTAssert(comentCorrect, "Comment was incorrect, expected \(expectedComment) found \(entries[0].comments)")
        }
    }
    

    func testScriptReader_EntryLineWithCommentInBrackets_HasNoCommentInValue() {
        var input = "Hello:: [\n#Comment\n]\n\n#Comment2"
        let expectedValue = "[]"
        var reader = PSScriptReader(script: input)
        
        let noErrors = reader.errors.count == 0
        XCTAssert(noErrors, "There should be no errors")
        
        let oneEntry = reader.ghostScript.entries.count == 1
        XCTAssert(oneEntry, "No entries should be created")
        
        if oneEntry {
            let entries = reader.ghostScript.entries
            let correctValue = entries[0].currentValue == expectedValue
            XCTAssert(correctValue, "Value was incorrect, expected \(expectedValue) found \(entries[0].currentValue)")
        }
    }
    
    func testScriptReader_TestScript1_HasNoErrors() {
        var path = NSBundle(forClass: self.dynamicType).pathForResource("TestScript1", ofType: "") as String!
        do {
            let theFile : String = try String(contentsOfFile:path, encoding: NSUTF8StringEncoding)
            var reader = PSScriptReader(script: theFile)
            
            for entry in reader.ghostScript.entries {
                testghostEntry(entry)
            }
            
            XCTAssert(reader.errors.count == 0, "The script had errors...")
        } catch _ {
        }
    }
    
    
    func testghostEntry(ghostEntry : PSGhostEntry) {
        let parser = PSEntryValueParser(stringValue: ghostEntry.currentValue)
        XCTAssert(parser.foundErrors == false, "The script had an error with entry value: \(ghostEntry.currentValue)")
        for entry in ghostEntry.subEntries {
            testghostEntry(entry)
        }
    }
}
