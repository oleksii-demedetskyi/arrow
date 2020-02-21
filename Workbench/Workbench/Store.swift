struct AppState {
    var lines: [String] = []
    var highlightedLine: Int = 0
}

protocol Action {}

struct RenderFile: Action {
    let contents: String
}

struct HighlightLine: Action {
    let index: Int
}

func reduce(state: inout AppState, action: Action) {
    switch action {
        
    case let action as RenderFile:
        state.lines = action.contents.components(separatedBy: .newlines)
        
    case let action as HighlightLine:
        state.highlightedLine = action.index
    
    default:
        break
    }
}

import Combine

class Store: ObservableObject {
    @Published var state: AppState = AppState()
    
    func dispatch(action: Action) {
        reduce(state: &state, action: action)
    }
}
