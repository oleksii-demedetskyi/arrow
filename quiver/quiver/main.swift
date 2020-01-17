import Foundation
import Parser


let filePath = CommandLine.arguments[1]

var file = try String(contentsOfFile: filePath)

file = file.replacingOccurrences(of: ":", with: " : ")
file = file.replacingOccurrences(of: "+", with: " + ")
file = file.replacingOccurrences(of: "-", with: " - ")

let tokensStrings = file.split { $0.isWhitespace }

var tokens = tokensStrings.map(Token.init)

enum Expression {
    case action(Action)
    case state(State)
    case reduce(Reduce)
    
    struct Action {
        let identifier: Substring
    }
    
    struct State {
        let identifier: Substring
        let type: Substring
        let initial: Substring
    }
    
    struct Reduce {
        let stateIdentifier: Substring
        let actionIdentifier: Substring
        let expressions: [Expression]
    }
}

func parseAction(stream: inout [Token]) -> Expression.Action? {
    guard stream[0] == .action else { return nil }
    guard case let .identifier(identifier) = stream[1] else { return nil }
    
    stream.removeFirst(2)
    return Expression.Action(identifier: identifier)
}

func parseState(stream: inout [Token]) -> Expression.State? {
    guard stream[0] == .state else { return nil }
    guard case let .identifier(identifier) = stream[1] else { return nil }
    guard stream[2] == .colon else { return nil }
    guard case let .identifier(type) = stream[3] else { return nil }
    guard stream[4] == .equals else { return nil }
    guard case let .identifier(initial) = stream[5] else { return nil }
    
    stream.removeFirst(6)
    
    return Expression.State(
        identifier: identifier,
        type: type,
        initial: initial
    )
}

func parseReduce(stream: inout [Token]) -> Expression.Reduce? {
    return nil
}

func parseExpression(stream: inout [Token]) -> Expression? {
    if let action = parseAction(stream: &stream) { return .action(action) }
    if let state = parseState(stream: &stream) { return .state(state) }
    if let reduce = parseReduce(stream: &stream) { return .reduce(reduce) }
    
    return nil
}

func parseExpressions(stream: inout [Token]) -> [Expression] {
    var expressions: [Expression] = []
    while (stream.isEmpty == false) {
        guard let expression = parseExpression(stream: &stream) else { break }
        expressions.append(expression)
    }
    return expressions
}

print("Expressions", parseExpressions(stream: &tokens))
print("Remainded tokens", tokens)
