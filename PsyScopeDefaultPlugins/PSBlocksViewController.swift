//
//  PSBlocksViewController.swift
//  PsyScopeEditor
//
//  Created by James on 31/08/2014.
//

import Foundation

class PSBlocksViewController : PSToolPropertyController {
    
    init(entry : Entry, scriptData : PSScriptData) {
        var bundle = NSBundle(forClass:self.dynamicType)
        super.init(nibName: "BlocksView", bundle: bundle, entry: entry, scriptData: scriptData)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var childTypeControllerView : NSView!
    var childTypeController : PSChildTypeViewController!
    let yOffSet = CGFloat(50)
    
    override func docMocChanged(notification: NSNotification!) {
        super.docMocChanged(notification)
        reloadChildTypeViewController()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reloadChildTypeViewController()
    }
    
    func reloadChildTypeViewController() {
        if let v = childTypeControllerView {
            v.removeFromSuperview()
        }
        childTypeController = PSChildTypeViewController.createForEntry(entry, pluginViewController: self)
        childTypeControllerView = childTypeController.view
        self.view.addSubview(childTypeController.view)
        
        var frame = childTypeController.view.frame
        var yposition = CGRectGetHeight(self.view.frame) - CGRectGetHeight(frame) - yOffSet
        frame.origin = CGPointMake(0.0, ceil(yposition))
        childTypeController.view.frame = frame
    }
}