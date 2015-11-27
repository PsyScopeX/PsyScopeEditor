//
//  PSAttributeParameter.swift
//  PsyScopeEditor
//
//  Created by James on 07/02/2015.
//

import Foundation

//holds a current value and references to controls on a PSCellView which modify that value
//can have default controls of label and varybyscript button - needs to be set up by PSAttributeParameterBuilder
public class PSAttributeParameter : NSObject {
    
    public static let defaultHeight : CGFloat = CGFloat(25)
    
    public var attributeSourceLabel : NSTextField?
    public var currentValue : String = "NULL"
    public var scriptData : PSScriptData!
    public var name : String = "Unknown"
    public var cell : PSCellView!
    public var attributeValueControlFrame : NSRect  = NSMakeRect(0, 0, 200, 20)
    public var varyByEntryName : String?  //if attribute is varying by another entry, it can be accessed here
    
    //override this to hide any borders if they appear ugly in table views etc
    public func hideBorders() {
        
    }
    
    //adds / sets up the attribute's control to the cell view
    public final func updateAttributeControl(attributeValueControlFrame : NSRect) {
        self.attributeValueControlFrame = attributeValueControlFrame
        if let scriptData = scriptData, attributedStringAndEntry = scriptData.identifyAsAttributeSourceAndReturnRepresentiveString(self.currentValue) {
            varyByEntryName = attributedStringAndEntry.1
            setupAttributeSourceLabel(attributedStringAndEntry.0)
            setCustomControl(false)
        } else {
            varyByEntryName = nil
            setupAttributeSourceLabel(nil)
            setCustomControl(true)
        }
    }
    
    //used to display generic view with icons (if block/attrib used)
    public final func setupAttributeSourceLabel(attributedString : NSAttributedString?) {
        if let attributedString = attributedString {
            if let attributeSourceLabel = attributeSourceLabel {
                attributeSourceLabel.hidden = false
            } else {

                attributeSourceLabel = NSTextField(frame: attributeValueControlFrame)
                attributeSourceLabel!.autoresizingMask = [NSAutoresizingMaskOptions.ViewWidthSizable, NSAutoresizingMaskOptions.ViewHeightSizable]
                attributeSourceLabel!.drawsBackground = false
                attributeSourceLabel!.selectable = false
                cell.addSubview(attributeSourceLabel!)
            }
            
            attributeSourceLabel!.attributedStringValue = attributedString
            attributeSourceLabel!.editable = false
        } else {
            if let attributeSourceLabel = attributeSourceLabel {
                attributeSourceLabel.hidden = true
            }
        }
    }
    
    //override this to display/hide a custom control for displaying and setting value
    public func setCustomControl(visible : Bool) {
        
    }
    
    public func clickMenuItem(sender : NSMenuItem) {
        if let scriptData = scriptData, val = scriptData.valueForMenuItem(sender, original: self.currentValue, originalFullType: nil) {
            
            
            self.currentValue = val
        } else {
            self.currentValue = ""
        }
        
        cell.updateScript()
    }
}
