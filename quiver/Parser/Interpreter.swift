public struct StateValue: Equatable {
    public let type: Substring
    public var value: String
}

public struct ActionValue {
    public let type: ActionIdentifier
    public let payload: ActionPayload?
    
    public init(type: ActionIdentifier,
                payload: ActionPayload? = nil) {
        self.type = type
        self.payload = payload
    }
}

public struct ActionPayload {
    //let type: Substring
    public let value: Substring
    
    public init(value: Substring) {
        self.value = value
    }
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

public class Interpreter {
    let program: Program
    
    public init(program: Program) {
        self.program = program
        
        self.state = [:]
        for (id, definition) in program.state {
            self.state[id] = StateValue(type: definition.type, value: String(definition.value))
        }
    }
    
    public var state: [StateIdentifier: StateValue]
    
    struct UnknownAction: Error {
        let action: ActionValue
    }
    
    struct ActionPayloadMismatch: Error {
        let expectedType: Substring?
        let actualType: Substring?
    }
    
    public func dispatch(action: ActionValue) throws {
        guard program.actions[action.type] != nil else {
            throw UnknownAction(action: action)
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
