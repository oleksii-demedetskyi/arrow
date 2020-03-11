//
//  Document.swift
//  Workbench
//
//  Created by Alexey Demedetskii on 2/9/20.
//  Copyright © 2020 Arrow. All rights reserved.
//

import Cocoa
import SwiftUI
import Combine
import Parser

struct ProgramView: View {
    let program: Program
    let interpretor: Interpreter
    let testResults: TestInterpreter.Results
    
    func stateCurrentValue(id: StateIdentifier) -> String {
        interpretor.state[id]?.value ?? "<nil>"
    }
    
    var states: some View {
        VStack(alignment: .leading) {
            ForEach(Array(program.state), id: \.key) { (key, value) in
                HStack {
                    StateDefinitionNode(node: value)
                    Spacer()
                    Text(self.stateCurrentValue(id: key))
                }
            }
        }
    }
    
    func fire(action: ActionIdentifier) -> () -> () {
        return {
            let value = ActionValue(type: action)
            try? self.interpretor.dispatch(action: value)
        }
    }
    
    var actions: some View {
        VStack(alignment: .leading) {
            ForEach(Array(program.actions), id: \.key) { (key, value) in
                HStack {
                    ActionDefinitionNode(node: value)
                    Spacer()
                    Button(action: self.fire(action: key)) {
                        Text("🚀")
                    }
                }
            }
        }
    }
    
    func testResult(for id: TestIdentifier) -> String {
        for (_, tests) in testResults.tests {
            guard let test = tests[id] else { continue }
            
            switch test {
            case .assertFailed: return "❌"
            case .error: return "⚠️"
            case .ok: return "✅"
            }
        }
        
        return "❓"
    }
    
    var tests: some View {
        VStack(alignment: .leading) {
            ForEach(Array(program.tests), id: \.key) { (key, value) in
                ForEach(Array(value), id: \.key) { key, value in
                    HStack {
                        TestDefinitionNode(node: value)
                        Spacer()
                        Text(self.testResult(for: key))
                    }
                }
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                states
                Divider()
                actions
                Divider()
                tests
            }.padding([.leading, .trailing], 20)
        }
    }
}

struct DocumentView: View {
    let store: Store
    
    
    var body: some View {
        Root(store: store) { state, dispatch in
            VStack(alignment: .leading) {
                Text(state.parserError?.localizedDescription ?? "No error").font(.title).padding([.leading, .trailing, .top], 20)
                HStack {
                    ProgramView(program: state.program,
                                interpretor: state.interpreter,
                                testResults: state.testResults)
                    
                    Editor(lines: state.lines.enumerated().map { line in
                        Line(
                            id: line.offset,
                            text: line.element,
                            select: .bind(HighlightLine(index: line.offset), to: dispatch),
                            cursorOffset: state.cursorOffset,
                            isSelected: state.highlightedLine == line.offset
                        )}
                    )
                    //LexemesList(lexems: state.lexems)
                    ASTView(ast: state.ast)
                }
            }
        }
    }
}

class Document: NSDocument {
    let store = Store()
    let compiler: Compiler
    
    override init() {
        self.compiler = Compiler(store: store)
    }
    
    override func makeWindowControllers() {
        // Create the window and set the content view.
        let window = Window(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.store = store
        window.contentView = NSHostingView(rootView: DocumentView(store: store))
        let windowController = NSWindowController(window: window)
        self.addWindowController(windowController)
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        let text = String(data: data, encoding: .utf8)!
        store.dispatch(action: RenderFile(contents: text))
    }
}

class Window: NSWindow {
    var store: Store!
    
    override func keyDown(with event: NSEvent) {
        interpretKeyEvents([event])
    }
    
    override func moveUp(_ sender: Any?) {
        store.dispatch(action: MoveLineUp())
    }
    
    override func moveDown(_ sender: Any?) {
        store.dispatch(action: MoveLineDown())
    }
    
    override func moveLeft(_ sender: Any?) {
        store.dispatch(action: MoveLeft())
    }
    
    override func moveRight(_ sender: Any?) {
        store.dispatch(action: MoveRight())
    }
    
    override func insertNewline(_ sender: Any?) {
        store.dispatch(action: InsertNewLine())
    }
    
    override func insertText(_ insertString: Any) {
        guard let text = insertString as? String else {
            assertionFailure("WTF Appkit?")
            return
        }
        
        store.dispatch(action: InsertText(text: text))
    }
    
    override func deleteBackward(_ sender: Any?) {
        store.dispatch(action: DeleteBackward())
    }
}
