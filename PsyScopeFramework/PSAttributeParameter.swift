//
//  PSAttributeParameter.swift
//  PsyScopeEditor
//
//  Created by James on 07/02/2015.
//

import Foundation

//holds a current value and references to controls on a PSCellView which modify that value
//can have default controls of label and varybyscript button - needs to be set up by PSAttributeParameterBuilder
open class PSAttributeParameter : NSObject {
    
    open static let defaultHeight : CGFloat = CGFloat(25)
    
    open var attributeSourceLabel : NSTextField?
    open var currentValue : PSEntryElement = .stringToken(stringElement: PSStringElement(value: "NULL", quotes: .none))
    open var scriptData : PSScriptData!
    open var name : String = "Unknown"
    open var cell : PSCellView!
    open var attributeValueControlFrame : NSRect  = NSMakeRect(0, 0, 200, 20)
    open var varyByEntryName : String?  //if attribute is varying by another entry, it can be accessed here
    open var attributeType : PSAttributeType?
    
    //override this to hide any borders if they appear ugly in table views etc
    open func hideBorders() {
        
    }
    
    //adds / sets up the attribute's control to the cell view
    public final func updateAttributeControl(_ attributeValueControlFrame : NSRect) {
        self.attributeValueControlFrame = attributeValueControlFrame
        if let scriptData = scriptData, let attributedStringAndEntry = scriptData.identifyAsAttributeSourceAndReturnRepresentiveString(self.currentValue.stringValue()) {
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
    public final func setupAttributeSourceLabel(_ attributedString : NSAttributedString?) {
        if let attributedString = attributedString {
            if let attributeSourceLabel = attributeSourceLabel {
                attributeSourceLabel.isHidden = false
            } else {

                attributeSourceLabel = NSTextField(frame: attributeValueControlFrame)
                attributeSourceLabel!.autoresizingMask = [NSView.AutoresizingMask.width, NSView.AutoresizingMask.height]
                attributeSourceLabel!.drawsBackground = false
                attributeSourceLabel!.isSelectable = false
                cell.addSubview(attributeSourceLabel!)
            }
            
            attributeSourceLabel!.attributedStringValue = attributedString
            attributeSourceLabel!.isEditable = false
        } else {
            if let attributeSourceLabel = attributeSourceLabel {
                attributeSourceLabel.isHidden = true
            }
        }
    }
    
    //override this to display/hide a custom control for displaying and setting value
    open func setCustomControl(_ visible : Bool) {
        
    }
    
    open func clickMenuItem(_ sender : NSMenuItem) {
        if let scriptData = scriptData, let val = scriptData.valueForMenuItem(sender, original: self.currentValue.stringValue(), originalFullType: attributeType) , let entryElement = PSGetFirstEntryElementForString(val) {
            self.currentValue = entryElement
            cell.updateScript()
            return
            
        }
        self.currentValue = .stringToken(stringElement: PSStringElement(value: "NULL", quotes: .none))
        cell.updateScript()
    }
}
