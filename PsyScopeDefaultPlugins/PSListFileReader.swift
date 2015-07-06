//
//  PSListFileReader.swift
//  PsyScopeEditor
//
//  Created by James on 26/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation
import Cocoa

public class PSListFileReader {

    public var rows: [[String]] = []
    let delimiter = NSCharacterSet.whitespaceCharacterSet()
    let newline = NSCharacterSet.newlineCharacterSet()
    
    public init(contentsOfPath path: String) throws {
        let csvString: String?
        do {
            csvString = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
        } catch _ {
            csvString = nil
        }
        if let csvStringToParse = csvString {
            
            
            var lines: [String] = []
            csvStringToParse.stringByTrimmingCharactersInSet(newline).enumerateLines { line, stop in lines.append(line) }
            
            self.rows = self.parseRows(fromLines: lines)
        }
    }
    
    public init(contentsOfPath path: String, forceNumberOfColumns : Int) throws {
        let csvString: String?
        do {
            csvString = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
        } catch _ {
            csvString = nil
        }
        if let csvStringToParse = csvString {
            
            
            var elements: [String] = []
            let delimiters = NSCharacterSet.whitespaceAndNewlineCharacterSet()
            elements = csvStringToParse.componentsSeparatedByCharactersInSet(delimiters)
            
            self.rows = []
            var colCounter : Int = 1
            var row : [String] = []
            for element in elements {
                row.append(element)
                colCounter++
                if colCounter > forceNumberOfColumns {
                    colCounter = 1
                    rows.append(row)
                    row = []
                }
            }
        }
    }
    
    
    public var numberOfColumnsInFirstRow : Int {
        if let firstRow = rows.first {
            return firstRow.count
        } else {
            return 0
        }
    }

    
    func parseRows(fromLines lines: [String]) -> [[String]] {
        var rows: [[String]] = []
        
        for (lineNumber, line) in lines.enumerate() {
            let row : [String] = line.componentsSeparatedByCharactersInSet(self.delimiter)
            rows.append(row)
        }
        
        return rows
    }
}