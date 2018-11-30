import Foundation

typealias PSRule = (()->(Bool))
typealias PSMemoization = [Int:Int]


public class PSEntryValueParser {
    fileprivate let tokens : [PSToken]
    fileprivate var p : Int
    fileprivate var parsedList : PSStringListElement!
    public var foundErrors : Bool
    
    public init(stringValue : String) {
        let tokeniser = PSTokenizer(string: stringValue)
        tokens = tokeniser.tokens
        foundErrors = tokeniser.error
        p = 0
        parsedList = nil
        
        print(tokeniser.dumpTokens())
        
        _ = listRule() //triggers parsing
        parsedList = getLast(&listObjDic, stack: &listStack)
        if (p < tokens.count) {
            foundErrors = true
        }
    }
    
    func match(_ tokenType : PSTokenType) -> PSToken? {
        //end of file
        if (p == tokens.count) { return nil }
        
        let currentToken = tokens[p]
        if (currentToken.type == tokenType) {
            p += 1
            return currentToken
        }
        
        return nil
    }
    
    var listElement : PSEntryElement {
        return PSEntryElement.list(stringListElement: parsedList)
    }
    
    public var values : [PSEntryElement] {
        get {
            return parsedList.values
        }
    }
    
    //looks for previously created object - and moves p to it's parsed location if found
    //returns true or false, if already parsed, nil if not
    func recall(_ stack : inout [Int], endPosDic : inout [Int : Int]) -> Bool? {
        if let previousP = endPosDic[p] {
            if previousP == -1 {
                return false
            } else {
                stack.append(p)
                p = previousP
                return true
            }
        }
        return nil
    }
    
    //stores the object (if created) or stores -1 and resets p if not created
    func store<T>(_ stack : inout [Int], objDic: inout [Int : T], endPosDic : inout [Int : Int], obj : T?, startP : Int ) -> Bool {
        if let realObj = obj {
            objDic[startP] = realObj
            endPosDic[startP] = p
            stack.append(startP)
            return true
        } else {
            endPosDic[startP] = -1
            p = startP
            return false
        }
    }
    
    func getLast<T>(_ objDic: inout [Int : T], stack : inout [Int]) -> T {
        let pos = stack.last!
        stack.removeLast()
        return objDic[pos]!
    }
    
    var listStack : [Int] = []
    var listObjDic : [Int : PSStringListElement] = [:]
    var listEndPosDic : [Int : Int] = [:]
    func listRule() -> Bool {
        if let r = recall(&listStack, endPosDic: &listEndPosDic) { return r }
        
        let startP = p
        let element = PSStringListElement()
        _ = whiteSpaceRule()
        while (expressionRule()) {
            
            //successfully parsed expression, add to current list
            element.values.append(getLast(&expressionObjDic, stack: &expressionStack))
            if !whiteSpaceRule() { break }
        }
        return store(&listStack, objDic: &listObjDic, endPosDic: &listEndPosDic, obj: element, startP: startP)
    }
    
    var expressionStack : [Int] = []
    var expressionObjDic : [Int : PSEntryElement] = [:]
    var expressionEndPosDic : [Int : Int] = [:]
    func expressionRule() -> Bool {
        if let r = recall(&expressionStack, endPosDic: &expressionEndPosDic) { return r }
        let startP = p
        
        var element : PSEntryElement?
        if operationRule() {
            element = PSEntryElement.function(functionElement: getLast(&operationObjDic, stack: &operationStack))
        } else if nonOperationValueRule() {
            element = getLast(&nonOperationValueObjDic, stack: &nonOperationValueStack)
        }
        
        return store(&expressionStack, objDic: &expressionObjDic, endPosDic: &expressionEndPosDic, obj: element, startP: startP)
    }
    
    var nonOperationValueStack : [Int] = []
    var nonOperationValueObjDic : [Int : PSEntryElement] = [:]
    var nonOperationValueEndPosDic : [Int : Int] = [:]
    func nonOperationValueRule() -> Bool {
        if let r = recall(&nonOperationValueStack, endPosDic: &nonOperationValueEndPosDic) { return r }
        let startP = p
        
        var element : PSEntryElement?
        if functionRule() {
            element = PSEntryElement.function(functionElement: getLast(&functionObjDic, stack: &functionStack))
        } else if plainValueRule() {
            //musn't be an inline entry
            if let _ = match(.inlineAttributeSymbol) {
                //inline entry so no good
            } else {
                element = PSEntryElement.stringToken(stringElement: getLast(&plainValueObjDic, stack: &plainValueStack))
            }
        } else if unaryOperatorThenExpressionRule() {
            
            let function = PSFunctionElement()
            function.bracketType = .expression
            let unop = getLast(&unaryOperatorThenExpressionObjDic, stack: &unaryOperatorThenExpressionStack)
            function.values.append(unop.op)
            function.values.append(unop.val)
            element = PSEntryElement.function(functionElement: function)
        }

        return store(&nonOperationValueStack, objDic: &nonOperationValueObjDic, endPosDic: &nonOperationValueEndPosDic, obj: element, startP: startP)
    }
    
    var operationStack : [Int] = []
    var operationObjDic : [Int : PSFunctionElement] = [:]
    var operationEndPosDic : [Int : Int] = [:]
    func operationRule() -> Bool {
        if let r = recall(&operationStack, endPosDic: &operationEndPosDic) { return r }
        let startP = p
        
        var function : PSFunctionElement?
        
        if nonOperationValueRule() {
            _ = whiteSpaceRule()
            
            let firstVal = getLast(&nonOperationValueObjDic, stack: &nonOperationValueStack)
            
            //binary operators appear as functions, with the type 'expression'
            //the components including the operator will appear as the values.
            
 
            if binaryOperatorThenExpressionRule() {
                function = PSFunctionElement()
                function!.bracketType = .expression
                function!.values.append(firstVal)
                let binop = getLast(&binaryOperatorThenExpressionObjDic, stack: &binaryOperatorThenExpressionStack)
                function!.values.append(binop.op)
                function!.values.append(binop.val)
        
                while(binaryOperatorThenExpressionRule()) {
                    let binop2 = getLast(&binaryOperatorThenExpressionObjDic, stack: &binaryOperatorThenExpressionStack)
                    function!.values.append(binop2.op)
                    function!.values.append(binop2.val)
                }
            }
        }
        
        
        return store(&operationStack, objDic: &operationObjDic, endPosDic: &operationEndPosDic, obj: function, startP: startP)
    }
    
    var binaryOperatorThenExpressionStack : [Int] = []
    var binaryOperatorThenExpressionObjDic : [Int : (op : PSEntryElement, val : PSEntryElement)] = [:]
    var binaryOperatorThenExpressionEndPosDic : [Int : Int] = [:]
    func binaryOperatorThenExpressionRule() -> Bool {
        if let r = recall(&binaryOperatorThenExpressionStack, endPosDic: &binaryOperatorThenExpressionEndPosDic) { return r }
        let startP = p
        
        var obj : (op : PSEntryElement, val : PSEntryElement)?
        if binaryOperatorRule() {
            _ = whiteSpaceRule()
            let op = getLast(&binaryOperatorObjDic, stack: &binaryOperatorStack)
            
            if expressionRule() {
                obj = (op, getLast(&expressionObjDic, stack: &expressionStack))
            }
        }
        
        return store(&binaryOperatorThenExpressionStack, objDic: &binaryOperatorThenExpressionObjDic, endPosDic: &binaryOperatorThenExpressionEndPosDic, obj: obj, startP: startP)
    }
    
    var unaryOperatorThenExpressionStack : [Int] = []
    var unaryOperatorThenExpressionObjDic : [Int : (op : PSEntryElement, val : PSEntryElement)] = [:]
    var unaryOperatorThenExpressionEndPosDic : [Int : Int] = [:]
    func unaryOperatorThenExpressionRule() -> Bool {
        if let r = recall(&unaryOperatorThenExpressionStack, endPosDic: &unaryOperatorThenExpressionEndPosDic) { return r }
        let startP = p
        
        var obj : (op : PSEntryElement, val : PSEntryElement)?
        if unaryOperatorRule() {
            _ = whiteSpaceRule()
            
            let op = getLast(&unaryOperatorObjDic, stack: &unaryOperatorStack)
            
            //all unary operators operate on plain values....
            if plainValueRule() {
                obj = (op, PSEntryElement.stringToken(stringElement: getLast(&plainValueObjDic, stack: &plainValueStack)))
            }
        }
        
        return store(&unaryOperatorThenExpressionStack, objDic: &unaryOperatorThenExpressionObjDic, endPosDic: &unaryOperatorThenExpressionEndPosDic, obj: obj, startP: startP)
    }
    
    var binaryOperatorStack : [Int] = []
    var binaryOperatorObjDic : [Int : PSEntryElement] = [:]
    var binaryOperatorEndPosDic : [Int : Int] = [:]
    func binaryOperatorRule() -> Bool {
        if let r = recall(&binaryOperatorStack, endPosDic: &binaryOperatorEndPosDic) { return r }
        let startP = p
        
        var element : PSEntryElement?
        if let binoperator = match(.binaryOperator) {
            element = PSEntryElement.stringToken(stringElement: PSStringElement(value: binoperator.value!, quotes: .none))
        }
        
        return store(&binaryOperatorStack, objDic: &binaryOperatorObjDic, endPosDic: &binaryOperatorEndPosDic, obj: element, startP: startP)
    }
    
    var unaryOperatorStack : [Int] = []
    var unaryOperatorObjDic : [Int : PSEntryElement] = [:]
    var unaryOperatorEndPosDic : [Int : Int] = [:]
    func unaryOperatorRule() -> Bool {
        if let r = recall(&unaryOperatorStack, endPosDic: &unaryOperatorEndPosDic) { return r }
        let startP = p
        
        var element : PSEntryElement?
        if let binoperator = match(.unaryOperator) {
            element = PSEntryElement.stringToken(stringElement: PSStringElement(value: binoperator.value!, quotes: .none))
        }
        
        return store(&unaryOperatorStack, objDic: &unaryOperatorObjDic, endPosDic: &unaryOperatorEndPosDic, obj: element, startP: startP)
    }
    
    var inlineEntryStack : [Int] = []
    var inlineEntryObjDic : [Int : PSFunctionElement] = [:]
    var inlineEntryEndPosDic : [Int : Int] = [:]
    func inlineEntryRule() -> Bool {
        if let r = recall(&inlineEntryStack, endPosDic: &inlineEntryEndPosDic) { return r }
        let startP = p
        
        var newInlineEntry : PSFunctionElement?

        if plainValueRule() {
            
            let functionName = getLast(&plainValueObjDic, stack: &plainValueStack).quotedValue
            
            if let _ = match(.inlineAttributeSymbol) {
                newInlineEntry = PSFunctionElement()
                newInlineEntry!.functionName = functionName
                newInlineEntry!.bracketType = .inlineEntry
                _ = whiteSpaceRule()
                if listRule() {
                    let list = getLast(&listObjDic, stack: &listStack)
                    newInlineEntry!.values = list.values
                }
            }
        }
        
        return store(&inlineEntryStack, objDic: &inlineEntryObjDic, endPosDic: &inlineEntryEndPosDic, obj: newInlineEntry, startP: startP)
    }
    
    
    
    var functionStack : [Int] = []
    var functionObjDic : [Int : PSFunctionElement] = [:]
    var functionEndPosDic : [Int : Int] = [:]
    func functionRule() -> Bool {
        
        if let r = recall(&functionStack, endPosDic: &functionEndPosDic) { return r }
        let startP = p
        
        var newFunction : PSFunctionElement?
        var functionName : String = ""
        if plainValueRule() {
            functionName = getLast(&plainValueObjDic, stack: &plainValueStack).value
        }
        
        _ = match(.functionEvaluationSymbol) //eat these for now
        
        if let _ = match(.openRoundBracket) {
            _ = whiteSpaceRule()
            _ = listRule()
            let list = getLast(&listObjDic, stack: &listStack)
            if let _ = match(.closeRoundBracket) {
                newFunction = PSFunctionElement()
                newFunction!.functionName = functionName
                newFunction!.bracketType = .round
                newFunction!.values = list.values
            }
        } else if let _ = match(.openSquareBracket) {
            _ = whiteSpaceRule()
            _ = listRule()
            let list = getLast(&listObjDic, stack: &listStack)
            
            //now try to get inline entries
            var inlineEntries : [PSEntryElement] = []
            //now do inline sub entries
            while (inlineEntryRule()) {
                inlineEntries.append(PSEntryElement.function(functionElement: getLast(&inlineEntryObjDic, stack: &inlineEntryStack)))
                _ = whiteSpaceRule()
            }
            
            if let _ = match(.closeSquareBracket) {
                newFunction = PSFunctionElement()
                newFunction!.functionName = functionName
                newFunction!.bracketType = .square
                newFunction!.values = list.values + inlineEntries
            }
        }
        
        return store(&functionStack, objDic: &functionObjDic, endPosDic: &functionEndPosDic, obj: newFunction, startP: startP)
    }
    
    var plainValueStack : [Int] = []
    var plainValueObjDic : [Int : PSStringElement] = [:]
    var plainValueEndPosDic : [Int : Int] = [:]
    func plainValueRule() -> Bool {
        if let r = recall(&plainValueStack, endPosDic: &plainValueEndPosDic) { return r }
        let startP = p
        
        var element : PSStringElement?
        if let curlyBracketString = match(.curlyBracketString) {
            element = PSStringElement(value: curlyBracketString.value!, quotes: PSStringElement.Quotes.curlyBrackets)
    
        } else if let quoteString = match(.quoteString) {
            element = PSStringElement(value: quoteString.value!, quotes: PSStringElement.Quotes.doubles)
 
        } else if let quoteString = match(.singleQuoteString) {
            element = PSStringElement(value: quoteString.value!, quotes: PSStringElement.Quotes.singles)
       
        }else if let val = match(.value) {
            element = PSStringElement(strippedValue: val.value!)
        }
        
        return store(&plainValueStack, objDic: &plainValueObjDic, endPosDic: &plainValueEndPosDic, obj: element, startP: startP)
    }
    
    var whiteSpaceMemo : [Int : Int] = [:]
    func whiteSpaceRule() -> Bool {
        if let endP = whiteSpaceMemo[p] {
            if endP > 0 {
                p = endP
                return true
            }
            return false
        }
        
        let startP = p
        if let _ = match(.whiteSpace) {
            while whiteSpaceRule() {
                
            }
            whiteSpaceMemo[startP] = p
            return true
        } else {
            whiteSpaceMemo[startP] = -1
        }
        return false
    }
    
}

