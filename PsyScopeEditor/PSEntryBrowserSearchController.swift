//
//  PSEntryBrowserSearchController.swift
//  PsyScopeEditor
//
//  Created by James on 29/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSEntryBrowserSearchController : NSObject, NSTextFieldDelegate, NCRAutocompleteTableViewDelegate {
    
    //MARK: Outlets
    @IBOutlet var textField : NSTextField!
    
    //MARK: Vars
    
    var selectionInterface : PSSelectionInterface!
    var scriptData : PSScriptData!
    var entryNames : [String] = []
    var iconsForNames : [String : NSImage] = [:]
    
    //MARK: Setup
    
    func setup(_ scriptData : PSScriptData) {
        self.scriptData = scriptData
        self.selectionInterface = scriptData.selectionInterface
    }
    
    //MARK: Update
    
    func update( _ iconsForNames : [String : NSImage] ) {
        self.iconsForNames = iconsForNames
        self.entryNames = Array(iconsForNames.keys)
    }



    
    //MARK: Autocomplete TextView Delegate
    
    func textView(_ textView: NSTextView!, completions words: [AnyObject]!, forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>) -> [AnyObject]! {

            
        let toMatch : String = (textView.string! as NSString).substringWithRange(charRange).lowercased()
        let completions : [String] = entryNames.filter { $0.lowercased().range(of: toMatch) != nil }
    
        return completions
    }
    
    func textView(_ textView: NSTextView!, imageForCompletion word: String!) -> NSImage! {
        if let icon = iconsForNames[word] {
            return icon
        } else {
            return NSImage()
        }
    }
    
    func textViewDidEnterPress(_ textView : NSTextView) {
        if let entry = scriptData.getBaseEntry(textView.string!) {
            selectionInterface.selectEntry(entry)
        }
    }
    
    
        /*- (NSImage *)textView:(NSTextView *)textView imageForCompletion:(NSString *)word {
    NSImage *image = self.imageDict[word];
    if (image) {
    return image;
    }
    return self.imageDict[@"Unknown"];
    }
    
    - (NSArray *)textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
    NSMutableArray *matches = [NSMutableArray array];
    for (NSString *string in self.wordlist) {
    if ([string rangeOfString:[[textView string] substringWithRange:charRange] options:NSAnchoredSearch|NSCaseInsensitiveSearch range:NSMakeRange(0, [string length])].location != NSNotFound) {
    [matches addObject:string];
    }
    }
    [matches sortUsingSelector:@selector(compare:)];
    return matches;
    }*/
    
}

class PSAutoCompleteTextFieldCell : NSTextFieldCell {
    @IBOutlet var autoCompleteTextView : NCRAutocompleteTextView!
    @IBOutlet var controller : PSEntryBrowserSearchController!
    
    override func fieldEditor(for aControlView: NSView) -> NSTextView? {
        autoCompleteTextView.delegate = controller
        return autoCompleteTextView
    }
}
