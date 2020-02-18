
// TODO: Embed into action definition
struct ActionIdentifier: Hashable {
    let name: [Substring]
}

extension ActionDefinition {
    var identifier: ActionIdentifier { ActionIdentifier(name: name) }
}

struct StateIdentifier: Hashable {
    let name: [Substring]
}

extension StateDefinition {
    var identifier: StateIdentifier { StateIdentifier(name: [name]) }
}

struct Program {
    var state: [StateIdentifier: StateDefinition] = [:]
    var actions: [ActionIdentifier: ActionDefinition] = [:]
    
    var reducers: [ActionIdentifier: [StateIdentifier: [SingleReduceDefinition]]] = [:]
    
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
    
    mutating func append(topLevelDefinitions: [TopLevelDefinition]) throws {
        // Add states and actions
        for definition in topLevelDefinitions {
            switch definition {
            case let .action(action): try append(action: action)
            case let .state(state): try append(state: state)
            default: break
            }
        }
        
        // Add reducers
        for defintion in topLevelDefinitions {
            switch defintion {
            case let .reduce(reducer): try append(reducer: reducer)
            default: break
            }
        }
    }
    
    // TODO: Append tests. 
}


