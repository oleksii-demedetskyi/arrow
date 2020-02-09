public enum Token: Equatable, Hashable {
    // Keywords
    case action
    case state
    case reduce
    case with
    case `for`
    case test
    case assert
    case `is`
    
    // Symbols
    case colon
    case equals
    case plus
    case minus
    case openCurlyBrace
    case closedCurlyBrace
    
    // Regular identifiers
    case identifier(Substring)
}

extension Token: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .identifier(Substring(value))
    }
}
