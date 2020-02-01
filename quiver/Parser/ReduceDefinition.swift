struct StateReducersDefinition: Equatable {
    let state: Substring
    let reducers: [SingleReduceDefinition] // TODO: Required to be non empty. Phantom type?
}

struct SingleReduceDefinition: Equatable {
    let action: [Substring]
    let expressions: [ExpressionDefintion]
}

struct ReduceDefinition: Equatable {
    let state: Substring
    let action: Substring
    let expressions: [ExpressionDefintion]
}
