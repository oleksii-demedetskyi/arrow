struct AppState {
    var lines: [String] = []
    var highlightedLine: Int = 0
    var cursorOffset: String.Index = "".startIndex
    var lexems: [Lexeme] = []
    
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

@testable import Parser

struct LexerDidSuccess: Action {
    let lexems: [Lexeme]
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
        print("Receive", action.lexems.count)
        state.lexems = action.lexems
    
    default:
        break
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
        print("Display", store.state.lexems.count)
        return connect(store.state, store.dispatch(action:))
    }
}
