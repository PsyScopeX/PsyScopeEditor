//
//  PSActionCell.swift
//  PsyScopeEditor
//
//  Created by James on 09/02/2015.
//

import Foundation

//a view which represents an action
public class PSActionCell : PSCellView {
    
    //MARK: Publics
    
    public var entryFunction : PSEventActionFunction!
    public var actionInterface : PSActionInterface!
    public var actionParameters : [PSAttributeParameter] = []
    public var expandAction : (Bool -> ())? //used to tie events when cell is expanded (e.g. recording that)
    
    
    //MARK: Privates
    
    var expandedHeight : CGFloat = 0
    var viewsToNotHide : [NSView] = []
    var disclosureButton : NSButton!
    var summaryLabel : NSTextField!
    var instancesParameter : PSAttributeParameter_Int?
    var activeUntilParameter : PSAttributeParameter_ActiveUntil?
    
    
    override public func updateScript() {
        
        //add parameters for action's function
        var values : [String] = []
        for p in actionParameters {
            values.append(p.currentValue)
        }
        
        let instances : String? = instancesParameter?.currentValue
        let activeUntil : String? = activeUntilParameter?.currentValue
        
        entryFunction.setActionParameterValues(values,instances: instances, activeUntil: activeUntil)
        
        //add inline sub entries
        super.updateScript()
    }
    
    func expandButtonClicked(button : NSButton) {
        if disclosureButton.state == NSOnState {
            setExpanded(true)
            expandAction?(true)
        } else {
            setExpanded(false)
            expandAction?(false)
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
    
    public func setup(actionInterface : PSActionInterface, entryFunction : PSEventActionFunction, scriptData : PSScriptData, parameters : [NSObject.Type], names: [String], expandedHeight : CGFloat) {
        
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
        let title_label = NSTextField(frame: NSMakeRect(PSDefaultConstants.ActionsBuilder.headerLeftMargin, topYPosition, 100, 17))
        title_label.autoresizingMask = [NSAutoresizingMaskOptions.ViewMaxXMargin, NSAutoresizingMaskOptions.ViewMinYMargin]
        title_label.stringValue = actionInterface.userFriendlyName()
        title_label.bezeled = false
        title_label.drawsBackground = false
        title_label.editable = false
        title_label.selectable = false
        title_label.font = NSFont.boldSystemFontOfSize(12)
        self.addSubview(title_label)
        viewsToNotHide.append(title_label)
        
        
        //add summary label
        let width = self.frame.width - PSDefaultConstants.ActionsBuilder.summaryLabelLeftMargin - PSDefaultConstants.ActionsBuilder.controlsRightMargin
        summaryLabel = NSTextField(frame: NSMakeRect(PSDefaultConstants.ActionsBuilder.summaryLabelLeftMargin, topYPosition, width, 17))
        summaryLabel.autoresizingMask = [NSAutoresizingMaskOptions.ViewMinYMargin, NSAutoresizingMaskOptions.ViewWidthSizable]
        summaryLabel.alignment = NSTextAlignment.Left
        summaryLabel.bezeled = false
        summaryLabel.drawsBackground = false
        summaryLabel.editable = false
        summaryLabel.selectable = false
        summaryLabel.font = NSFont.systemFontOfSize(12)
        summaryLabel.cell!.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        self.addSubview(summaryLabel)
        
        
        
        summaryLabel.stringValue = entryFunction.getParametersStringValue()
        
        //add parameters
        for (index,actionParameter) in parameters.enumerate() {
            if let ap = actionParameter.init() as? PSAttributeParameter {
                topYPosition -= PSAttributeParameter.defaultHeight
                
                //automatically adds to view
                let builder = PSAttributeParameterBuilder(parameter: ap)
                builder.setupMultiCell(names[index], y: topYPosition, cell: self, currentValue: entryFunction.currentValues[index])
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
            builder.setupMultiCell("Instances", y: topYPosition, cell: self, currentValue: instances)
            
            topYPosition -= PSAttributeParameter.defaultHeight
            
            //activeuntil
            activeUntilParameter = PSAttributeParameter_ActiveUntil()
            let activeUntil = entryFunction.activeUntilValue != nil ? entryFunction.activeUntilValue! : "NONE"
            let builder2 = PSAttributeParameterBuilder(parameter: activeUntilParameter!)
            builder2.setupMultiCell("ActiveUntil", y: topYPosition, cell: self, currentValue: activeUntil)
        }
        
        
    }
}
