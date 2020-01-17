extension TokenStream {
    
    /// Primitive identifier extractor
    mutating func parseIdentifier() -> Substring? {
        guard case let .identifier(value) = current else { return nil }
        consume()
        return value
    }
    
    /// Primitive keyword detector
    mutating func parseActionKeyword() -> Bool {
        guard current == .action else { return false }
        consume()
        return true
    }
    
    struct ActionIdentifierExpected: Error {}
    
    /// Parse whole action definition
    mutating func parseActionDefinition() throws -> ActionDefinition? {
        guard parseActionKeyword() else { return nil }
        guard let id = parseIdentifier() else { throw ActionIdentifierExpected() }
        
        return ActionDefinition(identifier: id)
    }
}
