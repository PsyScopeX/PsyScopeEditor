//
//  PSConditionCell.swift
//  PsyScopeEditor
//
//  Created by James on 09/02/2015.
//

import Foundation

public class PSConditionCell : PSCellView {
    public var entryFunction : PSFunctionElement!
    public var conditionInterface : PSConditionInterface!
    
    var alreadySetup : Bool = false
    var expandedHeight : CGFloat = 0
    var viewsToNotHide : [NSView] = []
    var disclosureButton : NSButton!
    var summaryLabel : NSTextField!
    public var expandAction : (Bool -> ())?
    
    func expandButtonClicked(button : NSButton) {
        if disclosureButton.state == NSOnState {
            setExpanded(true)
            expandAction!(true)
        } else {
            setExpanded(false)
            expandAction!(false)
        }
    }
    
    public func setExpanded(expanded : Bool) {
        if expanded {
            disclosureButton.state = NSOnState
            var new_frame = self.frame
            new_frame.size.height = expandedHeight
            self.frame = new_frame
            for view in self.subviews as [NSView] {
                view.hidden = false
            }
            summaryLabel.hidden = true
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
                view.hidden = hidden
            }
            summaryLabel.hidden = false
        }
    }
    
    public func setup(conditionInterface : PSConditionInterface, function entryFunction : PSFunctionElement, scriptData : PSScriptData, expandedHeight : CGFloat) {
        self.conditionInterface = conditionInterface
        self.entryFunction = entryFunction
        self.scriptData = scriptData
        
        self.expandedHeight = expandedHeight

        self.autoresizesSubviews = true
        
        if !(alreadySetup) {
            let position = expandedHeight - 20
            
            //add disclosure button
            disclosureButton = NSButton(frame: NSMakeRect(0, position, 20, 20))
            disclosureButton.autoresizingMask = [NSAutoresizingMaskOptions.ViewMaxXMargin, NSAutoresizingMaskOptions.ViewMinYMargin]
            disclosureButton.bezelStyle = NSBezelStyle.DisclosureBezelStyle
            disclosureButton.setButtonType(.PushOnPushOffButton)
            disclosureButton.title = ""
            disclosureButton.state = NSOffState
            disclosureButton.target = self
            disclosureButton.action = "expandButtonClicked:"
            self.addSubview(disclosureButton)
            viewsToNotHide.append(disclosureButton)
            
            
            //add title
            let title_label = NSTextField(frame: NSMakeRect(PSDefaultConstants.ActionsBuilder.headerLeftMargin, position, 100, 17))
            title_label.autoresizingMask = [NSAutoresizingMaskOptions.ViewMaxXMargin, NSAutoresizingMaskOptions.ViewMinYMargin]
            title_label.stringValue = conditionInterface.userFriendlyName()
            title_label.bezeled = false
            title_label.drawsBackground = false
            title_label.editable = false
            title_label.selectable = false
            title_label.font = NSFont.boldSystemFontOfSize(12)
            self.addSubview(title_label)
            viewsToNotHide.append(title_label)
            
            
            //add summary label
            let width = self.frame.width - PSDefaultConstants.ActionsBuilder.summaryLabelLeftMargin - PSDefaultConstants.ActionsBuilder.controlsRightMargin
            summaryLabel = NSTextField(frame: NSMakeRect(PSDefaultConstants.ActionsBuilder.summaryLabelLeftMargin, position, width, 17))
            summaryLabel.autoresizingMask = [NSAutoresizingMaskOptions.ViewMinYMargin, NSAutoresizingMaskOptions.ViewWidthSizable]
            summaryLabel.alignment = NSTextAlignment.Left
            
            summaryLabel.bezeled = false
            summaryLabel.drawsBackground = false
            summaryLabel.editable = false
            summaryLabel.selectable = false
            summaryLabel.font = NSFont.systemFontOfSize(12)
            summaryLabel.cell!.lineBreakMode = NSLineBreakMode.ByTruncatingTail
            
            self.addSubview(summaryLabel)
            self.alreadySetup = true
        }
        
        //get current value
        summaryLabel.stringValue = entryFunction.getParametersStringValue()
    }

}