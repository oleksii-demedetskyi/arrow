public struct StateDefinition: Equatable {
    public let name: Substring
    public let type: Substring
    public let value: Substring // Need to be more specific type
}

extension Parser {
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
}
