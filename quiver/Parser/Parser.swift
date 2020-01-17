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
    
    struct ActionIdentifierExpected: Error {}
    
    /// Parse whole action definition
    mutating func parseActionDefinition() throws -> ActionDefinition? {
        guard parseKeyword(.action) else { return nil }
        guard let id = parseIdentifier() else { throw ActionIdentifierExpected() }
        
        return ActionDefinition(identifier: id)
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
        
        var expressions = [] as [ExpressionDefintion]
        while let expresion = parseExpression() {
            expressions.append(expresion)
        }
        
        guard parseKeyword(.closedCurlyBrace) else { throw ExpressionsBlockCloseBraceExpected() }
        
        return expressions
    }
    
    mutating func parseExpression() -> ExpressionDefintion? {
        guard parseKeyword(.state) else { return nil }
        guard parseOneOfKeywords(.plus, .minus) else { return nil }
        guard parseKeyword(.equals) else { return nil }
        guard let _ = parseIdentifier() else { return nil }
        
        return ExpressionDefintion()
    }
    
    struct TestNameExpected: Error {}
    struct TestForKeywordExpected: Error {}
    struct TestStateExpected: Error {}
    
    mutating func parseTestDefinition() throws -> TestDefinition? {
        guard parseKeyword(.test) else { return nil }
        
        var identifiers = [] as [Substring]
        while let identifier = parseIdentifier() {
            identifiers.append(identifier)
        }
        
        guard identifiers.isEmpty == false else { throw TestNameExpected() }
        guard parseKeyword(.for) else { throw TestForKeywordExpected() }
        guard let _ = parseIdentifier() else { throw TestStateExpected() }
        
        throw NotImplemented()
    }
    
    mutating func parseStateAssertExpression() throws -> StateAssertExpression? {
        guard parseKeyword(.assert) else { return nil }
        guard parseKeyword(.state) else { return nil } // TODO: throw or rollback
        guard parseKeyword(.is) else { return nil }
        guard let value = parseIdentifier() else { return nil }
        
        return StateAssertExpression(value: value)
    }
    
    mutating func parseStateAssignmentExpression() throws -> StateAssignmentExpression? {
        guard parseKeyword(.state) else { return nil }
        guard parseKeyword(.equals) else { return nil }
        guard let value = parseIdentifier() else { return nil }
        
        return StateAssignmentExpression(value: value)
    }
    
    mutating func parseTestReduceExpression() throws -> ReduceExpression? {
        guard parseKeyword(.reduce) else { return nil }
        guard let action = parseIdentifier() else { return nil }
        
        return ReduceExpression(action: action)
    }
    
    mutating func parseTestExpression() throws -> TestExpression? {
        if let assert = try parseStateAssertExpression() { return .assertState(assert) }
        if let assign = try parseStateAssignmentExpression() { return .assignState(assign) }
        if let reduce = try parseTestReduceExpression() { return .reduceExpression(reduce) }
        
        return nil
    }
}
