//
//  PSCellView.swift
//  PsyScopeEditor
//
//  Created by James on 09/02/2015.
//

import Foundation

//a custom view which can be activated with a custom block,
//and holds scriptData, and updates script with custom block
open class PSCellView : NSView {
    open var scriptData : PSScriptData!
    open var activateViewBlock : (() -> ())?
    open var updateScriptBlock : (() -> ())!
    
    
    open func activate() {
        if let activateViewBlock = activateViewBlock {
            activateViewBlock()
        }
    }
    
    open func updateScript() {
        if let updateScriptBlock = updateScriptBlock {
            updateScriptBlock()
        }
    }
}
