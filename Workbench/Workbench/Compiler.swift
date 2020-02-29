import Combine
import Parser

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
                
                let lexems = Lexer(string: text).scan()
                self.store.dispatch(action: LexerDidSuccess(lexems: lexems))
                
                var parser = Parser(stream: lexems.map { $0.token })
                
                do {
                    let ast = try parser.parseProgram()
                    self.store.dispatch(action: ParserDidSuccess(ast: ast))
                } catch {
                    self.store.dispatch(action: ParserDidFail(error: error))
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
