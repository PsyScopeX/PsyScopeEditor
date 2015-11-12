//
//  PSGroupsCreator.swift
//  PsyScopeEditor
//
//  Created by James on 20/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation
//takes group variables, and creates groups automatically based on the combinations therin
class PSGroupsCreator {
    
    let scriptData : PSScriptData
    let groupTool : PSToolInterface
    
    init(scriptData : PSScriptData) {
        self.scriptData = scriptData
        self.groupTool = scriptData.pluginProvider.getInterfaceForType("Group")!
    }
    
    func generateGroups(groupVariables : [PSSubjectVariable]) {
        //first delete existing groups
        let existingGroups = scriptData.getBaseEntriesOfType(PSType.Group)
        
        if existingGroups.count > 0 {
            let question = "Overwrite existing groups?"
            let info = "There are already groups created, this process will delete these groups and replace them with new ones.  Are you sure you want to do this?"
            let yesButton = "Yes"
            let noButton = "No"
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButtonWithTitle(yesButton)
            alert.addButtonWithTitle(noButton)
            
            let answer = alert.runModal()
            if answer != NSAlertFirstButtonReturn {
                return
            }
        }
        
        for existingGroup in existingGroups {
            scriptData.deleteMainEntry(existingGroup)
        }
        
        //next generate new groups
        var groupCombinations : [[String]] = []
        var conditionNames : [String] = []
        for groupingVariable in groupVariables {
            var validCombinations : [String] = []
            switch (groupingVariable.dialogType) {
            case let .CheckBoxes(values):
                validCombinations = generateCombinationsRecursive(values)
            case let .RadioButtons(values):
                validCombinations = values
            default:
                break
            }
            groupCombinations.append(validCombinations)
            conditionNames.append(groupingVariable.name)
        }
        
        let groupEntries = createGroupRecursive(conditionNames, combinations: groupCombinations, values: [])
        let experimentEntry = scriptData.getMainExperimentEntry()
        for groupEntry in groupEntries {
            groupTool.createLinkFrom(experimentEntry, to: groupEntry, withScript: scriptData)
        }
        PSSortSubTree(experimentEntry.layoutObject, scriptData: scriptData)
    }
    
    func createGroupRecursive(names : [String], combinations : [[String]], values : [String]) -> [Entry] {
        
        if values.count == names.count {
            return [createGroupWithConditionNames(names, values: values)]
        }
        
        let index = (combinations.count - 1) - ( (names.count - values.count) - 1 )
        var entries : [Entry] = []
        for combination in combinations[index] {
            var newValues = values
            newValues.append(combination)
            entries += createGroupRecursive(names, combinations: combinations, values: newValues)
        }
        return entries
    }
    
    func createGroupWithConditionNames(names : [String], values : [String]) -> Entry {
        let newEntry = groupTool.createObject(scriptData)
        
        let group = PSGroup(entry: newEntry,scriptData: scriptData)
        
        for (index, name) in names.enumerate() {
            group.addCriteria(name, value: values[index])
        }
        return newEntry
    }
    
    func generateCombinationsRecursive(values : [String]) -> [String] {
        if values.count == 1 {
            return values + [""]
        }
        var newCombinations : [String] = []
        if let firstValue = values.first {
            var subSet = values
            subSet.removeAtIndex(0)
            let subCombinations = generateCombinationsRecursive(subSet)
            newCombinations = subCombinations
            newCombinations += subCombinations.map { $0 + " " + firstValue }
        }
        return newCombinations
    }
}