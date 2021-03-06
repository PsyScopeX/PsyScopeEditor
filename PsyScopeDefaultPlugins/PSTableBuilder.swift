//
//  PSTableBuilder.swift
//  PsyScopeEditor
//
//  Created by James on 10/10/2014.
//

import Foundation

class PSTableBuilder: NSObject {
    
    @IBOutlet var window : NSWindow!
    @IBOutlet var controller : PSTableBuilderController!

    var scriptData : PSScriptData
    var objects : NSArray?
    var tableEntry : Entry
    
    init ( theScriptData : PSScriptData, theTableEntry : Entry) {
        scriptData = theScriptData
        tableEntry = theTableEntry
        super.init()
    }
    
    
    var registeredForChanges : Bool = false {
        willSet {
            if newValue != registeredForChanges {
                if newValue {
                    print("table registered")
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "docMocChanged:", name: NSManagedObjectContextObjectsDidChangeNotification, object: scriptData.docMoc)
                } else {
                    print("table unregistered")
                    NSNotificationCenter.defaultCenter().removeObserver(self)
                }
            }
        }
    }
    

    
    func showWindow() {
        NSBundle(forClass:self.dynamicType).loadNibNamed("TableBuilder", owner: self, topLevelObjects: &objects)
        window.title = "Edit Table: \(tableEntry.name)"
        window.releasedWhenClosed = true
        registeredForChanges = true
        window.makeKeyAndOrderFront(self)
        
    }
    
    //make sure to degregister when window gets closed
    func deregister() {
        registeredForChanges = false
    }
    
    func closeWindow() {
        deregister()
        window.close()
    }
    
    
    

    
}

extension PSDefaultConstants {
    struct TableBuilder {
        static let levelWidth = CGFloat(75)
        static let rowHeight = CGFloat(20)
    }
}

class PSFactorTable {
    var factors : [PSFactor] = []
    var tableView : NSTableView
    var selectedFactor : PSFactor {
        get {
            return _selectedFactor
        }
        set {
            _selectedLevel = nil
            _selectedFactor = newValue
        }
    }
    private var _selectedFactor : PSFactor!
    
    var selectedLevel : PSFactorLevel? {
        get {
            return _selectedLevel
        }
        set {
            _selectedLevel = newValue
            if let nv = newValue {
                _selectedFactor = nv.factor
            }
        }
    }
    private var _selectedLevel : PSFactorLevel?
    
    var leftConstraint : NSLayoutConstraint!
    var widthConstraint : NSLayoutConstraint!
    var topConstraint : NSLayoutConstraint!
    var heightConstraint : NSLayoutConstraint!
    var view : NSView
    
    init(superView : NSView) {
        view = superView
        tableView = NSTableView(frame: NSMakeRect(0, 0, 300, 300))
        createTableView()
        

        addFactor()
       
    }
    
    func rows() -> Int {
        if factors.count < 2 {
            return 1
        }
        
        var rows : Int = 1
        for a in 1...(factors.count - 1)
        {
            rows = rows * factors[a].levels.count
        }
        return rows
    }
    
    func createTableView() {
        let scrollView = NSScrollView(frame: NSMakeRect(0, 0, 300, 300))
        let column = NSTableColumn(identifier: "id")

        tableView.headerView = nil

        
        scrollView.documentView = tableView
        scrollView.borderType = NSBorderType.NoBorder
        scrollView.horizontalScrollElasticity = NSScrollElasticity.None
        scrollView.verticalScrollElasticity = NSScrollElasticity.None
        
        tableView.addTableColumn(column)
        tableView.columnAutoresizingStyle = NSTableViewColumnAutoresizingStyle.UniformColumnAutoresizingStyle
        
        view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        leftConstraint = NSLayoutConstraint(
            item: scrollView,
            attribute: NSLayoutAttribute.Left,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Left,
            multiplier: 1.0, constant: 20.0)
        
        widthConstraint = NSLayoutConstraint(
            item: scrollView,
            attribute: NSLayoutAttribute.Right,
            relatedBy: NSLayoutRelation.Equal,
            toItem: scrollView,
            attribute: NSLayoutAttribute.Left,
            multiplier: 1.0, constant: 300.0)
        
        topConstraint = NSLayoutConstraint(
            item: scrollView,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0, constant: 60.0)
        
        heightConstraint = NSLayoutConstraint(
            item: scrollView,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: scrollView,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0, constant: 200.0)
        
        view.addConstraint(leftConstraint)
        view.addConstraint(widthConstraint)
        view.addConstraint(topConstraint)
        view.addConstraint(heightConstraint)
        
        
        //Constraints to keep table view same size as scrollview
        let tleftConstraint = NSLayoutConstraint(item: tableView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0)
        let trightConstraint = NSLayoutConstraint(item: tableView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0)
        
        let ttopConstraint = NSLayoutConstraint(item: tableView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0)
        let tbottomConstraint = NSLayoutConstraint(item: tableView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -2.0)
        view.addConstraint(tleftConstraint)
        view.addConstraint(trightConstraint)
        view.addConstraint(ttopConstraint)
        view.addConstraint(tbottomConstraint)
        
        
        //Constraints for window view,
        //var winWidth = NSLayoutConstraint(item: view,
        
    }
    
    func updateTableViewConstraints() {
        let rowHeight : Int = Int(PSDefaultConstants.TableBuilder.rowHeight)
        heightConstraint.constant = CGFloat(rowHeight * rows() + 4)
        leftConstraint.constant = CGFloat(factors.count) * PSDefaultConstants.TableBuilder.levelWidth
        widthConstraint.constant = CGFloat(factors[0].levels.count) * PSDefaultConstants.TableBuilder.levelWidth
    }
    
    func addFactor() {
        let displayLevel = PSFactorDisplayLevel.displayLevelForIndex(factors.count)
        let new_factor = PSFactor(tableView: tableView, superView: view, displayLevel: displayLevel, factorTable: self)
        factors.append(new_factor)
        
        //set the name
        let new_name = "Factor \(factors.count)"
        new_factor.name = new_name
        selectedFactor = new_factor
        updateTableViewConstraints()
        updateLevelButtons()
    }
    
    func addLevel() {
        selectedFactor.addLevel()
        updateTableViewConstraints()
        updateLevelButtons()
    }
    
    func updateLevelButtons() {
        
        var rowsSpanned = rows()
        
        for (_,factor) in factors.enumerate() {
            switch (factor.displayLevel) {
            case .Top:
                factor.updateButtons(nil, numberRowsSpanned: 0)
            case let .Side(index):
                if index>1 {
                    factor.updateButtons(factors[index-1],numberRowsSpanned: rowsSpanned)
                } else {
                    factor.updateButtons(nil,numberRowsSpanned: rowsSpanned)
                }
                rowsSpanned = rowsSpanned / factor.levels.count
            }
        }
    }
    
}

enum PSFactorDisplayLevel {
    case Top
    case Side(Int)
    
    static func displayLevelForIndex(index : Int) -> PSFactorDisplayLevel {
        if index == 0 {
            return PSFactorDisplayLevel.Top
        } else {
            return PSFactorDisplayLevel.Side(index)
        }
    }
}

func PSFormatFactorButton(superView : NSView, name : String) -> NSButton {
    let button = NSButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.title = name
    superView.addSubview(button)
    return button
}


class PSFactor : NSObject {
    var name : String {
        get {
            return _name
        }
        set {
            _name = newValue
            button.title = newValue
        }
    }
    
    private var _name : String = "New factor"
    
    var button : NSButton
    var levels : [PSFactorLevel] = []
    var tableView : NSView
    var factorTable : PSFactorTable
    var displayLevel : PSFactorDisplayLevel
    var superView : NSView
    
    init(tableView : NSView, superView : NSView, displayLevel : PSFactorDisplayLevel, factorTable : PSFactorTable) {
        self.factorTable = factorTable
        self.displayLevel = displayLevel
        self.tableView = tableView
        self.superView = superView
        self.button = PSFormatFactorButton(superView, name: _name)
        super.init()
        self.button.action = "selected:"
        self.button.target = self
        
        switch (displayLevel) {
        case .Top:
        //top row above factors
        superView.addConstraint(NSLayoutConstraint(
            item: button,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: superView,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0, constant: 20.0))
        //left align with table
        superView.addConstraint(NSLayoutConstraint(
            item: button,
            attribute: NSLayoutAttribute.Left,
            relatedBy: NSLayoutRelation.Equal,
            toItem: tableView,
            attribute: NSLayoutAttribute.Left,
            multiplier: 1.0, constant: 0.0))
        //label is as wide as table view
        superView.addConstraint(NSLayoutConstraint(
            item: button,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: tableView,
            attribute: NSLayoutAttribute.Width,
            multiplier: 1.0, constant: 0.0))
        //always a fixed height here
        superView.addConstraint(NSLayoutConstraint(
            item: button,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: button,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0, constant: PSDefaultConstants.TableBuilder.rowHeight))
            
        case let .Side(index):
            //left button
            //top align with table view
            superView.addConstraint(NSLayoutConstraint(
                item: button,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: tableView,
                attribute: NSLayoutAttribute.Top,
                multiplier: 1.0, constant: CGFloat(0) - PSDefaultConstants.TableBuilder.rowHeight))
            //left align with table
            let constant : CGFloat = (PSDefaultConstants.TableBuilder.levelWidth * CGFloat(index))
            superView.addConstraint(NSLayoutConstraint(
                item: button,
                attribute: NSLayoutAttribute.Left,
                relatedBy: NSLayoutRelation.Equal,
                toItem: superView,
                attribute: NSLayoutAttribute.Left,
                multiplier: 1.0, constant: constant))
            //label is as wide as level
            superView.addConstraint(NSLayoutConstraint(
                item: button,
                attribute: NSLayoutAttribute.Right,
                relatedBy: NSLayoutRelation.Equal,
                toItem: button,
                attribute: NSLayoutAttribute.Left,
                multiplier: 1.0, constant: PSDefaultConstants.TableBuilder.levelWidth))
            //always as tall as row height
            superView.addConstraint(NSLayoutConstraint(
                item: button,
                attribute: NSLayoutAttribute.Bottom,
                relatedBy: NSLayoutRelation.Equal,
                toItem: button,
                attribute: NSLayoutAttribute.Top,
                multiplier: 1.0, constant: PSDefaultConstants.TableBuilder.rowHeight))
            break
        }
        
        //start with two factors as having one makes no sense
        addLevel()
        addLevel()
    }
    
    func selected(button : AnyObject) {
        factorTable.selectedFactor = self
        print("Factor selected: \(name)")
    }
    
    func addLevel() {
        let new_level = PSFactorLevel(factor: self, displayLevel: displayLevel, tableView: tableView, superView: superView)
        levels.append(new_level)
        new_level.name = "Level \(levels.count)"
    }
    
    func updateButtons(previousFactor : PSFactor?, numberRowsSpanned : Int) {
        //clear all buttons
        for level in levels {
            for button in level.buttons {
                button.removeFromSuperview()
            }
            level.buttons = []
        }
        
        switch (displayLevel) {
        case .Top:
            for (index, level) in levels.enumerate() {
                let new_button = PSFormatFactorButton(superView, name: level.name)
                level.buttons.append(new_button)
                new_button.action = "selected:"
                new_button.target = level
                superView.addConstraint(NSLayoutConstraint(
                    item: new_button,
                    attribute: NSLayoutAttribute.Top,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: button,
                    attribute: NSLayoutAttribute.Top,
                    multiplier: 1.0, constant: PSDefaultConstants.TableBuilder.rowHeight))
                //left align with table button
                let left : CGFloat = CGFloat(index) * PSDefaultConstants.TableBuilder.levelWidth
                superView.addConstraint(NSLayoutConstraint(
                    item: new_button,
                    attribute: NSLayoutAttribute.Left,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: button,
                    attribute: NSLayoutAttribute.Left,
                    multiplier: 1.0, constant: left))
                //label is standard width
                superView.addConstraint(NSLayoutConstraint(
                    item: new_button,
                    attribute: NSLayoutAttribute.Right,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: new_button,
                    attribute: NSLayoutAttribute.Left,
                    multiplier: 1.0, constant: PSDefaultConstants.TableBuilder.levelWidth))
                //on top, always as tall as rowheight
                superView.addConstraint(NSLayoutConstraint(
                    item: button,
                    attribute: NSLayoutAttribute.Bottom,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: button,
                    attribute: NSLayoutAttribute.Top,
                    multiplier: 1.0, constant: PSDefaultConstants.TableBuilder.rowHeight))
            }
            break
        case .Side:
            let buttonHeight = PSDefaultConstants.TableBuilder.rowHeight * CGFloat(numberRowsSpanned) / CGFloat(levels.count)
            if let pf = previousFactor {
                for previousLevel in pf.levels {
                    for previousButton in previousLevel.buttons {
                        for (index, level) in levels.enumerate() {
                            let new_button = PSFormatFactorButton(superView, name: level.name)
                            level.buttons.append(new_button)
                            new_button.action = "selected:"
                            new_button.target = level
                            let pos : CGFloat = (CGFloat(index) / CGFloat(levels.count)) * PSDefaultConstants.TableBuilder.rowHeight * CGFloat(numberRowsSpanned)
                            superView.addConstraint(NSLayoutConstraint(
                                item: new_button,
                                attribute: NSLayoutAttribute.Top,
                                relatedBy: NSLayoutRelation.Equal,
                                toItem: previousButton,
                                attribute: NSLayoutAttribute.Top,
                                multiplier: 1.0, constant: pos))
                            superView.addConstraint(NSLayoutConstraint(
                                item: new_button,
                                attribute: NSLayoutAttribute.Left,
                                relatedBy: NSLayoutRelation.Equal,
                                toItem: self.button,
                                attribute: NSLayoutAttribute.Left,
                                multiplier: 1.0, constant: 0.0))
                            //label is standard width
                            superView.addConstraint(NSLayoutConstraint(
                                item: new_button,
                                attribute: NSLayoutAttribute.Right,
                                relatedBy: NSLayoutRelation.Equal,
                                toItem: new_button,
                                attribute: NSLayoutAttribute.Left,
                                multiplier: 1.0, constant: PSDefaultConstants.TableBuilder.levelWidth))
                            superView.addConstraint(NSLayoutConstraint(
                                item: new_button,
                                attribute: NSLayoutAttribute.Bottom,
                                relatedBy: NSLayoutRelation.Equal,
                                toItem: new_button,
                                attribute: NSLayoutAttribute.Top,
                                multiplier: 1.0, constant: buttonHeight))
                        }
                    }
                }
            } else {
                //this is for the base factor on the left, that should span entire tableview
                for (index, level) in levels.enumerate() {
                    let new_button = PSFormatFactorButton(superView, name: level.name)
                    level.buttons.append(new_button)
                    let pos : CGFloat = CGFloat((CGFloat(index) / CGFloat(levels.count))) * PSDefaultConstants.TableBuilder.rowHeight * CGFloat(numberRowsSpanned)
                    new_button.action = "selected:"
                    new_button.target = level
                    
                    
                    print("Adding button at \(pos)")
                    superView.addConstraint(NSLayoutConstraint(
                        item: new_button,
                        attribute: NSLayoutAttribute.Top,
                        relatedBy: NSLayoutRelation.Equal,
                        toItem: tableView,
                        attribute: NSLayoutAttribute.Top,
                        multiplier: 1.0, constant: pos))
                    superView.addConstraint(NSLayoutConstraint(
                        item: new_button,
                        attribute: NSLayoutAttribute.Left,
                        relatedBy: NSLayoutRelation.Equal,
                        toItem: self.button,
                        attribute: NSLayoutAttribute.Left,
                        multiplier: 1.0, constant: 0.0))
                    //label is standard width
                    superView.addConstraint(NSLayoutConstraint(
                        item: new_button,
                        attribute: NSLayoutAttribute.Right,
                        relatedBy: NSLayoutRelation.Equal,
                        toItem: new_button,
                        attribute: NSLayoutAttribute.Left,
                        multiplier: 1.0, constant: PSDefaultConstants.TableBuilder.levelWidth))
                    //as tall as number of rows spanned
                    superView.addConstraint(NSLayoutConstraint(
                        item: new_button,
                        attribute: NSLayoutAttribute.Bottom,
                        relatedBy: NSLayoutRelation.Equal,
                        toItem: new_button,
                        attribute: NSLayoutAttribute.Top,
                        multiplier: 1.0, constant: buttonHeight))
                }
            }
        }
    }
}

class PSFactorLevel : NSObject {
    var name : String {
        get {
            return _name
        }
        set {
            _name = newValue
            for button in buttons {
                button.title = newValue
            }
        }
    }
    
    private var _name : String = "Level 1"

    var factor : PSFactor
    var buttons : [NSButton] = []
    var superView : NSView
    
    init(factor : PSFactor, displayLevel: PSFactorDisplayLevel, tableView : NSView, superView : NSView) {
        self.factor = factor
        self.superView = superView
        super.init()
    }
    

    func selected(button : AnyObject) {
        print("Selected \(name)")
        factor.factorTable.selectedLevel = self
    }
}