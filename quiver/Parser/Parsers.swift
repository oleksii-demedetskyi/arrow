struct NotImplemented: Error {}
extension Parser {
    
    /// Primitive identifier extractor
    mutating func parseIdentifier() -> Substring? {
        guard case let .identifier(value) = current else { return nil }
        consume()
        return value
    }
    
    /// Primitive keyword detector
    mutating func parseKeyword(_ token: Token) -> Bool {
        guard current == token else { return false }
        consume()
        return true
    }
    
    mutating func parseOneOfKeywords(_ tokens: Token...) -> Bool {
        for token in tokens {
            if parseKeyword(token) { return true }
        }
        return false
    }
    
    mutating func parseAllKeywords(_ tokens: Token...) -> Bool {
        let state = store()
        for token in tokens {
            if parseKeyword(token) == false {
                restore(state: state)
                return false
            }
        }
        
        return true
    }
    
    mutating func parseMany<T>(parser: (_ stream: inout Parser) throws -> T?) rethrows -> [T] {
        var values = [] as [T]
        while let item = try parser(&self) {
            values.append(item)
        }
        
        return values
    }
    
    mutating func parseIdentifierSequence() -> [Substring] {
        return parseMany { $0.parseIdentifier() }
    }
    
    struct ReduceStateIdentifierExpected: Error {}
    struct ReduceWithKeywordExpected: Error {}
    struct ReduceActionIdentifierExpected: Error {}
    struct ReduceExpressionsExpected: Error {}
    
    struct ExpressionsBlockOpenBraceExpected: Error {}
    struct ExpressionsBlockCloseBraceExpected: Error {}
    
    mutating func parseExpressionsBlock() throws -> [ExpressionDefintion] {
        guard parseKeyword(.openCurlyBrace) else { throw ExpressionsBlockOpenBraceExpected() }
        let expressions = try parseMany { try $0.parseExpression() }
        guard parseKeyword(.closedCurlyBrace) else { throw ExpressionsBlockCloseBraceExpected() }
        
        return expressions
    }
    
    struct ExpressionOperatorExpected: Error {}
    struct ExpressionValueExpected: Error {}
    
    /// Represents parsing of single expressson.
    /// Examples of valid expressions:
    /// `state += 1` `state -= 1` `state += action` `state -= action`
    mutating func parseExpression() throws -> ExpressionDefintion? {
        guard parseKeyword(.state) else { return nil }
        
        // TODO: Refactor to routine??
        let op: OperatorDefinition
        if parseAllKeywords(.plus, .equals) {
            op = .increment
        } else if parseAllKeywords(.minus, .equals) {
            op = .decrement
        } else {
            throw ExpressionOperatorExpected()
        }
        
        // TODO: Switch
        /// Here we can expect identifier or action.
        let rhs: ExpressionRHS
        if let id = parseIdentifier() {
            rhs = .identifier(id)
        } else if parseKeyword(.action) {
            rhs = .action
        }
        else {
            throw ExpressionValueExpected()
        }
        
        return ExpressionDefintion(operator: op, value: rhs)
    }
    
    /// Value is a single identifier that can be prefixed with plus or minus
    mutating func parseValue() -> ValueDefinition? {
        var sign = nil as ValueDefinition.Sign?
        if parseKeyword(.minus) { sign = .minus }
        else if parseKeyword(.plus) { sign = .plus }
        
        guard let value = parseIdentifier() else {
            if sign != nil { rollback() }
            return nil
        }
        
        return ValueDefinition(sign: sign, value: value)
    }
    
    mutating func parseStateAssertExpression() throws -> StateAssertExpression? {
        guard parseKeyword(.assert) else { return nil }
        guard parseKeyword(.state) else { return nil } // TODO: throw or rollback
        guard parseKeyword(.is) else { return nil }
        guard let value = parseValue() else { return nil }
        
        return StateAssertExpression(value: value)
    }
    
    mutating func parseStateAssignmentExpression() throws -> StateAssignmentExpression? {
        guard parseKeyword(.state) else { return nil }
        guard parseKeyword(.equals) else { return nil }
        guard let value = parseValue() else { return nil }
        
        return StateAssignmentExpression(value: value)
    }
    
    struct ActionValueExpected: Error {}
    
    mutating func parseTestReduceExpression() throws -> ReduceExpression? {
        guard parseKeyword(.reduce) else { return nil }
        let action = parseIdentifierSequence()
        guard !action.isEmpty else { throw ReduceActionIdentifierExpected() }
        
        let value: Substring?
        if parseKeyword(.colon) {
            guard let id = parseIdentifier() else { throw ActionValueExpected() }
            value = id
        } else {
            value = nil
        }
        
        return ReduceExpression(action: action, value: value)
    }
    
    mutating func parseTestExpression() throws -> TestExpression? {
        if let assert = try parseStateAssertExpression() { return .assertState(assert) }
        if let assign = try parseStateAssignmentExpression() { return .assignState(assign) }
        if let reduce = try parseTestReduceExpression() { return .reduceExpression(reduce) }
        
        return nil
    }
}
