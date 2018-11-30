//
//  PSLayoutHelper.swift
//  PsyScopeEditor
//
//  Created by James on 09/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation


//get hiding preferences
private var eventsHidden = !UserDefaults.standard.bool(forKey: PSPreferences.showEvents.key)
private var listsHidden = !UserDefaults.standard.bool(forKey: PSPreferences.showLists.key)


public func PSCleanUpTree(_ scriptData : PSScriptData) {

    
    let allobjects : [LayoutObject] = scriptData.getLayoutObjects()
    

    //1st copy tree structure to treenodes
    var treeNodes : [TreeNode] = []
    var treeTops : [TreeNode] = []
    var treeLeaves : [TreeNode] = []
    var lobjToTreeNode : [LayoutObject : TreeNode] = [:]
    
    
    
    //get hiding preferences
    eventsHidden = !UserDefaults.standard.bool(forKey: PSPreferences.showEvents.key)
    listsHidden = !UserDefaults.standard.bool(forKey: PSPreferences.showLists.key)

    var lobjects : [LayoutObject] = []
    for obj in allobjects {
        if !((listsHidden && obj.mainEntry.type == "List") || (eventsHidden && scriptData.typeIsEvent(obj.mainEntry.type))) {
            lobjects.append(obj)
        }
    }
    
    if lobjects.isEmpty { return}
    
    for lobj in lobjects {
        let newNode = TreeNode(layoutObject: lobj, scriptData: scriptData)
        treeNodes.append(newNode)
        lobjToTreeNode[lobj] = newNode
    }
    
    
    
    
    // copy the links
    for lobj in lobjects {
        for child in lobj.childLink.array as! [LayoutObject] {
            if !((listsHidden && child.mainEntry.type == "List") || (eventsHidden && scriptData.typeIsEvent(child.mainEntry.type))) {
                let childNode = lobjToTreeNode[child]!
                lobjToTreeNode[lobj]!.addChild(childNode)
            }
        }
    }
    
    //pass through assign local order to children
    //for node in treeNodes {
    //    node.assignChildrenLocalX()
    //}
    
    //get tree tops and set depth for all tree (propogates)
    for node in treeNodes {
        if node.isTopOfTree() {
            treeTops.append(node)
            node.setTreeDepth(0)
        }
        
        if node.isLeaf() {
            treeLeaves.append(node)
        }
    }
    
    //pass to get maximum depths to begin positioning
    var maxDepth : Double = 0
    for node in treeTops {
        maxDepth = max(maxDepth, node.getMaxDepth())
        node.sizeOfChildren() //set width of children
    }
    
    //set xs based on width of children
    var childX : Double = 0
    for node in treeTops {
        node.setNewX(childX)
        childX += node.widthOfChildren
    }
    
    //centre
    for node in treeTops {
        node.centreOverChildren()
    }
    
    //now apply measurements
    
    let xmult = Double(PSPreferences.cleanUpXSpacing.integerValue)
    let ymult = Double(PSPreferences.cleanUpYSpacing.integerValue)
    
    scriptData.beginUndoGrouping("Reposition Objects")
    for lobj in lobjects {
        lobj.xPos = (1 + lobjToTreeNode[lobj]!.x) * xmult as NSNumber
        lobj.yPos = (1 + lobjToTreeNode[lobj]!.depth) * ymult as NSNumber
    }
    scriptData.endUndoGrouping(true)

}


public func PSSortSubTree(_ lobj : LayoutObject, scriptData : PSScriptData) {
    //get hiding preferences
    eventsHidden = !UserDefaults.standard.bool(forKey: PSPreferences.showEvents.key)
    listsHidden = !UserDefaults.standard.bool(forKey: PSPreferences.showLists.key)
    
    var parentX = lobj.xPos.doubleValue
    let parentY = lobj.yPos.doubleValue
    
    //1st copy tree structure to treenodes
    let treeNode = TreeNode(layoutObject: lobj, scriptData: scriptData)
    treeNode.populateChildren()
    treeNode.setTreeDepth(0)
    _ = treeNode.sizeOfChildren()
    treeNode.setNewX(parentX)
    treeNode.centreOverChildren()
    let xmult = Double(PSPreferences.cleanUpXSpacing.integerValue)
    let ymult = Double(PSPreferences.cleanUpYSpacing.integerValue)
    
    let diff = parentX - (treeNode.widthOfChildren / 2)
    
    if diff < 10 {
        parentX -= diff
    }
    
    let offsetX = parentX - ((1 + treeNode.x) * xmult)
    let offsetY = parentY - ((1 + treeNode.depth) * ymult)
    
    
    
    
    scriptData.beginUndoGrouping("Reposition Objects")
    treeNode.setLayoutObjectPosition(xmult,ymult: ymult,xOffset: offsetX,yOffset: offsetY)
    scriptData.endUndoGrouping(true)
}


class TreeNode : NSObject {
    var lobject : LayoutObject
    var localX : Double
    var depth : Double
    var widthOfChildren : Double
    var parent : TreeNode? = nil
    var x : Double = 0
    var children : [TreeNode]
    let scriptData : PSScriptData
    
    init(layoutObject : LayoutObject, scriptData : PSScriptData) {
        self.scriptData = scriptData
        lobject = layoutObject
        localX = -1 //unassigned
        depth = -1 //unassigned
        children = []
        widthOfChildren = 1
    }
    
    func populateChildren() {
        
        
        
        for lobj in lobject.childLink.array as! [LayoutObject] {
            if !((listsHidden && lobj.mainEntry.type == "List") || (eventsHidden && scriptData.typeIsEvent(lobj.mainEntry.type))) {
                let newNode = TreeNode(layoutObject: lobj, scriptData: scriptData)
                children.append(newNode)
                newNode.populateChildren()
            }
        }
    }
    
    func addChild(_ node : TreeNode) {
        if node.parent == nil { //first come frst serve for child ownership
            children.append(node)
            node.parent = self
        }
    }
    

    
    func setLayoutObjectPosition(_ xmult : Double, ymult : Double, xOffset : Double, yOffset : Double) {
        lobject.xPos = ((1 + self.x) * xmult) + xOffset as NSNumber
        lobject.yPos = ((1 + self.depth) * ymult) + yOffset as NSNumber
        for c in children {
            c.setLayoutObjectPosition(xmult, ymult: ymult, xOffset: xOffset, yOffset: yOffset)
        }
    }
    
    
    
    func setNewX(_ x : Double) {
        self.x = x
        var childX = x
        for (_,c) in children.enumerated() {
            c.setNewX(childX)
            childX += c.widthOfChildren
        }
    }
    
    @discardableResult
    func centreOverChildren() -> Double {
        if isLeaf() {
            return self.x
        }
        var childLocs : [Double] = []
        for c in children {
            childLocs.append(c.centreOverChildren())
        }
        self.x = childLocs.reduce(0,{ $0 + $1 }) / Double(childLocs.count)
        return self.x
    }
    
    @discardableResult
    func sizeOfChildren() -> Double {
        
        if self.isLeaf() {
            widthOfChildren = 1
            return 1
        } else {
            var sizeOfChild : Double = 0
            for c in children {
                 sizeOfChild += c.sizeOfChildren()
            }
            widthOfChildren = sizeOfChild + 1 //add space for between children
            return sizeOfChild
        }
    }
    
    func isTopOfTree() -> Bool {
        return parent == nil
    }
    
    func getTopOfTree() -> TreeNode {
        if let p = parent {
            return p.getTopOfTree()
        } else {
            return self
        }
    }
    
    func getMaxDepth() -> Double {
        if children.isEmpty {
            return depth
        } else {
            var maxDepth = depth
            for c in children {
                let newMaxDepth = c.getMaxDepth()
                if newMaxDepth > maxDepth {
                    maxDepth = newMaxDepth
                }
            }
            return maxDepth
        }
    }
    
    func setTreeDepth(_ depth : Double) {
        self.depth = depth
        for c in children {
            c.setTreeDepth(depth+1)
        }
    }
    
    func isLeaf() -> Bool {
        return children.isEmpty
    }
    
    func IsLeftMost() -> Bool
    {
        if let p = parent {
            let lastE : TreeNode = p.children.first!
            return (lastE == self)
        } else {
            return true
        }
    }
    
    func IsRightMost() -> Bool
    {
        if let p = parent {
            let lastE : TreeNode = p.children.last!
            return (lastE == self)
        } else {
            return true
        }
    }
    
}

public func PSPositionNewObject(_ lobject : LayoutObject, scriptData : PSScriptData) {
    //find all parent objects
    let parent_objects = lobject.parentLink as! Set<LayoutObject>
    
    if parent_objects.count > 0 { //if there parent objects get right most and put next to that
        let parent_object = parent_objects.first!
        PSPositionNewObjectWithParent(lobject, parentObject: parent_object)
        
    } else if parent_objects.count == 0 { //if there are none then put in the centre of the screen
        PSPutInFreeSpot(lobject, scriptData: scriptData)
        
    }
}

public func PSPositionNewObjectWithParent(_ lobject : LayoutObject, parentObject : LayoutObject) {
    var yPos : Int = Int(truncating: parentObject.yPos) + PSPreferences.cleanUpYSpacing.integerValue
    if yPos < 0 { yPos = 0 }
    var xPos = Int(truncating: parentObject.xPos)
    let xMult = PSPreferences.cleanUpXSpacing.integerValue
    
    //get max xPos
    for child in parentObject.childLink.array as! [LayoutObject] {
        
        if Int(truncating: child.xPos) + xMult > xPos {
            xPos = Int(truncating: child.xPos) + xMult
        }
    }
    lobject.yPos = yPos as NSNumber
    lobject.xPos = xPos as NSNumber
}

public func PSPutInFreeSpot(_ lobject : LayoutObject, scriptData : PSScriptData) {
    //todo check screen coordinate
    //for now, pile at 50,50 going left
    let all_lobjects = scriptData.getLayoutObjects()
    let xMult = PSPreferences.cleanUpXSpacing.integerValue
    var x : Int = xMult
    let y : Int = PSPreferences.cleanUpYSpacing.integerValue
    var tooClose = true
    repeat {
        tooClose = false
        for lobj in all_lobjects {
            let x_diff = (Int(truncating: lobj.xPos) - x)
            let y_diff = (Int(truncating: lobj.yPos) - y)
            if ((x_diff * x_diff) + (y_diff * y_diff) < 250) {
                x += xMult
                tooClose = true
            }
        }
    } while (tooClose)
    lobject.xPos = x as NSNumber
    lobject.yPos = y as NSNumber
    
    PSSortSubTree(lobject, scriptData: scriptData) //ok position for this object, so sort its children
}
