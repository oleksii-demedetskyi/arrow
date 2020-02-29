public struct StateReducersDefinition: Equatable {
    public let state: Substring
    public let reducers: NonEmpty<[SingleReduceDefinition]>
}

public struct SingleReduceDefinition: Equatable {
    public let action: [Substring]
    public let expressions: [ExpressionDefintion]
}

extension Parser {
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

        return StateReducersDefinition(state: state, reducers: try reducers.asNonEmpty())
    }
}
