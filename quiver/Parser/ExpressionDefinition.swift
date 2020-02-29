public struct ExpressionDefintion: Equatable {
    // let lhs: State ???
    public let `operator`: OperatorDefinition
    public let value: ExpressionRHS
}

public enum OperatorDefinition: Equatable {
    case increment
    case decrement
}

public enum ExpressionRHS: Equatable {
    case identifier(Substring)
    case action
}
