//
//  PSBlocksViewController.swift
//  PsyScopeEditor
//
//  Created by James on 31/08/2014.
//

import Foundation

class PSBlocksViewController : PSToolPropertyController {
    
    init(entry : Entry, scriptData : PSScriptData) {
        let bundle = Bundle(for:type(of: self))
        super.init(nibName: "BlocksView", bundle: bundle, entry: entry, scriptData: scriptData)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var childTypeControllerView : NSView!
    var childTypeController : PSChildTypeViewController!
    let yOffSet = CGFloat(50)
    
    override func refresh() {
        super.refresh()
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
        let yposition = self.view.frame.height - frame.height - yOffSet
        frame.origin = CGPoint(x: 0.0, y: ceil(yposition))
        childTypeController.view.frame = frame
    }
}
