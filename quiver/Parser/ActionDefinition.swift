/// `action Increment` definition
struct ActionDefinition: Equatable {
    let identifier: [Substring]
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
            return ActionDefinition(identifier: identifiers, type: type)
        } else {
            return ActionDefinition(identifier: identifiers, type: nil)
        }
    }
}
