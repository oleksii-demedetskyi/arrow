public struct TestDefinition: Equatable {
    public let name: [Substring] // Need to be collapsed into single one?
    public let state: Substring
    public let expressions: [TestExpression]
}

public enum TestExpression: Equatable {
    case assertState(StateAssertExpression)
    case assignState(StateAssignmentExpression)
    case reduceExpression(ReduceExpression)
}

public struct StateAssertExpression: Equatable {
    public let value: ValueDefinition
}

public struct ValueDefinition: Equatable {
    public enum Sign { case plus, minus }
    public let sign: Sign?
    public let value: Substring // Can be simple identifier or composite one.
}

public struct StateAssignmentExpression: Equatable {
    public let value: ValueDefinition
}

public struct ReduceExpression: Equatable {
    public let action: [Substring]
    public let value: Substring?
}

extension Parser {
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
}
