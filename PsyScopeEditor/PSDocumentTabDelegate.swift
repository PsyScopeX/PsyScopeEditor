//
//  PSDocumentTabDelegate.swift
//  PsyScopeEditor
//
//  Created by James on 29/07/2014.
//

import Cocoa


//handles the display of the three tabviews (left middle and right)
class PSDocumentTabDelegate: NSObject, NSTabViewDelegate {
    
    typealias TabItems = (tag: Int, midPanelItem: NSTabViewItem!, leftPanelItem: NSTabViewItem!)
    
    @IBOutlet var document : Document!
    @IBOutlet var selectionInterface : PSSelectionController!
    @IBOutlet var layoutController : LayoutController!
    @IBOutlet var experimentSetup : PSExperimentSetup!
    @IBOutlet var propertiesButton : NSButton!
    @IBOutlet var attributesButton : NSButton!
    @IBOutlet var actionsButton : NSButton!
    @IBOutlet var experimentSetupButton : NSButton!
    
    
    //left tab view buttons
    @IBOutlet var entriesButton : NSButton!
    @IBOutlet var errorsButton : NSButton!
    @IBOutlet var toolsButton : NSButton!
    
    //tab views
    @IBOutlet var rightPanelTabView : NSTabView!
    @IBOutlet var midPanelTabView : NSTabView!
    @IBOutlet var leftPanelTabView : NSTabView!
    
    
    //right panel tab views
    @IBOutlet var propertiesTabViewItem : NSTabViewItem!
    @IBOutlet var attributesTabViewItem : NSTabViewItem!
    @IBOutlet var actionsTabViewItem : NSTabViewItem!
    
    //centre panel tab views
    @IBOutlet var layoutTabViewItem : NSTabViewItem!
    @IBOutlet var scriptTabViewItem : NSTabViewItem!
    
    //left panel tab views
    @IBOutlet var layoutToolsTabViewItem : NSTabViewItem!
    @IBOutlet var scriptToolsTabViewItem : NSTabViewItem!

    //tool bar
    @IBOutlet var toolbar : NSToolbar!

    //window segmented control
    @IBOutlet var toolbarSegmentedControl : NSSegmentedControl!
    //key = tag of segment, value = the tab items to display
    var items : [Int : TabItems] = [:]
    var identifiers : [String : Int] = [:]
    
    var propertiesTabViewItemViewController : PSPluginViewController? = nil
    var objectViewControllers : [Entry : PSPluginViewController] = [:]
    
    func initialize(){
        super.awakeFromNib()
        
        //create notification listeners for left panel windows
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showErrors", name: "PSShowErrorsNotification", object: document)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showProperties", name: "PSShowPropertiesNotification", object: document)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAttributes", name: "PSShowAttributesNotification", object: document)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showActions", name: "PSShowActionsNotification", object: document)
        
        //setup initial state
        currentToolsTabViewItem = leftPanelTabView.selectedTabViewItem
        toolsShowing = true
        showProperties()
        
        //register the layout view / script view (these must be already setup)
        items[0] = (tag: 0, midPanelItem: layoutTabViewItem, leftPanelItem: layoutToolsTabViewItem)
        items[1] = (tag: 1, midPanelItem: scriptTabViewItem, leftPanelItem: scriptToolsTabViewItem)
        
        //register experiment setup view (comes from seperate nib, so using -1 as index)
        let expSetupMidPanel = experimentSetup.midPanelTab()
        let expSetupLeftPanel = experimentSetup.leftPanelTab()
        items[-1] = (tag: -1, midPanelItem: expSetupMidPanel, leftPanelItem: expSetupLeftPanel)
        
        //add the experiment setup tabs
        midPanelTabView.addTabViewItem(expSetupMidPanel)
        leftPanelTabView.addTabViewItem(expSetupLeftPanel)
        
        //set number of segmented control items already added
        var totalTags = 2
        
        //load all tabitems from plugins
        let tabitems = PSPluginSingleton.sharedInstance.pluginLoader.instantiatePluginsOfType(.WindowView) as! [PSWindowViewInterface]
        
        //layout view + script view already on segmented control (whence + 2)
        toolbarSegmentedControl.segmentCount = totalTags + tabitems.count
        
        for tabitem in tabitems {
            tabitem.setup(document.scriptData, selectionInterface: selectionInterface)
            let tag = totalTags
            let identifier = tabitem.identifier()
            let icon = tabitem.icon()
            let leftP = tabitem.leftPanelTab()
            let midP = tabitem.midPanelTab()
            selectionInterface.registerSelectionInterface(tabitem)
            
            let i = (tag: tag, midPanelItem: midP, leftPanelItem: leftP)
            items[tag] = i
            identifiers[identifier] = tag
            
            //add the items to the respective tabs
            midPanelTabView.addTabViewItem(i.midPanelItem)
            leftPanelTabView.addTabViewItem(i.leftPanelItem)
            
            let segmentIndex = tag
            toolbarSegmentedControl.setImage(icon, forSegment: segmentIndex)
            toolbarSegmentedControl.setImageScaling(toolbarSegmentedControl.imageScalingForSegment(0), forSegment: segmentIndex)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "showWindowNotification:", name: "PSShowWindowNotificationFor\(identifier)", object: document)
            totalTags++
        }
    }
    
    @IBAction func experimentSetupButtonClick(_: AnyObject) {
        if let item = items[-1] {
            toolbarSegmentedControl.selectedSegment = -1 //deselect
            experimentSetupButton.state = 1
            show(item)
        }
    }
    
    @IBAction func segmentedControlClick(controller : NSSegmentedControl) {
        experimentSetupButton.state = 0
        let selected = controller.selectedSegment
        
        if selected > -1 {
            let item = items[selected]
            show(item!)
        }
    }
    
    func refresh() {
        //refresh window
        if let pvc = propertiesTabViewItemViewController { pvc.refresh() }
    }
    
    func showWindowNotification(notification : NSNotification) {
        //get window name from notification
        let windowName = notification.name.stringByReplacingOccurrencesOfString("PSShowWindowNotificationFor", withString: "")
        showWindow(windowName)
    }
    
    func showWindow(windowName : String) {
        if let tag = identifiers[windowName], item = items[tag] {
            show(item)
        } else {
            print(windowName + " not found")
        }
    }
    
    
    //left panel varialbes
    @IBOutlet var entriesTabViewItem : NSTabViewItem!
    @IBOutlet var errorsTabViewItem : NSTabViewItem!
    var currentToolsTabViewItem : NSTabViewItem?
    var toolsShowing : Bool = false
    
    //left panel buttons
    @IBAction func leftPanelButtonClicked(button : NSButton) {
        switch(button) {
        case entriesButton:
            toolsShowing = false
            leftPanelTabView.selectTabViewItem(entriesTabViewItem)
            break
        case errorsButton:
            toolsShowing = false
            leftPanelTabView.selectTabViewItem(errorsTabViewItem)
            break
        case toolsButton:
            toolsShowing = true
            if let ct = currentToolsTabViewItem {
                leftPanelTabView.selectTabViewItem(ct)
            }
            break
        default:
            break
        }
    }
    
    //right panel buttons
    @IBAction func propertiesButtonClick(_: AnyObject) {
        self.showProperties()
    }
    
    @IBAction func attributesButtonClick(_: AnyObject) {
        self.showAttributes()
    }
    
    @IBAction func actionsButtonClick(_: AnyObject) {
        self.showActions()
    }
    
    func show(items : TabItems) {
        midPanelTabView.selectTabViewItem(items.midPanelItem)
        currentToolsTabViewItem = items.leftPanelItem
        if toolsShowing {
            leftPanelTabView.selectTabViewItem(items.leftPanelItem)
        }
    }
    
    func deleteEntry(entry : Entry) {
        //to not keep the viewControllers in memory //TODO check this actually works
        if let vc = objectViewControllers[entry] {
            vc.closeAllWindows()
            objectViewControllers[entry] = nil
        }
    }
    
    //handles selecting objects
    func selectEntry(entry : Entry?) {
        //try to create view
        var selectedViewController : PSPluginViewController?
        
        //always need to get the view controller, because it can change with context
        if let e = entry, vc = PSPluginSingleton.sharedInstance.getViewControllerFor(e, document: document) {
            
            selectedViewController = vc
            if objectViewControllers[e] != nil && objectViewControllers[e] != vc {
                //if the object had a previous view controller, close all the windows
                objectViewControllers[e]!.closeAllWindows()
            }
            
            objectViewControllers[e] = vc //keep in memory for this object
        } else if let e = entry {
            selectedViewController = PSDefaultPropertiesViewController(entry: e, scriptData: document.scriptData)
            if objectViewControllers[e] != nil && objectViewControllers[e] != selectedViewController {
                //if the object had a previous view controller, close all the windows
                objectViewControllers[e]!.closeAllWindows()
            }
            
            objectViewControllers[e] = selectedViewController //keep in memory for this object
        } else {
            //if no view controller display blank
            selectedViewController = nil
        }
        
        
        propertiesTabViewItemViewController = selectedViewController
        
        if let svc = selectedViewController {
            //set the view to the viewcontrollers view
            propertiesTabViewItem.view = svc.view
        } else {
            // : TODO, have a placeholder view
            propertiesTabViewItem.view = NSView()
        }

    }
    
    //MARK: Notifications
    
    func showErrors() {
        toolsShowing = false
        leftPanelTabView.selectTabViewItem(errorsTabViewItem)
    }
    
    func showProperties() {
        rightPanelTabView.selectTabViewItem(propertiesTabViewItem)
        propertiesButton.state = 1
        attributesButton.state = 0
        actionsButton.state = 0
    }
    
    func showAttributes() {
        rightPanelTabView.selectTabViewItem(attributesTabViewItem)
        propertiesButton.state = 0
        attributesButton.state = 1
        actionsButton.state = 0
    }
    
    func showActions() {
        rightPanelTabView.selectTabViewItem(actionsTabViewItem)
        propertiesButton.state = 0
        attributesButton.state = 0
        actionsButton.state = 1
    }
    
    func doubleClickProperties() {
        if let pvc = propertiesTabViewItemViewController as? PSDoubleClickAction {
            pvc.doubleClickAction()
        }
    }
}


