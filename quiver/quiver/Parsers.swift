import Parser

struct ContParsers {

}

struct MonadicParsers {
    struct Parser<Result> {
        let parse: (ArraySlice<Token>) -> (Result, ArraySlice<Token>)?
    }
    
    func identifier() -> Parser<Substring> {
        Parser { stream in
            guard case let .identifier(value) = stream.first else { return nil }
            return (value, stream.dropFirst())
        }
    }
    
    func token(_ token: Token) -> Parser<Token> {
        Parser { stream in
            guard stream.first == token else { return nil }
            return (token, stream.dropFirst())
        }
    }
}

struct IdealParser {

    var stream: ArraySlice<Token>
    
    mutating func success<Value>(_ value: Value) -> Value {
        stream = stream.dropFirst()
        return value
    }
    
    mutating func fail<Value>() -> Value? {
        // Restore stream
        return nil
    }
    
    mutating func identifier() -> Substring? {
        guard case let .identifier(value) = stream.first else { return fail() }
        return success(value)
    }
    
    mutating func token(_ token: Token) -> Token? {
        guard stream.first == token else { return fail() }
        return success(token)
    }
    
    mutating func action() -> Expression.Action? {
        guard let _ = token(.action) else { return fail() }
        guard let id = identifier() else { return fail() }
        
        // No eating. Tokens was eated by subroutines
        return Expression.Action(identifier: id)
    }
}
