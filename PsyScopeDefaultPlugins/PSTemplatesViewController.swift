//
//  PSTemplatesViewController.swift
//  PsyScopeEditor
//
//  Created by James on 31/08/2014.
//
// plus minus buttons: http://stackoverflow.com/questions/22586313/nstableview-with-buttons-like-in-system-preferences-using-only-interface-bui/22586314#22586314

import Foundation

class PSTemplatesViewController : PSToolPropertyController {
    init(entry : Entry, scriptData : PSScriptData) {
        let bundle = Bundle(for:self.dynamicType)
        super.init(nibName: "TemplatesView", bundle: bundle, entry: entry, scriptData: scriptData)
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
        
        self.view.addSubview(childTypeController.view)
        
        var frame = childTypeController.view.frame
        let yposition = self.view.frame.height - frame.height - yOffSet
        frame.origin = CGPoint(x: 0.0, y: ceil(yposition))
        childTypeController.view.frame = frame
    }
}
