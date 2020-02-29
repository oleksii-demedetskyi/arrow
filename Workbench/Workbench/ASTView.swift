import SwiftUI
import Parser

enum Syntax {
    struct Identifier: View {
        let text: [Substring]
        var body: some View {
            ForEach(text, id:\.self) { part in
                Text(part).foregroundColor(.yellow)
            }
        }
    }
    
    struct TypeIdentifier: View {
        let text: Substring
        var body: some View { Text(text).foregroundColor(.green) }
    }
    
    struct Keyword: View {
        let text: String
        var body: some View { Text(text).foregroundColor(.gray) }
    }
    
    struct Value: View {
        let text: Substring
        var body: some View { Text(text).foregroundColor(.red) }
    }
    
    struct Indent: View {
        let level: Int
        var body: some View {
            HStack {
                ForEach(0..<level, id: \.self) { index in
                    Text("\t")
                }
            }
        }
    }
}

struct ActionDefinitionNode: View {
    let node: ActionDefinition
    
    var body: some View {
        HStack {
            Syntax.Keyword(text: "action")
            Syntax.Identifier(text: node.name)
            if (node.type != nil) {
                Syntax.Keyword(text: ":")
                Syntax.TypeIdentifier(text: node.type!)
            }
        }
    }
}

struct StateDefinitionNode: View {
    let node: StateDefinition
    
    var body: some View {
        HStack {
            Syntax.Keyword(text: "state")
            Syntax.Identifier(text: [node.name])
            Syntax.Keyword(text: ":")
            Syntax.TypeIdentifier(text: node.type)
            Syntax.Keyword(text: "=")
            Syntax.Value(text: node.value)
        }
    }
}

struct ExpressionDefinitionNode: View {
    let node: ExpressionDefintion
    
    var operation: some View {
        switch node.operator {
        case .increment: return Syntax.Keyword(text: "+=")
        case .decrement: return Syntax.Keyword(text: "-=")
        }
    }
    
    var value: some View {
        switch node.value {
        case .action: return Syntax.Value(text: "action")
        case .identifier(let value): return Syntax.Value(text: value)
        }
    }
    
    var body: some View {
        HStack {
            Syntax.Keyword(text: "state")
            operation
            value
        }
    }
}

struct SingleReduceDefinitionNode: View {
    let node: SingleReduceDefinition
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Syntax.Keyword(text: "with")
                Syntax.Identifier(text: node.action)
            }
            HStack {
                Syntax.Indent(level: 1)
                VStack(alignment: .leading) {
                    ForEach(node.expressions.indices) { idx in
                        ExpressionDefinitionNode(node: self.node.expressions[idx]).outlined
                    }
                }
            }
        }
    }
}

struct StateReduceDefinitionNode: View {
    let node: StateReducersDefinition
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Syntax.Keyword(text: "reduce")
                Syntax.Identifier(text: [node.state])
            }
            HStack {
                Syntax.Indent(level: 1)
                VStack(alignment: .leading) {
                    ForEach(node.reducers.indices, id: \.self) { idx in
                        SingleReduceDefinitionNode(node: self.node.reducers[idx]).outlined
                    }
                }
            }
        }
    }
}

struct ValueDefinitionNode: View {
    let node: ValueDefinition
    
    var sign: some View {
        switch node.sign {
        case .minus: return Syntax.Value(text: "-").withoutType
        case .plus: return Syntax.Value(text: "+").withoutType
        default: return EmptyView().withoutType
        }
    }
    
    var body: some View {
        HStack {
            sign
            Syntax.Value(text: node.value)
        }
    }
}

struct TestExpressionNode: View {
    let node: TestExpression
    
    func assert(node: StateAssertExpression) -> some View {
        HStack {
            Syntax.Keyword(text: "assert")
            Syntax.Keyword(text: "state")
            Syntax.Keyword(text: "is")
            ValueDefinitionNode(node: node.value)
        }
    }
    
    func assign(node: StateAssignmentExpression) -> some View {
        HStack {
            Syntax.Keyword(text: "state")
            Syntax.Keyword(text: "=")
            ValueDefinitionNode(node: node.value)
        }
    }
    
    func reduce(node: ReduceExpression) -> some View {
        HStack {
            Syntax.Keyword(text: "reduce")
            Syntax.Identifier(text: node.action)
            if (node.value != nil) {
                Syntax.Keyword(text: ":")
                Syntax.Identifier(text: [node.value!])
            }
        }
    }
    
    var body: some View {
        switch node {
        case .assertState(let node): return assert(node: node).withoutType
        case .assignState(let node): return assign(node: node).withoutType
        case .reduceExpression(let node): return reduce(node: node).withoutType
        }
    }
}

struct TestDefinitionNode: View {
    let node: TestDefinition
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Syntax.Keyword(text: "test")
                Syntax.Identifier(text: node.name)
                Syntax.Keyword(text: "for")
                Syntax.Identifier(text: [node.state])
            }
            HStack {
                Syntax.Indent(level: 1)
                VStack(alignment: .leading) {
                    ForEach(node.expressions.indices, id: \.self) { idx in
                        TestExpressionNode(node: self.node.expressions[idx]).outlined
                    }
                }
            }
        }
    }
}

extension View {
    var withoutType: AnyView {
        AnyView(self)
    }
    
    var outlined: some View {
        self
            .padding([.leading, .trailing], 5)
            .border(Color.white)
    }
}


struct Node: View {
    let node: TopLevelDefinition
    
    var body: some View {
        switch node {
        case .action(let node): return ActionDefinitionNode(node: node).withoutType.outlined
        case .state(let node): return StateDefinitionNode(node: node).withoutType.outlined
        case .reduce(let node): return StateReduceDefinitionNode(node: node).withoutType.outlined
        case .test(let node): return TestDefinitionNode(node: node).withoutType.outlined
        }
    }
}

struct ASTView: View {
    let ast: AST
    
    var body: some View {        
        List {
            ForEach(ast.indices, id: \.self) { index in
                Node(node: self.ast[index])
            }
        }
    }
}
