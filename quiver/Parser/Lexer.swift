public struct Lexer {
    let scanner: Scanner
    
    public init(string: String) {
        self.scanner = Scanner(string: string)
        self.scanner.caseSensitive = true
        self.scanner.charactersToBeSkipped = .whitespacesAndNewlines
    }
    
    public func scan() -> [Lexeme] {
        var result = [] as [Lexeme]
        
        while let lexeme = scanSomething() {
            result.append(lexeme)
        }
            
        precondition(scanner.isAtEnd, "Cannot scan anything at all")
        return result
    }
    
    func scanSomething() -> Lexeme? {
        let scaners = [
            scanKeyword(.action, for: "action"),
            scanKeyword(.state, for: "state"),
            scanKeyword(.reduce, for: "reduce"),
            scanKeyword(.with, for: "with"),
            scanKeyword(.for, for: "for"),
            scanKeyword(.test, for: "test"),
            scanKeyword(.assert, for: "assert"),
            scanKeyword(.is, for: "is"),
            
            scanKeyword(.colon, for: ":", canConnect: false),
            scanKeyword(.equals, for: "=", canConnect: false),
            scanKeyword(.plus, for: "+", canConnect: false),
            scanKeyword(.minus, for: "-", canConnect: false),
            scanKeyword(.openCurlyBrace, for: "{"),
            scanKeyword(.closedCurlyBrace, for: "}", canConnect: false),
            
            scanIdentifier
        ]
        
        for scaner in scaners {
            guard scanner.isAtEnd == false else { break }
            if let lexeme = scaner() { return lexeme }
        }
        
        return nil
    }
    
    func scanKeyword(_ token: Token, for string: String, canConnect: Bool = true) -> () -> Lexeme? {
        return {
            let index = self.scanner.currentIndex
            guard let _ = self.scanner.scanString(string) else { return nil }
            
            if canConnect {
                let currentCharacter =
                CharacterSet(charactersIn:
                    String(self.scanner.string[self.scanner.currentIndex]))
                
                guard currentCharacter.isSubset(of: .whitespacesAndNewlines) else {
                    self.scanner.currentIndex = index
                    return nil
                }
            }
            
            return Lexeme(
                token: token,
                range: index..<self.scanner.currentIndex)
        }
    }
    
    func scanIdentifier() -> Lexeme? {
        let index = scanner.currentIndex
        
        var identifierEnd: CharacterSet = .whitespacesAndNewlines
        identifierEnd.insert(":")
        
        guard let value = scanner.scanUpToCharacters(from: identifierEnd) else {
            return nil
        }
        
        return Lexeme(token: .identifier(Substring(value)),
                      range: index..<scanner.currentIndex)
    }
}
