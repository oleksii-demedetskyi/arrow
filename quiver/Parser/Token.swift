public enum Token: Equatable {
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
    
    public init(value: Substring) {
        switch value {
            
        case "action": self = .action
        case "state": self = .state
        case "reduce": self = .reduce
        case "with": self = .with
        case "for": self = .for
        case "test": self = .test
        case "assert": self = .assert
        case "is": self = .is
            
        case ":": self = .colon
        case "=": self = .equals
        case "+": self = .plus
        case "-": self = .minus
        case "{": self = .openCurlyBrace
        case "}": self = .closedCurlyBrace
        
        default: self = .identifier(value)
        }
    }
}
