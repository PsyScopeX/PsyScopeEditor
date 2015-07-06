//
//  String.swift
//  PsyScopeEditor
//
//  Created by James on 16/09/2014.
//

import Foundation

extension String {
    func stringTrimmedOfWhiteSpace() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}