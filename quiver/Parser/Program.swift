
public struct ActionIdentifier: Hashable {
    public let name: [Substring]
}

extension ActionDefinition {
    var identifier: ActionIdentifier { ActionIdentifier(name: name) }
}

public struct StateIdentifier: Hashable {
    public let name: [Substring]
    
    public var asString: String { name.joined(separator: " ") }
}

extension StateDefinition {
    var identifier: StateIdentifier { StateIdentifier(name: [name]) }
}

public struct TestIdentifier: Hashable {
    public let name: [Substring]
}

extension TestDefinition {
    var identifier: TestIdentifier { TestIdentifier(name: name) }
    var stateIdentifier: StateIdentifier { StateIdentifier(name: [state]) }
}

public struct Program {
    public var state: [StateIdentifier: StateDefinition] = [:]
    public var actions: [ActionIdentifier: ActionDefinition] = [:]
    public var tests: [StateIdentifier: [TestIdentifier: TestDefinition]] = [:]
    
    public init() {}
    
    public var reducers: [ActionIdentifier: [StateIdentifier: [SingleReduceDefinition]]] = [:]
    
    struct StateAlreadyDefined: Error {
        let state: StateDefinition
        let declared: StateDefinition
    }
    
    mutating func append(state: StateDefinition) throws {
        if let declared = self.state[state.identifier] {
            throw StateAlreadyDefined(state: state, declared: declared)
        }
        
        self.state[state.identifier] = state
    }
    
    //? Generic already declared?
    struct ActionAlreadyDefined: Error {
        let action: ActionDefinition
        let declared: ActionDefinition
    }
    
    mutating func append(action: ActionDefinition) throws {
        if let declared = self.actions[action.identifier] {
            throw ActionAlreadyDefined(action: action, declared: declared)
        }
        
        self.actions[action.identifier] = action
    }
    
    struct UnknownStateIdentifier: Error {
        let identifier: StateIdentifier
    }
    
    struct UnknownActionIdentifier: Error {
        let identifier: ActionIdentifier
    }
    
    mutating func append(reducer: StateReducersDefinition) throws {
        let stateId = StateIdentifier(name: [reducer.state])
        
        guard state.keys.contains(stateId) else {
            throw UnknownStateIdentifier(identifier: stateId)
        }
        
        for reducer in reducer.reducers {
            let actionId = ActionIdentifier(name: reducer.action)
            
            guard actions.keys.contains(actionId) else {
                throw UnknownActionIdentifier(identifier: actionId)
            }
            
            reducers[actionId, default: [:]][stateId, default: []].append(reducer)
        }
    }
    
    public mutating func append(topLevelDefinitions: [TopLevelDefinition]) throws {
        // Add states and actions
        for definition in topLevelDefinitions {
            switch definition {
            case let .action(action): try append(action: action)
            case let .state(state): try append(state: state)
            default: break
            }
        }
        
        // Add reducers and tests
        for defintion in topLevelDefinitions {
            switch defintion {
            case let .reduce(reducer): try append(reducer: reducer)
            case let .test(test): try append(testDefinition: test) // TODO: Move to separate pass.
            default: break
            }
        }
    }
    
    struct TestAlreadyDeclared: Error {
        let test: TestDefinition
        let declared: TestDefinition
    }
    
    func hasAction(name: [Substring]) -> Bool {
        actions.keys.contains(ActionIdentifier(name: name))
    }
    
    mutating func append(testDefinition: TestDefinition) throws {
        // Check that state is known
        guard state.keys.contains(testDefinition.stateIdentifier) else {
            throw UnknownStateIdentifier(identifier: testDefinition.stateIdentifier)
        }
        
        var stateTests = tests[testDefinition.stateIdentifier, default: [:]]
        
        // Check for test identifier uniqueness inside state
        if let test = stateTests[testDefinition.identifier] {
            throw TestAlreadyDeclared(test: testDefinition, declared: test)
        }
        
        for expression in testDefinition.expressions {
            switch expression {
            case .reduceExpression(let expression):
                // TODO: Add check that this state reduce this action
                guard hasAction(name: expression.action) else {
                    throw UnknownActionIdentifier(identifier: ActionIdentifier(name: expression.action))
                }
            case .assertState(_):
                // TODO: Check types
                break
            case .assignState(_):
                // TODO: Check types
                break
            }
        }
        
        stateTests[testDefinition.identifier] = testDefinition
        tests[testDefinition.stateIdentifier] = stateTests
    }
}


