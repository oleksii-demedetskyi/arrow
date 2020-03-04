extension ValueDefinition {
    var stateValue: StateValue {
        
        var valueString = ""
        if let sign = sign {
            switch sign {
            case .minus: valueString += "-"
            default: break
            }
        }
        
        valueString += value
        
        return StateValue(
            type: "Int",
            value: valueString
        )
    }
}

enum TestResult: Equatable {
    case ok
    case assertFailed
    case error
}

class TestInterpreter {
    var program: Program
    
    init(program: Program) {
        self.program = program
    }
    
    struct Results: Equatable {
        var tests: [StateIdentifier: [TestIdentifier: TestResult]]
    }
    
    func runAllTests() -> Results {
        var results = Results(tests: [:])
        for (stateIdentifier, testList) in program.tests {
            for (testIdentifer, test)  in testList {
                let result = runTest(state: stateIdentifier, name: testIdentifer, body: test)
                results.tests[stateIdentifier, default: [:]][testIdentifer] = result
            }
        }
        
        return results
    }
    
    func runTest(state: StateIdentifier, name: TestIdentifier, body: TestDefinition) -> TestResult {
        let interpreter = Interpreter(program: program)

        // TODO: Wrap in do catch block
        for expression in body.expressions {
            switch expression {
            case .assertState(let expression):
                let expected = expression.value.stateValue
                let actual = interpreter.state[state]!
                
                guard actual == expected else {
                    return .assertFailed
                }
                
            case .assignState(let expression):
                interpreter.state[state] = expression.value.stateValue
                
            case .reduceExpression(let expression):
                let action = ActionValue(
                    type: ActionIdentifier(name: expression.action),
                    payload: expression.value.map { it in ActionPayload(value: it) }
                )
                
                do {
                    try interpreter.dispatch(action: action)
                } catch {
                    return .error
                }
                
            }
        }
        
        return .ok
    }
}
