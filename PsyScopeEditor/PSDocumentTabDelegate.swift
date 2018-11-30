//
//  PSDocumentTabDelegate.swift
//  PsyScopeEditor
//
//  Created by James on 29/07/2014.
//

import Cocoa

class PSWindowViewElement : NSObject {
    
    init(tag : Int, midPanelView : NSView, leftPanelView : NSView?, midPanelTabViewItem : NSTabViewItem, leftPanelTabViewItem : NSTabViewItem?) {
        self.tag = tag
        self.midPanelView = midPanelView
        self.leftPanelView = leftPanelView
        self.midPanelTabViewItem = midPanelTabViewItem
        self.leftPanelTabViewItem = leftPanelTabViewItem
        super.init()
    }
    let tag : Int
    let midPanelView : NSView
    let leftPanelView : NSView?
    let midPanelTabViewItem : NSTabViewItem
    let leftPanelTabViewItem : NSTabViewItem?
    var windowController : NSWindowController?
}

//handles the display of the three tabviews (left middle and right)
class PSDocumentTabDelegate: NSObject, NSTabViewDelegate {
    
    
    @IBOutlet var mainWindowController : PSMainWindowController!
    var selectionInterface : PSSelectionController!
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
    @IBOutlet var blankTabViewItem : NSTabViewItem!

    //tool bar
    @IBOutlet var toolbar : NSToolbar!

    //window segmented control
    @IBOutlet var toolbarSegmentedControl : NSSegmentedControl!
    
    //key = tag of segment, value = the tab items to display
    var items : [Int : PSWindowViewElement] = [:]
    var identifiers : [String : Int] = [:]
    var currentlySelectedTag : Int = 0
    
    var propertiesTabViewItemViewController : PSPluginViewController? = nil
    
    
    var currentSelectedEntry : Entry?
    
    func initialize(){
        super.awakeFromNib()
        
        self.selectionInterface = mainWindowController.selectionController
        
        //create notification listeners for left panel windows
        NotificationCenter.default.addObserver(self, selector: #selector(PSDocumentTabDelegate.showErrors), name: NSNotification.Name(rawValue: "PSShowErrorsNotification"), object: mainWindowController.document)
        NotificationCenter.default.addObserver(self, selector: #selector(PSDocumentTabDelegate.showProperties), name: NSNotification.Name(rawValue: "PSShowPropertiesNotification"), object: mainWindowController.document)
        NotificationCenter.default.addObserver(self, selector: #selector(PSDocumentTabDelegate.showAttributes), name: NSNotification.Name(rawValue: "PSShowAttributesNotification"), object: mainWindowController.document)
        NotificationCenter.default.addObserver(self, selector: #selector(PSDocumentTabDelegate.showActions), name: NSNotification.Name(rawValue: "PSShowActionsNotification"), object: mainWindowController.document)
        
        //setup initial state
        currentToolsTabViewItem = leftPanelTabView.selectedTabViewItem
        toolsShowing = true
        showProperties()
        
        //register the layout view / script view (these must be already setup)
        items[0] = PSWindowViewElement(tag: 0, midPanelView: layoutTabViewItem.view!, leftPanelView: layoutToolsTabViewItem.view!, midPanelTabViewItem: layoutTabViewItem, leftPanelTabViewItem: layoutToolsTabViewItem)
        items[1] = PSWindowViewElement(tag: 1, midPanelView: scriptTabViewItem.view!, leftPanelView: nil, midPanelTabViewItem: scriptTabViewItem, leftPanelTabViewItem: nil)
        
        
        //register experiment setup view (comes from seperate nib, so using -1 as index)
        let expSetupMidPanel = experimentSetup.midPanelTab()!
        items[-1] = PSWindowViewElement(tag: -1, midPanelView: expSetupMidPanel.view!, leftPanelView: nil, midPanelTabViewItem: expSetupMidPanel, leftPanelTabViewItem: nil)
        
        
        //add the experiment setup tab
        midPanelTabView.addTabViewItem(expSetupMidPanel)

        
        //set number of segmented control items already added
        var totalTags = 2
        
        //load all tabitems from plugins
        let windowViewInterfaces = PSPluginSingleton.sharedInstance.pluginLoader.windowViews
        
        //layout view + script view already on segmented control (whence + 2)
        toolbarSegmentedControl.segmentCount = totalTags + windowViewInterfaces.count
        
        for windowViewInterface in windowViewInterfaces {
            windowViewInterface.setup(mainWindowController.scriptData, selectionInterface: selectionInterface)
            let tag = totalTags
            let identifier = windowViewInterface.identifier()
            let icon = windowViewInterface.icon()
            let leftView = windowViewInterface.leftPanelTab()
            let midView = windowViewInterface.midPanelTab()
            selectionInterface.registerSelectionInterface(windowViewInterface)
            
            let leftTabItem = NSTabViewItem()
            leftTabItem.view = leftView
            
            let midTabItem = NSTabViewItem()
            midTabItem.view = midView
            
            items[tag] = PSWindowViewElement(tag: tag, midPanelView: midView, leftPanelView: leftView, midPanelTabViewItem: midTabItem, leftPanelTabViewItem: leftTabItem)
            identifiers[identifier] = tag
            
            //add the items to the respective tabs
            midPanelTabView.addTabViewItem(midTabItem)
            leftPanelTabView.addTabViewItem(leftTabItem)
            
            let segmentIndex = tag
            toolbarSegmentedControl.setImage(icon, forSegment: segmentIndex)
            toolbarSegmentedControl.setImageScaling(toolbarSegmentedControl.imageScaling(forSegment: 0), forSegment: segmentIndex)
            NotificationCenter.default.addObserver(self, selector: #selector(PSDocumentTabDelegate.showWindowNotification(_:)), name: NSNotification.Name(rawValue: "PSShowWindowNotificationFor\(identifier)"), object: mainWindowController.document)
            totalTags += 1
        }

    }
    
    @IBAction func experimentSetupButtonClick(_: AnyObject) {
        if let item = items[-1] {
            toolbarSegmentedControl.selectedSegment = -1 //deselect
            experimentSetupButton.state = NSControl.StateValue.on
            show(item)
        }
    }
    
    @IBAction func segmentedControlClick(_ controller : NSSegmentedControl) {
        experimentSetupButton.state = NSControl.StateValue.off
        let selected = controller.selectedSegment
        
        if selected > -1 {
            let item = items[selected]
            show(item!)
        }
    }
    
    func refresh() {
        //get selection
        let selectedEntry = selectionInterface.getSelectedEntry()
        if selectedEntry != currentSelectedEntry {
            if let propertiesTabViewItemViewController = propertiesTabViewItemViewController {
                propertiesTabViewItemViewController.closeAllWindows()
            }
            selectEntry(selectedEntry) //will perform refresh (after window loaded)
        } else if let pvc = propertiesTabViewItemViewController { pvc.refresh() } //refresh window
        
    }
    
    @objc func showWindowNotification(_ notification : Notification) {
        //get window name from notification
        let windowName = (notification.name as NSString).replacingOccurrences(of: "PSShowWindowNotificationFor", with: "")
        showWindow(windowName)
    }
    
    func showWindow(_ windowName : String) {
        if let tag = identifiers[windowName], let item = items[tag] {
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
    @IBAction func leftPanelButtonClicked(_ button : NSButton) {
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
            
            if let ct = currentToolsTabViewItem {
                toolsShowing = true
                leftPanelTabView.selectTabViewItem(ct)
            } else {
                //shouldnt happen but as a fail safe
                toolsShowing = false
                leftPanelTabView.selectTabViewItem(entriesTabViewItem)
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
    
    func show(_ element : PSWindowViewElement) {
        
        if let windowController = element.windowController {
            //element is currently in it's own window
            windowController.becomeFirstResponder()
        } else {
            //element is nestled in tab item
            currentlySelectedTag = element.tag
            midPanelTabView.selectTabViewItem(element.midPanelTabViewItem)
            currentToolsTabViewItem = element.leftPanelTabViewItem
            toolsButton.isEnabled = currentToolsTabViewItem != nil
            if let currentToolsTabViewItem = currentToolsTabViewItem, toolsShowing {
                leftPanelTabView.selectTabViewItem(currentToolsTabViewItem)
            } else if toolsShowing {
                //tools showing but window doesnt have a tool kit so deaflut to entries browser
                toolsShowing = false
                leftPanelTabView.selectTabViewItem(entriesTabViewItem)
            }
            toolbarSegmentedControl.selectedSegment = element.tag
        }
    }
    
    //handles selecting objects
    func selectEntry(_ entry : Entry?) {
        
        self.currentSelectedEntry = entry
        
        //try to create view
        var selectedViewController : PSPluginViewController?
        
        //always need to get the view controller, because it can change with context
        if let e = entry, let vc = PSPluginSingleton.sharedInstance.getViewControllerFor(e, document: mainWindowController.mainDocument) {
            selectedViewController = vc
        } else if let e = entry {
            selectedViewController = PSDefaultPropertiesViewController(entry: e, scriptData: mainWindowController.scriptData)
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
    
    //MARK: Showing a window
    
    func detachCurrentWindow() {
        
        guard let element = items[currentlySelectedTag], currentlySelectedTag > -1 else { return }
        
        //show another window
        guard let otherElement = items[-1] else { return }
        show(otherElement)
        
        let windowController = PSWindowViewWindowController(windowNibName: "WindowView")
        element.windowController = windowController
        windowController.setup(mainWindowController.scriptData,leftView: element.leftPanelView, rightView: element.midPanelView, tabDelegate: self)
        
        windowController.showWindow(self)
    }
    
    func reattachWindow(_ windowController : PSWindowViewWindowController) {
        guard let element = Array(items.values).filter({ $0.windowController == windowController }).first else {
            //big error but lets at least let them save
            PSModalAlert("An error has occurred with the windows - please save and restart!")
            return
        }
        
        //push views back to tabViewItems
        element.midPanelTabViewItem.view = element.midPanelView
        
        if let leftPanelTabViewItem = element.leftPanelTabViewItem {
            leftPanelTabViewItem.view = element.leftPanelView
        }
        
        element.windowController = nil
        show(element)
    }
    
    //MARK: Notifications
    
    @objc func showErrors() {
        toolsShowing = false
        leftPanelTabView.selectTabViewItem(errorsTabViewItem)
    }
    
    @objc func showProperties() {
        rightPanelTabView.selectTabViewItem(propertiesTabViewItem)
        propertiesButton.state = NSControl.StateValue.on
        attributesButton.state = NSControl.StateValue.off
        actionsButton.state = NSControl.StateValue.off
    }
    
    @objc func showAttributes() {
        rightPanelTabView.selectTabViewItem(attributesTabViewItem)
        propertiesButton.state = NSControl.StateValue.off
        attributesButton.state = NSControl.StateValue.on
        actionsButton.state = NSControl.StateValue.off
    }
    
    @objc func showActions() {
        rightPanelTabView.selectTabViewItem(actionsTabViewItem)
        propertiesButton.state = NSControl.StateValue.off
        attributesButton.state = NSControl.StateValue.off
        actionsButton.state = NSControl.StateValue.on
    }
    
    func doubleClickProperties() {
        if let pvc = propertiesTabViewItemViewController {
            pvc.doubleClickAction()
        }
    }
    
    func showScript() {
        //item 1 is the script,
        if let item = items[1] {
            show(item)
        }
    }
    
    func showLayoutBoard() {
        //item 0 is the layoutBoard,
        if let item = items[0] {
            show(item)
        }
    }
}



