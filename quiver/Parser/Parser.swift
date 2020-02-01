struct NotImplemented: Error {}
extension TokenStream {
    
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
    
    mutating func parseMany<T>(parser: (_ stream: inout TokenStream) throws -> T?) rethrows -> [T] {
        var values = [] as [T]
        while let item = try parser(&self) {
            values.append(item)
        }
        
        return values
    }
    
    struct ActionIdentifierExpected: Error {}
    struct ActionTypeIdentifierExprected: Error {}
    
    /// Parse whole action definition
    mutating func parseActionDefinition() throws -> ActionDefinition? {
        guard parseKeyword(.action) else { return nil }
        
        let identifiers = parseIdentifierSequence()
        guard !identifiers.isEmpty else { throw ActionIdentifierExpected() }
        
        if parseKeyword(.colon) {
            guard let type = parseIdentifier() else { throw ActionTypeIdentifierExprected()}
            return ActionDefinition(identifier: identifiers, type: type)
        } else {
            return ActionDefinition(identifier: identifiers, type: nil)
        }
    }
    
    mutating func parseIdentifierSequence() -> [Substring] {
        return parseMany { $0.parseIdentifier() }
    }
    
    struct StateNameIdentifierExpected: Error {}
    struct ColonExpected: Error {}
    struct StateTypeIdentifierExpected: Error {}
    struct EqualsExpected: Error {}
    struct StateDefaultValueExpected: Error {}
    
    mutating func parseStateDefinition() throws -> StateDefinition? {
        guard parseKeyword(.state) else { return nil }
        guard let name = parseIdentifier() else { throw StateNameIdentifierExpected() }
        guard parseKeyword(.colon) else { throw ColonExpected() }
        guard let type = parseIdentifier() else { throw StateTypeIdentifierExpected() }
        guard parseKeyword(.equals) else { throw EqualsExpected() }
        guard let value = parseIdentifier() else { throw StateDefaultValueExpected() }
        
        return StateDefinition(name: name, type: type, value: value)
    }
    
    struct ReduceStateIdentifierExpected: Error {}
    struct ReduceWithKeywordExpected: Error {}
    struct ReduceActionIdentifierExpected: Error {}
    struct ReduceExpressionsExpected: Error {}
    
    
    mutating func parseReduceDefinition() throws -> ReduceDefinition? {
        guard parseKeyword(.reduce) else { return nil }
        guard let state = parseIdentifier() else { throw ReduceStateIdentifierExpected() }
        
        guard parseKeyword(.with) else { throw ReduceWithKeywordExpected() }
        guard let action = parseIdentifier() else { throw ReduceActionIdentifierExpected() }
        let expressions = try parseExpressionsBlock()
        
        return ReduceDefinition(
            state: state,
            action: action,
            expressions: expressions)
    }
    
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
    
    struct TestNameExpected: Error {}
    struct TestForKeywordExpected: Error {}
    struct TestStateExpected: Error {}
    
    mutating func parseTestDefinition() throws -> TestDefinition? {
        guard parseKeyword(.test) else { return nil }
        
        let identifiers = parseIdentifierSequence()
        
        guard parseKeyword(.for) else { throw TestForKeywordExpected() }
        guard let state = parseIdentifier() else { throw TestStateExpected() }
        
        guard parseKeyword(.openCurlyBrace) else { throw ExpressionsBlockOpenBraceExpected() }
        
        let expressions = try parseMany { try $0.parseTestExpression() }
        
        guard parseKeyword(.closedCurlyBrace) else { throw ExpressionsBlockCloseBraceExpected() }
        
        return TestDefinition(name: identifiers, state: state, expressions: expressions)
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
    
    mutating func parseSingleReduceDefinition() throws -> SingleReduceDefinition? {
        guard parseKeyword(.with) else { return nil }
        let action = parseIdentifierSequence()
        guard !action.isEmpty else { throw ReduceActionIdentifierExpected() }
        
        let expressions = try parseExpressionsBlock()
        
        
        return SingleReduceDefinition(
            action: action,
            expressions: expressions)
    }
    
    mutating func parseStateReducersDefinition() throws -> StateReducersDefinition? {
        guard parseKeyword(.reduce) else { return nil }
        guard let state = parseIdentifier() else { throw ReduceStateIdentifierExpected() }
        
        let reducers: [SingleReduceDefinition]
        if current == .with {
            guard let reducer = try parseSingleReduceDefinition() else {
                throw ReduceActionIdentifierExpected()
            }
            reducers = [reducer]
        } else {
            guard parseKeyword(.openCurlyBrace) else { throw ExpressionsBlockOpenBraceExpected() }
            
            reducers = try parseMany { try $0.parseSingleReduceDefinition() }
            guard !reducers.isEmpty else { throw ReduceWithKeywordExpected() }
            
            guard parseKeyword(.closedCurlyBrace) else { throw ExpressionsBlockCloseBraceExpected() }
        }

        return StateReducersDefinition(state: state, reducers: reducers)
    }
}
