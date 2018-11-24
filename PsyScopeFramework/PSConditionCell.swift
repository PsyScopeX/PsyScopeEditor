//
//  PSConditionCell.swift
//  PsyScopeEditor
//
//  Created by James on 09/02/2015.
//

import Foundation

open class PSConditionCell : PSCellView {
    open var entryFunction : PSFunctionElement!
    open var conditionInterface : PSConditionInterface!
    
    var alreadySetup : Bool = false
    var expandedHeight : CGFloat = 0
    var viewsToNotHide : [NSView] = []
    var disclosureButton : NSButton!
    var summaryLabel : NSTextField!
    open var expandAction : ((Bool) -> ())?
    
    func expandButtonClicked(_ button : NSButton) {
        if disclosureButton.state == NSOnState {
            setExpanded(true)
            expandAction!(true)
        } else {
            setExpanded(false)
            expandAction!(false)
        }
    }
    
    open func setExpanded(_ expanded : Bool) {
        if expanded {
            disclosureButton.state = NSOnState
            var new_frame = self.frame
            new_frame.size.height = expandedHeight
            self.frame = new_frame
            for view in self.subviews as [NSView] {
                view.isHidden = false
            }
            summaryLabel.isHidden = true
        } else {
            disclosureButton.state == NSOffState
            var new_frame = self.frame
            new_frame.size.height = 30
            self.frame = new_frame
            for view in self.subviews as [NSView] {
                var hidden = true
                for nh in viewsToNotHide {
                    if nh == view {
                        hidden = false
                        break
                    }
                }
                view.isHidden = hidden
            }
            summaryLabel.isHidden = false
        }
    }
    
    open func setup(_ conditionInterface : PSConditionInterface, function entryFunction : PSFunctionElement, scriptData : PSScriptData, expandedHeight : CGFloat) {
        self.conditionInterface = conditionInterface
        self.entryFunction = entryFunction
        self.scriptData = scriptData
        
        self.expandedHeight = expandedHeight

        self.autoresizesSubviews = true
        
        if !(alreadySetup) {
            let position = expandedHeight - 20
            
            //add disclosure button
            disclosureButton = NSButton(frame: NSMakeRect(0, position, 20, 20))
            disclosureButton.autoresizingMask = [NSAutoresizingMaskOptions.viewMaxXMargin, NSAutoresizingMaskOptions.viewMinYMargin]
            disclosureButton.bezelStyle = NSBezelStyle.disclosure
            disclosureButton.setButtonType(.pushOnPushOff)
            disclosureButton.title = ""
            disclosureButton.state = NSOffState
            disclosureButton.target = self
            disclosureButton.action = "expandButtonClicked:"
            self.addSubview(disclosureButton)
            viewsToNotHide.append(disclosureButton)
            
            
            //add title
            let title_label = NSTextField(frame: NSMakeRect(PSDefaultConstants.ActionsBuilder.headerLeftMargin, position, 100, 17))
            title_label.autoresizingMask = [NSAutoresizingMaskOptions.viewMaxXMargin, NSAutoresizingMaskOptions.viewMinYMargin]
            title_label.stringValue = conditionInterface.userFriendlyName()
            title_label.isBezeled = false
            title_label.drawsBackground = false
            title_label.isEditable = false
            title_label.isSelectable = false
            title_label.font = NSFont.boldSystemFont(ofSize: 12)
            self.addSubview(title_label)
            viewsToNotHide.append(title_label)
            
            
            //add summary label
            let width = self.frame.width - PSDefaultConstants.ActionsBuilder.summaryLabelLeftMargin - PSDefaultConstants.ActionsBuilder.controlsRightMargin
            summaryLabel = NSTextField(frame: NSMakeRect(PSDefaultConstants.ActionsBuilder.summaryLabelLeftMargin, position, width, 17))
            summaryLabel.autoresizingMask = [NSAutoresizingMaskOptions.viewMinYMargin, NSAutoresizingMaskOptions.viewWidthSizable]
            summaryLabel.alignment = NSTextAlignment.left
            
            summaryLabel.isBezeled = false
            summaryLabel.drawsBackground = false
            summaryLabel.isEditable = false
            summaryLabel.isSelectable = false
            summaryLabel.font = NSFont.systemFont(ofSize: 12)
            summaryLabel.cell!.lineBreakMode = NSLineBreakMode.byTruncatingTail
            
            self.addSubview(summaryLabel)
            self.alreadySetup = true
        }
        
        //get current value
        summaryLabel.stringValue = entryFunction.getParametersStringValue()
    }

}
