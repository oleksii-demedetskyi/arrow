import Combine
import Parser

extension Result {
    var value: Success? {
        guard case .success(let value) = self else { return nil }
        return value
    }
    
    var error: Failure? {
        guard case .failure(let error) = self else { return nil }
        return error
    }
}

class Compiler: Subscriber {
    
    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }
    
    var textHash: Int = 0
    
    func receive(_: ()) -> Subscribers.Demand {
            DispatchQueue.main.async {
                let text = self.store.state.lines.joined(separator: "\n")
                guard text.hashValue != self.textHash else { return }
                self.textHash = text.hashValue
                
                // Form lexems
                let lexems = Lexer(string: text).scan()
                self.store.dispatch(action: LexerDidSuccess(lexems: lexems))
                
                // Parse AST
                var parser = Parser(stream: lexems.map { $0.token })
                
                let result = Result {
                    try parser.parseProgram()
                }
                
                guard let ast = result.value else {
                    self.store.dispatch(action: ParserDidFail(error: result.error!))
                    return
                }
                
                self.store.dispatch(action: ParserDidSuccess(ast: ast))
                
                // Normalize program
                var program = Program()
                do {
                    try program.append(topLevelDefinitions: ast)
                    self.store.dispatch(action: SemanticDidSuccess(program: program))
                    
                    // Test program
                    let testInterpreter = TestInterpreter(program: program)
                    let results = testInterpreter.runAllTests()
                    self.store.dispatch(action: TestResultsUpdate(test: results))
                } catch {
                    self.store.dispatch(action: SemanticDidFail(error: error))
                }
            }
        
        return .unlimited
    }
    
    func receive(completion: Subscribers.Completion<Never>) {}
    
    let store: Store
    
    init(store: Store) {
        self.store = store
        store.objectWillChange.subscribe(self)
    }
}
