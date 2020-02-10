struct TestDefinition: Equatable {
    let name: [Substring] // Need to be collapsed into single one?
    let state: Substring
    let expressions: [TestExpression]
}

enum TestExpression: Equatable {
    case assertState(StateAssertExpression)
    case assignState(StateAssignmentExpression)
    case reduceExpression(ReduceExpression)
}

struct StateAssertExpression: Equatable {
    let value: ValueDefinition
}

struct ValueDefinition: Equatable {
    enum Sign { case plus, minus }
    let sign: Sign?
    let value: Substring // Can be simple identifier or composite one.
}

struct StateAssignmentExpression: Equatable {
    let value: ValueDefinition
}

struct ReduceExpression: Equatable {
    let action: [Substring]
    let value: Substring?
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
