enum TopLevelDefinition: Equatable {
    case action(ActionDefinition)
    case state(StateDefinition)
    case reduce(StateReducersDefinition)
    case test(TestDefinition)
}

extension Parser {
    mutating func parseTopLevelDefinition() throws -> TopLevelDefinition? {
        if let item = try parseActionDefinition() { return .action(item) }
        if let item = try parseStateDefinition() { return .state(item) }
        if let item = try parseStateReducersDefinition() { return .reduce(item) }
        if let item = try parseTestDefinition() { return .test(item) }
        
        return nil
    }
    
    mutating func parseProgram() throws -> [TopLevelDefinition] {
        try parseMany { try $0.parseTopLevelDefinition() }
    }
}
