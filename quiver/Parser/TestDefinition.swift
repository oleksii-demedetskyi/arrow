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
