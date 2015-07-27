import Foundation

typealias PSRule = (()->(Bool))
typealias PSMemoization = [Int:Int]

/*func PSEntryValueSyntaxError(token : String, range : NSRange) -> PSScriptError {
    let description = token == "" ? "A syntax error was detected on this line." : "The token \"\(token)\" has caused a syntax error."
    let solution = "Check the entire value for correct syntax."
    var new_error = PSScriptError(errorDescription: "Syntax Error", detailedDescription: description, solution: solution, range: range)
    return new_error
}*/

public class PSEntryValueParser {
    private let tokens : [PSToken]
    private var p : Int
    private var parsedList : PSStringListElement!
    public var foundErrors : Bool
    
    public init(stringValue : String) {
        let tokeniser = PSTokenizer(string: stringValue)
        tokens = tokeniser.tokens
        foundErrors = false
        p = 0
        parsedList = nil
        
        //print(tokeniser.dumpTokens())
        
        listRule() //triggers parsing
        parsedList = getLast(&listObjDic, stack: &listStack)
        if (p < tokens.count) {
            foundErrors = true
        }
    }
    
    
    func match(tokenType : PSTokenType) -> PSToken? {
        //end of file
        if (p == tokens.count) { return nil }
        
        let currentToken = tokens[p]
        if (currentToken.type == tokenType) {
            p++
            return currentToken
        }
        
        return nil
    }
    
    var listElement : PSEntryElement {
        return PSEntryElement.List(stringListElement: parsedList)
    }
    
    public var values : [PSEntryElement] {
        get {
            return parsedList.values
        }
    }
    
    //looks for previously created object - and moves p to it's parsed location if found
    //returns true or false, if already parsed, nil if not
    func recall(inout stack : [Int], inout endPosDic : [Int : Int]) -> Bool? {
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
    func store<T>(inout stack : [Int], inout objDic: [Int : T], inout endPosDic : [Int : Int], obj : T?, startP : Int ) -> Bool {
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
    
    func getLast<T>(inout objDic: [Int : T], inout stack : [Int]) -> T {
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
        whiteSpaceRule()
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
            element = PSEntryElement.Function(functionElement: getLast(&operationObjDic, stack: &operationStack))
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
            element = PSEntryElement.Function(functionElement: getLast(&functionObjDic, stack: &functionStack))
        } else if plainValueRule() {
            //musn't be an inline entry
            if let ias = match(.InlineAttributeSymbol) {
                //inline entry so no good
            } else {
                element = PSEntryElement.StringToken(stringElement: getLast(&plainValueObjDic, stack: &plainValueStack))
            }
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
            whiteSpaceRule()
            
            let firstVal = getLast(&nonOperationValueObjDic, stack: &nonOperationValueStack)
            
 
            if binaryOperatorThenExpressionRule() {
                function = PSFunctionElement()
                function!.bracketType = .Expression
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
        } else if unaryOperatorThenExpressionRule() {
       
            function = PSFunctionElement()
            function!.bracketType = .Expression
            let unop = getLast(&unaryOperatorThenExpressionObjDic, stack: &unaryOperatorThenExpressionStack)
            function!.values.append(unop.op)
            function!.values.append(unop.val)
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
            whiteSpaceRule()
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
            whiteSpaceRule()
            
            let op = getLast(&unaryOperatorObjDic, stack: &unaryOperatorStack)
            if expressionRule() {
                obj = (op, getLast(&expressionObjDic, stack: &expressionStack))
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
        if let binoperator = match(.BinaryOperator) {
            element = PSEntryElement.StringToken(stringElement: PSStringElement(value: binoperator.value!, quotes: .None))
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
        if let binoperator = match(.UnaryOperator) {
            element = PSEntryElement.StringToken(stringElement: PSStringElement(value: binoperator.value!, quotes: .None))
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
            
            if let ias = match(.InlineAttributeSymbol) {
                newInlineEntry = PSFunctionElement()
                newInlineEntry!.functionName = functionName
                newInlineEntry!.bracketType = .InlineEntry
                whiteSpaceRule()
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
        
        match(.FunctionEvaluationSymbol) //eat these for now
        
        if let orb = match(.OpenRoundBracket) {
            whiteSpaceRule()
            listRule()
            let list = getLast(&listObjDic, stack: &listStack)
            if let crb = match(.CloseRoundBracket) {
                newFunction = PSFunctionElement()
                newFunction!.functionName = functionName
                newFunction!.bracketType = .Round
                newFunction!.values = list.values
            }
        } else if let osb = match(.OpenSquareBracket) {
            whiteSpaceRule()
            listRule()
            let list = getLast(&listObjDic, stack: &listStack)
            
            //now try to get inline entries
            var inlineEntries : [PSEntryElement] = []
            //now do inline sub entries
            while (inlineEntryRule()) {
                inlineEntries.append(PSEntryElement.Function(functionElement: getLast(&inlineEntryObjDic, stack: &inlineEntryStack)))
                whiteSpaceRule()
            }
            
            if let csb = match(.CloseSquareBracket) {
                newFunction = PSFunctionElement()
                newFunction!.functionName = functionName
                newFunction!.bracketType = .Square
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
        if let curlyBracketString = match(.CurlyBracketString) {
            element = PSStringElement(value: curlyBracketString.value!, quotes: PSStringElement.Quotes.CurlyBrackets)
    
        } else if let quoteString = match(.QuoteString) {
            element = PSStringElement(value: quoteString.value!, quotes: PSStringElement.Quotes.Doubles)
 
        } else if let quoteString = match(.SingleQuoteString) {
            element = PSStringElement(value: quoteString.value!, quotes: PSStringElement.Quotes.Singles)
       
        }else if let val = match(.Value) {
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
        if let whiteSpaceToken = match(.WhiteSpace) {
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

