struct ExpressionDefintion: Equatable {
    // let lhs: State ???
    let `operator`: OperatorDefinition
    let value: ExpressionRHS
}

enum OperatorDefinition: Equatable {
    case increment
    case decrement
}

enum ExpressionRHS: Equatable {
    case identifier(Substring)
    case action
}
