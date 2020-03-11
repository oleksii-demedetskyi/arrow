struct AppState {
    var lines: [String] = [""]
    var highlightedLine: Int = 0
    var cursorOffset: String.Index = "".startIndex
    
    var lexems: [Lexeme] = []
    
    var parserError: Error?
    
    var ast: AST = []
    var program = Program()
    var interpreter = Interpreter(program: Program())
    var testResults = TestInterpreter.Results()
    
    var currentLine: String {
        get { lines[highlightedLine] }
        set { lines[highlightedLine] = newValue }
    }
}

protocol Action {}

struct RenderFile: Action {
    let contents: String
}

struct HighlightLine: Action {
    let index: Int
}

struct MoveLineUp: Action {}
struct MoveLineDown: Action {}
struct MoveLeft: Action {}
struct MoveRight: Action {}
struct InsertNewLine: Action {}

struct InsertText: Action {
    let text: String
}

import Parser

struct LexerDidSuccess: Action {
    let lexems: [Lexeme]
}

struct ParserDidSuccess: Action {
    let ast: AST
}

struct ParserDidFail: Action {
    let error: Error
}

struct SemanticDidSuccess: Action {
    let program: Program
}

struct SemanticDidFail: Action {
    let error: Error
}

struct TestResultsUpdate: Action {
    let test: TestInterpreter.Results
}

struct DeleteBackward: Action {}

func reduce(state: inout AppState, action: Action) {
    switch action {
        
    case let action as RenderFile:
        state.lines = action.contents.components(separatedBy: .newlines)
        
    case let action as HighlightLine:
        state.highlightedLine = action.index
        
    case is MoveLineUp:
        state.highlightedLine -= 1
        
    case is MoveLineDown:
        state.highlightedLine += 1
        
    case is MoveLeft:
        guard (state.cursorOffset != state.currentLine.startIndex) else { break }
        state.cursorOffset = state.currentLine.index(before: state.cursorOffset)
        
    case is MoveRight:
        guard (state.cursorOffset != state.currentLine.endIndex) else { break }
        state.cursorOffset = state.currentLine.index(after: state.cursorOffset)
        
    case is InsertNewLine:
        let newLine = String(state.currentLine[state.cursorOffset...])
        state.currentLine.removeSubrange(state.cursorOffset...)
        state.highlightedLine += 1
        state.lines.insert(newLine, at: state.highlightedLine)
        state.cursorOffset = newLine.startIndex
        
    case let action as InsertText:
        state.currentLine.insert(contentsOf: action.text, at: state.cursorOffset)
        state.cursorOffset = state.currentLine.index(state.cursorOffset, offsetBy: action.text.count)
        
    case is DeleteBackward:
        if state.cursorOffset == state.currentLine.startIndex {
            if (state.highlightedLine == 0) { break }
            
            let text = state.currentLine
            state.lines.remove(at: state.highlightedLine)
            state.highlightedLine -= 1
            
            state.cursorOffset = state.currentLine.endIndex
            state.currentLine.append(text)
        } else {
            state.cursorOffset = state.currentLine.index(before: state.cursorOffset)
            state.currentLine.remove(at: state.cursorOffset)
        }
        
    case let action as LexerDidSuccess:
        state.lexems = action.lexems
        
    case let action as ParserDidSuccess:
        state.ast = action.ast
        state.parserError = nil
        
    case let action as ParserDidFail:
        state.parserError = action.error
    
    case let action as SemanticDidSuccess:
        state.program = action.program
        state.parserError = nil
        
        state.interpreter = Interpreter(program: action.program)
        
    case let action as TestResultsUpdate:
        state.testResults = action.test
        
    case let action as SemanticDidFail:
        state.parserError = action.error
        
    default: break
    }
    
    if state.lines.isEmpty { state.lines = [""] }
    state.highlightedLine = state.highlightedLine.clamp(to: state.lines.indices)
    
    if state.cursorOffset > state.currentLine.endIndex {
        state.cursorOffset = state.currentLine.endIndex
    }
    
    if state.cursorOffset < state.currentLine.startIndex {
        state.cursorOffset = state.currentLine.endIndex
    }
}

extension Strideable {
    func clamp(to range: Range<Self>) -> Self {
        if self < range.lowerBound { return range.lowerBound }
        if self >= range.upperBound { return range.upperBound.advanced(by: -1) }
        
        return self
    }
}

import Combine

class Store: ObservableObject {
    var state: AppState = AppState()
    
    func dispatch(action: Action) {
        objectWillChange.send()
        reduce(state: &state, action: action)
    }
}

import SwiftUI
struct Root<T: View>: View {
    @ObservedObject var store: Store
    let connect: (AppState, @escaping (Action) -> ()) -> T
    
    var body: T {
        return connect(store.state, store.dispatch(action:))
    }
}
