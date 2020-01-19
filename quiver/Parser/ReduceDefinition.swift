struct StateReducersDefinition {
    let state: Substring
    let reducers: [SingleReduceDefinition] // Required to be non empty. Phantom type?
}

struct SingleReduceDefinition {
    let action: [Substring]
    let expressions: [ExpressionDefintion]
}

struct ReduceDefinition {
    let state: Substring
    let action: Substring
    let expressions: [ExpressionDefintion]
}
