//
//  PSEntryValueControlDelegate.swift
//  PsyScopeEditor
//
//  Created by James on 03/08/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

@objc public protocol PSEntryValueControlDelegate {
    optional func control(controlShouldBeginEditing: PSEntryValueControl) -> Bool
    optional func control(controlShouldEndEditing: PSEntryValueControl) -> Bool
    func scriptData() -> PSScriptData
}