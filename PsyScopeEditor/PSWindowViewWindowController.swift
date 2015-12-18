//
//  PSWindowViewWindowController.swift
//  PsyScopeEditor
//
//  Created by James on 17/12/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

class PSWindowViewWindowController : NSWindowController, NSWindowDelegate, NSSplitViewDelegate {
    
    @IBOutlet var leftPanel : NSView!
    @IBOutlet var midPanel : NSView!
    
    var scriptData : PSScriptData!
    var leftView : NSView!
    var rightView : NSView!
    var tabDelegate : PSDocumentTabDelegate!
    
    func setup(scriptData : PSScriptData, leftView : NSView?, rightView : NSView, tabDelegate : PSDocumentTabDelegate) {
        self.scriptData = scriptData
        self.leftView = leftView
        self.rightView = rightView
        self.tabDelegate = tabDelegate
        scriptData.addWindowController(self)
        
    }
    
    override func awakeFromNib() {
        if let leftView = leftView {
            leftPanel.addSubview(leftView)
            leftView.frame = leftPanel.bounds
        } else {
            leftPanel.hidden = true
        }
        
        midPanel.addSubview(rightView)
        
        rightView.frame = midPanel.bounds
    }
    
    func windowWillClose(notification: NSNotification) {
        tabDelegate.reattachWindow(self)
        scriptData.removeWindowController(self)
    }
    
    let leftPanelThickness : CGFloat = CGFloat(PSConstants.LayoutConstants.leftPanelSize)
    
    func splitView(splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        if subview == leftPanel { return true }
        return false
    }
    
    func splitView(splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        if dividerIndex == 0 {
            //first divider
            return leftPanelThickness
        }
        return 0;
    }
    
    func splitView(splitView: NSSplitView, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        if dividerIndex == 0 {
            //first divider
            return leftPanelThickness
        }
        return 0;
    }
    
    func splitView(splitView: NSSplitView, resizeSubviewsWithOldSize oldSize: NSSize) {
        //var horizontalDiff : CGFloat = splitView.bounds.width - oldSize.width
        //var verticalDiff : CGFloat = splitView.bounds.width - oldSize.height
        
        var oLeftFrame = leftPanel.frame
        var oMiddleFrame = midPanel.frame
        let nFrame = splitView.frame
        
        let dThickness : CGFloat = splitView.dividerThickness
        
        //heights are all the same
        oLeftFrame.size.height = nFrame.size.height
        oMiddleFrame.size.height = nFrame.size.height
        
        oLeftFrame.origin = CGPointZero
        oLeftFrame.size.width = leftPanelThickness
        let new_x : CGFloat = dThickness + (leftPanel.hidden ? 0 : leftPanelThickness)
        oMiddleFrame.origin = CGPoint(x: new_x, y: 0)
        let new_width = nFrame.size.width - new_x
        oMiddleFrame.size.width = new_width
        
        
        leftPanel.frame = oLeftFrame
        midPanel.frame = oMiddleFrame
        
    }

}