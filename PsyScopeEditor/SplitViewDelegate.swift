//
//  SplitViewDelegate.swift
//  PsyScopeEditor
//
//  Created by James on 29/07/2014.
//

import Cocoa

class SplitViewDelegate: NSObject, NSSplitViewDelegate {
    
    @IBOutlet var leftPanel : NSView!
    @IBOutlet var midPanel : NSView!
    @IBOutlet var rightPanel : NSView!
    
    let rightPanelThickness : CGFloat = CGFloat(PSConstants.LayoutConstants.rightPanelSize)
    let leftPanelThickness : CGFloat = CGFloat(PSConstants.LayoutConstants.leftPanelSize)

    func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        //only left and right panels can be collapse
        return (subview == leftPanel || subview == rightPanel)
    }
    
    func splitView(_ splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        if dividerIndex == 0 {
            //first divider
            return leftPanelThickness
        } else if (dividerIndex == 1) {
            return splitView.bounds.width - rightPanelThickness
        }
        
        return proposedMinimumPosition;
    }
    
    func splitView(_ splitView: NSSplitView, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        if dividerIndex == 0 {
            //first divider
            return leftPanelThickness
        } else if (dividerIndex == 1) {
            return splitView.bounds.width - rightPanelThickness
        }
        return proposedMaximumPosition
    }
    
    func splitView(_ splitView: NSSplitView, resizeSubviewsWithOldSize oldSize: NSSize) {
        //var horizontalDiff : CGFloat = splitView.bounds.width - oldSize.width
        //var verticalDiff : CGFloat = splitView.bounds.width - oldSize.height
        
        var oLeftFrame = leftPanel.frame
        var oRightFrame = rightPanel.frame
        var oMiddleFrame = midPanel.frame
        let nFrame = splitView.frame
        
        let dThickness : CGFloat = splitView.dividerThickness
        
        //heights are all the same
        oLeftFrame.size.height = nFrame.size.height
        oRightFrame.size.height = nFrame.size.height
        oMiddleFrame.size.height = nFrame.size.height
        
        oLeftFrame.origin = CGPoint.zero
        oLeftFrame.size.width = leftPanelThickness
        let new_x : CGFloat = dThickness + (leftPanel.isHidden ? 0 : leftPanelThickness)
        oMiddleFrame.origin = CGPoint(x: new_x, y: 0)
        let new_width = nFrame.size.width - (leftPanel.isHidden ? 0 : leftPanelThickness) - (rightPanel.isHidden ? 0 : rightPanelThickness) - dThickness - dThickness
        oMiddleFrame.size.width = new_width
        oRightFrame.origin = CGPoint(x: oMiddleFrame.origin.x + oMiddleFrame.size.width + dThickness, y: 0)
        oRightFrame.size.width = rightPanelThickness
        
        
        leftPanel.frame = oLeftFrame
        midPanel.frame = oMiddleFrame
        rightPanel.frame = oRightFrame
        
    }
    
}
