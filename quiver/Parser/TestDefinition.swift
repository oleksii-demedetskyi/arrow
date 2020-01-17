struct TestDefinition {
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
    let value: Substring
}

struct StateAssignmentExpression: Equatable {
    let value: Substring
}

struct ReduceExpression: Equatable {
    let action: Substring
}
