//
//  PSGroupsViewController.swift
//  PsyScopeEditor
//
//  Created by James on 31/08/2014.
//

import Foundation

class PSGroupsViewController : PSToolPropertyController, NSTableViewDelegate, NSTableViewDataSource {

    let group : PSGroup
    var criteria : [(variable: PSSubjectVariable,value: String)]
    var subjectVariables : [PSSubjectVariable]
    
    init(entry : Entry, scriptData : PSScriptData) {
        let bundle = NSBundle(forClass:self.dynamicType)
        group = PSGroup(entry: entry, scriptData: scriptData)
        criteria = []
        subjectVariables = []
        super.init(nibName: "GroupsView", bundle: bundle, entry: entry, scriptData: scriptData)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var childTypeControllerView : NSView!
    var childTypeController : PSChildTypeViewController!
    let yOffSet = CGFloat(200)
    
    override func refresh() {
        super.refresh()
        refreshCriteriaTableView()
        reloadChildTypeViewController()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        refreshCriteriaTableView()
        reloadChildTypeViewController()
    }
    
    func reloadChildTypeViewController() {
        if let v = childTypeControllerView {
            v.removeFromSuperview()
        }
        childTypeController = PSChildTypeViewController.createForEntry(entry, pluginViewController: self)
        
        self.view.addSubview(childTypeController.view)
        
        var frame = childTypeController.view.frame
        let yposition = CGRectGetHeight(self.view.frame) - CGRectGetHeight(frame) - yOffSet
        frame.origin = CGPointMake(0.0, ceil(yposition))
        childTypeController.view.frame = frame
    }
    
    func refreshCriteriaTableView() {
        //get subject variables this group is involved in
        criteria = group.getCriteria()
        
        //get all subject variables
        let subjectInfo = PSSubjectInformation(scriptData: scriptData)
        subjectInfo.updateVariablesFromScript()
        subjectVariables = subjectInfo.subjectVariables.filter({ subjectVariable in subjectVariable.isGroupingVariable})
        
        //reload
        criteriaTableView.reloadData()
    }
    
    //MARK: Table view
    
    @IBOutlet var criteriaTableView : NSTableView!
    @IBOutlet var criteriaNameColumn : NSTableColumn!
    @IBOutlet var criteriaValueTableColumn : NSTableColumn!
    @IBOutlet var criteriaActiveTableColumn : NSTableColumn!
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return subjectVariables.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var active : Bool = false
        var activeValue : String = ""
        for criter in criteria {
            if subjectVariables[row].name == criter.variable.name {
                activeValue = criter.value
                active = true
                break
            }
        }
        
        if tableColumn!.identifier == criteriaActiveTableColumn.identifier {
            let view = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: nil) as! NSButton
            view.state = active ? 1 : 0
            view.tag = row
            view.target = self
            view.action = "activeCheckClicked:"
            return view
        } else if tableColumn!.identifier == criteriaNameColumn.identifier {
            let view = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: nil) as! NSTableCellView
            view.textField!.stringValue = subjectVariables[row].name
            view.textField?.enabled = active
            return view
        } else if tableColumn!.identifier == criteriaValueTableColumn.identifier {
            let groupView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: nil) as! PSGroupValueCellView
            groupView.textField!.stringValue = activeValue
            groupView.textField?.enabled = active
            groupView.row = row
            groupView.buttonClickedBlock = showDialog
            groupView.button.enabled = active
            return groupView
        }
        return nil
    }
    
    func activeCheckClicked(checkbox : NSButton) {
        if checkbox.state == 1 {
            group.addCriteria(subjectVariables[checkbox.tag], value: "")
        } else {
            group.removeCriteria(subjectVariables[checkbox.tag].name)
        }
        refreshCriteriaTableView()
    }
    
    func showDialog(row : Int) {
        let subjectVariableName = subjectVariables[row].name
        for (index,criterium) in criteria.enumerate() {
            if criterium.variable.name == subjectVariableName {
                let value = PSSubjectVariableDialog(criterium.variable, currentValue: criterium.value)
                criteria[index].value = value
                group.setCriteria(criteria)
                criteriaTableView.reloadData()
                return
            }
        }
        fatalError("Subject variable not found")
        
    }
    
    
    
    
}