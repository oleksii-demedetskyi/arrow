/// `action Increment` definition
struct ActionDefinition: Equatable {
    let name: [Substring]
    let type: Substring?
}

extension Parser {
    struct ActionIdentifierExpected: Error {}
    struct ActionTypeIdentifierExprected: Error {}

    /// Parse whole action definition
    mutating func parseActionDefinition() throws -> ActionDefinition? {
        guard parseKeyword(.action) else { return nil }
        
        let identifiers = parseIdentifierSequence()
        guard !identifiers.isEmpty else { throw ActionIdentifierExpected() }
        
        if parseKeyword(.colon) {
            guard let type = parseIdentifier() else { throw ActionTypeIdentifierExprected()}
            return ActionDefinition(name: identifiers, type: type)
        } else {
            return ActionDefinition(name: identifiers, type: nil)
        }
    }
}
