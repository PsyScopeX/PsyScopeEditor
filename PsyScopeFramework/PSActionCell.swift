//
//  PSActionCell.swift
//  PsyScopeEditor
//
//  Created by James on 09/02/2015.
//

import Foundation

//a view which represents an action
open class PSActionCell : PSCellView {
    
    //MARK: Publics
    
    open var entryFunction : PSEventActionFunction!
    open var actionInterface : PSActionInterface!
    open var actionParameters : [PSAttributeParameter] = []
    open var expandAction : ((Bool) -> ())? //used to tie events when cell is expanded (e.g. recording that)
    
    
    //MARK: Privates
    
    var expandedHeight : CGFloat = 0
    var viewsToNotHide : [NSView] = []
    var disclosureButton : NSButton!
    var summaryLabel : NSTextField!
    var instancesParameter : PSAttributeParameter_Int?
    var activeUntilParameter : PSAttributeParameter_ActiveUntil?
    
    
    override open func updateScript() {
        
        //add parameters for action's function
        var values : [PSEntryElement] = []
        for p in actionParameters {
            values.append(p.currentValue)
        }
        
        //if we have blanks but later on there are values, then make the blanks NULL
        //find last element with value
        let nElements = values.count
        var indexOfLastValue = 0
        for indexOfLastValue = (nElements - 1); indexOfLastValue > 0; --indexOfLastValue {
            if values[indexOfLastValue] != PSEntryElement.null {
                break
            }
        }
        
        
        let instances : String? = instancesParameter?.currentValue.stringValue()
        let activeUntil : String? = activeUntilParameter?.currentValue.stringValue()
        
        entryFunction.setActionParameterValues(values,instances: instances, activeUntil: activeUntil)
        
        //add inline sub entries
        super.updateScript()
    }
    
    func expandButtonClicked(_ button : NSButton) {
        if disclosureButton.state == NSOnState {
            setExpanded(true)
            expandAction?(true)
        } else {
            setExpanded(false)
            expandAction?(false)
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
    
    open func setup(_ actionInterface : PSActionInterface, entryFunction : PSEventActionFunction, scriptData : PSScriptData, parameters : [NSObject.Type], names: [String], expandedHeight : CGFloat) {
        
        //setup dependencies
        self.actionInterface = actionInterface
        self.entryFunction = entryFunction
        self.scriptData = scriptData
        self.expandedHeight = expandedHeight
        
        self.autoresizesSubviews = true
        
        var topYPosition = expandedHeight - 20

        Swift.print(topYPosition.description)
        //add disclosure button
        disclosureButton = NSButton(frame: NSMakeRect(0, topYPosition, 20, 20))
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
        let title_label = NSTextField(frame: NSMakeRect(PSDefaultConstants.ActionsBuilder.headerLeftMargin, topYPosition, 100, 17))
        title_label.autoresizingMask = [NSAutoresizingMaskOptions.viewMaxXMargin, NSAutoresizingMaskOptions.viewMinYMargin]
        title_label.stringValue = actionInterface.userFriendlyName()
        title_label.isBezeled = false
        title_label.drawsBackground = false
        title_label.isEditable = false
        title_label.isSelectable = false
        title_label.font = NSFont.boldSystemFont(ofSize: 12)
        self.addSubview(title_label)
        viewsToNotHide.append(title_label)
        
        
        //add summary label
        let width = self.frame.width - PSDefaultConstants.ActionsBuilder.summaryLabelLeftMargin - PSDefaultConstants.ActionsBuilder.controlsRightMargin
        summaryLabel = NSTextField(frame: NSMakeRect(PSDefaultConstants.ActionsBuilder.summaryLabelLeftMargin, topYPosition, width, 17))
        summaryLabel.autoresizingMask = [NSAutoresizingMaskOptions.viewMinYMargin, NSAutoresizingMaskOptions.viewWidthSizable]
        summaryLabel.alignment = NSTextAlignment.left
        summaryLabel.isBezeled = false
        summaryLabel.drawsBackground = false
        summaryLabel.isEditable = false
        summaryLabel.isSelectable = false
        summaryLabel.font = NSFont.systemFont(ofSize: 12)
        summaryLabel.cell!.lineBreakMode = NSLineBreakMode.byTruncatingTail
        self.addSubview(summaryLabel)
        
        
        
        summaryLabel.stringValue = entryFunction.getParametersStringValue()
        
        //add parameters
        for (index,actionParameter) in parameters.enumerated() {
            if let ap = actionParameter.init() as? PSAttributeParameter {
                topYPosition -= PSAttributeParameter.defaultHeight
                
                //automatically adds to view
                let builder = PSAttributeParameterBuilder(parameter: ap)
                var currentValue : PSEntryElement
                if index < entryFunction.values.count {
                    currentValue = entryFunction.values[index]
                } else {
                    currentValue = .null
                }
                builder.setupMultiCell(names[index], y: topYPosition, cell: self, currentValue: currentValue, type: nil)
                self.actionParameters.append(ap)
            }
        }
        
        //add instances and active until if relevent
        if entryFunction.hasInstancesOrActiveUntilValueAttributes {
            topYPosition -= PSAttributeParameter.defaultHeight
            
            //isntances
            instancesParameter = PSAttributeParameter_Int()
            let instances = entryFunction.instancesValue != nil ? "\(entryFunction.instancesValue!)" : "1"
            let builder = PSAttributeParameterBuilder(parameter: instancesParameter!)
            builder.setupMultiCell("Instances", y: topYPosition, cell: self, currentValue: PSGetFirstEntryElementForStringOrNull(instances), type: nil)
            
            topYPosition -= PSAttributeParameter.defaultHeight
            
            //activeuntil
            activeUntilParameter = PSAttributeParameter_ActiveUntil()
            let activeUntil = entryFunction.activeUntilValue != nil ? entryFunction.activeUntilValue! : "NONE"
            let builder2 = PSAttributeParameterBuilder(parameter: activeUntilParameter!)
            builder2.setupMultiCell("ActiveUntil", y: topYPosition, cell: self, currentValue: PSGetFirstEntryElementForStringOrNull(activeUntil), type: nil)
        }
        
        
    }
}
