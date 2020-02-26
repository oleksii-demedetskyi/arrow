struct StateValue {
    let type: Substring
    var value: String
}

struct ActionValue {
    let type: ActionIdentifier
    let payload: ActionPayload?
}

struct ActionPayload {
    let type: Substring
    let value: Substring
}

struct EvaluationContext {
    var state: StateValue
    let action: ActionValue
    
    mutating func evaluate(expression: ExpressionDefintion) {
        switch expression.operator {
        case .increment: increment(value: expression.value)
        case .decrement: decrement(value: expression.value)
        }
    }
    
    func expressionValue(value: ExpressionRHS) -> Int {
        switch value {
        case .identifier(let value):
            guard let rhsAmount = Int(value) else {
                preconditionFailure("State is not convertible to Int")
            }
            
            return rhsAmount
            
        case .action:
            guard let payload = action.payload else {
                preconditionFailure("Cannot use action without payload")
            }
            
            precondition(payload.type == "Int")
            
            guard let rhsAmount = Int(payload.value) else {
                preconditionFailure("Action payload is not convertible to Int")
            }
            
            return rhsAmount
        }
        
    }
    
    mutating func increment(value: ExpressionRHS) {
        precondition(state.type == "Int")
        guard let stateValue = Int(state.value) else {
            preconditionFailure("State is not convertible to Int")
        }
        
        state.value = String(stateValue + expressionValue(value: value))
    }
    
    mutating func decrement(value: ExpressionRHS) {
        precondition(state.type == "Int")
        guard let stateValue = Int(state.value) else {
            preconditionFailure("State is not convertible to Int")
        }
        
        state.value = String(stateValue - expressionValue(value: value))
    }
}

class Interpreter {
    let program: Program
    
    init(program: Program) {
        self.program = program
        
        self.state = [:]
        for (id, definition) in program.state {
            self.state[id] = StateValue(type: definition.type, value: String(definition.value))
        }
    }
    
    private(set) var state: [StateIdentifier: StateValue]
    
    struct UnknownAction: Error {
        let action: ActionValue
    }
    
    struct ActionPayloadMismatch: Error {
        let expectedType: Substring?
        let actualType: Substring?
    }
    
    func dispatch(action: ActionValue) throws {
        guard let definition = program.actions[action.type] else {
            throw UnknownAction(action: action)
        }
        
        guard definition.type == action.payload?.type else {
            throw ActionPayloadMismatch(
                expectedType: definition.type,
                actualType: action.payload?.type)
        }
        
        guard let reducers = program.reducers[action.type] else {
            return
        }
        
        for (stateId, reducers) in reducers {
            for reducer in reducers {
                reduce(state: &state[stateId]!, action: action, reducer: reducer)
            }
        }
    }
    
    func reduce(state: inout StateValue, action: ActionValue, reducer: SingleReduceDefinition) {
        var context = EvaluationContext(state: state, action: action)
        
        for expression in reducer.expressions {
            context.evaluate(expression: expression)
        }
        
        state = context.state
    }
}
