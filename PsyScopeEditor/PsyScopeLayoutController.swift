//
//  PsyScopeScriptController.swift
//  PsyScopeEditor
//
//  Created by James on 18/07/2014.
//  Copyright (c) 2014 James. All rights reserved.
//

import Cocoa

//there are two representations, one of the layout board, and one of the actual script

class PsyScopeLayoutController: NSObject {
    
    var moc : NSManagedObjectContext //model
    @IBOutlet var lb : LayoutBoard //view
    
    init() {
        moc = AppWideMOC.sharedInstance.managedObjectContext!
        super.init()
    }
    
   
    func addNewObject(toolName : String, location: NSPoint) {
        //var empty_object = NSEntityDescription.insertNewObjectForEntityForName("LayoutObject", inManagedObjectContext: moc) as NSManagedObject
        //empty_object.setValue(tool.name(), forKey: "type")
        //empty_object.setValue(tool.name(), forKey: "name")
        
        //empty_object.setValue(location.x, forKey:"xPos")
        //empty_object.setValue(location.y, forKey:"yPos" )
        
        //updateViewForObject(empty_object)
    }
    
    func updateViewForObject(object : NSManagedObject) {
        /*var sublayer = CALayer();
        sublayer.backgroundColor = NSColor.blueColor().CGColor;
        sublayer.shadowOffset = CGSizeMake(0, 3);
        sublayer.shadowRadius = 5.0;
        sublayer.shadowColor = NSColor.blackColor().CGColor;
        sublayer.shadowOpacity = 0.8;
        sublayer.frame = CGRect(origin: self.convertPoint(sender.draggedImageLocation(),fromView: nil),size: CGSizeMake(32,32))
        sublayer.contents = sender.draggedImage()
        
        
        sublayer.borderColor = NSColor.blackColor().CGColor;
        sublayer.borderWidth = 2.0;
        
        //CGRectMake(30, 30, 128, 192);
        self.layer.addSublayer(sublayer)
        self.iconLayers.append(sublayer)
        
        
        statusBar.stringValue = "Control added at: " + sublayer.frame.origin.ToString()*/
    }

}
