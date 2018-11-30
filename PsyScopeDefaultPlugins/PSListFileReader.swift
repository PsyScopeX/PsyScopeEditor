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
    let delimiter = CharacterSet.whitespaces
    let newline = CharacterSet.newlines
    
    public init(contentsOfPath path: String) throws {
        let csvString: String?
        do {
            csvString = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
        } catch _ {
            csvString = nil
        }
        if let csvStringToParse = csvString {
            
            
            var lines: [String] = []
            csvStringToParse.trimmingCharacters(in: newline).enumerateLines { line, stop in lines.append(line) }
            
            self.rows = self.parseRows(fromLines: lines)
        }
    }
    
    public init(contentsOfPath path: String, forceNumberOfColumns : Int) throws {
        let csvString: String?
        do {
            csvString = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
        } catch _ {
            csvString = nil
        }
        if let csvStringToParse = csvString {
            
            
            var elements: [String] = []
            let delimiters = CharacterSet.whitespacesAndNewlines
            elements = csvStringToParse.components(separatedBy: delimiters)
            
            self.rows = []
            var colCounter : Int = 1
            var row : [String] = []
            for element in elements {
                row.append(element)
                colCounter += 1
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
        
        for line in lines {
            let row : [String] = line.components(separatedBy: self.delimiter)
            rows.append(row)
        }
        
        return rows
    }
}
