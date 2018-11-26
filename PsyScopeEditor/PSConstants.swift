//
//  Constants.swift
//  PsyScopeEditor
//
//  Created by James on 23/07/2014.
//

import Cocoa
import QuartzCore

class PSConstants {
    
    struct PSToolBrowserView {
        static let pasteboardType = NSPasteboard.PasteboardType(rawValue: "public.item.psyscopetoolbar")
        static let dragType = NSPasteboard.PasteboardType(rawValue: "psyscopetoolbarDragType")
    }
    
    struct PSEventBrowserView {
        static let pasteboardType = NSPasteboard.PasteboardType(rawValue: "public.item.psyscopeeventtoolbar")
        static let dragType = NSPasteboard.PasteboardType(rawValue: "psyscopeeventtoolbarDragType")
    }
    
    struct Spacing {
        static let iconSize = 32 //size of icons in layout board
        static let halfIconSize = CGFloat(iconSize / 2)
        static let objectTableViewRowHeight = CGFloat(30) //the height of rows in the object table view
        static let attributesTableViewRowHeight = CGFloat(30)
        
        //sizes for actions browser
        static let ACVRowHeight = 27
        static let ACVToolbarHeight = 15
        
    
    }
    
    struct LayoutConstants {
        static let leftPanelSize = 195
        static let rightPanelSize = 280
        static let docMinWidth = leftPanelSize + rightPanelSize + 400
        static let docMinHeight = 500
        
    }
    
    struct AttributeNames {
        static let Items = "Items"
    }
    
    struct Fonts {
        static let toolMenuHeader = NSFont.boldSystemFont(ofSize: 11)
        static let toolMenuBody = NSFont.systemFont(ofSize: 10)
        static let layoutBoardIcons = NSFont.systemFont(ofSize: 10)
        static let scriptFont : NSFont = NSFont(name: "Menlo", size: 11.0)!
        //static let scriptFontBold : NSFont = NSFont(name: "Menlo Bold", size: 11.0)!
        static let scriptCommentColor = NSColor(calibratedRed: 0.1, green: 0.8, blue: 0.1, alpha: 1.0)
        static let scriptEntryColor = NSColor(calibratedRed: 0.8, green: 0.0, blue: 0.8, alpha: 1.0)
        static let scriptAttributeColor = NSColor(calibratedRed: 0.0, green: 0.0, blue: 0.8, alpha: 1.0)
        static let scriptErrorColor = NSColor.red
        static let scriptValueColor = NSColor.black

    }

    // LucaL: defining two major background/foreground colors
    struct BasicDefaultColors {
        
        static let foregroundColor = NSColor(calibratedRed: 0.40, green: 0.67, blue: 0.82, alpha: 1).cgColor // slightly darker blue for internal color
        static let backgroundColor =  NSColor(calibratedRed: 0.73, green: 0.84, blue: 0.89, alpha: 1).cgColor // light blue color
        
        static let backgroundColorLowAlpha =  NSColor(calibratedRed: 0.73, green: 0.84, blue: 0.89, alpha: 0.5).cgColor // light blue color
        
        static let foregroundColorLowAlpha = NSColor(calibratedRed: 0.40, green: 0.67, blue: 0.82, alpha: 0.5).cgColor // slightly darker blue for internal color
    }
    
}
