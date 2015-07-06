//
//  PSCellView.swift
//  PsyScopeEditor
//
//  Created by James on 09/02/2015.
//

import Foundation

//a custom view which can be activated with a custom block,
//and holds scriptData, and updates script with custom block
public class PSCellView : NSView {
    public var scriptData : PSScriptData!
    public var activateViewBlock : (() -> ())?
    public var updateScriptBlock : (() -> ())!
    
    
    public func activate() {
        if let activateViewBlock = activateViewBlock {
            activateViewBlock()
        }
    }
    
    public func updateScript() {
        if let updateScriptBlock = updateScriptBlock {
            updateScriptBlock()
        }
    }
}
