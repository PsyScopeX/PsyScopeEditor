//
//  PSAttributeParameter_Button.swift
//  PsyScopeEditor
//
//  Created by James on 14/02/2015.
//

import Foundation

//displays a cell with a button - abstract to be overriden
public class PSAttributeParameter_Button : PSAttributeParameter {
    
    public var editButton : NSButton!
    public var displayValueTransformer : ((PSEntryElement) -> (String))? //can transform the display to make it prettier
    
    override public func setCustomControl(visible: Bool) {
        if visible {
            if editButton == nil {
                //add editButton
                editButton = NSButton(frame: attributeValueControlFrame)
                cell?.activateViewBlock = { self.editButton.performClick(self) }
                editButton.bezelStyle = NSBezelStyle.RoundRectBezelStyle
                let bcell = editButton.cell!
                bcell.lineBreakMode = NSLineBreakMode.ByTruncatingTail
                bcell.backgroundStyle = NSBackgroundStyle.Dark
                
                editButton.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable
                editButton.target = self
                editButton.action = "clickButton:"
                setButtonTitle()
                cell.addSubview(editButton)
            } else {
                editButton.hidden = false
            }
            
            setButtonTitle()
        } else {
            if editButton != nil {
                editButton.hidden = true
            }
        }
    }
    
    func setButtonTitle() {
        if currentValue == PSEntryElement.Null {
            editButton.title = ""
        } else if let displayValueTransformer = displayValueTransformer {
            editButton.title = displayValueTransformer(currentValue)
        } else {
            editButton.title = currentValue.stringValue()
        }
    }
    
    func clickButton(sender : NSButton) {
        fatalError("use of abstract class PSAttributeParameter_Button")
    }
}