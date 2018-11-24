//
//  PSModalAlert.swift
//  PsyScopeEditor
//
//  Created by James on 14/02/2015.
//

import Cocoa

public func PSModalAlert(_ text : String) {
    let new_alert = NSAlert()
    new_alert.messageText = text
    new_alert.runModal()
}
