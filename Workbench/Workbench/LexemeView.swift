import Parser
import SwiftUI

struct LexemeView: View {
    let lexeme: Lexeme
    
    var text: String {
        switch lexeme.token {
        case .action: return "action"
        case .state: return "state"
        case .reduce: return "reduce"
        case .with: return "with"
        case .for: return "for"
        case .test: return "test"
        case .assert: return "assert"
        case .is: return "is"
        case .colon: return ":"
        case .equals: return "="
        case .plus: return "+"
        case .minus: return "-"
        case .openCurlyBrace: return "{"
        case .closedCurlyBrace: return "}"
        case .identifier(let id): return String(id)
        }
    }
    
    var kind: String {
        switch lexeme.token {
        case .identifier:
            return "identifier"
        case .colon, .equals, .plus, .minus, .openCurlyBrace, .closedCurlyBrace:
            return "punctuation"
        default:
            return "keyword"
        }
    }
    
    var body: some View {
        HStack {
            Text(text)
            Spacer()
            Text(kind)
        }
    }
}

struct LexemesList: View {
    let lexems: [Lexeme]
    var body: some View {
        List {
            ForEach(lexems.indices, id: \.self) { idx in
                LexemeView(lexeme: self.lexems[idx])
            }
        }
    }
}
