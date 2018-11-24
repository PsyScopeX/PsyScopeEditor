//
//  PSEntryValueControlDelegate.swift
//  PsyScopeEditor
//
//  Created by James on 03/08/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

@objc public protocol PSEntryValueControllerDelegate {
    //optional func control(controlShouldBeginEditing: PSEntryValueControl) -> Bool
    func control(_ controlShouldEndEditing: PSEntryValueController) -> Bool
    func getScriptData() -> PSScriptData
}
