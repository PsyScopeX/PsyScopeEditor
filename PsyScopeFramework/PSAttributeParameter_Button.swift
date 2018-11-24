//
//  PSAttributeParameter_Button.swift
//  PsyScopeEditor
//
//  Created by James on 14/02/2015.
//

import Foundation

//displays a cell with a button - abstract to be overriden
open class PSAttributeParameter_Button : PSAttributeParameter {
    
    open var editButton : NSButton!
    open var displayValueTransformer : ((PSEntryElement) -> (String))? //can transform the display to make it prettier
    
    override open func setCustomControl(_ visible: Bool) {
        if visible {
            if editButton == nil {
                //add editButton
                editButton = NSButton(frame: attributeValueControlFrame)
                cell?.activateViewBlock = { self.editButton.performClick(self) }
                editButton.bezelStyle = NSButton.BezelStyle.roundRect
                let bcell = editButton.cell!
                bcell.lineBreakMode = NSLineBreakMode.byTruncatingTail
                bcell.backgroundStyle = NSView.BackgroundStyle.dark
                
                editButton.autoresizingMask = NSView.AutoresizingMask.width
                editButton.target = self
                editButton.action = #selector(PSAttributeParameter_Button.clickButton(_:))
                setButtonTitle()
                cell.addSubview(editButton)
            } else {
                editButton.isHidden = false
            }
            
            setButtonTitle()
        } else {
            if editButton != nil {
                editButton.isHidden = true
            }
        }
    }
    
    func setButtonTitle() {
        if currentValue == PSEntryElement.null {
            editButton.title = ""
        } else if let displayValueTransformer = displayValueTransformer {
            editButton.title = displayValueTransformer(currentValue)
        } else {
            editButton.title = currentValue.stringValue()
        }
    }
    
    @objc func clickButton(_ sender : NSButton) {
        fatalError("use of abstract class PSAttributeParameter_Button")
    }
}
